codeunit 50100 "Graph Node Data Mgt. CS"
{
    procedure UpdateNodeSetFields(NodeSetCode: Code[20]; TableNo: Integer)
    begin
        RemoveNonEligibleFielfdFromNodeData(NodeSetCode, TableNo);
        AddTableFieldsToNodeSet(NodeSetCode, TableNo);
    end;

    procedure CanRemoveFieldFromNodeData(NodeSetCode: Code[20]; FieldNo: Integer): Boolean
    var
        NodeSet: Record "Node Set CS";
        CanRemove: Boolean;
    begin
        NodeSet.Get(NodeSetCode);
        CanRemove := not IsPrimaryKeyField(NodeSet."Table No.", FieldNo);

        exit(CanRemove);
    end;

    local procedure RemoveNonEligibleFielfdFromNodeData(NodeSetCode: Code[20]; TableNo: Integer)
    var
        NodeSetField: Record "Node Set Field CS";
        Field: Record Field;
    begin
        NodeSetField.SetRange("Node Set Code", NodeSetCode);
        if NodeSetField.FindSet() then begin
            repeat
                if not Field.Get(TableNo, NodeSetField."Field No.") then
                    NodeSetField.Mark(true)
                else
                    if not FieldCanBeNodeData(TableNo, NodeSetField."Field No.") then
                        NodeSetField.Mark(true);
            until NodeSetField.Next() = 0;

            NodeSetField.MarkedOnly(true);
            NodeSetField.DeleteAll();
        end;
    end;

    local procedure AddTableFieldsToNodeSet(NodeSetCode: Code[20]; TableNo: Integer)
    var
        NodeSetField: Record "Node Set Field CS";
        Field: Record Field;
    begin
        FilterTableFieldsForNodeData(Field, TableNo);
        if Field.FindSet() then
            repeat
                NodeSetField.SetRange("Node Set Code", NodeSetCode);
                NodeSetField.SetRange("Field No.", Field."No.");
                if NodeSetField.IsEmpty() then begin
                    NodeSetField.Init();
                    NodeSetField."Node Set Code" := NodeSetCode;
                    NodeSetField.Validate("Table No.", TableNo);
                    NodeSetField.Validate("Field No.", Field."No.");
                    NodeSetField.Validate("Include in Node Data", FieldIsInDefaultSet(Field.TableNo, Field."No."));
                    NodeSetField.Insert(true);
                end;
            until Field.Next() = 0;
    end;

    procedure FilterTableFieldsForNodeData(var Field: Record Field; TableNo: Integer)
    begin
        Field.SetRange(TableNo, TableNo);
        Field.SetFilter(
            Type, '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7',
            Field.Type::TableFilter, Field.Type::RecordID, Field.Type::DateFormula, Field.Type::Media, Field.Type::MediaSet, Field.Type::Binary, Field.Type::BLOB);
        Field.SetFilter(Class, '<>%1', Field.Class::FlowFilter);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
    end;

    local procedure FieldCanBeNodeData(TableNo: Integer; FieldNo: Integer): Boolean
    var
        Field: Record Field;
        CanBeNodeData: Boolean;
    begin
        FilterTableFieldsForNodeData(Field, TableNo);
        Field.SetRange("No.", FieldNo);
        CanBeNodeData := not Field.IsEmpty();

        OnFieldCanBeNodeData(TableNo, FieldNo, CanBeNodeData);
        exit(CanBeNodeData);
    end;

    local procedure FieldIsInDefaultSet(TableNo: Integer; FieldNo: Integer): Boolean
    var
        IsFieldInDefaultSet: Boolean;
    begin
        IsFieldInDefaultSet := IsPrimaryKeyField(TableNo, FieldNo);

        OnFieldIsInDefaultSet(TableNo, FieldNo, IsFieldInDefaultSet);
        exit(IsFieldInDefaultSet);
    end;

    procedure IsFieldRequiredInTooltips(NodeSetCode: Code[20]; FieldNo: Integer): Boolean
    var
        NodeTooltipField: Record "Node Tooltip Field CS";
    begin
        NodeTooltipField.SetRange("Node Set Code", NodeSetCode);
        NodeTooltipField.SetRange("Field No.", FieldNo);
        exit(not NodeTooltipField.IsEmpty());
    end;

    procedure IsFieldRequiredInSelectorFilters(NodeSetCode: Code[20]; FieldNo: Integer): Boolean
    var
        StyleSet: Record "Style Set CS";
        Style: Record "Style CS";
        Selector: Record "Selector CS";
        SelectorFilter: Record "Selector Filter CS";
    begin
        StyleSet.SetRange("Node Set Code", NodeSetCode);
        if StyleSet.FindSet() then
            repeat
                Style.Get(StyleSet."Style Code");
                if Selector.Get(Style."Selector Code") then begin
                    SelectorFilter.SetRange("Selector Code", Selector.Code);
                    SelectorFilter.SetRange("Field No.", FieldNo);
                    if not SelectorFilter.IsEmpty() then
                        exit(true);
                end;
            until StyleSet.Next() = 0;

        exit(false);
    end;

    procedure IsPrimaryKeyField(TableNo: Integer; FieldNo: Integer): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        PrimaryKeyRef: KeyRef;
        I: Integer;
    begin
        RecRef.Open(TableNo);
        PrimaryKeyRef := RecRef.KeyIndex(1);
        for I := 1 to PrimaryKeyRef.FieldCount do begin
            FieldRef := PrimaryKeyRef.FieldIndex(I);
            if FieldRef.Number = FieldNo then
                exit(true);
        end;

        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFieldCanBeNodeData(TableNo: Integer; FieldNo: Integer; var CanBeNodeData: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFieldIsInDefaultSet(TableNo: Integer; FieldNo: Integer; var IncludeInDefaultSet: Boolean)
    begin
    end;
}
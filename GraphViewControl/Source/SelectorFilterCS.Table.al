table 50104 "Selector Filter CS"
{
    DataClassification = CustomerContent;
    Caption = 'Selector Filter';
    LookupPageId = "Selector Filters CS";

    fields
    {
        field(1; "Selector Code"; Code[20])
        {
            Caption = 'Selector Code';
            TableRelation = "Selector CS".Code;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                Selector: Record "Selector CS";
                Field: Record Field;
                GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
                FieldCannotBeFilterErr: Label 'Field %1 cannot be used for filtering.', Comment = '%1: Field No.';
            begin
                TestField("Selector Code");
                Selector.Get("Selector Code");
                Selector.TestField("Table No.");
                GraphNodeDataMgt.FilterTableFieldsForNodeData(Field, Selector."Table No.");
                Field.SetRange("No.", "Field No.");
                if Field.IsEmpty() then
                    Error(FieldCannotBeFilterErr, "Field No.");
            end;

            trigger OnLookup()
            var
                Selector: Record "Selector CS";
                Field: Record Field;
                FieldsLookup: Page "Fields Lookup";
            begin
                TestField("Selector Code");
                Selector.Get("Selector Code");
                Selector.TestField("Table No.");

                Field.FilterGroup(2);
                Field.SetRange(TableNo, Selector."Table No.");
                Field.FilterGroup(0);
                FieldsLookup.LookupMode(true);
                FieldsLookup.SetTableView(Field);

                if FieldsLookup.RunModal() = Action::LookupOK then begin
                    FieldsLookup.GetRecord(Field);
                    "Field No." := Field."No.";
                end;
            end;
        }
        field(3; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = filter(Database::"Item Ledger Entry"), "No." = field("Field No.")));
        }
        field(4; "Field Filter"; Text[250])
        {
            Caption = 'Field Filter';
        }
    }

    keys
    {
        key(PK; "Selector Code", "Field No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        Style: Record "Style CS";
        StyleSet: Record "Style Set CS";
    begin
        if "Field No." = 0 then
            exit;

        Style.SetRange("Selector Code", Rec."Selector Code");
        if Style.FindSet() then
            repeat
                StyleSet.SetRange("Style Code", Style.Code);
                if StyleSet.FindSet() then
                    repeat
                        GraphNodeDataMgt.UpdateNodeSetFieldInData(StyleSet."Node Set Code", "Field No.", true);
                    until StyleSet.Next() = 0;
            until Style.Next() = 0;
    end;

    trigger OnRename()
    var
        Style: Record "Style CS";
        StyleSet: Record "Style Set CS";
    begin
        Style.SetRange("Selector Code", Rec."Selector Code");
        if Style.FindSet() then
            repeat
                StyleSet.SetRange("Style Code", Style.Code);
                if StyleSet.FindSet() then
                    repeat
                        GraphNodeDataMgt.UpdateNodeSetFieldInData(StyleSet."Node Set Code", Rec."Field No.", true);
                        RemoveFieldFromNodeDataIfNotRequired(StyleSet."Node Set Code", xRec."Field No.", "Selector Code");
                    until StyleSet.Next() = 0;
            until Style.Next() = 0;
    end;

    trigger OnDelete()
    var
        Style: Record "Style CS";
        StyleSet: Record "Style Set CS";
    begin
        if "Field No." = 0 then
            exit;

        Style.SetRange("Selector Code", Rec."Selector Code");
        if Style.FindSet() then
            repeat
                StyleSet.SetRange("Style Code", Style.Code);
                if StyleSet.FindSet() then
                    repeat
                        RemoveFieldFromNodeDataIfNotRequired(StyleSet."Node Set Code", "Field No.", "Selector Code");
                    until StyleSet.Next() = 0;
            until Style.Next() = 0;

    end;

    local procedure RemoveFieldFromNodeDataIfNotRequired(NodeSetCode: Code[20]; FieldNo: Integer; SelectorCodeToExclude: Code[20])
    begin
        if GraphNodeDataMgt.CanRemoveFieldFromNodeData(NodeSetCode, FieldNo) then
            if not GraphNodeDataMgt.IsFieldRequiredInNodeText(NodeSetCode, FieldNo, Enum::"Node Text Type CS"::None) then
                if not GraphNodeDataMgt.IsFieldRequiredInSelectorFilters(NodeSetCode, FieldNo, SelectorCodeToExclude) then
                    GraphNodeDataMgt.UpdateNodeSetFieldInData(NodeSetCode, FieldNo, false);

    end;

    var
        GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
}

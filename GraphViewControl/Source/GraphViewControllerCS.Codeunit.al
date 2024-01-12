codeunit 50101 "Graph View Controller CS"
{
    procedure ConvertFieldNameToJsonToken(NodeSetField: Record "Node Set Field CS") ConvertedName: Text[80]
    begin
        if (NodeSetField."Table No." <> 0) and (NodeSetField."Field No." <> 0) then
            exit(ConvertFieldNameToJsonToken(NodeSetField."Table No.", NodeSetField."Field No."));

        exit('');
    end;

    procedure ConvertFieldNameToJsonToken(TableNo: Integer; FieldNo: Integer): Text[80]
    var
        Field: Record Field;
    begin
        Field.SetLoadFields(FieldName);
        if not Field.Get(TableNo, FieldNo) then
            exit('');

        if IsIdField(TableNo, FieldNo) then
            exit('id');

        exit(ConvertFieldNameToJsonToken(Field.FieldName));
    end;

    procedure ConvertFieldNameToJsonToken(FieldName: Text[80]) ConvertedName: Text[80]
    var
        I: Integer;
    begin
        for I := 1 to StrLen(FieldName) do
            ConvertedName := CopyStr(ConvertedName + ReplaceSymbolIfNotAllowedInPropertyName(FieldName[I]), 1, MaxStrLen(ConvertedName));
    end;

    local procedure ReplaceSymbolIfNotAllowedInPropertyName(Symbol: Char): Text[1]
    begin
        if ((Symbol >= 'a') and (Symbol <= 'z')) or (Symbol >= 'A') and (Symbol <= 'Z') or ((Symbol >= '0') and (Symbol <= '9')) or (Symbol = '-') then
            exit(Symbol);

        exit('_');
    end;

    procedure GraphLayoutEnumToText(GraphLayout: Enum "Graph Layout Name CS"): Text
    begin
        case GraphLayout of
            GraphLayout::Grid:
                exit('grid');
            GraphLayout::Circle:
                exit('circle');
            GraphLayout::Concentric:
                exit('concentric');
            GraphLayout::Breadthfirst:
                exit('breadthfirst');
        end;
    end;

    procedure AddFieldValueConvertedToFieldType(var Node: JsonToken; PropertyName: Text; ValueFieldRef: FieldRef)
    begin
        if ValueFieldRef.Type in [ValueFieldRef.Type::Integer, ValueFieldRef.Type::BigInteger, ValueFieldRef.Type::Decimal] then
            AddFieldValueAsNumeric(Node, PropertyName, ValueFieldRef.Value)
        else
            if ValueFieldRef.Type = ValueFieldRef.Type::Boolean then
                AddFieldValueAsBoolean(Node, PropertyName, ValueFieldRef.Value)
            else
                Node.AsObject().Add(PropertyName, Format(ValueFieldRef.Value));
    end;

    local procedure AddFieldValueAsNumeric(var Node: JsonToken; PropertyName: Text; Value: Variant)
    var
        FieldValue: Decimal;
    begin
        FieldValue := Value;
        Node.AsObject().Add(PropertyName, FieldValue);
    end;

    local procedure AddFieldValueAsBoolean(var Node: JsonToken; PropertyName: Text; Value: Variant)
    var
        FieldValue: Boolean;
    begin
        FieldValue := Value;
        Node.AsObject().Add(PropertyName, FieldValue);
    end;

    procedure FormatNodeText(RecRef: RecordRef; NodeSetCode: Code[20]; TextType: Enum "Node Text Type CS"): Text
    var
        NodeTextField: Record "Node Text Field CS";
        TableFieldRef: FieldRef;
        Builder: TextBuilder;
    begin
        NodeTextField.SetRange("Node Set Code", NodeSetCode);
        NodeTextField.SetRange(Type, TextType);
        if NodeTextField.FindSet() then
            repeat
                TableFieldRef := RecRef.Field(NodeTextField."Field No.");
                if TableFieldRef.Class = FieldClass::FlowField then
                    TableFieldRef.CalcField();

                if NodeTextField."Show Caption" then begin
                    NodeTextField.CalcFields("Field Caption");
                    Builder.Append(NodeTextField."Field Caption" + ': ');
                end;

                Builder.Append(Format(TableFieldRef.Value));
                if NodeTextField.Delimiter = NodeTextField.Delimiter::Space then
                    Builder.Append(' ')
                else
                    if NodeTextField.Delimiter = NodeTextField.Delimiter::"New Line" then
                        AppendLineBreak(Builder, TextType);
            until NodeTextField.Next() = 0;

        exit(Builder.ToText());
    end;

    local procedure AppendLineBreak(var Builder: TextBuilder; TextType: Enum "Node Text Type CS")
    var
        LF: Char;
    begin
        LF := 10;

        case TextType of
            TextType::Tooltip:
                Builder.Append('<br>');
            TextType::Label:
                Builder.Append(LF);
        end;
    end;

    local procedure GetNodeIdAsJsonToken(Node: JsonObject) NodeId: JsonToken
    begin
        Node.Get('id', NodeId);
    end;

    procedure GetNodeIdAsInteger(Node: JsonObject): Integer
    begin
        exit(GetNodeIdAsJsonToken(Node).AsValue().AsInteger());
    end;

    procedure GetNodeIdAsText(Node: JsonObject): Text
    begin
        exit(GetNodeIdAsJsonToken(Node).AsValue().AsText());
    end;

    procedure IsIdField(TableNo: Integer; FieldNo: Integer): Boolean
    var
        GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
        IsHandled: Boolean;
        IsId: Boolean;
    begin
        OnBeforeIsIdField(TableNo, FieldNo, IsHandled, IsId);
        if IsHandled then
            exit(IsId);

        exit(GraphNodeDataMgt.IsPrimaryKeyField(TableNo, FieldNo));
    end;

    procedure GetNodeTooltip(RecRef: RecordRef; NodeId: Text; NodeSetCode: Code[20]) Tooltip: JsonObject
    begin
        Tooltip.Add('nodeId', NodeId);
        Tooltip.Add('content', FormatNodeText(RecRef, NodeSetCode, Enum::"Node Text Type CS"::Tooltip));
    end;

    local procedure AppendNodeLabelStyleSelector(var Styles: JsonArray)
    var
        LabelSelector: JsonObject;
        LabelStyle: JsonObject;
    begin
        LabelStyle.Add('label', 'data(label)');
        LabelStyle.Add('text-wrap', 'wrap');
        LabelSelector.Add('selector', 'node[label]');
        LabelSelector.Add('style', LabelStyle);
        Styles.Add(LabelSelector);
    end;

    procedure FormatSelectorText(SelectorCode: Code[20]): Text
    var
        SelectorFilter: Record "Selector Filter CS";
        Selector: Record "Selector CS";
        Filters: Text;
    begin
        Filters := 'node';
        Selector.Get(SelectorCode);
        SelectorFilter.SetRange("Selector Code", SelectorCode);
        if SelectorFilter.FindSet() then
            repeat
                Filters := Filters + '[' + ConvertFieldNameToJsonToken(Selector."Table No.", SelectorFilter."Field No.") + SelectorFilter."Field Filter" + ']';
            until SelectorFilter.Next() = 0;

        exit(Filters);
    end;

    procedure GetStylesAsJson(NodeSetCode: Code[20]): JsonArray
    var
        StyleSet: Record "Style Set CS";
        Style: Record "Style CS";
        StyleDef: JsonObject;
        StyleSheet: JsonObject;
        StylesArr: JsonArray;
        CouldNotReadStyleErr: Label 'Could not read style description %1. Make sure that the style is correctly defined.', Comment = '%1: Style code';
    begin
        if NodeSetCode = '' then
            exit(StylesArr);  // Returning an empty array if the style set is undefined        

        StyleSet.SetRange("Node Set Code", NodeSetCode);
        if StyleSet.FindSet() then
            repeat
                Style.Get(StyleSet."Style Code");
                if not StyleSheet.ReadFrom(Style.ReadStyleSheetText()) then
                    Error(CouldNotReadStyleErr, Style.Code);

                Clear(StyleDef);
                StyleDef.Add('selector', Style."Selector Text");
                StyleDef.Add('css', StyleSheet);
                StylesArr.Add(StyleDef);
            until StyleSet.Next() = 0;

        if NodeLabesDefined(NodeSetCode) then
            AppendNodeLabelStyleSelector(StylesArr);

        exit(StylesArr);
    end;

    local procedure NodeLabesDefined(NodeSetCode: Code[20]): Boolean
    var
        NodeTextField: Record "Node Text Field CS";
    begin
        NodeTextField.SetRange("Node Set Code", NodeSetCode);
        NodeTextField.SetRange(Type, NodeTextField.Type::Label);
        exit(not NodeTextField.IsEmpty());
    end;

    procedure SetNodeProperties(var Node: JsonToken; SourceRecRef: RecordRef; NodeSetCode: Code[20])
    var
        NodeSetField: Record "Node Set Field CS";
        SourceFieldRef: FieldRef;
    begin
        NodeSetField.SetRange("Node Set Code", NodeSetCode);
        NodeSetField.SetRange("Include in Node Data", true);

        if NodeSetField.FindSet() then
            repeat
                SourceFieldRef := SourceRecRef.Field(NodeSetField."Field No.");
                if SourceFieldRef.Class = FieldClass::FlowField then
                    SourceFieldRef.CalcField();

                if not IsIdField(NodeSetField."Table No.", NodeSetField."Field No.") then  // Entry No. is always enabled by default as the node ID
                    AddFieldValueConvertedToFieldType(Node, NodeSetField."Json Property Name", SourceFieldRef);
            until NodeSetField.Next() = 0;

        Node.AsObject().Add('label', FormatNodeText(SourceRecRef, NodeSetCode, Enum::"Node Text Type CS"::Label));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsIdField(TableNo: Integer; FieldNo: Integer; var IsHandled: Boolean; var IsId: Boolean)
    begin
    end;
}

codeunit 50101 "Graph View Controller CS"
{
    procedure ConverFieldNameToJsonToken(NodeSetField: Record "Node Set Field CS") ConvertedName: Text[80]
    var
        I: Integer;
    begin
        if IsMandatoryField(NodeSetField) then
            exit('id');

        NodeSetField.CalcFields("Field Name");

        for I := 1 to StrLen(NodeSetField."Field Name") do
            ConvertedName := CopyStr(ConvertedName + ReplaceSymbolIfNotAllowedInPropertyName(NodeSetField."Field Name"[I]), 1, MaxStrLen(ConvertedName));
    end;

    local procedure ReplaceSymbolIfNotAllowedInPropertyName(Symbol: Char): Text[1]
    begin
        if ((Symbol >= 'a') and (Symbol <= 'z')) or (Symbol >= 'A') and (Symbol <= 'Z') or ((Symbol >= '0') and (Symbol <= '9')) then
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

    procedure FormatNodeTooltipText(RecRef: RecordRef; NodeSetCode: Code[20]): Text
    var
        NodeTooltipField: Record "Node Tooltip Field CS";
        TableFieldRef: FieldRef;
        TooltipText: Text;
        NewLineTok: Label '<br>';
    begin
        NodeTooltipField.SetRange("Node Set Code", NodeSetCode);
        if NodeTooltipField.FindSet() then
            repeat
                TableFieldRef := RecRef.Field(NodeTooltipField."Field No.");
                if TableFieldRef.Class = FieldClass::FlowField then
                    TableFieldRef.CalcField();

                if NodeTooltipField."Show Caption" then begin
                    NodeTooltipField.CalcFields("Field Caption");
                    TooltipText := TooltipText + NodeTooltipField."Field Caption" + ': ';
                end;

                TooltipText := TooltipText + Format(TableFieldRef.Value);
                if NodeTooltipField.Delimiter = NodeTooltipField.Delimiter::Space then
                    TooltipText := TooltipText + ' '
                else
                    if NodeTooltipField.Delimiter = NodeTooltipField.Delimiter::"New Line" then
                        TooltipText := TooltipText + NewLineTok;
            until NodeTooltipField.Next() = 0;

        exit(TooltipText);
    end;

    procedure GetNodeIdAsInteger(Node: JsonObject): Integer
    var
        NodeId: JsonToken;
    begin
        Node.Get('id', NodeId);
        exit(NodeId.AsValue().AsInteger());
    end;

    procedure GetNodeIdAsText(Node: JsonObject): Text
    var
        NodeId: JsonToken;
    begin
        Node.Get('id', NodeId);
        exit(NodeId.AsValue().AsText());
    end;

    procedure IsMandatoryField(NodeSetField: Record "Node Set Field CS"): Boolean
    var
        GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
        IsHandled: Boolean;
        IsMandatory: Boolean;
    begin
        OnBeforeIsMandatoryField(NodeSetField, IsHandled, IsMandatory);
        if IsHandled then
            exit(IsMandatory);

        exit(GraphNodeDataMgt.IsPrimaryKeyField(NodeSetField."Table No.", NodeSetField."Field No."));
    end;

    procedure GetNodeTooltip(RecRef: RecordRef; NodeId: Text; NodeSetCode: Code[20]): JsonObject
    var
        Tooltip: JsonObject;
    begin
        Tooltip.Add('nodeId', NodeId);
        Tooltip.Add('content', FormatNodeTooltipText(RecRef, NodeSetCode));
        exit(Tooltip);
    end;

    procedure FormatSelectorText(SelectorCode: Code[20]): Text
    var
        SelectorFilter: Record "Selector Filter CS";
        NodeSetField: Record "Node Set Field CS";
        Selector: Record "Selector CS";
        Filters: Text;
    begin
        Filters := 'node';
        Selector.Get(SelectorCode);
        SelectorFilter.SetRange("Selector Code", SelectorCode);
        if SelectorFilter.FindSet() then
            repeat
                NodeSetField.Get(Selector."Table No.", SelectorFilter."Field No.");
                Filters := Filters + '[' + NodeSetField."Json Property Name" + SelectorFilter."Field Filter" + ']';
            until SelectorFilter.Next() = 0;

        exit(Filters);
    end;

    procedure GetStylesAsJson(StyleSetCode: Code[20]): JsonArray
    var
        Style: Record "Style CS";
        StyleDef: JsonObject;
        StyleSheet: JsonObject;
        StylesArr: JsonArray;
        CouldNotReadStyleErr: Label 'Could not read style description %1. Make sure that the style is correctly defined.', Comment = '%1: Style code';
    begin
        if StyleSetCode = '' then
            exit(StylesArr);  // Returning an empty array if the style set code is blank

        Style.SetRange("Style Set", StyleSetCode);
        if Style.FindSet() then
            repeat
                if not StyleSheet.ReadFrom(Style.ReadStyleSheetText()) then
                    Error(CouldNotReadStyleErr, Style.Code);

                Clear(StyleDef);
                StyleDef.Add('selector', Style."Selector Text");
                StyleDef.Add('css', StyleSheet);
                StylesArr.Add(StyleDef);
            until Style.Next() = 0;

        exit(StylesArr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsMandatoryField(NodeSetField: Record "Node Set Field CS"; var IsHandled: Boolean; var IsMandatory: Boolean)
    begin
    end;
}

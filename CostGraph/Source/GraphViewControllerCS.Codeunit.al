codeunit 50101 "Graph View Controller CS"
{
    procedure SetNodesData(var Nodes: JsonArray)
    var
        Node: JsonToken;
    begin
        foreach Node in Nodes do
            SetItemLedgEntryNodeProperties(Node);
    end;

    procedure ConverFieldNameToJsonToken(GraphNodeData: Record "Graph Node Data CS") ConvertedName: Text[80]
    var
        I: Integer;
    begin
        if IsEntryNoField(GraphNodeData) then
            exit('id');

        GraphNodeData.CalcFields("Field Name");

        for I := 1 to StrLen(GraphNodeData."Field Name") do
            ConvertedName := ConvertedName + ReplaceSymbolIfNotAllowedInPropertyName(GraphNodeData."Field Name"[I]);
    end;

    local procedure ReplaceSymbolIfNotAllowedInPropertyName(Symbol: Text[1]): Text[1]
    begin
        if ((Symbol >= 'a') and (Symbol <= 'z')) or ((Symbol >= '0') and (Symbol <= '9')) then
            exit(Symbol);

        if (Symbol >= 'A') and (Symbol <= 'Z') then
            exit(LowerCase(Symbol));

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

    local procedure SetItemLedgEntryNodeProperties(var Node: JsonToken)
    var
        GraphNodeData: Record "Graph Node Data CS";
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecRef: RecordRef;
        TableFieldRef: FieldRef;
    begin
        GraphNodeData.SetRange("Table No.", Database::"Item Ledger Entry");
        GraphNodeData.SetRange("Include in Node Data", true);

        ItemLedgerEntry.Get(GetNodeId(Node.AsObject()));
        RecRef.GetTable(ItemLedgerEntry);

        // Not checking the return value here, since at least the Entry No. must be included
        GraphNodeData.FindSet();
        repeat
            TableFieldRef := RecRef.Field(GraphNodeData."Field No.");
            if TableFieldRef.Class = FieldClass::FlowField then
                TableFieldRef.CalcField();

            if not IsEntryNoField(GraphNodeData) then  // Entry No. is always enabled by default as the node ID
                AddFieldValueConvertedToFieldType(Node, GraphNodeData."Json Property Name", TableFieldRef);
        until GraphNodeData.Next() = 0;
    end;

    local procedure AddFieldValueConvertedToFieldType(var Node: JsonToken; PropertyName: Text; ValueFieldRef: FieldRef)
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

    local procedure FormatNodeTooltipText(NodeId: Integer): Text
    var
        NodeTooltipField: Record "Node Tooltip Field CS";
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecRef: RecordRef;
        TableFieldRef: FieldRef;
        TooltipText: Text;
        NewLineTok: Label '<br>';
    begin
        ItemLedgerEntry.Get(NodeId);
        RecRef.GetTable(ItemLedgerEntry);

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

    local procedure GetNodeId(Node: JsonObject): Integer
    var
        NodeId: JsonToken;
    begin
        Node.Get('id', NodeId);
        exit(NodeId.AsValue().AsInteger());
    end;

    procedure IsEntryNoField(GraphNodeData: Record "Graph Node Data CS"): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        exit((GraphNodeData."Table No." = Database::"Item Ledger Entry") and (GraphNodeData."Field No." = ItemLedgerEntry.FieldNo("Entry No.")));
    end;

    procedure NodeId2ItemLedgEntryNo(NodeId: Text) ItemLedgerEntryNo: Integer
    begin
        Evaluate(ItemLedgerEntryNo, NodeId);
    end;

    procedure GetNodeTooltipsArray(Nodes: JsonArray): JsonArray
    var
        TooltipsArray: JsonArray;
        Node: JsonToken;
    begin
        foreach Node in Nodes do
            TooltipsArray.Add(GetNodeTooltip(GetNodeId(Node.AsObject())));

        exit(TooltipsArray);
    end;

    local procedure GetNodeTooltip(ItemLedgEntryNo: Integer): JsonObject
    var
        Tooltip: JsonObject;
    begin
        Tooltip.Add('nodeId', ItemLedgEntryNo);
        Tooltip.Add('content', FormatNodeTooltipText(ItemLedgEntryNo));
        exit(Tooltip);
    end;

    procedure FormatSelectorText(SelectorCode: Code[20]): Text
    var
        SelectorFilter: Record "Selector Filter CS";
        GraphNodeData: Record "Graph Node Data CS";
        Filters: Text;
    begin
        Filters := 'node';
        SelectorFilter.SetRange("Selector Code", SelectorCode);
        if SelectorFilter.FindSet() then
            repeat
                GraphNodeData.Get(Database::"Item Ledger Entry", SelectorFilter."Field No.");
                Filters := Filters + '[' + GraphNodeData."Json Property Name" + SelectorFilter."Field Filter" + ']';
            until SelectorFilter.Next() = 0;

        exit(Filters);
    end;

    procedure GetStylesAsJson(): JsonArray
    var
        Style: Record "Style CS";
        StyleDef: JsonObject;
        StyleSheet: JsonObject;
        StylesArr: JsonArray;
        CouldNotReadStyleErr: Label 'Could not read style description %1. Make sure that the style is correctly defined.', Comment = '%1: Style code';
    begin
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
}

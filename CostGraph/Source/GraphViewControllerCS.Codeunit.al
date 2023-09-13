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
        FieldValue: Decimal;
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
                if TableFieldRef.Type in [TableFieldRef.Type::Integer, TableFieldRef.Type::BigInteger, TableFieldRef.Type::Decimal] then begin
                    FieldValue := TableFieldRef.Value;
                    Node.AsObject().Add(GraphNodeData."Json Property Name", FieldValue);
                end
                else
                    Node.AsObject().Add(GraphNodeData."Json Property Name", Format(TableFieldRef.Value));
        until GraphNodeData.Next() = 0;
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
}

codeunit 50101 "Graph View Controller CS"
{
    procedure AddNodesDisplayContent(var Nodes: JsonArray)
    var
        Node: JsonToken;
        NodeId: JsonToken;
    begin
        foreach Node in Nodes do begin
            Node.AsObject().Get('nodeId', NodeId);
            Node.AsObject().Add('content', FormatItemLedgEntryDisplayProperties(NodeId2ItemLedgEntryNo(NodeId.AsValue().AsText())));
        end;
    end;

    procedure ConverFieldNameToJsonToken(GraphNodeData: Record "Graph Node Data CS") ConvertedName: Text
    var
        I: Integer;
    begin
        if IsEntryNoField(GraphNodeData) then
            exit('nodeId');

        GraphNodeData.CalcFields("Field Name");

        for I := 1 to StrLen(GraphNodeData."Field Name") do
            if IsSymbolAllowedInPropertyName(GraphNodeData."Field Name"[I]) then
                ConvertedName := ConvertedName + GraphNodeData."Field Name"[I]
            else
                ConvertedName := ConvertedName + '_';
    end;

    local procedure IsSymbolAllowedInPropertyName(Symbol: Char): Boolean
    begin
        if (Symbol >= 'a') and (Symbol <= 'z') then
            exit(true);

        if (Symbol >= 'A') and (Symbol <= 'Z') then
            exit(true);

        if (Symbol >= '0') and (Symbol <= '9') then
            exit(true);

        if Symbol = '_' then
            exit(true);

        exit(false);
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

    local procedure FormatItemLedgEntryDisplayProperties(ItemLedgEntryNo: Integer): JsonArray
    var
        GraphNodeData: Record "Graph Node Data CS";
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecRef: RecordRef;
        TableFieldRef: FieldRef;
        NodeDataField: JsonObject;
        NodeData: JsonArray;
    begin
        GraphNodeData.SetRange("Table No.", Database::"Item Ledger Entry");
        GraphNodeData.SetRange("Include in Node Data", true);

        ItemLedgerEntry.Get(ItemLedgEntryNo);
        RecRef.GetTable(ItemLedgerEntry);

        // Not checking the return value here, since at least the Entry No. must be included
        GraphNodeData.FindSet();
        repeat
            TableFieldRef := RecRef.Field(GraphNodeData."Field No.");
            if TableFieldRef.Class = FieldClass::FlowField then
                TableFieldRef.CalcField();

            GraphNodeData.CalcFields("Field Name");
            NodeDataField.Add('name', GraphNodeData."Field Name");
            NodeDataField.Add('value', Format(TableFieldRef.Value));
            NodeDataField.Add('showInLabel', GraphNodeData."Show in Node Label");
            NodeDataField.Add('showInStaticText', GraphNodeData."Show in Static Text");
            NodeDataField.Add('showInTooltip', GraphNodeData."Show in Tooltip");

            NodeData.Add(NodeDataField);
        until GraphNodeData.Next() = 0;

        exit(NodeData);
    end;

    procedure IsEntryNoField(GraphNodeData: Record "Graph Node Data CS"): Boolean
    begin
        exit((GraphNodeData."Table No." = Database::"Item Ledger Entry") and (GraphNodeData."Field No." = 1));
    end;

    procedure ItemLedgEntryNo2NodeId(ItemLedgEntryNo: Integer): Text
    begin
        exit(Format(ItemLedgEntryNo));
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
            TooltipsArray.Add(GetNodeTooltip(Node.AsValue().AsInteger()));

        exit(TooltipsArray);
    end;

    local procedure GetNodeTooltip(ItemLedgEntryNo: Integer): JsonObject
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Tooltip: JsonObject;
    begin
        ItemLedgerEntry.Get(ItemLedgEntryNo);
        Tooltip.Add('nodeId', ItemLedgEntryNo2NodeId(ItemLedgEntryNo));
        Tooltip.Add('content', FormatTooltipText(ItemLedgerEntry));
        exit(Tooltip);
    end;

    local procedure FormatTooltipText(ItemLedgerEntry: Record "Item Ledger Entry"): Text
    var
        TooltipFormatTok: Label '%1<br/>%2 %3', Comment = '%1: Entry No.; %2: Document Type; %3: Document No.';
    begin
        exit(StrSubstNo(TooltipFormatTok, ItemLedgerEntry."Entry Type", ItemLedgerEntry."Document Type", ItemLedgerEntry."Document No."));
    end;
}

codeunit 50101 "Graph View Controller CS"
{
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

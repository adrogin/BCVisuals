codeunit 50101 "Graph View Controller"
{
    procedure GraphLayoutEnumToText(GraphLayout: Enum "Graph Layout Name"): Text
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
        Tooltip.Add('nodeId', Format(ItemLedgEntryNo));
        Tooltip.Add('content', FormatTooltipText(ItemLedgerEntry));
        exit(Tooltip);
    end;

    local procedure FormatTooltipText(ItemLedgerEntry: Record "Item Ledger Entry"): Text
    begin
        exit(StrSubstNo('%1&#10;%2 %3', ItemLedgerEntry."Entry Type", ItemLedgerEntry."Document Type", ItemLedgerEntry."Document No."));
    end;
}

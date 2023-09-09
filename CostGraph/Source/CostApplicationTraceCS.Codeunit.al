codeunit 50100 "Cost Application Trace CS"
{
    procedure BuildCostSourceGraph(ItemLedgEntryNo: Integer; var Nodes: JsonArray; var Edges: JsonArray)
    var
        FromItemLedgerEntry: Record "Item Ledger Entry";
        TempDistinctNodes: Record Integer temporary;
    begin
        FromItemLedgerEntry.Get(ItemLedgEntryNo);
        GetVisitedEntriesBackward(FromItemLedgerEntry, false);

        ItemCostFlowBuf.Reset();
        if ItemCostFlowBuf.FindSet() then
            repeat
                AddNodeToArray(Nodes, ItemCostFlowBuf."From Item Ledg. Entry No.", TempDistinctNodes);
                AddNodeToArray(Nodes, ItemCostFlowBuf."To Item Ledg. Entry No.", TempDistinctNodes);
                AddEdgeToArray(Edges, ItemCostFlowBuf."From Item Ledg. Entry No.", ItemCostFlowBuf."To Item Ledg. Entry No.");
            until ItemCostFlowBuf.Next() = 0;
    end;

    internal procedure GetVisitedEntriesBackward(FromItemLedgEntry: Record "Item Ledger Entry"; WithinValuationDate: Boolean)
    var
        DummyItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        AvgCostEntryPointHandler: Codeunit "Avg. Cost Entry Point Handler";
    begin
        MaxValuationDate := 0D;
        if WithinValuationDate then begin
            ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Valuation Date");
            ValueEntry.SetRange("Item Ledger Entry No.", FromItemLedgEntry."Entry No.");
            ValueEntry.FindLast();
            MaxValuationDate := AvgCostEntryPointHandler.GetMaxValuationDate(FromItemLedgEntry, ValueEntry);
        end;

        ItemCostFlowBuf.Reset();
        ItemCostFlowBuf.DeleteAll();
        DummyItemLedgEntry.Init();
        DummyItemLedgEntry."Entry No." := -1;
        TraceCostBackward(FromItemLedgEntry);
    end;

    local procedure TraceCostBackward(FromItemLedgEntry: Record "Item Ledger Entry")
    begin
        TempVisitedItemApplnEntry.DeleteAll();

        if FromItemLedgEntry.Positive then
            TraceCostBackwardToAppliedOutbnds(FromItemLedgEntry."Entry No.")
        else
            TraceCostBackwardToAppliedInbnds(FromItemLedgEntry."Entry No.");

        TraceCostBackwardToInbndTransfers(FromItemLedgEntry."Entry No.");

        if FromItemLedgEntry."Entry Type" = FromItemLedgEntry."Entry Type"::Output then
            TraceCyclicProdCyclicalLoop(FromItemLedgEntry);

        if FromItemLedgEntry."Entry Type" = FromItemLedgEntry."Entry Type"::"Assembly Output" then
            TraceCyclicAsmCyclicalLoop(FromItemLedgEntry);
    end;

    local procedure TraceCostBackwardToAppliedOutbnds(EntryNo: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if GetOutboundEntriesTheInbndEntryAppliedTo(ItemApplnEntry, EntryNo) then
            TraceCostBackwardToAppliedEntries(ItemApplnEntry, EntryNo, true);
    end;

    local procedure TraceCostBackwardToAppliedInbnds(EntryNo: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemApplnEntry.GetInboundEntriesTheOutbndEntryAppliedTo(EntryNo) then
            TraceCostBackwardToAppliedEntries(ItemApplnEntry, EntryNo, false);
    end;

    local procedure TraceCostBackwardToInbndTransfers(EntryNo: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemApplnEntry.AppliedInbndTransEntryExists(EntryNo, false) then
            TraceCostBackwardToAppliedEntries(ItemApplnEntry, EntryNo, false);
    end;

    local procedure TraceCostBackwardToProdConsumption(EntryNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if not ItemLedgEntry.Get(EntryNo) then
            exit;

        TraceCyclicProdCyclicalLoop(ItemLedgEntry);
    end;

    local procedure TraceCostBackwardToAsmConsumption(EntryNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if not ItemLedgEntry.Get(EntryNo) then
            exit;

        TraceCyclicAsmCyclicalLoop(ItemLedgEntry);
    end;

    local procedure TraceCostBackwardToAppliedEntries(var ItemApplnEntry: Record "Item Application Entry"; FromEntryNo: Integer; IsPositiveToNegativeFlow: Boolean)
    var
        ToEntryNo: Integer;
    begin
        if EntryIsVisited(FromEntryNo) then
            exit;

        repeat
            if IsPositiveToNegativeFlow then
                ToEntryNo := ItemApplnEntry."Outbound Item Entry No."
            else
                ToEntryNo := ItemApplnEntry."Inbound Item Entry No.";

            if CheckLatestItemLedgEntryValuationDate(ItemApplnEntry."Item Ledger Entry No.", MaxValuationDate) then begin
                // Flow is reversed when inserting into the buffer, since the tracing runs backwards
                InsertCostFlowBufIfNotExists(ToEntryNo, FromEntryNo);

                TraceCostBackwardToAppliedOutbnds(ToEntryNo);
                TraceCostBackwardToAppliedInbnds(ToEntryNo);
                TraceCostBackwardToProdConsumption(ToEntryNo);
                TraceCostBackwardToAsmConsumption(ToEntryNo);
            end;
        until ItemApplnEntry.Next() = 0;

        TraceCostBackwardToInbndTransfers(FromEntryNo);
    end;

    local procedure TraceCyclicProdCyclicalLoop(ItemLedgEntry: Record "Item Ledger Entry")
    var
        ToItemLedgEntryNo: Integer;
    begin
        if ItemLedgEntry."Order Type" <> ItemLedgEntry."Order Type"::Production then
            exit;
        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Consumption then
            exit;
        if not ItemLedgEntry.Positive then
            exit;

        ToItemLedgEntryNo := ItemLedgEntry."Entry No.";
        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type");
        ItemLedgEntry.SetRange("Order No.", ItemLedgEntry."Order No.");
        ItemLedgEntry.SetRange("Order Line No.", ItemLedgEntry."Order Line No.");
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Consumption);
        if MaxValuationDate <> 0D then
            ItemLedgEntry.SetRange("Posting Date", 0D, MaxValuationDate);
        if ItemLedgEntry.FindSet() then
            repeat
                InsertCostFlowBufIfNotExists(ItemLedgEntry."Entry No.", ToItemLedgEntryNo);

                if not ItemLedgEntry.Positive then
                    TraceCostBackwardToAppliedInbnds(ItemLedgEntry."Entry No.");
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure TraceCyclicAsmCyclicalLoop(ItemLedgEntry: Record "Item Ledger Entry")
    var
        ToItemLedgEntryNo: Integer;
    begin
        if ItemLedgEntry."Order Type" <> ItemLedgEntry."Order Type"::Assembly then
            exit;
        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::"Assembly Consumption" then
            exit;
        if not ItemLedgEntry.Positive then
            exit;

        ToItemLedgEntryNo := ItemLedgEntry."Entry No.";
        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type");
        ItemLedgEntry.SetRange("Order No.", ItemLedgEntry."Order No.");
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::"Assembly Consumption");
        if MaxValuationDate <> 0D then
            ItemLedgEntry.SetRange("Posting Date", 0D, MaxValuationDate);
        if ItemLedgEntry.FindSet() then
            repeat
                InsertCostFlowBufIfNotExists(ItemLedgEntry."Entry No.", ToItemLedgEntryNo);

                if not ItemLedgEntry.Positive then
                    TraceCostBackwardToAppliedInbnds(ItemLedgEntry."Entry No.");
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure EntryIsVisited(EntryNo: Integer): Boolean
    begin
        if TempVisitedItemApplnEntry.Get(EntryNo) then
            exit(true);

        TempVisitedItemApplnEntry.Init();
        TempVisitedItemApplnEntry."Entry No." := EntryNo;
        TempVisitedItemApplnEntry.Quantity += 1;
        TempVisitedItemApplnEntry.Insert();
        exit(false);
    end;

    local procedure CheckLatestItemLedgEntryValuationDate(ItemLedgerEntryNo: Integer; MaxDate: Date): Boolean
    var
        ValueEntry: Record "Value Entry";
    begin
        if MaxDate = 0D then
            exit(true);
        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Valuation Date");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        ValueEntry.FindLast();
        exit(ValueEntry."Valuation Date" <= MaxDate);
    end;

    local procedure InsertCostFlowBufIfNotExists(FromEntryNo: Integer; ToEntryNo: Integer)
    begin
        ItemCostFlowBuf.Reset();
        ItemCostFlowBuf.SetRange("From Item Ledg. Entry No.", FromEntryNo);
        ItemCostFlowBuf.SetRange("To Item Ledg. Entry No.", ToEntryNo);
        if ItemCostFlowBuf.IsEmpty() then begin
            ItemCostFlowBuf.Init();
            ItemCostFlowBuf."Entry No." := GetNextEntryNo();
            ItemCostFlowBuf."From Item Ledg. Entry No." := FromEntryNo;
            ItemCostFlowBuf."To Item Ledg. Entry No." := ToEntryNo;
            ItemCostFlowBuf.Insert();
        end;
    end;

    local procedure GetNextEntryNo(): Integer
    begin
        LastEntryNo += 1;
        exit(LastEntryNo);
    end;

    local procedure GetOutboundEntriesTheInbndEntryAppliedTo(var ItemApplnEntry: Record "Item Application Entry"; InbndItemLedgEntryNo: Integer): Boolean
    begin
        ItemApplnEntry.SetCurrentKey("Outbound Item Entry No.", "Item Ledger Entry No.");
        ItemApplnEntry.SetRange("Inbound Item Entry No.", InbndItemLedgEntryNo);
        ItemApplnEntry.SetRange("Item Ledger Entry No.", InbndItemLedgEntryNo);
        ItemApplnEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
        exit(ItemApplnEntry.FindSet());
    end;

    local procedure AddNodeToArray(var Nodes: JsonArray; NodeId: Integer; var DistinctNodes: Record Integer)
    begin
        if DistinctNodes.Get(NodeId) then
            exit;

        Nodes.Add(NodeId);

        DistinctNodes.Number := NodeId;
        DistinctNodes.Insert();
    end;

    local procedure AddEdgeToArray(var Edges: JsonArray; SourceNodeId: Integer; TargetNodeId: Integer)
    var
        Edge: JsonObject;
    begin
        Edge.Add('source', Format(SourceNodeId));
        Edge.Add('target', Format(TargetNodeId));
        Edges.Add(Edge);
    end;

    var
        ItemCostFlowBuf: Record "Item Cost Flow Buf. CS";
        TempVisitedItemApplnEntry: Record "Item Application Entry" temporary;
        MaxValuationDate: Date;
        LastEntryNo: Integer;
}

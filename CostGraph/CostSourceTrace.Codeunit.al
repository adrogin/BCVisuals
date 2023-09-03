codeunit 50100 "Cost Source Trace"
{
    procedure GetVisitedEntriesBackward(FromItemLedgEntry: Record "Item Ledger Entry"; var ItemLedgEntryInChain: Record "Item Ledger Entry"; WithinValuationDate: Boolean)
    var
        ToItemLedgEntry: Record "Item Ledger Entry";
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

        ItemLedgEntryInChain.Reset();
        ItemLedgEntryInChain.DeleteAll();
        DummyItemLedgEntry.Init();
        DummyItemLedgEntry."Entry No." := -1;
        TraceCostBackward(FromItemLedgEntry);
        if TempItemLedgEntryInChainNo.FindSet() then
            repeat
                ToItemLedgEntry.Get(TempItemLedgEntryInChainNo.Number);
                ItemLedgEntryInChain := ToItemLedgEntry;
                ItemLedgEntryInChain.Insert();
            until TempItemLedgEntryInChainNo.Next() = 0;
    end;

    local procedure TraceCostBackward(FromItemLedgEntry: Record "Item Ledger Entry")
    begin
        TempVisitedItemApplnEntry.DeleteAll();
        TempItemLedgEntryInChainNo.DeleteAll();

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
        if ItemApplnEntry.AppliedOutbndEntryExists(EntryNo, false, false) then
            TraceCostBackwardToAppliedEntries(ItemApplnEntry, EntryNo, true);
    end;

    local procedure TraceCostBackwardToAppliedInbnds(EntryNo: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemApplnEntry.AppliedInbndEntryExists(EntryNo, false) then
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
                if not TempItemLedgEntryInChainNo.Get(ToEntryNo) then begin
                    TempItemLedgEntryInChainNo.Number := ToEntryNo;
                    TempItemLedgEntryInChainNo.Insert();
                end;

                TraceCostBackwardToAppliedOutbnds(ToEntryNo);
                TraceCostBackwardToAppliedInbnds(ToEntryNo);
                TraceCostBackwardToProdConsumption(ToEntryNo);
                TraceCostBackwardToAsmConsumption(ToEntryNo);
            end;
        until ItemApplnEntry.Next() = 0;

        TraceCostBackwardToInbndTransfers(FromEntryNo);
    end;

    local procedure TraceCyclicProdCyclicalLoop(ItemLedgEntry: Record "Item Ledger Entry")
    begin
        if ItemLedgEntry."Order Type" <> ItemLedgEntry."Order Type"::Production then
            exit;
        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Consumption then
            exit;
        if not ItemLedgEntry.Positive then
            exit;

        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type");
        ItemLedgEntry.SetRange("Order No.", ItemLedgEntry."Order No.");
        ItemLedgEntry.SetRange("Order Line No.", ItemLedgEntry."Order Line No.");
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Consumption);
        if MaxValuationDate <> 0D then
            ItemLedgEntry.SetRange("Posting Date", 0D, MaxValuationDate);
        if ItemLedgEntry.FindSet() then
            repeat
                if not TempItemLedgEntryInChainNo.Get(ItemLedgEntry."Entry No.") then begin
                    TempItemLedgEntryInChainNo.Number := ItemLedgEntry."Entry No.";
                    TempItemLedgEntryInChainNo.Insert();
                end;

                if not ItemLedgEntry.Positive then
                    TraceCostBackwardToAppliedInbnds(ItemLedgEntry."Entry No.");
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure TraceCyclicAsmCyclicalLoop(ItemLedgEntry: Record "Item Ledger Entry")
    begin
        if ItemLedgEntry."Order Type" <> ItemLedgEntry."Order Type"::Assembly then
            exit;
        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::"Assembly Consumption" then
            exit;
        if not ItemLedgEntry.Positive then
            exit;

        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type");
        ItemLedgEntry.SetRange("Order No.", ItemLedgEntry."Order No.");
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::"Assembly Output");
        if MaxValuationDate <> 0D then
            ItemLedgEntry.SetRange("Posting Date", 0D, MaxValuationDate);
        if ItemLedgEntry.FindSet() then
            repeat
                if not TempItemLedgEntryInChainNo.Get(ItemLedgEntry."Entry No.") then begin
                    TempItemLedgEntryInChainNo.Number := ItemLedgEntry."Entry No.";
                    TempItemLedgEntryInChainNo.Insert();
                end;

                if not ItemLedgEntry.Positive then
                    TraceCostBackwardToAppliedInbnds(ItemLedgEntry."Entry No.");
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure EntryIsVisited(EntryNo: Integer): Boolean
    begin
        if TempVisitedItemApplnEntry.Get(EntryNo) then begin
            // This is to take into account quantity flows from an inbound entry to an inbound transfer
            if TempVisitedItemApplnEntry.Quantity = 2 then
                exit(true);
            TempVisitedItemApplnEntry.Quantity += 1;
            TempVisitedItemApplnEntry.Modify();
            exit(false);
        end;

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

    procedure BuildCostSourceGraph(ILENo: Integer; var Nodes: JsonArray; var Edges: JsonArray)
    var
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        AddNodeToArray(Nodes, ILENo);

        ItemApplicationEntry.SetLoadFields("Inbound Item Entry No.");
        ItemApplicationEntry.SetRange("Outbound Item Entry No.", ILENo);
        if ItemApplicationEntry.FindSet() then
            repeat
                AddEdgeToArray(Edges, ItemApplicationEntry."Inbound Item Entry No.", ILENo);
                BuildCostSourceGraph(ItemApplicationEntry."Inbound Item Entry No.", Nodes, Edges);
            until ItemApplicationEntry.Next() = 0;
    end;

    local procedure AddNodeToArray(var Nodes: JsonArray; NodeId: Integer)
    begin
        Nodes.Add(NodeId);
    end;

    local procedure AddEdgeToArray(var Edges: JsonArray; SourceNodeId: Integer; TargetNodeId: Integer)
    var
        Edge: JsonObject;
    begin
        Edge.Add(Format(SourceNodeId), Format(TargetNodeId));
        Edges.Add(Edge);
    end;

    var
        TempItemLedgEntryInChainNo: Record Integer temporary;
        TempVisitedItemApplnEntry: Record "Item Application Entry" temporary;
        MaxValuationDate: Date;
}

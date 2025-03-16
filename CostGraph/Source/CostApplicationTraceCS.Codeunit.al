codeunit 50150 "Cost Application Trace CS"
{
    procedure BuildCostSourceGraph(ItemLedgEntryNo: Integer; var Nodes: JsonArray; var Edges: JsonArray)
    begin
        BuildCostSourceGraph(ItemLedgEntryNo, Enum::"Cost Trace Direction"::Backward, Nodes, Edges);
    end;

    procedure BuildCostSourceGraph(ItemLedgEntryNo: Integer; Direction: Enum "Cost Trace Direction"; var Nodes: JsonArray; var Edges: JsonArray)
    var
        FromItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemCostFlowBuf.Reset();
        ItemCostFlowBuf.DeleteAll();
        TempVisitedItemApplnEntry.DeleteAll();

        FromItemLedgerEntry.Get(ItemLedgEntryNo);
        TraceCost(FromItemLedgerEntry, Direction, 0);

        GetGraphElements(Nodes, Edges);
    end;

    internal procedure GetGraphElements(var Nodes: JsonArray; var Edges: JsonArray)
    var
        TempDistinctNodes: Record Integer temporary;
    begin
        ItemCostFlowBuf.Reset();
        ItemCostFlowBuf.SetFilter("From Item Ledg. Entry No.", '>%1', 0);
        ItemCostFlowBuf.SetFilter("To Item Ledg. Entry No.", '>%1', 0);
        if ItemCostFlowBuf.FindSet() then
            repeat
                AddNodeToArray(Nodes, ItemCostFlowBuf."From Item Ledg. Entry No.", TempDistinctNodes);
                AddNodeToArray(Nodes, ItemCostFlowBuf."To Item Ledg. Entry No.", TempDistinctNodes);
                AddEdgeToArray(Edges, ItemCostFlowBuf."From Item Ledg. Entry No.", ItemCostFlowBuf."To Item Ledg. Entry No.");
            until ItemCostFlowBuf.Next() = 0;

        // Special case of entries without applications. These entries should be added as detached graph nodes with no edges.
        ItemCostFlowBuf.Reset();
        ItemCostFlowBuf.SetRange("From Item Ledg. Entry No.", 0);
        if ItemCostFlowBuf.FindSet() then
            repeat
                AddNodeToArray(Nodes, ItemCostFlowBuf."To Item Ledg. Entry No.", TempDistinctNodes);
            until ItemCostFlowBuf.Next() = 0;
    end;

    internal procedure TraceCost(FromItemLedgEntry: Record "Item Ledger Entry"; Direction: Enum "Cost Trace Direction"; MaxTraceDepth: Integer)
    begin
        InsertCostFlowBufIfNotExists(0, FromItemLedgEntry."Entry No.");
        MaxDepth := MaxTraceDepth;
        TraceCostApplication(FromItemLedgEntry, Direction, MaxTraceDepth);
    end;

    local procedure TraceCostApplication(FromItemLedgerEntry: Record "Item Ledger Entry"; Direction: Enum "Cost Trace Direction"; Depth: Integer)
    begin
        if IsApplicationBetweenConsumptionAndOuntput(FromItemLedgerEntry, Direction) then
            case true of
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::Output) and (Direction = Enum::"Cost Trace Direction"::Backward):
                    TraceCyclicProdCyclicalLoopBackward(FromItemLedgerEntry, Depth + 1);  // tracing backward to consumption
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::Consumption) and (Direction = Enum::"Cost Trace Direction"::Forward):
                    TraceCyclicProdCyclicalLoopForward(FromItemLedgerEntry, Depth + 1);   // tracing forward to output
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::"Assembly Output") and (Direction = Enum::"Cost Trace Direction"::Backward):
                    TraceCyclicAsmCyclicalLoopBackward(FromItemLedgerEntry, Depth + 1);   // tracing backward to assembly consumption
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::"Assembly Consumption") and (Direction = Enum::"Cost Trace Direction"::Forward):
                    TraceCyclicAsmCyclicalLoopForward(FromItemLedgerEntry, Depth + 1);    // tracing forward to assembly output
            end
        else
            case true of
                FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction"::Forward):
                    TraceCostForwardToOutbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
                FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction"::Backward):
                    TraceCostBackwardToOutbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
                not FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction"::Forward):
                    TraceCostForwardToInbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
                not FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction"::Backward):
                    TraceCostBackwardToInbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
            end;
    end;

    local procedure IsApplicationBetweenConsumptionAndOuntput(ItemLedgerEntry: Record "Item Ledger Entry"; Direction: Enum "Cost Trace Direction"): Boolean
    begin
        case Direction of
            Enum::"Cost Trace Direction"::Forward:
                exit(ItemLedgerEntry."Entry Type" in [Enum::"Item Ledger Entry Type"::Consumption, Enum::"Item Ledger Entry Type"::"Assembly Consumption"]);
            Enum::"Cost Trace Direction"::Backward:
                exit(ItemLedgerEntry."Entry Type" in [Enum::"Item Ledger Entry Type"::Output, Enum::"Item Ledger Entry Type"::"Assembly Output"]);
        end;
    end;

    local procedure TraceCostBackwardToOutbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if GetOutboundEntriesTheInbndEntryAppliedTo(ItemApplnEntry, EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction"::Backward, true, Depth);
    end;

    local procedure TraceCostBackwardToInbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemApplnEntry.GetInboundEntriesTheOutbndEntryAppliedTo(EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction"::Backward, false, Depth);
    end;

    local procedure TraceCostForwardToOutbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemApplnEntry.GetOutboundEntriesAppliedToTheInboundEntry(EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction"::Forward, true, Depth);
    end;

    local procedure TraceCostForwardToInbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if GetInboundEntriesAppliedToTheOutboundEntry(ItemApplnEntry, EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction"::Forward, false, Depth);
    end;

    local procedure TraceCostApplicationEntries(var ItemApplnEntry: Record "Item Application Entry"; FromEntryNo: Integer; Direction: Enum "Cost Trace Direction"; IsPositiveToNegativeFlow: Boolean; Depth: Integer)
    var
        ToItemLedgerEntry: Record "Item Ledger Entry";
        ToEntryNo: Integer;
    begin
        if EntryIsVisited(FromEntryNo) then
            exit;

        repeat
            if IsPositiveToNegativeFlow then
                ToEntryNo := ItemApplnEntry."Outbound Item Entry No."
            else
                ToEntryNo := ItemApplnEntry."Inbound Item Entry No.";

            if Direction = Enum::"Cost Trace Direction"::Forward then
                InsertCostFlowBufIfNotExists(FromEntryNo, ToEntryNo)
            else
                InsertCostFlowBufIfNotExists(ToEntryNo, FromEntryNo);

            if (ToEntryNo > 0) and ((MaxDepth = 0) or (Depth < MaxDepth)) then begin
                ToItemLedgerEntry.Get(ToEntryNo);
                TraceCostApplication(ToItemLedgerEntry, Direction, Depth);
            end;
        until ItemApplnEntry.Next() = 0;
    end;

    local procedure TraceCyclicProdCyclicalLoopBackward(ItemLedgEntry: Record "Item Ledger Entry"; Depth: Integer)
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
        if FindOrderItemLedgerEntries(ItemLedgEntry, ItemLedgEntry."Order Type", ItemLedgEntry."Order No.", Enum::"Item Ledger Entry Type"::Consumption) then
            repeat
                InsertCostFlowBufIfNotExists(ItemLedgEntry."Entry No.", ToItemLedgEntryNo);

                if not ItemLedgEntry.Positive then
                    TraceCostBackwardToInbounds(ItemLedgEntry."Entry No.", Depth + 1);
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure TraceCyclicProdCyclicalLoopForward(ItemLedgEntry: Record "Item Ledger Entry"; Depth: Integer)
    var
        FromItemLedgEntryNo: Integer;
    begin
        if ItemLedgEntry."Order Type" <> ItemLedgEntry."Order Type"::Production then
            exit;
        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Output then
            exit;
        if ItemLedgEntry.Positive then
            exit;

        FromItemLedgEntryNo := ItemLedgEntry."Entry No.";
        if FindOrderItemLedgerEntries(ItemLedgEntry, ItemLedgEntry."Order Type", ItemLedgEntry."Order No.", Enum::"Item Ledger Entry Type"::Output) then
            repeat
                InsertCostFlowBufIfNotExists(FromItemLedgEntryNo, ItemLedgEntry."Entry No.");

                if ItemLedgEntry.Positive then
                    TraceCostForwardToOutbounds(ItemLedgEntry."Entry No.", Depth + 1);
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure TraceCyclicAsmCyclicalLoopBackward(ItemLedgEntry: Record "Item Ledger Entry"; Depth: Integer)
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
        if FindOrderItemLedgerEntries(ItemLedgEntry, ItemLedgEntry."Order Type", ItemLedgEntry."Order No.", Enum::"Item Ledger Entry Type"::"Assembly Consumption") then
            repeat
                InsertCostFlowBufIfNotExists(ItemLedgEntry."Entry No.", ToItemLedgEntryNo);

                if not ItemLedgEntry.Positive then
                    TraceCostBackwardToInbounds(ItemLedgEntry."Entry No.", Depth);
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure TraceCyclicAsmCyclicalLoopForward(ItemLedgEntry: Record "Item Ledger Entry"; Depth: Integer)
    var
        FromItemLedgEntryNo: Integer;
    begin
        if ItemLedgEntry."Order Type" <> ItemLedgEntry."Order Type"::Assembly then
            exit;
        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::"Assembly Output" then
            exit;
        if ItemLedgEntry.Positive then
            exit;

        FromItemLedgEntryNo := ItemLedgEntry."Entry No.";
        if FindOrderItemLedgerEntries(ItemLedgEntry, ItemLedgEntry."Order Type", ItemLedgEntry."Order No.", Enum::"Item Ledger Entry Type"::"Assembly Output") then
            repeat
                InsertCostFlowBufIfNotExists(FromItemLedgEntryNo, ItemLedgEntry."Entry No.");

                if ItemLedgEntry.Positive then
                    TraceCostForwardToOutbounds(ItemLedgEntry."Entry No.", Depth);
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure FindOrderItemLedgerEntries(var ItemLedgerEntry: Record "Item Ledger Entry"; OrderType: Enum "Inventory Order Type"; OrderNo: Code[20]; EntryType: Enum "Item Ledger Entry Type"): Boolean
    begin
        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgerEntry.SetRange("Order Type", OrderType);
        ItemLedgerEntry.SetRange("Order No.", OrderNo);
        ItemLedgerEntry.SetRange("Entry Type", EntryType);
        exit(ItemLedgerEntry.FindSet());
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

    local procedure GetInboundEntriesAppliedToTheOutboundEntry(var ItemApplnEntry: record "Item Application Entry"; OutbndItemLedgEntryNo: Integer): Boolean
    begin
        ItemApplnEntry.Reset();
        ItemApplnEntry.SetCurrentKey("Inbound Item Entry No.", "Item Ledger Entry No.");
        ItemApplnEntry.SetRange("Outbound Item Entry No.", OutbndItemLedgEntryNo);
        ItemApplnEntry.SetFilter("Item Ledger Entry No.", '<>%1', OutbndItemLedgEntryNo);
        ItemApplnEntry.SetFilter("Inbound Item Entry No.", '<>%1', 0);
        exit(ItemApplnEntry.FindSet());
    end;

    local procedure AddNodeToArray(var Nodes: JsonArray; NodeId: Integer; var DistinctNodes: Record Integer)
    var
        Node: JsonObject;
    begin
        if DistinctNodes.Get(NodeId) then
            exit;

        Node.Add('id', NodeId);
        Nodes.Add(Node);

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
        LastEntryNo: Integer;
        MaxDepth: Integer;
}

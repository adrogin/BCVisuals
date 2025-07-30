codeunit 50150 "Cost Application Trace CS"
{
    procedure BuildCostSourceGraph(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20]; Direction: Enum "Cost Trace Direction CS"; var Nodes: JsonArray; var Edges: JsonArray)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        InterimNodes, InterimEdges : JsonArray;
    begin
        // Handle special cases for production and assembly where applications between entries are possible within the same document.
        if DocumentType = Enum::"Item Ledger Document Type"::"Posted Assembly" then begin
            ItemLedgEntry.SetRange("Entry Type", Enum::"Item Ledger Entry Type"::"Assembly Output");
            if ItemLedgEntry.IsEmpty() then
                ItemLedgEntry.SetRange("Entry Type", Enum::"Item Ledger Entry Type"::"Assembly Consumption");
        end
        else
            if DocumentType = Enum::"Item Ledger Document Type"::" " then begin
                ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type"::Production);
                ItemLedgEntry.SetRange("Entry Type", Enum::"Item Ledger Entry Type"::Output);
                if ItemLedgEntry.IsEmpty() then
                    ItemLedgEntry.SetRange("Entry Type", Enum::"Item Ledger Entry Type"::Consumption);
            end;

        ItemLedgEntry.SetRange("Document Type", DocumentType);
        ItemLedgEntry.SetRange("Document No.", DocumentNo);
        if ItemLedgEntry.FindSet() then
            repeat
                if not GraphJsonArray.ContainsNode(Nodes, ItemLedgEntry."Entry No.") then begin
                    BuildCostSourceGraph(ItemLedgEntry."Entry No.", Direction, InterimNodes, InterimEdges);
                    GraphJsonArray.MergeNodeArrays(Nodes, InterimNodes);
                    GraphJsonArray.MergeEdgeArrays(Edges, InterimEdges);
                end;
            until ItemLedgEntry.Next() = 0;
    end;

    procedure BuildCostSourceGraph(ItemLedgEntryNo: Integer; var Nodes: JsonArray; var Edges: JsonArray)
    begin
        BuildCostSourceGraph(ItemLedgEntryNo, Enum::"Cost Trace Direction CS"::Backward, Nodes, Edges);
    end;

    procedure BuildCostSourceGraph(ItemLedgEntryNo: Integer; Direction: Enum "Cost Trace Direction CS"; var Nodes: JsonArray; var Edges: JsonArray)
    var
        FromItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemCostFlowBuf.Reset();
        ItemCostFlowBuf.DeleteAll();
        TempVisitedItemApplnEntry.DeleteAll();
        Clear(Nodes);
        Clear(Edges);

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

    internal procedure TraceCost(FromItemLedgEntry: Record "Item Ledger Entry"; Direction: Enum "Cost Trace Direction CS"; MaxTraceDepth: Integer)
    begin
        InsertCostFlowBufIfNotExists(0, FromItemLedgEntry."Entry No.");
        MaxDepth := MaxTraceDepth;
        TraceCostApplication(FromItemLedgEntry, Direction, MaxTraceDepth);
    end;

    local procedure TraceCostApplication(FromItemLedgerEntry: Record "Item Ledger Entry"; Direction: Enum "Cost Trace Direction CS"; Depth: Integer)
    begin
        if IsApplicationBetweenConsumptionAndOuntput(FromItemLedgerEntry, Direction) then
            case true of
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::Output) and (Direction = Enum::"Cost Trace Direction CS"::Backward):
                    TraceCyclicProdCyclicalLoopBackward(FromItemLedgerEntry, Depth + 1);  // tracing backward to consumption
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::Consumption) and (Direction = Enum::"Cost Trace Direction CS"::Forward):
                    TraceCyclicProdCyclicalLoopForward(FromItemLedgerEntry, Depth + 1);   // tracing forward to output
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::"Assembly Output") and (Direction = Enum::"Cost Trace Direction CS"::Backward):
                    TraceCyclicAsmCyclicalLoopBackward(FromItemLedgerEntry, Depth + 1);   // tracing backward to assembly consumption
                (FromItemLedgerEntry."Entry Type" = FromItemLedgerEntry."Entry Type"::"Assembly Consumption") and (Direction = Enum::"Cost Trace Direction CS"::Forward):
                    TraceCyclicAsmCyclicalLoopForward(FromItemLedgerEntry, Depth + 1);    // tracing forward to assembly output
            end
        else
            case true of
                FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction CS"::Forward):
                    TraceCostForwardToOutbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
                FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction CS"::Backward):
                    TraceCostBackwardToOutbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
                not FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction CS"::Forward):
                    TraceCostForwardToInbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
                not FromItemLedgerEntry.Positive and (Direction = Enum::"Cost Trace Direction CS"::Backward):
                    TraceCostBackwardToInbounds(FromItemLedgerEntry."Entry No.", Depth + 1);
            end;
    end;

    local procedure IsApplicationBetweenConsumptionAndOuntput(ItemLedgerEntry: Record "Item Ledger Entry"; Direction: Enum "Cost Trace Direction CS"): Boolean
    begin
        case Direction of
            Enum::"Cost Trace Direction CS"::Forward:
                exit(ItemLedgerEntry."Entry Type" in [Enum::"Item Ledger Entry Type"::Consumption, Enum::"Item Ledger Entry Type"::"Assembly Consumption"]);
            Enum::"Cost Trace Direction CS"::Backward:
                exit(ItemLedgerEntry."Entry Type" in [Enum::"Item Ledger Entry Type"::Output, Enum::"Item Ledger Entry Type"::"Assembly Output"]);
        end;
    end;

    local procedure TraceCostBackwardToOutbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if GetOutboundEntriesTheInbndEntryAppliedTo(ItemApplnEntry, EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction CS"::Backward, true, Depth);
    end;

    local procedure TraceCostBackwardToInbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemApplnEntry.GetInboundEntriesTheOutbndEntryAppliedTo(EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction CS"::Backward, false, Depth);
    end;

    local procedure TraceCostForwardToOutbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemApplnEntry.GetOutboundEntriesAppliedToTheInboundEntry(EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction CS"::Forward, true, Depth);
    end;

    local procedure TraceCostForwardToInbounds(EntryNo: Integer; Depth: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if GetInboundEntriesAppliedToTheOutboundEntry(ItemApplnEntry, EntryNo) then
            TraceCostApplicationEntries(ItemApplnEntry, EntryNo, Enum::"Cost Trace Direction CS"::Forward, false, Depth);
    end;

    local procedure TraceCostApplicationEntries(var ItemApplnEntry: Record "Item Application Entry"; FromEntryNo: Integer; Direction: Enum "Cost Trace Direction CS"; IsPositiveToNegativeFlow: Boolean; Depth: Integer)
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

            if Direction = Enum::"Cost Trace Direction CS"::Forward then
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

    procedure TraceFromSourceRecord(TraceSource: RecordRef; TraceDirection: Enum "Cost Trace Direction CS"; var GraphNodes: JsonArray; var GraphEdges: JsonArray)
    var
        CostGraph: Codeunit "Cost Graph CS";
    begin
        if TraceSource.Number = 0 then
            exit;

        if TraceSource.Number = Database::"Item Ledger Entry" then
            TraceCostApplicationFromItemLedgerEntry(TraceSource, TraceDirection, GraphNodes, GraphEdges)
        else
            TraceCostApplicationFromDocument(TraceSource.Number, TraceSource.Field(CostGraph.FindDocumentNoField(TraceSource.Number)).Value, TraceDirection, GraphNodes, GraphEdges);
    end;

    local procedure TraceCostApplicationFromDocument(SourceTableNo: Integer; DocumentNo: Code[20]; TraceDirection: Enum "Cost Trace Direction CS"; var GraphNodes: JsonArray; var GraphEdges: JsonArray)
    var
        CostGraph: Codeunit "Cost Graph CS";
    begin
        if SourceTableNo = 0 then
            exit;

        BuildCostSourceGraph(CostGraph.TableNo2DocumentType(SourceTableNo), DocumentNo, TraceDirection, GraphNodes, GraphEdges);
    end;

    local procedure TraceCostApplicationFromItemLedgerEntry(TraceSource: RecordRef; TraceDirection: Enum "Cost Trace Direction CS"; var GraphNodes: JsonArray; var GraphEdges: JsonArray)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        EntryNo: Integer;
    begin
        EntryNo := TraceSource.Field(ItemLedgerEntry.FieldNo("Entry No.")).Value;
        if EntryNo = 0 then
            exit;

        BuildCostSourceGraph(EntryNo, TraceDirection, GraphNodes, GraphEdges);
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
    begin
        if DistinctNodes.Get(NodeId) then
            exit;

        GraphJsonArray.AddNodeToArray(Nodes, NodeId);
        DistinctNodes.Number := NodeId;
        DistinctNodes.Insert();
    end;

    local procedure AddEdgeToArray(var Edges: JsonArray; SourceNodeId: Integer; TargetNodeId: Integer)
    begin
        GraphJsonArray.AddEdgeToArray(Edges, SourceNodeId, TargetNodeId);
    end;

    var
        ItemCostFlowBuf: Record "Item Cost Flow Buf. CS";
        TempVisitedItemApplnEntry: Record "Item Application Entry" temporary;
        GraphJsonArray: Codeunit "Graph Json Array CS";
        LastEntryNo: Integer;
        MaxDepth: Integer;
}

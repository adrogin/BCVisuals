codeunit 60150 "Cost Trace Tests CS"
{
    Subtype = Test;

    var
        CostApplicationTrace: Codeunit "Cost Application Trace CS";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryManufacturing: Codeunit "Library - Manufacturing";
        LibraryAssembly: Codeunit "Library - Assembly";
        LibraryPatterns: Codeunit "Library - Patterns";
        LibraryRandom: Codeunit "Library - Random";
        LibraryAssert: Codeunit "Library Assert";
        IncorrectNodeCountErr: Label 'Incorrect number of nodes in the graph.';
        IncorrectEdgeCountErr: Label 'Incorrect number of edges in the graph.';
        IncorrectNodeNoErr: Label 'Incorrect item ledger entry No. in the edge.';
        ItemLedgEntryMissingInNodeListErr: Label 'Node is missing in the list.';

    [Test]
    procedure ApplyOutboutdToInboudTraceBack()
    var
        Item: Record Item;
        Quantity: Integer;
        ItemLedgEntryNos: List of [Integer];
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [SCENARIO] Post inbound and outboud entries, build cost graph. Result contains two nodes and one edge connecting the nodes.

        // [GIVEN] Item "I"
        LibraryInventory.CreateItem(Item);
        Quantity := LibraryRandom.RandInt(100);

        // [GIVEN] Post positive adjustment of the item "I" (item ledger entry 1) and negative adjustment of the same item (item ledger entry 2)
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::"Positive Adjmt.", Item."No.", Quantity));
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::"Negative Adjmt.", Item."No.", Quantity));

        // [WHEN] Build cost graph
        CostApplicationTrace.BuildCostSourceGraph(ItemLedgEntryNos.Get(ItemLedgEntryNos.Count()), Nodes, Edges);

        // [THEN] The set of nodes includes entries 1 and 2
        // [THEN] One edge returned, entry 1 pointing to entry 2
        VerifyNodesList(ItemLedgEntryNos, Nodes);
        LibraryAssert.AreEqual(1, Edges.Count(), IncorrectEdgeCountErr);

        VerifyEdgeInArray(Edges, 0, ItemLedgEntryNos.Get(1), ItemLedgEntryNos.Get(2));
    end;

    [Test]
    procedure TraceCostInboundNoSource()
    var
        ItemLedgEntryNo: Integer;
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [SCENARIO] Post single inbound entry and build cost graph. Result set is empty.

        ItemLedgEntryNo :=
            CreateAndPostItemJournalLine(Enum::"Item Ledger Entry Type"::"Positive Adjmt.", LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));

        CostApplicationTrace.BuildCostSourceGraph(ItemLedgEntryNo, Nodes, Edges);

        LibraryAssert.AreEqual(0, Nodes.Count(), IncorrectNodeCountErr);
        LibraryAssert.AreEqual(0, Edges.Count(), IncorrectEdgeCountErr);
    end;

    [Test]
    procedure TraceCostOutboundNoSource()
    var
        ItemLedgEntryNo: Integer;
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [SCENARIO] Post single outbound entry without application and build cost graph. Result set is empty.

        ItemLedgEntryNo :=
            CreateAndPostItemJournalLine(Enum::"Item Ledger Entry Type"::"Negative Adjmt.", LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));

        CostApplicationTrace.BuildCostSourceGraph(ItemLedgEntryNo, Nodes, Edges);

        LibraryAssert.AreEqual(0, Nodes.Count(), IncorrectNodeCountErr);
        LibraryAssert.AreEqual(0, Edges.Count(), IncorrectEdgeCountErr);
    end;

    [Test]
    procedure TraceOutboundAppliedToMultipleInbounds()
    var
        Item: Record Item;
        Quantity: Integer;
        ItemLedgEntryNos: List of [Integer];
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [SCENARIO] Post out bound entry applied to two inbounds, build cost graph.

        // [GIVEN] Item "I"
        LibraryInventory.CreateItem(Item);
        Quantity := LibraryRandom.RandInt(100);

        // [GIVEN] Post two positive adjustment journal lines for item "I", quantity is "X in each line". Item ledger entries 1 and 2 are created.
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Ledger Entry Type"::"Positive Adjmt.", Item."No.", Quantity));
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Ledger Entry Type"::"Positive Adjmt.", Item."No.", Quantity));

        // [GIVEN] Post negative adjustment of item "I", quantity = "2X"
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Ledger Entry Type"::"Negative Adjmt.", Item."No.", Quantity * 2));

        // [WHEN] Build cost graph
        CostApplicationTrace.BuildCostSourceGraph(ItemLedgEntryNos.Get(ItemLedgEntryNos.Count()), Nodes, Edges);

        // [THEN] Graph contains 3 nodes and 2 edges: 1 -> 3, 2 -> 3
        VerifyNodesList(ItemLedgEntryNos, Nodes);

        LibraryAssert.AreEqual(2, Edges.Count(), IncorrectEdgeCountErr);
        VerifyEdgeInArray(Edges, 0, ItemLedgEntryNos.Get(1), ItemLedgEntryNos.Get(3));
        VerifyEdgeInArray(Edges, 1, ItemLedgEntryNos.Get(2), ItemLedgEntryNos.Get(3));
    end;

    [Test]
    procedure TraceSaleAppliedToTransfer()
    var
        Item: Record Item;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Locations: array[3] of Record Location;
        Quantity: Integer;
        ItemLedgEntryNos: List of [Integer];
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [SCENARIO] Post inbound entry, transfer the item to another location, post outbound entry, and build cost graph

        // [GIVEN] Item "I", locations "L1", "L2", and a transfer location "L3"
        LibraryInventory.CreateItem(Item);
        Quantity := LibraryRandom.RandInt(100);
        LibraryWarehouse.CreateTransferLocations(Locations[1], Locations[2], Locations[3]);

        // [GIVEN] Post purchase of item "I" on location "L1"
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::Purchase, Item."No.", Quantity, Locations[1].Code));

        // [GIVEN] Create and post transfer order moving item "I" from location "L1" to location "L2" via the transit locaton "L3"
        LibraryInventory.CreateTransferHeader(TransferHeader, Locations[1].Code, Locations[2].Code, Locations[3].Code);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, Item."No.", Quantity);
        LibraryInventory.PostTransferHeader(TransferHeader, true, true);
        CollectItemLedgerEntries(
            ItemLedgEntryNos, Item."No.", Enum::"Item Ledger Document Type"::"Transfer Shipment", GetPostedTransferShipmentNo(TransferHeader."No."));
        CollectItemLedgerEntries(
            ItemLedgEntryNos, Item."No.", Enum::"Item Ledger Document Type"::"Transfer Receipt", GetPostedTransferReceiptNo(TransferHeader."No."));

        // [GIVEN] Post sale entry for item "I" on locaton "L2"
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::Sale, Item."No.", Quantity, Locations[2].Code));

        // [WHEN] Build cost graph
        CostApplicationTrace.BuildCostSourceGraph(ItemLedgEntryNos.Get(ItemLedgEntryNos.Count()), Nodes, Edges);

        // [THEN] Graph contains 6 nodes and 5 edges:
        // [THEN] Purchase -> Transfer Shipment (L1) -> Transfer Shipment (L3) -> Transfer Receipt (L3) -> Transfer Receipt (L2) -> Sale
        VerifyNodesList(ItemLedgEntryNos, Nodes);

        LibraryAssert.AreEqual(5, Edges.Count(), IncorrectEdgeCountErr);
        VerifyEdgeInArray(Edges, 4, ItemLedgEntryNos.Get(1), ItemLedgEntryNos.Get(2));
        VerifyEdgeInArray(Edges, 3, ItemLedgEntryNos.Get(2), ItemLedgEntryNos.Get(3));
        VerifyEdgeInArray(Edges, 2, ItemLedgEntryNos.Get(3), ItemLedgEntryNos.Get(4));
        VerifyEdgeInArray(Edges, 1, ItemLedgEntryNos.Get(4), ItemLedgEntryNos.Get(5));
        VerifyEdgeInArray(Edges, 0, ItemLedgEntryNos.Get(5), ItemLedgEntryNos.Get(6));
    end;

    [Test]
    procedure TraceOutboundAppliedToProductionOutput()
    var
        ComponentItem: Record Item;
        ProdItem: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        Quantity: Integer;
        ItemLedgEntryNos: List of [Integer];
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [SCENARIO] Purchase component, produce a manufacturing item in a production order, sell the product, and build the cost graph

        // [GIVEN] Component item "CI" and a production item "PI". "PI" includes "CI" in its production BOM.
        LibraryInventory.CreateItem(ComponentItem);
        Quantity := LibraryRandom.RandInt(100);

        LibraryInventory.CreateItem(ProdItem);
        ProdItem.Validate("Production BOM No.", LibraryManufacturing.CreateCertifiedProductionBOM(ProdBOMHeader, ComponentItem."No.", Quantity));
        ProdItem.Modify(true);

        // [GIVEN] Create a production order for item "PI"
        LibraryManufacturing.CreateAndRefreshProductionOrder(
            ProductionOrder, ProductionOrder.Status::Released, ProductionOrder."Source Type"::Item, ProdItem."No.", Quantity);

        // [GIVEN] Post purchase of the component "CI"
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::Purchase, ComponentItem."No.", Quantity));

        // [GIVEN] Post production order consumption and output
        FindProdOrderLine(ProductionOrder, ProdOrderLine);
        LibraryPatterns.POSTConsumption(ProdOrderLine, ComponentItem, '', '', Quantity, WorkDate(), 0);
        LibraryPatterns.POSTOutput(ProdOrderLine, Quantity, WorkDate(), 0);
        CollectItemLedgerEntries(ItemLedgEntryNos, ComponentItem."No.", Enum::"Item Ledger Document Type"::" ", ProductionOrder."No.");
        CollectItemLedgerEntries(ItemLedgEntryNos, ProdItem."No.", Enum::"Item Ledger Document Type"::" ", ProductionOrder."No.");

        // [GIVEN] Sell the item "PI"
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::Sale, ProdItem."No.", Quantity));

        // [WHEN] Build cost graph
        CostApplicationTrace.BuildCostSourceGraph(ItemLedgEntryNos.Get(ItemLedgEntryNos.Count()), Nodes, Edges);

        // [THEN] Graph contains 4 nodes and 3 edges: Purchase -> Consumption -> Output -> Sale
        VerifyNodesList(ItemLedgEntryNos, Nodes);

        LibraryAssert.AreEqual(3, Edges.Count(), IncorrectEdgeCountErr);
        VerifyEdgeInArray(Edges, 2, ItemLedgEntryNos.Get(1), ItemLedgEntryNos.Get(2));
        VerifyEdgeInArray(Edges, 1, ItemLedgEntryNos.Get(2), ItemLedgEntryNos.Get(3));
        VerifyEdgeInArray(Edges, 0, ItemLedgEntryNos.Get(3), ItemLedgEntryNos.Get(4));
    end;

    [Test]
    procedure TraceOutboundAppliedToAssemblyOutput()
    var
        ComponentItem: Record Item;
        AsmItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        Quantity: Integer;
        ItemLedgEntryNos: List of [Integer];
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [SCENARIO] Purchase component, produce an assembled item in an assembly order, sell the product, and build the cost graph

        // [GIVEN] Component item "CI" and an assembly item "AI"
        LibraryInventory.CreateItem(ComponentItem);
        Quantity := LibraryRandom.RandInt(100);

        LibraryInventory.CreateItem(AsmItem);

        // [GIVEN] Create an assembly order for item "AI"
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate(), AsmItem."No.", '', Quantity, '');
        LibraryAssembly.CreateAssemblyLine(
            AssemblyHeader, AssemblyLine, AssemblyLine.Type::Item, ComponentItem."No.", ComponentItem."Base Unit of Measure", Quantity, 1, '');

        // [GIVEN] Post purchase of the component "CI"
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::Purchase, ComponentItem."No.", Quantity));

        // [GIVEN] Post the assembly order
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');
        CollectItemLedgerEntries(
            ItemLedgEntryNos, ComponentItem."No.", Enum::"Item Ledger Document Type"::"Posted Assembly", GetPostedAssemblyNo(AssemblyHeader."No."));
        CollectItemLedgerEntries(
            ItemLedgEntryNos, AsmItem."No.", Enum::"Item Ledger Document Type"::"Posted Assembly", GetPostedAssemblyNo(AssemblyHeader."No."));

        // [GIVEN] Sell the assembled quantity of the item "AI"
        ItemLedgEntryNos.Add(CreateAndPostItemJournalLine(Enum::"Item Journal Entry Type"::Sale, AsmItem."No.", Quantity));

        // [WHEN] Build cost graph
        CostApplicationTrace.BuildCostSourceGraph(ItemLedgEntryNos.Get(ItemLedgEntryNos.Count()), Nodes, Edges);

        // [THEN] Graph contains 4 nodes and 3 edges: Purchase -> Consumption -> Output -> Sale
        VerifyNodesList(ItemLedgEntryNos, Nodes);

        LibraryAssert.AreEqual(3, Edges.Count(), IncorrectEdgeCountErr);
        VerifyEdgeInArray(Edges, 2, ItemLedgEntryNos.Get(1), ItemLedgEntryNos.Get(2));
        VerifyEdgeInArray(Edges, 1, ItemLedgEntryNos.Get(2), ItemLedgEntryNos.Get(3));
        VerifyEdgeInArray(Edges, 0, ItemLedgEntryNos.Get(3), ItemLedgEntryNos.Get(4));
    end;

    local procedure CollectItemLedgerEntries(
        var ItemLedgerEntryNos: List of [Integer]; ItemNo: Code[20]; DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Document Type", DocumentType);
        ItemLedgerEntry.SetRange("Document No.", DocumentNo);
        ItemLedgerEntry.FindSet();
        repeat
            ItemLedgerEntryNos.Add(ItemLedgerEntry."Entry No.");
        until ItemLedgerEntry.Next() = 0;
    end;

    local procedure CreateAndPostItemJournalLine(EntryType: Enum "Item Ledger Entry Type"; ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[10]): Integer
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        LibraryInventory.CreateItemJnlLine(ItemJnlLine, EntryType, WorkDate(), ItemNo, Quantity, LocationCode);
        LibraryInventory.PostItemJournalLine(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");

        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.FindLast();

        exit(ItemLedgerEntry."Entry No.");
    end;

    local procedure CreateAndPostItemJournalLine(EntryType: Enum "Item Ledger Entry Type"; ItemNo: Code[20]; Quantity: Decimal): Integer
    begin
        exit(CreateAndPostItemJournalLine(EntryType, ItemNo, Quantity, ''));
    end;

    local procedure FindProdOrderLine(ProductionOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line")
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.FindFirst();
    end;

    local procedure GetNodeId(Node: JsonObject): Integer
    var
        NodeId: JsonToken;
    begin
        Node.Get('id', NodeId);
        exit(NodeId.AsValue().AsInteger());
    end;

    local procedure GetPostedAssemblyNo(OrderNo: Code[20]): Code[20]
    var
        PostedAsmHeader: Record "Posted Assembly Header";
    begin
        PostedAsmHeader.SetRange("Order No.", OrderNo);
        PostedAsmHeader.FindFirst();
        exit(PostedAsmHeader."No.");
    end;

    local procedure GetPostedTransferReceiptNo(TransferOrderNo: Code[20]): Code[20]
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        TransferReceiptHeader.SetRange("Transfer Order No.", TransferOrderNo);
        TransferReceiptHeader.FindFirst();
        exit(TransferReceiptHeader."No.");
    end;

    local procedure GetPostedTransferShipmentNo(TransferOrderNo: Code[20]): Code[20]
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        TransferShipmentHeader.SetRange("Transfer Order No.", TransferOrderNo);
        TransferShipmentHeader.FindFirst();
        exit(TransferShipmentHeader."No.");
    end;

    local procedure VerifyJsonObjectValue(ExpectedValue: Integer; ActualObject: JsonObject; KeyName: Text)
    var
        ActualValue: JsonToken;
    begin
        ActualObject.Get(KeyName, ActualValue);
        LibraryAssert.AreEqual(ExpectedValue, ActualValue.AsValue().AsInteger(), IncorrectNodeNoErr);
    end;

    local procedure VerifyEdge(ExpectedSource: Integer; ExpectedTarget: Integer; Edge: JsonObject)
    begin
        VerifyJsonObjectValue(ExpectedSource, Edge, 'source');
        VerifyJsonObjectValue(ExpectedTarget, Edge, 'target');
    end;

    local procedure VerifyEdgeInArray(Edges: JsonArray; EdgeNoToVerify: Integer; ExpectedSourceNode: Integer; ExpectedTargetNode: Integer)
    var
        Edge: JsonToken;
    begin
        Edges.Get(EdgeNoToVerify, Edge);
        VerifyEdge(ExpectedSourceNode, ExpectedTargetNode, Edge.AsObject());
    end;

    local procedure VerifyNodesList(ExpectedNodes: List of [Integer]; Nodes: JsonArray)
    var
        I: Integer;
        Node: JsonToken;
    begin
        LibraryAssert.AreEqual(ExpectedNodes.Count(), Nodes.Count(), IncorrectNodeCountErr);

        for I := 0 to ExpectedNodes.Count() - 1 do begin
            Nodes.Get(I, Node);
            LibraryAssert.IsTrue(ExpectedNodes.Contains(GetNodeId(Node.AsObject())), ItemLedgEntryMissingInNodeListErr);
        end;
    end;
}

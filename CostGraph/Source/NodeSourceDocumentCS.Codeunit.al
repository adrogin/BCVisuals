codeunit 50155 "Node Source Document CS"
{
    #region Pages

    procedure TryOpenSourceDocument(Node: JsonObject)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        JTok: JsonToken;
        DocumentType: Enum "Item Ledger Document Type";
        DocumentNo: Code[20];
    begin
#pragma warning disable AA0139 // Field name cannot exceed 80 characters
        if not Node.Get(GraphDataManagement.ConvertFieldNameToJsonToken(ItemLedgerEntry.FieldName("Document Type")), JTok) then
            exit;
        DocumentType := DocTypeText2Enum(JTok.AsValue().AsText());

        if not Node.Get(GraphDataManagement.ConvertFieldNameToJsonToken(ItemLedgerEntry.FieldName("Document No.")), JTok) then
            exit;
        DocumentNo := CopyStr(JTok.AsValue().AsText(), 1, MaxStrLen(ItemLedgerEntry."Document No."));
        OpenItemLedgEntrySourceDocument(DocumentType, DocumentNo);
#pragma warning restore
    end;

    local procedure OpenItemLedgEntrySourceDocument(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20])
    begin
        case DocumentType of
            Enum::"Item Ledger Document Type"::"Posted Assembly":
                OpenPostedAssembly(DocumentNo);
            Enum::"Item Ledger Document Type"::"Purchase Credit Memo":
                OpenPurchaseCreditMemo(DocumentNo);
            Enum::"Item Ledger Document Type"::"Purchase Receipt":
                OpenPurchaseReceipt(DocumentNo);
            Enum::"Item Ledger Document Type"::"Purchase Return Shipment":
                OpenPurchaseReturnShipment(DocumentNo);
            Enum::"Item Ledger Document Type"::"Sales Return Receipt":
                OpenSalesReturnReceipt(DocumentNo);
            Enum::"Item Ledger Document Type"::"Sales Shipment":
                OpenSalesShipment(DocumentNo);
            Enum::"Item Ledger Document Type"::"Transfer Shipment":
                OpenTransferShipment(DocumentNo);
            Enum::"Item Ledger Document Type"::"Transfer Receipt":
                OpenTransferReceipt(DocumentNo);
            Enum::"Item Ledger Document Type"::" ":
                OpenProductionOrder(DocumentNo);
        end;
    end;

    local procedure OpenProductionOrder(DocumentNo: Code[20])
    var
        ProductionOrder: Record "Production Order";
    begin
        ProductionOrder.SetFilter(Status, '%1|%2', Enum::"Production Order Status"::Released, Enum::"Production Order Status"::Finished);
        ProductionOrder.SetRange("No.", DocumentNo);

        // Item Ledger Document Type enum doesn't have a value for production order, the document type is blank.
        // Production orders are classified in a separate field (oh, this decades old ISV integration!)
        // Because of this the blank document type in item ledger entry can mean either production order or an entry posted directly from the item journal.
        // Since compound nodes data does not include production order classifiers, we have to guess. Can be worked around in the future by including prod. order information in graph nodes.
        if ProductionOrder.FindFirst() then
            PageManagement.PageRun(ProductionOrder);
    end;

    local procedure OpenPostedAssembly(DocumentNo: Code[20])
    var
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        PostedAssemblyHeader.Get(DocumentNo);
        PageManagement.PageRun(PostedAssemblyHeader);
    end;

    local procedure OpenPurchaseCreditMemo(DocumentNo: Code[20])
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        PurchCrMemoHdr.Get(DocumentNo);
        PageManagement.PageRun(PurchCrMemoHdr);
    end;

    local procedure OpenPurchaseReceipt(DocumentNo: Code[20])
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        PurchRcptHeader.Get(DocumentNo);
        PageManagement.PageRun(PurchRcptHeader);
    end;

    local procedure OpenPurchaseReturnShipment(DocumentNo: Code[20])
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        ReturnShipmentHeader.Get(DocumentNo);
        PageManagement.PageRun(ReturnShipmentHeader);
    end;

    local procedure OpenSalesReturnReceipt(DocumentNo: Code[20])
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
    begin
        ReturnReceiptHeader.Get(DocumentNo);
        PageManagement.PageRun(ReturnReceiptHeader);
    end;

    local procedure OpenSalesShipment(DocumentNo: Code[20])
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.Get(DocumentNo);
        PageManagement.PageRun(SalesShipmentHeader);
    end;

    local procedure OpenTransferShipment(DocumentNo: Code[20])
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        TransferShipmentHeader.Get(DocumentNo);
        PageManagement.PageRun(TransferShipmentHeader);
    end;

    local procedure OpenTransferReceipt(DocumentNo: Code[20])
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        TransferReceiptHeader.Get(DocumentNo);
        PageManagement.PageRun(TransferReceiptHeader);
    end;

    local procedure DocTypeText2Enum(DocType: Text): Enum "Item Ledger Document Type"
    var
        DocTypeLowerCase: Text;
        I: Integer;
    begin
        DocTypeLowerCase := DocType.ToLower();
        for I := 1 to Enum::"Item Ledger Document Type".Names().Count do
            if Enum::"Item Ledger Document Type".Names().Get(I).ToLower() = DocTypeLowerCase then
                exit(Enum::"Item Ledger Document Type".FromInteger(Enum::"Item Ledger Document Type".Ordinals().Get(I)));

        exit(Enum::"Item Ledger Document Type"::" ");
    end;

    procedure OpenItemLedgerEntryList(NodeId: Text)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.Get(NodeId2ItemLedgEntryNo(NodeId));
        Page.Run(Page::"Item Ledger Entries", ItemLedgerEntry);
    end;

    procedure NodeId2ItemLedgEntryNo(NodeId: Text) ItemLedgerEntryNo: Integer
    begin
        Evaluate(ItemLedgerEntryNo, NodeId);
    end;

    procedure RunCostTrace(TraceStartRecord: Variant; TraceDirection: Enum "Cost Trace Direction CS")
    var
        CostSource: Page "Cost Source CS";
    begin
        CostSource.SetTraceStart(TraceStartRecord);
        CostSource.SetTraceDirection(TraceDirection);
        CostSource.Run();
    end;

    #endregion Pages

    #region Cost source selection

    internal procedure SelectSource(var TraceStartRef: RecordRef): Boolean
    begin
        case TraceStartRef.Number of
            0:  // If the page is opened from the role center rather than from a document, the trace source is not defined, and we fall back to the default.
                exit(SelectItemLedgerEntry(TraceStartRef));
            Database::"Item Ledger Entry":
                exit(SelectItemLedgerEntry(TraceStartRef));
            Database::"Sales Shipment Header":
                exit(SelectSalesShipment(TraceStartRef));
            Database::"Purch. Rcpt. Header":
                exit(SelectPurchaseReceipt(TraceStartRef));
            Database::"Transfer Shipment Header":
                exit(SelectTransferShipment(TraceStartRef));
            Database::"Transfer Receipt Header":
                exit(SelectTransferReceipt(TraceStartRef));
            Database::"Assembly Header":
                exit(SelectAssemblyOrder(TraceStartRef));
            Database::"Production Order":
                SelectProductionOrder(TraceStartRef);
        end;
    end;

    local procedure SelectItemLedgerEntry(ItemLedgEntryRecRef: RecordRef): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if Page.RunModal(0, ItemLedgerEntry) <> Action::LookupOK then
            exit(false);

        ItemLedgEntryRecRef.GetTable(ItemLedgerEntry);
        exit(true);
    end;

    local procedure SelectSalesShipment(SalesShmptRecRef: RecordRef): Boolean
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if Page.RunModal(0, SalesShipmentHeader) <> Action::LookupOK then
            exit(false);

        SalesShmptRecRef.GetTable(SalesShipmentHeader);
        exit(true);
    end;

    local procedure SelectPurchaseReceipt(PurchRcptRecRef: RecordRef): Boolean
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if Page.RunModal(0, PurchRcptHeader) <> Action::LookupOK then
            exit(false);

        PurchRcptRecRef.GetTable(PurchRcptHeader);
        exit(true);
    end;

    local procedure SelectTransferShipment(TransferShpmtRecRef: RecordRef): Boolean
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        if Page.RunModal(0, TransferShipmentHeader) <> Action::LookupOK then
            exit(false);

        TransferShpmtRecRef.GetTable(TransferShipmentHeader);
        exit(true);
    end;

    local procedure SelectTransferReceipt(TransferRcptRecRef: RecordRef): Boolean
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        if Page.RunModal(0, TransferReceiptHeader) <> Action::LookupOK then
            exit(false);

        TransferRcptRecRef.GetTable(TransferReceiptHeader);
        exit(true);
    end;

    local procedure SelectAssemblyOrder(AssemblyOrderRecRef: RecordRef): Boolean
    var
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        if Page.RunModal(0, PostedAssemblyHeader) <> Action::LookupOK then
            exit(false);

        AssemblyOrderRecRef.GetTable(PostedAssemblyHeader);
        exit(true);
    end;

    local procedure SelectProductionOrder(ProductionRecRef: RecordRef): Boolean
    var
        ProductionOrder: Record "Production Order";
    begin
        if Page.RunModal(0, ProductionOrder) <> Action::LookupOK then
            exit(false);

        ProductionRecRef.GetTable(ProductionOrder);
        exit(true);
    end;

    #endregion Cost source selection

    var
        GraphDataManagement: Codeunit "Graph Data Management CS";
        PageManagement: Codeunit "Page Management";
}
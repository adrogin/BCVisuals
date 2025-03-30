page 50150 "Cost Source CS"
{
    Caption = 'Cost Source';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Settings)
            {
                Caption = 'Settings';

                field(EntryInfoControl; DataSourceInfo)
                {
                    Caption = 'Item Ledger Entry';
                    ToolTip = 'Select an item ledger entry to trace its cost source.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        if SelectSource(TraceStartRef) then
                            ShowCostApplicationGraph();
                    end;
                }
                field(CostTraceDirection; TraceDirection)
                {
                    Caption = 'Cost Trace Direction';
                    ToolTip = 'Select the cost tracing direction: whether the cost application will be traced backwards to the cost source for the selected entry, or forward to all entries whose cost depends on the selected entry.';

                    trigger OnValidate()
                    begin
                        ShowCostApplicationGraph();
                    end;
                }
                field(GraphLayoutControl; GraphLayout)
                {
                    Caption = 'Graph Layout';
                    ToolTip = 'Select the preferred graph layout which will be applied to the cost graph.';

                    trigger OnValidate()
                    begin
                        CurrPage.GraphControl.SetLayout(GraphViewController.GraphLayoutEnumToText(GraphLayout));
                    end;
                }
            }
            group(Graph)
            {
                Caption = 'Graph';

                usercontrol(GraphControl; "Graph View CS")
                {
                    ApplicationArea = Basic, Suite;

                    trigger ControlAddinReady()
                    begin
                        ShowCostApplicationGraph();
                    end;

                    trigger OnNodeClick(NodeId: Text)
                    begin
                        CostViewController.HandleNodeClick(NodeId, Nodes);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(NodeSets)
            {
                Caption = 'Node Sets';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select table fields to be displayed in node labels and tooltips.';
                Image = Comment;
                RunObject = page "Node Sets List CS";
            }
            action(GraphViewSetup)
            {
                Caption = 'Graph View Setup';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Configure the graph presentation parameters, such as node labels, tooltips, and graph element styles.';
                Image = Setup;
                RunObject = page "Graph View Setup CS";
            }
            action(DownloadGraph)
            {
                Caption = 'Download Graph';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Download the graph data.';
                Image = Download;
                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                    InStr: InStream;
                    FileName: Text;
                begin
                    TempBlob.CreateOutStream(OutStr);
                    Nodes.WriteTo(OutStr);

                    TempBlob.CreateInStream(InStr);
                    DownloadFromStream(InStr, '', '', '', FileName);
                end;
            }
        }
        area(Promoted)
        {
            actionref(PromotedGraphViewSetup; GraphViewSetup) { }
        }
    }

    trigger OnInit()
    begin
        GraphLayout := CostViewController.GetDefaultLayout();
        TraceDirection := Enum::"Cost Trace Direction CS"::Backward;
    end;

    local procedure SelectSource(var TraceStartRef: RecordRef): Boolean
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

    procedure SetTraceStart(TraceStart: Variant)
    begin
        TraceStartRef.GetTable(TraceStart);
    end;

    procedure SetTraceDirection(Direction: Enum "Cost Trace Direction CS")
    begin
        TraceDirection := Direction;
    end;

    local procedure FormatDataSourceInfo(TraceStartRef: RecordRef): Text
    var
        FieldNo: Integer;
    begin
        if TraceStartRef.Number = 0 then
            exit('');

        if TraceStartRef.Number = Database::"Item Ledger Entry" then
            exit(FormatItemLedgerEntryInfo(TraceStartRef));

        FieldNo := FindDocumentNoField(TraceStartRef.Number);
        if FieldNo = 0 then
            exit('');

        exit(StrSubstNo('%1 %2', TraceStartRef.Caption, TraceStartRef.Field(FieldNo).Value));
    end;

    local procedure FindDocumentNoField(TableNo: Integer): Integer
    var
        FieldRec: Record Field;
    begin
        FieldRec.SetRange(TableNo, TableNo);
        FieldRec.SetFilter(FieldName, 'No.');
        if not FieldRec.FindFirst() then
            exit(0);

        exit(FieldRec."No.");
    end;

    local procedure FormatItemLedgerEntryInfo(ItemLedgerEntryRecRef: RecordRef): Text
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        EntryNo: Integer;
        EntryInfoFormatTok: Label '%1: %2 %3', Comment = '%1: Entry No.; %2: Document Type; %3: Document No.';
    begin
        EntryNo := ItemLedgerEntryRecRef.Field(ItemLedgerEntry.FieldNo("Entry No.")).Value;
        ItemLedgerEntry.SetLoadFields("Document Type", "Document No.");
        ItemLedgerEntry.Get(EntryNo);
        exit(StrSubstNo(EntryInfoFormatTok, EntryNo, ItemLedgerEntry."Document Type", ItemLedgerEntry."Document No."));
    end;

    local procedure TraceCostApplication(TraceSource: RecordRef)
    begin
        if TraceSource.Number = 0 then
            exit;

        if TraceSource.Number = Database::"Item Ledger Entry" then
            TraceCostApplicationFromItemLedgerEntry(TraceSource)
        else
            TraceCostApplicationFromDocument(TraceSource.Number, TraceSource.Field(FindDocumentNoField(TraceSource.Number)).Value);
    end;

    local procedure TraceCostApplicationFromItemLedgerEntry(TraceSource: RecordRef)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        CostApplicationTrace: Codeunit "Cost Application Trace CS";
        EntryNo: Integer;
    begin
        EntryNo := TraceSource.Field(ItemLedgerEntry.FieldNo("Entry No.")).Value;
        if EntryNo = 0 then
            exit;

        CostApplicationTrace.BuildCostSourceGraph(EntryNo, TraceDirection, Nodes, Edges);
    end;

    local procedure TraceCostApplicationFromDocument(SourceTableNo: Integer; DocumentNo: Code[20])
    var
        CostApplicationTrace: Codeunit "Cost Application Trace CS";
    begin
        if SourceTableNo = 0 then
            exit;

        CostApplicationTrace.BuildCostSourceGraph(TableNo2DocumentType(SourceTableNo), DocumentNo, TraceDirection, Nodes, Edges);
    end;

    local procedure TableNo2DocumentType(TableNo: Integer): Enum "Item Ledger Document Type"
    begin
        case TableNo of
            Database::"Sales Shipment Header":
                exit(Enum::"Item Ledger Document Type"::"Sales Shipment");
            Database::"Purch. Rcpt. Header":
                exit(Enum::"Item Ledger Document Type"::"Purchase Receipt");
            Database::"Transfer Shipment Header":
                exit(Enum::"Item Ledger Document Type"::"Transfer Shipment");
            Database::"Transfer Receipt Header":
                exit(Enum::"Item Ledger Document Type"::"Transfer Receipt");
            Database::"Assembly Header":
                exit(Enum::"Item Ledger Document Type"::"Posted Assembly");
        end;

        exit(Enum::"Item Ledger Document Type"::" ");
    end;

    local procedure ShowCostApplicationGraph()
    begin
        Clear(Nodes);
        Clear(Edges);
        DataSourceInfo := FormatDataSourceInfo(TraceStartRef);
        TraceCostApplication(TraceStartRef);
        CostViewController.SetNodesData(Nodes);
        CurrPage.GraphControl.DrawGraphWithStyles(
            'controlAddIn', Nodes, Edges, GraphViewController.GetStylesAsJson(CostViewController.GetDefaultNodeSet()),
            GraphViewController.GraphLayoutEnumToText(GraphLayout));
        CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(CostViewController.GetNodeTooltipsArray(Nodes));
        CurrPage.GraphControl.CreateTooltips();
    end;

    var
        GraphViewController: Codeunit "Graph View Controller CS";
        CostViewController: Codeunit "Cost View Controller CS";
        TraceStartRef: RecordRef;
        GraphLayout: Enum "Graph Layout Name CS";
        DataSourceInfo: Text;
        TraceDirection: Enum "Cost Trace Direction CS";
        Nodes: JsonArray;
        Edges: JsonArray;
}

codeunit 50151 "Cost Graph CS"
{
    procedure SetNodesData(var Nodes: JsonArray)
    begin
        SetNodesData(Nodes, GetDefaultNodeSet());
    end;

    procedure SetNodesData(var Nodes: JsonArray; NodeSetCode: Code[20])
    var
        GroupNodes: Dictionary of [Text, JsonObject];
        GroupNodeId: Text;
        Node: JsonToken;
    begin
        foreach Node in Nodes do
            SetItemLedgEntryNodeProperties(Node, GroupNodes, NodeSetCode);

        foreach GroupNodeId in GroupNodes.Keys do
            Nodes.Add(GroupNodes.Get(GroupNodeId));
    end;

    procedure GetDefaultNodeSet(): Code[20]
    var
        GraphViewSetup: Record "Graph View Setup CS";
    begin
        GraphViewSetup.SetLoadFields("Cost Trace Node Set CS");
        GraphViewSetup.Get();
        exit(GraphViewSetup."Cost Trace Node Set CS");
    end;

    procedure GetDefaultLayout(): Enum "Graph Layout Name CS"
    var
        GraphViewSetup: Record "Graph View Setup CS";
    begin
        GraphViewSetup.SetLoadFields("Cost Trace Graph Layout CS");
        GraphViewSetup.Get();
        exit(GraphViewSetup."Cost Trace Graph Layout CS");
    end;

    procedure GetNodeTooltipsArray(Nodes: JsonArray): JsonArray
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecRef: RecordRef;
        TooltipsArray: JsonArray;
        Node: JsonToken;
    begin
        foreach Node in Nodes do
            if not GraphDataManagement.IsCompoundNode(Node.AsObject()) then
                if ItemLedgerEntry.Get(GraphDataManagement.GetNodeIdAsInteger(Node.AsObject())) then begin
                    RecRef.GetTable(ItemLedgerEntry);
                    TooltipsArray.Add(GraphDataManagement.GetNodeTooltip(RecRef, Format(ItemLedgerEntry."Entry No."), GetDefaultNodeSet()));
                end;

        exit(TooltipsArray);
    end;

    procedure SetItemLedgEntryNodeProperties(var Node: JsonToken; GroupNodes: Dictionary of [Text, JsonObject]; NodeSetCode: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecRef: RecordRef;
    begin
        ItemLedgerEntry.Get(GraphDataManagement.GetNodeIdAsInteger(Node.AsObject()));
        RecRef.GetTable(ItemLedgerEntry);
        GraphDataManagement.SetNodeProperties(Node, GroupNodes, RecRef, NodeSetCode);
    end;

    procedure SetItemLedgEntryNodeProperties(var Node: JsonObject; var GroupNodes: Dictionary of [Text, JsonObject]; NodeSetCode: Code[20])
    var
        NodeToken: JsonToken;
    begin
        NodeToken := Node.AsToken();
        SetItemLedgEntryNodeProperties(NodeToken, GroupNodes, NodeSetCode);
        Node := NodeToken.AsObject();
    end;

    local procedure IsEntryNoField(TableNo: Integer; FieldNo: Integer): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        exit((TableNo = Database::"Item Ledger Entry") and (FieldNo = ItemLedgerEntry.FieldNo("Entry No.")));
    end;

    procedure HandleNodeClick(ClickedNodeId: Text; GraphNodes: JsonArray)
    var
        GraphJsonArray: Codeunit "Graph Json Array CS";
        NodeSourceDocument: Codeunit "Node Source Document CS";
        Node: JsonObject;
    begin
        if not GraphJsonArray.SelectNode(ClickedNodeId, GraphNodes, Node) then
            exit;

        // Compound node is assumed to be mapped to a document. Although node grouping can be set up, configurable click behaviour is not supported (yet).
        if GraphDataManagement.IsCompoundNode(Node) then
            NodeSourceDocument.TryOpenSourceDocument(Node)
        else
            NodeSourceDocument.OpenItemLedgerEntryList(ClickedNodeId);
    end;

    internal procedure TableNo2DocumentType(TableNo: Integer): Enum "Item Ledger Document Type"
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
            Database::"Return Receipt Header":
                exit(Enum::"Item Ledger Document Type"::"Sales Return Receipt");
            Database::"Return Shipment Header":
                exit(Enum::"Item Ledger Document Type"::"Purchase Return Shipment");
            Database::"Assembly Header":
                exit(Enum::"Item Ledger Document Type"::"Posted Assembly");
        end;

        exit(Enum::"Item Ledger Document Type"::" ");
    end;

    #region Initial node info

    internal procedure FormatDataSourceInfo(TraceStartRef: RecordRef): Text
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

    internal procedure FindDocumentNoField(TableNo: Integer): Integer
    var
        FieldRec: Record Field;
    begin
        FieldRec.SetRange(TableNo, TableNo);
        FieldRec.SetFilter(FieldName, 'No.');
        if not FieldRec.FindFirst() then
            exit(0);

        exit(FieldRec."No.");
    end;

    #endregion Initial node info

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Graph Data Management CS", 'OnBeforeIsIdField', '', false, false)]
    local procedure IsIdField(TableNo: Integer; FieldNo: Integer; var IsHandled: Boolean; var IsId: Boolean)
    begin
        if TableNo <> Database::"Item Ledger Entry" then
            exit;

        IsHandled := true;
        IsId := IsEntryNoField(TableNo, FieldNo);
    end;

    var
        GraphDataManagement: Codeunit "Graph Data Management CS";
}
codeunit 50151 "Cost View Controller CS"
{
    procedure SetNodesData(var Nodes: JsonArray)
    var
        Node: JsonToken;
    begin
        foreach Node in Nodes do
            SetItemLedgEntryNodeProperties(Node);
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
        foreach Node in Nodes do begin
            ItemLedgerEntry.Get(GraphViewController.GetNodeIdAsInteger(Node.AsObject()));
            RecRef.GetTable(ItemLedgerEntry);
            TooltipsArray.Add(GraphViewController.GetNodeTooltip(RecRef, Format(ItemLedgerEntry."Entry No."), GetDefaultNodeSet()));
        end;

        exit(TooltipsArray);
    end;

    procedure SetItemLedgEntryNodeProperties(var Node: JsonToken)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecRef: RecordRef;
    begin
        ItemLedgerEntry.Get(GraphViewController.GetNodeIdAsInteger(Node.AsObject()));
        RecRef.GetTable(ItemLedgerEntry);
        GraphViewController.SetNodeProperties(Node, RecRef, GetDefaultNodeSet());
    end;

    procedure SetItemLedgEntryNodeProperties(var Node: JsonObject)
    var
        NodeToken: JsonToken;
    begin
        NodeToken := Node.AsToken();
        SetItemLedgEntryNodeProperties(NodeToken);
        Node := NodeToken.AsObject();
    end;

    local procedure IsEntryNoField(TableNo: Integer; FieldNo: Integer): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        exit((TableNo = Database::"Item Ledger Entry") and (FieldNo = ItemLedgerEntry.FieldNo("Entry No.")));
    end;

    procedure NodeId2ItemLedgEntryNo(NodeId: Text) ItemLedgerEntryNo: Integer
    begin
        Evaluate(ItemLedgerEntryNo, NodeId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Graph View Controller CS", 'OnBeforeIsIdField', '', false, false)]
    local procedure IsIdField(TableNo: Integer; FieldNo: Integer; var IsHandled: Boolean; var IsId: Boolean)
    begin
        IsHandled := true;
        IsId := IsEntryNoField(TableNo, FieldNo);
    end;

    var
        GraphViewController: Codeunit "Graph View Controller CS";
        GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
}
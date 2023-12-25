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

    procedure GetDefaultStyleSet(): Code[20]
    var
        GraphViewSetup: Record "Graph View Setup CS";
    begin
        GraphViewSetup.SetLoadFields("Cost Trace Style Set CS");
        GraphViewSetup.Get();
        exit(GraphViewSetup."Cost Trace Style Set CS");
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

    local procedure SetItemLedgEntryNodeProperties(var Node: JsonToken)
    var
        NodeSetField: Record "Node Set Field CS";
        ItemLedgerEntry: Record "Item Ledger Entry";
        RecRef: RecordRef;
        TableFieldRef: FieldRef;
    begin
        NodeSetField.SetRange("Node Set Code", GetDefaultNodeSet());
        NodeSetField.SetRange("Include in Node Data", true);

        ItemLedgerEntry.Get(GraphViewController.GetNodeIdAsInteger(Node.AsObject()));
        RecRef.GetTable(ItemLedgerEntry);

        // Not checking the return value here, since at least the Entry No. must be included
        NodeSetField.FindSet();
        repeat
            TableFieldRef := RecRef.Field(NodeSetField."Field No.");
            if TableFieldRef.Class = FieldClass::FlowField then
                TableFieldRef.CalcField();

            if not IsEntryNoField(NodeSetField) then  // Entry No. is always enabled by default as the node ID
                GraphViewController.AddFieldValueConvertedToFieldType(Node, NodeSetField."Json Property Name", TableFieldRef);
        until NodeSetField.Next() = 0;
    end;

    local procedure IsEntryNoField(NodeSetField: Record "Node Set Field CS"): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        exit((NodeSetField."Table No." = Database::"Item Ledger Entry") and (NodeSetField."Field No." = ItemLedgerEntry.FieldNo("Entry No.")));
    end;

    procedure NodeId2ItemLedgEntryNo(NodeId: Text) ItemLedgerEntryNo: Integer
    begin
        Evaluate(ItemLedgerEntryNo, NodeId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Graph View Controller CS", 'OnBeforeIsMandatoryField', '', false, false)]
    local procedure IsMandatoryField(NodeSetField: Record "Node Set Field CS"; var IsHandled: Boolean; var IsMandatory: Boolean)
    begin
        IsHandled := true;
        IsMandatory := IsEntryNoField(NodeSetField);
    end;

    var
        GraphViewController: Codeunit "Graph View Controller CS";
}
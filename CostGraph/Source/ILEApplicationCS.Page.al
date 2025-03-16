page 50151 "ILE Application CS"
{
    Caption = 'ILE Application';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Settings)
            {
                Caption = 'Settings';

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
                        InitializeGraph();
                    end;

                    trigger OnNodeClick(NodeId: Text)
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin
                        ItemLedgerEntry.Get(CostViewController.NodeId2ItemLedgEntryNo(NodeId));
                        Page.Run(Page::"Item Ledger Entries", ItemLedgerEntry);
                    end;

                    trigger OnEdgeDrawingDone(SourceNode: JsonObject; TargetNode: JsonObject; AddedEdge: JsonObject)
                    var
                        EdgesArray: JsonArray;
                    begin
                        if IsVirtualEdge(AddedEdge) then
                            exit;

                        if ApplyRec(AddedEdge) then begin
                            Edges.Add(AddedEdge);
                            RefreshNode(SourceNode);
                            RefreshNode(TargetNode);
                        end
                        else begin
                            EdgesArray.Add(AddedEdge);
                            CurrPage.GraphControl.RemoveEdges(EdgesArray);
                            Error(GetLastErrorText());
                        end;
                    end;

                    trigger OnEdgeRemoved(RemovedEdge: JsonObject)
                    var
                        EdgesArray: JsonArray;
                    begin
                        if IsVirtualEdge(RemovedEdge) then
                            exit;

                        if RemoveApplications(RemovedEdge) then begin
                            RemoveEdgeFromCollection(RemovedEdge.AsToken());
                            RefreshNode(GraphNodeDataMgt.GetValueFromObject(RemovedEdge.AsToken(), 'source'));
                            RefreshNode(GraphNodeDataMgt.GetValueFromObject(RemovedEdge.AsToken(), 'target'));
                        end
                        else begin
                            EdgesArray.Add(RemovedEdge);
                            CurrPage.GraphControl.AddEdges(EdgesArray);
                            Error(GetLastErrorText());
                        end;
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
        }
        area(Processing)
        {
            group(View)
            {
                Caption = 'View';
                Image = ViewDetails;

                action(EnableEditMode)
                {
                    Caption = 'Edit';
                    ToolTip = 'In edit mode, you can add or remove graph edges. Start dragging a node to draw a new edge. Right-click on an edge to delete it.';
                    ApplicationArea = Basic, Suite;
                    Visible = not IsEditModeEnabled;
                    Image = Edit;

                    trigger OnAction()
                    begin
                        IsEditModeEnabled := not IsEditModeEnabled;
                        CurrPage.GraphControl.SetEditModeEnabled(IsEditModeEnabled);
                        CurrPage.GraphControl.InitializeDefaultContextMenu();
                    end;
                }
                action(DisableEditMode)
                {
                    Caption = 'View';
                    ToolTip = 'In view mode, nodes can be rearranged manually, but adding or removing edges is not allowed. Switch to edit mode to draw or delete graph edges.';
                    ApplicationArea = Basic, Suite;
                    Visible = IsEditModeEnabled;
                    Image = View;

                    trigger OnAction()
                    begin
                        IsEditModeEnabled := not IsEditModeEnabled;
                        CurrPage.GraphControl.SetEditModeEnabled(IsEditModeEnabled);
                        CurrPage.GraphControl.DestroyContextMenu();
                    end;
                }
            }
            group(Functions)
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(Reapply)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rea&pply';
                    Image = "Action";
                    ToolTip = 'Reapply entries that you have removed.';

                    trigger OnAction()
                    begin
                        ApplnWorksheetEdit.UnblockItems();
                        ApplnWorksheetEdit.ReapplyAll();
                    end;
                }
                action(UndoApplications)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Undo Manual Changes';
                    Image = Restore;
                    ToolTip = 'Undo your previous application change.';

                    trigger OnAction()
                    begin
                        if ApplnWorksheetEdit.ApplicationLogIsEmpty() then begin
                            Message(NothingToRevertMsg);
                            exit;
                        end;

                        if Confirm(RevertAllQst) then begin
                            ApplnWorksheetEdit.UndoApplications();
                            Message(RevertCompletedMsg);
                        end;

                        InitializeGraph();
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(EnableEditPromoted; EnableEditMode) { }
            actionref(DisableEditPromoted; DisableEditMode) { }
            actionref(ReapplyPromoted; Reapply) { }
            actionref(UndoPromoted; UndoApplications) { }
        }
    }

    trigger OnInit()
    begin
        GraphLayout := GraphLayout::Breadthfirst;
    end;

    local procedure InitializeGraph()
    begin
        Clear(Nodes);
        Clear(Edges);
        ApplnWorksheetEdit.BuildApplnWorksheetGraph(FilteredItemLedgEntry, Nodes, Edges);
        CostViewController.SetNodesData(Nodes);
        CurrPage.GraphControl.DrawGraphWithStyles('controlAddIn', Nodes, Edges, GraphViewController.GetStylesAsJson(CostViewController.GetDefaultNodeSet()));
        CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(CostViewController.GetNodeTooltipsArray(Nodes));
        CurrPage.GraphControl.CreateTooltips();
        CurrPage.GraphControl.InitializeEdgeHandles();  // Initialize necessary components to support edit mode
        CurrPage.GraphControl.SetEditModeEnabled(IsEditModeEnabled);
    end;

    local procedure IsVirtualEdge(Edge: JsonObject): Boolean
    var
        NodeFound: Boolean;
    begin
        // When the drawing gesture starts Cytoscape EdgeHandles creates a virtual graph node and an edge from the source node to the new virtual node.
        // If the gesture completes successfully on a real node, a new edge connecting the source and the target nodes is created, and the virtual pair is deleted.
        // All these events must be ignored and not trigger cost application actions. The vrtual node has a GUID identifier which will not be found in the cost graph data.

        if not TrySelectNodeToken(Edge.AsToken(), NodeFound) then
            exit(true);

        exit(not NodeFound);
    end;

    [TryFunction]
    local procedure TrySelectNodeToken(Edge: JsonToken; var NodeFound: Boolean)
    var
        SelectedNode: JsonToken;
        NodeSelectorTok: Label '$[?(@.id==%1)].id', Comment = '%1: ID of the node to search', Locked = true;
    begin
        NodeFound := Nodes.SelectToken(StrSubstNo(NodeSelectorTok, GraphNodeDataMgt.GetValueFromObject(Edge, 'target')), SelectedNode);
    end;

    procedure SetItemLedgEntryFilters(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        FilteredItemLedgEntry.CopyFilters(ItemLedgerEntry);
    end;

    local procedure RemoveEdgeFromCollection(Edge: JsonToken)
    var
        SelectedEdge: JsonToken;
        EdgeSelectorTok: Label '$[?(@.source=%1 && @.target=%2)]', Comment = '%1: ID of the source node, %2: ID of the target node', Locked = true;
    begin
        if Edges.SelectToken(StrSubstNo(EdgeSelectorTok, GraphNodeDataMgt.GetValueFromObject(Edge, 'source'), GraphNodeDataMgt.GetValueFromObject(Edge, 'target')), SelectedEdge) then
            Edges.RemoveAt(Edges.IndexOf(SelectedEdge));
    end;

    local procedure RefreshNode(NodeId: Text)
    var
        Node: JsonObject;
    begin
        Node.Add('id', NodeId);
        CostViewController.SetItemLedgEntryNodeProperties(Node);
        CurrPage.GraphControl.SetNodeData(GraphNodeDataMgt.GetValueFromObject(Node.AsToken(), 'id'), Node);
    end;

    local procedure RefreshNode(Node: JsonObject)
    begin
        RefreshNode(GraphNodeDataMgt.GetValueFromObject(Node.AsToken(), 'id'));
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if ApplnWorksheetEdit.AnyTouchedEntries() then begin
            if not Confirm(CloseWindowQst) then
                exit(false);

            ApplnWorksheetEdit.UnblockItems();
            ApplnWorksheetEdit.ReapplyAll();
        end;

        exit(true);
    end;

    procedure ApplyRec(GraphEdge: JsonObject): Boolean
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
        ApplyItemLedgerEntries: Codeunit "Apply Item Ledger Entries CS";
        IsOK: Boolean;
    begin
        ApplyItemLedgerEntries.SetContext(ApplnWorksheetEdit);
        ApplnWorksheetEdit.WriteJsonObjectToBuffer(GraphEdge, TempJsonBuffer);
        IsOK := ApplyItemLedgerEntries.Run(TempJsonBuffer);
        ApplyItemLedgerEntries.GetContext(ApplnWorksheetEdit);
        exit(IsOK);
    end;

    procedure RemoveApplications(GraphEdge: JsonObject): Boolean
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
        UnapplyItemLedgerEntries: Codeunit "Unapply Item Ledger Entries CS";
        IsOK: Boolean;
    begin
        UnapplyItemLedgerEntries.SetContext(ApplnWorksheetEdit);
        ApplnWorksheetEdit.WriteJsonObjectToBuffer(GraphEdge, TempJsonBuffer);
        IsOK := UnapplyItemLedgerEntries.Run(TempJsonBuffer);
        UnapplyItemLedgerEntries.GetContext(ApplnWorksheetEdit);
        exit(IsOK);
    end;

    var
        FilteredItemLedgEntry: Record "Item Ledger Entry";
        GraphViewController: Codeunit "Graph View Controller CS";
        CostViewController: Codeunit "Cost View Controller CS";
        GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
        ApplnWorksheetEdit: Codeunit "Appln. Worksheet - Edit CS";
        GraphLayout: Enum "Graph Layout Name CS";
        IsEditModeEnabled: Boolean;
        Nodes, Edges : JsonArray;
        CloseWindowQst: Label 'After the window is closed, the system will check for and reapply open entries.\Do you want to close the window?';
        RevertAllQst: Label 'Are you sure that you want to undo all changes?';
        NothingToRevertMsg: Label 'Nothing to undo.';
        RevertCompletedMsg: Label 'The changes have been undone.';
}

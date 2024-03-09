page 50151 "ILE Application CS"
{
    Caption = 'ILE Application';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Tasks;

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

                        if ApplnWorksheetEdit.ApplyRec(AddedEdge) then begin
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

                        if ApplnWorksheetEdit.RemoveApplications(RemovedEdge) then begin
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
            action(Save)
            {
                Caption = 'Save';
                ToolTip = 'Save the application changes.';
                ApplicationArea = Basic, Suite;
                Image = Save;

                trigger OnAction()
                begin
                    CurrPage.GraphControl.RequestGraphData();
                end;
            }
        }
        area(Promoted)
        {
            actionref(EnableEditPromoted; EnableEditMode) { }
            actionref(DisableEditPromoted; DisableEditMode) { }
            actionref(SavePromoted; Save) { }
            actionref(PromotedGraphViewSetup; GraphViewSetup) { }
        }
    }

    trigger OnInit()
    begin
        GraphLayout := GraphLayout::Breadthfirst;
    end;

    trigger OnOpenPage()
    begin
        ApplnWorksheetEdit.BuildApplnWorksheetGraph(FilteredItemLedgEntry, Nodes, Edges);
        CostViewController.SetNodesData(Nodes);
        CurrPage.GraphControl.DrawGraphWithStyles('controlAddIn', Nodes, Edges, GraphViewController.GetStylesAsJson(CostViewController.GetDefaultNodeSet()));
        CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(CostViewController.GetNodeTooltipsArray(Nodes));
        CurrPage.GraphControl.CreateTooltips();
        CurrPage.GraphControl.InitializeEdgeHandles();  // Initialize necessary components to support edit mode
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
        RefreshNode(Node);
    end;

    local procedure RefreshNode(Node: JsonObject)
    var
        UpdatedNode: JsonObject;
    begin
        UpdatedNode.Add('id', GraphNodeDataMgt.GetValueFromObject(Node.AsToken(), 'id'));
        CostViewController.SetItemLedgEntryNodeProperties(UpdatedNode);
        CurrPage.GraphControl.SetNodeData(GraphNodeDataMgt.GetValueFromObject(Node.AsToken(), 'id'), UpdatedNode);
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
}

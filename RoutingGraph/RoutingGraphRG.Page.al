page 50250 "Routing Graph RG"
{
    PageType = Card;
    Caption = 'Routing Graph';
    ApplicationArea = Manufacturing;

    layout
    {
        area(Content)
        {
            group(Graph)
            {
                Caption = 'Graph';

                usercontrol(GraphControl; "Graph View CS")
                {
                    ApplicationArea = Manufacturing;

                    trigger OnGraphDataReceived(Nodes: JsonArray; Edges: JsonArray)
                    begin
                        RoutingGraph.UpdatRoutingFromGraph(Nodes, Edges, RoutingNo, VersionCode);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EnableEditMode)
            {
                Caption = 'Edit';
                ToolTip = 'In edit mode, you can add or remove graph edges. Start dragging a node to draw a new edge. Right-click on an edge to delete it.';
                ApplicationArea = Manufacturing;
                Visible = not IsEditModeEnabled and RoutingIsEditable;
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
                ApplicationArea = Manufacturing;
                Visible = IsEditModeEnabled and RoutingIsEditable;
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
                ToolTip = 'Save the edits in the routing.';
                ApplicationArea = Manufacturing;
                Image = Save;
                Visible = RoutingIsEditable;

                trigger OnAction()
                begin
                    CurrPage.GraphControl.RequestGraphData();
                end;
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

        area(Promoted)
        {
            actionref(EnableEditPromoted; EnableEditMode) { }
            actionref(DisableEditPromoted; DisableEditMode) { }
            actionref(SavePromoted; Save) { }
            actionref(GraphViewSetupPromoted; GraphViewSetup) { }
        }
    }

    trigger OnOpenPage()
    begin
        RoutingGraph.SetNodesData(Nodes, RoutingNo, VersionCode);
        CurrPage.GraphControl.DrawGraphWithStyles('controlAddIn', Nodes, Edges, GraphViewController.GetStylesAsJson(RoutingGraph.GetDefaultStyleSet()));
        CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(RoutingGraph.GetNodeTooltipsArray(Nodes, RoutingNo, VersionCode));
        CurrPage.GraphControl.CreateTooltips();
        CurrPage.GraphControl.InitializeEdgeHandles();  // Initialize necessary components to support edit mode
    end;

    procedure SetRouting(NewRoutingNo: Code[20]; NewVersionCode: Code[20])
    begin
        RoutingNo := NewRoutingNo;
        VersionCode := NewVersionCode;
        RoutingGraph.BuildGraph(RoutingNo, VersionCode, Nodes, Edges);
        SetNodeData(Nodes, Edges);
        RoutingIsEditable := RoutingGraph.GetIsRoutingEditable(RoutingNo, VersionCode);
    end;

    procedure SetNodeData(NewNodes: JsonArray; NewEdges: JsonArray)
    begin
        Nodes := NewNodes;
        Edges := NewEdges;
    end;

    var
        RoutingGraph: Codeunit "Routing Graph RG";
        GraphViewController: Codeunit "Graph View Controller CS";
        RoutingNo: Code[20];
        VersionCode: Code[20];
        Nodes: JsonArray;
        Edges: JsonArray;
        IsEditModeEnabled: Boolean;
        RoutingIsEditable: Boolean;
}

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
                    var
                        NodeSourceDocument: Codeunit "Node Source Document CS";
                    begin
                        if NodeSourceDocument.SelectSource(TraceStartRef) then
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
                        CurrPage.GraphControl.SetLayout(GraphDataManagement.GraphLayoutEnumToText(GraphLayout));
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
                        CostGraph.HandleNodeClick(NodeId, GraphNodes);
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
                    GraphNodes.WriteTo(OutStr);

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
        GraphLayout := CostGraph.GetDefaultLayout();
        TraceDirection := Enum::"Cost Trace Direction CS"::Backward;
    end;


    procedure SetTraceStart(TraceStart: Variant)
    begin
        TraceStartRef.GetTable(TraceStart);
    end;

    procedure SetTraceDirection(Direction: Enum "Cost Trace Direction CS")
    begin
        TraceDirection := Direction;
    end;

    local procedure ShowCostApplicationGraph()
    var
        CostApplicatinoTrace: Codeunit "Cost Application Trace CS";
    begin
        Clear(GraphNodes);
        Clear(GraphEdges);
        DataSourceInfo := CostGraph.FormatDataSourceInfo(TraceStartRef);
        CostApplicatinoTrace.TraceFromSourceRecord(TraceStartRef, TraceDirection, GraphNodes, GraphEdges);
        CostGraph.SetNodesData(GraphNodes);
        CurrPage.GraphControl.DrawGraphWithStyles(
            'controlAddIn', GraphNodes, GraphEdges, GraphDataManagement.GetStylesAsJson(CostGraph.GetDefaultNodeSet()),
            GraphDataManagement.GraphLayoutEnumToText(GraphLayout));
        CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(CostGraph.GetNodeTooltipsArray(GraphNodes));
        CurrPage.GraphControl.CreateTooltips();
    end;

    var
        GraphDataManagement: Codeunit "Graph Data Management CS";
        CostGraph: Codeunit "Cost Graph CS";
        TraceStartRef: RecordRef;
        GraphLayout: Enum "Graph Layout Name CS";
        DataSourceInfo: Text;
        TraceDirection: Enum "Cost Trace Direction CS";
        GraphNodes: JsonArray;
        GraphEdges: JsonArray;
}

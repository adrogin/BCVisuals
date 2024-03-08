controladdin "Graph View CS"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedHeight = 500;
    MinimumHeight = 500;

    Scripts = 'Scripts/dist/main.js';

    procedure DrawGraph(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray);
    procedure DrawGraphWithStyles(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray; Styles: JsonArray);
    procedure SetLayout(LayoutName: Text);
    procedure SetNodeTooltipText(NodeId: Text; TooltipText: Text);
    procedure SetTooltipTextOnMultipleNodes(Tooltips: JsonArray);
    procedure CreateTooltips();
    procedure CreateTextElements();
    procedure InitializeEdgeHandles();
    procedure SetEditModeEnabled(IsEnabled: Boolean);
    procedure InitializeDefaultContextMenu();
    procedure DestroyContextMenu();
    procedure RequestGraphData();
    procedure AddNodes(NodesToAdd: JsonArray);
    procedure AddEdges(EdgesToAdd: JsonArray);
    procedure RemoveNodes(NodesToRemove: JsonArray);
    procedure RemoveEdges(EdgesToRemove: JsonArray);

    event OnNodeClick(NodeId: Text);
    event OnGraphDataReceived(Nodes: JsonArray; Edges: JsonArray);
    event OnEdgeDrawingStart(SourceNode: JsonObject);
    event OnEdgeDrawingStop(SourceNode: JsonObject);
    event OnEdgeDrawingDone(SourceNode: JsonObject; TargetNode: JsonObject);
    event OnEdgeDrawingCanceled(SourceNode: JsonObject; CanceledTargets: JsonArray);
    event OnNodeCreated(NewNode: JsonObject);
    event OnEdgeCreated(NewEdge: JsonObject);
    event OnNodeRemoved(RemovedNode: JsonObject);
    event OnEdgeRemoved(RemovedEdge: JsonObject);
}
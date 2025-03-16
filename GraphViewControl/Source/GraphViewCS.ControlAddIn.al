controladdin "Graph View CS"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedHeight = 500;
    MinimumHeight = 500;

    Scripts = 'Scripts/dist/main.js';
    StartupScript = 'Scripts/src/startup.js';

    procedure AddNodes(NodesToAdd: JsonArray);
    procedure AddEdges(EdgesToAdd: JsonArray);
    procedure CreateTextElements();
    procedure CreateTooltips();
    procedure DestroyContextMenu();
    procedure DrawGraph(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray);
    procedure DrawGraphWithStyles(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray; Styles: JsonArray);
    procedure InitializeDefaultContextMenu();
    procedure InitializeEdgeHandles();
    procedure RemoveEdges(EdgesToRemove: JsonArray);
    procedure RemoveNodes(NodesToRemove: JsonArray);
    procedure RequestGraphData();
    procedure SetLayout(LayoutName: Text);
    procedure SetNodeData(NodeId: Text; NodeData: JsonObject);
    procedure SetNodeLabel(NodeId: Text; Label: Text);
    procedure SetNodeTooltipText(NodeId: Text; TooltipText: Text);
    procedure SetTooltipTextOnMultipleNodes(Tooltips: JsonArray);
    procedure SetEditModeEnabled(IsEnabled: Boolean);

    event ControlAddinReady();
    event OnNodeClick(NodeId: Text);
    event OnGraphDataReceived(Nodes: JsonArray; Edges: JsonArray);
    event OnEdgeDrawingStart(SourceNode: JsonObject);
    event OnEdgeDrawingStop(SourceNode: JsonObject);
    event OnEdgeDrawingDone(SourceNode: JsonObject; TargetNode: JsonObject; AddedEdge: JsonObject);
    event OnEdgeDrawingCanceled(SourceNode: JsonObject; CanceledTargets: JsonArray);
    event OnNodeCreated(NewNode: JsonObject);
    event OnEdgeCreated(NewEdge: JsonObject);
    event OnNodeRemoved(RemovedNode: JsonObject);
    event OnEdgeRemoved(RemovedEdge: JsonObject);
}

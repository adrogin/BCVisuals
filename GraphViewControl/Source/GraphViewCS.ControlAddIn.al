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

    event OnNodeClick(NodeId: Text);
    event OnGraphDataReceived(Nodes: JsonArray; Edges: JsonArray);
    event OnEdgeCreated(SourceNode: JsonObject; TargetNode: JsonObject);
}
controladdin "Graph View CS"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedHeight = 500;
    MinimumHeight = 500;

    StyleSheets =
        'CSS/style.css',
        'node_modules/tippy.js/dist/tippy.css',
        'node_modules/tippy.js/themes/light.css',
        'node_modules/tippy.js/themes/material.css';

    Scripts = 'Scripts/dist/main.js';

    procedure DrawGraph(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray);
    procedure DrawGraphWithStyles(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray; Styles: JsonArray);
    procedure SetLayout(LayoutName: Text);
    procedure SetNodeTooltipText(NodeId: Text; TooltipText: Text);
    procedure SetTooltipTextOnMultipleNodes(Tooltips: JsonArray);
    procedure BindTooltipEvents();
    procedure CreateTooltips();
    procedure CreateTextElements();
    procedure InitializeEdgeHandles();
    procedure SetEditModeEnabled(IsEnabled: Boolean);
    procedure InitializeDefaultContextMenu();
    procedure DestroyContextMenu();
    procedure RequestGraphData();

    event OnNodeClick(NodeId: Text);
    event OnGraphDataReceived(Nodes: JsonArray; Edges: JsonArray);
}
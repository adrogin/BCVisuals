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

    Scripts =
        'node_modules/cytoscape/dist/cytoscape.min.js',
        'node_modules/@popperjs/core/dist/umd/popper.js',
        'node_modules/cytoscape-popper/cytoscape-popper.js',
        'node_modules/tippy.js/dist/tippy-bundle.umd.min.js',
        'Scripts/cytograph.js',
        'Scripts/index.js';

    procedure DrawGraph(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray);
    procedure SetLayout(LayoutName: Text);
    procedure SetNodeTooltipText(NodeId: Text; TooltipText: Text);
    procedure SetTooltipTextOnMultipleNodes(Tooltips: JsonArray);
    procedure BindTooltipEvents();
    procedure CreateTooltips();

    event OnNodeClick(NodeId: Text);
}
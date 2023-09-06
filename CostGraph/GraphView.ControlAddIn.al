controladdin "Graph View"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedHeight = 500;
    MinimumHeight = 500;
    StyleSheets = 'CSS\style.css';
    Scripts =
        // 'https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.26.0/cytoscape.min.js',
        // 'https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.11.8/umd/popper.min.js',
        // 'https://cdnjs.cloudflare.com/ajax/libs/cytoscape-popper/1.0.7/cytoscape-popper.min.js',
        'node_modules/cytoscape/dist/cytoscape.min.js',
        'node_modules/@popperjs/core/dist/umd/popper.js',
        'node_modules/cytoscape-popper/cytoscape-popper.js',
        'Scripts/cytograph.js',
        'Scripts/index.js';

    procedure DrawGraph(ContainerElementName: Text; Nodes: JsonArray; Edges: JsonArray);
    procedure SetLayout(LayoutName: Text);
    procedure SetNodeTooltip(NodeId: Text; Tooltip: Text);
    procedure SetTooltipsOnMultipleNodes(Tooltips: JsonArray);
}
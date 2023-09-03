controladdin "Graph View"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedHeight = 500;
    StyleSheets = 'CSS\style.css';
    StartupScript = 'Scripts\index.js';

    procedure RenderGraph(Nodes: JsonArray; Edges: JsonArray);
}
codeunit 50102 "Graph Json Array CS"
{
    procedure ContainsNode(Nodes: JsonArray; NodeId: Variant): Boolean
    var
        SelectedNode: JsonObject;
    begin
        exit(SelectNode(NodeId, Nodes, SelectedNode));
    end;

    procedure AddNodeToArray(var Nodes: JsonArray; NodeId: Text)
    var
        Node: JsonObject;
    begin
        Node.Add('id', NodeId);
        Nodes.Add(Node);
    end;

    procedure AddNodeToArray(var Nodes: JsonArray; NodeId: Integer)
    var
        Node: JsonObject;
    begin
        Node.Add('id', Format(NodeId));
        Nodes.Add(Node);
    end;

    procedure AddEdgeToArray(var Edges: JsonArray; SourceNodeId: Text; TargetNodeId: Text)
    var
        Edge: JsonObject;
    begin
        Edge.Add('source', Format(SourceNodeId));
        Edge.Add('target', Format(TargetNodeId));
        Edges.Add(Edge);
    end;

    procedure AddEdgeToArray(var Edges: JsonArray; SourceNodeId: Integer; TargetNodeId: Integer)
    var
        Edge: JsonObject;
    begin
        Edge.Add('source', Format(SourceNodeId));
        Edge.Add('target', Format(TargetNodeId));
        Edges.Add(Edge);
    end;

    procedure MergeNodeArrays(var TargetArray: JsonArray; SourceArray: JsonArray)
    var
        Element: JsonToken;
        TargetElements: List of [Text];
    begin
        foreach Element in TargetArray do
            targetElements.Add(GraphJsonObject.GetValueFromObject(Element, 'id'));

        foreach Element in SourceArray do
            if not TargetElements.Contains(GraphJsonObject.GetValueFromObject(Element, 'id')) then
                TargetArray.Add(Element);
    end;

    procedure MergeEdgeArrays(var TargetArray: JsonArray; SourceArray: JsonArray)
    var
        Element: JsonToken;
        TargetElements: List of [Text];
        SeparatorChar: Char;
    begin
        SeparatorChar := 0;

        foreach Element in TargetArray do
            targetElements.Add(GraphJsonObject.GetValueFromObject(Element, 'source') + SeparatorChar + GraphJsonObject.GetValueFromObject(Element, 'target'));

        foreach Element in SourceArray do
            if not TargetElements.Contains(GraphJsonObject.GetValueFromObject(Element, 'source') + SeparatorChar + GraphJsonObject.GetValueFromObject(Element, 'target')) then
                TargetArray.Add(Element);
    end;

    procedure SelectNode(NodeId: Variant; Nodes: JsonArray; var SelectedNode: JsonObject): Boolean
    var
        NodeSelectorTok: Label '$[?(@.id==''%1'')]', Comment = '%1: ID of the node to search', Locked = true;
        Node: JsonToken;
        NodeFound: Boolean;
    begin
        NodeFound := Nodes.SelectToken(StrSubstNo(NodeSelectorTok, NodeId), Node);

        if not NodeFound then
            exit(false);

        SelectedNode := Node.AsObject();
        exit(true);
    end;

    [TryFunction]
    procedure TrySelectNode(Nodes: JsonArray; NodeId: Text; var NodeFound: Boolean)
    var
        SelectedNode: JsonToken;
        NodeSelectorTok: Label '$[?(@.id==''%1'')].id', Comment = '%1: ID of the node to search', Locked = true;
    begin
        NodeFound := Nodes.SelectToken(StrSubstNo(NodeSelectorTok, NodeId), SelectedNode);
    end;

    procedure RemoveEdgeFromCollection(Edges: JsonArray; EdgeToRemove: JsonToken)
    var
        SelectedEdge: JsonToken;
        EdgeSelectorTok: Label '$[?(@.source=''%1'' && @.target=''%2'')]', Comment = '%1: ID of the source node, %2: ID of the target node', Locked = true;
    begin
        if Edges.SelectToken(StrSubstNo(EdgeSelectorTok, GraphJsonObject.GetValueFromObject(EdgeToRemove, 'source'), GraphJsonObject.GetValueFromObject(EdgeToRemove, 'target')), SelectedEdge) then
            Edges.RemoveAt(Edges.IndexOf(SelectedEdge));
    end;

    var
        GraphJsonObject: Codeunit "Graph Json Object CS";
}

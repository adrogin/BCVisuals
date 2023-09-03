codeunit 50100 "Cost Source Trace"
{
    procedure BuildCostSourceGraph(ILENo: Integer; var Nodes: JsonArray; var Edges: JsonArray)
    var
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        AddNodeToArray(Nodes, ILENo);

        ItemApplicationEntry.SetLoadFields("Inbound Item Entry No.");
        ItemApplicationEntry.SetRange("Outbound Item Entry No.", ILENo);
        if ItemApplicationEntry.FindSet() then
            repeat
                AddEdgeToArray(Edges, ItemApplicationEntry."Inbound Item Entry No.", ILENo);
                BuildCostSourceGraph(ItemApplicationEntry."Inbound Item Entry No.", Nodes, Edges);
            until ItemApplicationEntry.Next() = 0;
    end;

    local procedure AddNodeToArray(var Nodes: JsonArray; NodeId: Integer)
    begin
        Nodes.Add(NodeId);
    end;

    local procedure AddEdgeToArray(var Edges: JsonArray; SourceNodeId: Integer; TargetNodeId: Integer)
    var
        Edge: JsonObject;
    begin
        Edge.Add(Format(SourceNodeId), Format(TargetNodeId));
        Edges.Add(Edge);
    end;
}

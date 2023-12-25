codeunit 50250 "Routing Graph RG"
{
    procedure BuildGraph(RoutingNo: Code[20]; VersionCode: Code[20]; var Nodes: JsonArray; var Edges: JsonArray)
    var
        RoutingLine: Record "Routing Line";
    begin
        Clear(VisitedNodes);
        RoutingLine.SetLoadFields("Routing No.", "Version Code", "Operation No.", "Previous Operation No.", "Next Operation No.");
        RoutingLine.SetRange("Routing No.", RoutingNo);
        RoutingLine.SetRange("Version Code", VersionCode);
        RoutingLine.SetRange("Previous Operation No.", '');
        if RoutingLine.FindSet() then
            repeat
                TraceRoutingFromNode(Nodes, Edges, RoutingLine);
            until RoutingLine.Next() = 0;
    end;

    procedure UpdatRoutingFromGraph(var Nodes: JsonArray; var Edges: JsonArray; RoutingNo: Code[20]; VersionCode: Code[20])
    begin
        CreateRoutingLinesFromNodes(Nodes, RoutingNo, VersionCode);
        UpdatOperationSequenceFromEdges(Nodes, Edges, RoutingNo, VersionCode);
    end;

    procedure GetDefaultNodeSet(): Code[20]
    var
        GraphViewSetup: Record "Graph View Setup CS";
    begin
        GraphViewSetup.SetLoadFields("Routing Node Set RG");
        GraphViewSetup.Get();
        exit(GraphViewSetup."Routing Node Set RG");
    end;

    procedure GetDefaultStyleSet(): Code[20]
    var
        GraphViewSetup: Record "Graph View Setup CS";
    begin
        GraphViewSetup.SetLoadFields("Routing Style Set RG");
        GraphViewSetup.Get();
        exit(GraphViewSetup."Routing Style Set RG");
    end;

    procedure GetDefaultLayout(): Enum "Graph Layout Name CS"
    var
        GraphViewSetup: Record "Graph View Setup CS";
    begin
        GraphViewSetup.SetLoadFields("Routing Graph Layout RG");
        GraphViewSetup.Get();
        exit(GraphViewSetup."Routing Graph Layout RG");
    end;

    procedure SetNodesData(var Nodes: JsonArray; RoutingNo: Code[20]; VersionCode: Code[20])
    var
        Node: JsonToken;
    begin
        foreach Node in Nodes do
            SetRoutingNodeProperties(Node, RoutingNo, VersionCode);
    end;

    procedure GetIsRoutingEditable(RoutingNo: Code[20]; VersionCode: Code[20]): Boolean
    var
        RoutingHeader: Record "Routing Header";
        RoutingVersion: Record "Routing Version";
        Status: Enum "Routing Status";
    begin
        if VersionCode <> '' then begin
            RoutingVersion.Get(RoutingNo, VersionCode);
            Status := RoutingVersion.Status;
        end
        else begin
            RoutingHeader.Get(RoutingNo);
            Status := RoutingHeader.Status;
        end;

        exit(Status <> Status::Certified);
    end;

    local procedure CreateRoutingLinesFromNodes(var Nodes: JsonArray; RoutingNo: Code[20]; VersionCode: Code[20])
    var
        RoutingLine: Record "Routing Line";
        Node: JsonToken;
        OperationNo: Code[20];
    begin
        foreach Node in Nodes do begin
            OperationNo := CopyStr(GetValueFromObject(Node, 'id'), 1, MaxStrLen(OperationNo));

            if not RoutingLineExists(RoutingNo, VersionCode, OperationNo) then begin
                RoutingLine.Validate("Routing No.", RoutingNo);
                RoutingLine.Validate("Version Code", VersionCode);
                RoutingLine.Validate("Operation No.", OperationNo);
                RoutingLine.Insert(true);
            end;
        end;
    end;

    local procedure UpdatOperationSequenceFromEdges(Nodes: JsonArray; Edges: JsonArray; RoutingNo: Code[20]; VersionCode: Code[20])
    var
        RoutingLine: Record "Routing Line";
        NextOperations: Dictionary of [Text, Text];
        PreviousOperations: Dictionary of [Text, Text];
        OperationFilter: Text;
        Node: JsonToken;
        LineUpdated: Boolean;
    begin
        BuildOperationSequence(Edges, PreviousOperations, NextOperations);

        RoutingLine.SetRange("Routing No.", RoutingNo);
        RoutingLine.SetRange("Version Code", VersionCode);
        RoutingLine.ModifyAll("Next Operation No.", '');
        RoutingLine.ModifyAll("Previous Operation No.", '');

        foreach Node in Nodes do begin
            RoutingLine.Get(RoutingNo, VersionCode, GetValueFromObject(Node, 'id'));
            LineUpdated := false;

            if NextOperations.Get(RoutingLine."Operation No.", OperationFilter) then begin
                RoutingLine.Validate("Next Operation No.", OperationFilter);
                LineUpdated := true;
            end;

            if PreviousOperations.Get(RoutingLine."Operation No.", OperationFilter) then begin
                RoutingLine.Validate("Previous Operation No.", OperationFilter);
                LineUpdated := true;
            end;

            if LineUpdated then
                RoutingLine.Modify(true);
        end;
    end;

    local procedure BuildOperationSequence(var Edges: JsonArray; var PreviousOperations: Dictionary of [Text, Text]; var NextOperations: Dictionary of [Text, Text])
    var
        SourceNodeId: Text;
        TargetNodeId: Text;
        Edge: JsonToken;
    begin
        Clear(PreviousOperations);
        Clear(NextOperations);

        foreach Edge in Edges do begin
            SourceNodeId := GetValueFromObject(Edge, 'source');
            TargetNodeId := GetValueFromObject(Edge, 'target');
            AddEdgeToSequenceDictionary(SourceNodeId, TargetNodeId, NextOperations);
            AddEdgeToSequenceDictionary(TargetNodeId, SourceNodeId, PreviousOperations);
        end;
    end;

    local procedure TraceRoutingFromNode(var Nodes: JsonArray; var Edges: JsonArray; RoutingLine: Record "Routing Line")
    var
        NextRoutingLine: Record "Routing Line";
    begin
        if VisitedNodes.Contains(RoutingLine."Operation No.") then
            exit;

        AddNodeToArray(Nodes, RoutingLine."Operation No.");

        if RoutingLine."Next Operation No." = '' then
            exit;

        NextRoutingLine.SetLoadFields("Routing No.", "Version Code", "Operation No.", "Previous Operation No.", "Next Operation No.");
        NextRoutingLine.SetRange("Routing No.", RoutingLine."Routing No.");
        NextRoutingLine.SetRange("Version Code", RoutingLine."Version Code");
        NextRoutingLine.SetFilter("Operation No.", RoutingLine."Next Operation No.");
        if NextRoutingLine.FindSet() then
            repeat
                AddEdgeToArray(Edges, RoutingLine."Operation No.", NextRoutingLine."Operation No.");
                TraceRoutingFromNode(Nodes, Edges, NextRoutingLine);
            until NextRoutingLine.Next() = 0;
    end;

    local procedure AddNodeToArray(var Nodes: JsonArray; NodeId: Code[30])
    var
        Node: JsonObject;
    begin
        Node.Add('id', NodeId);
        Nodes.Add(Node);

        VisitedNodes.Add(NodeId);
    end;

    local procedure AddEdgeToArray(var Edges: JsonArray; SourceNodeId: Code[30]; TargetNodeId: Code[30])
    var
        Edge: JsonObject;
    begin
        Edge.Add('source', Format(SourceNodeId));
        Edge.Add('target', Format(TargetNodeId));
        Edges.Add(Edge);
    end;

    local procedure AddEdgeToSequenceDictionary(FromNodeId: Text; ToNodeId: Text; var SequenceDictionary: Dictionary of [Text, Text])
    var
        NodeFilterTok: Label '%1|%2', Comment = '%1: Source node ID, %2: Target node ID.';
    begin
        if SequenceDictionary.ContainsKey(FromNodeId) then
            SequenceDictionary.Set(FromNodeId, StrSubstNo(NodeFilterTok, SequenceDictionary.Get(FromNodeId), ToNodeId))
        else
            SequenceDictionary.Add(FromNodeId, ToNodeId)
    end;

    local procedure GetValueFromObject(JObj: JsonToken; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        JObj.AsObject().Get(KeyName, Token);
        exit(Token.AsValue().AsText());
    end;

    local procedure RoutingLineExists(RoutingNo: Code[20]; VersionCode: Code[20]; OperationNo: Code[30]): Boolean
    var
        RoutingLine: Record "Routing Line";
    begin
        RoutingLine.SetRange("Routing No.", RoutingNo);
        RoutingLine.SetRange("Version Code", VersionCode);
        RoutingLine.SetRange("Operation No.", OperationNo);
        exit(not RoutingLine.IsEmpty());
    end;

    procedure GetNodeTooltipsArray(Nodes: JsonArray; RoutingNo: Code[20]; VersionCode: Code[20]): JsonArray
    var
        RoutingLine: Record "Routing Line";
        RecRef: RecordRef;
        TooltipsArray: JsonArray;
        Node: JsonToken;
    begin
        foreach Node in Nodes do begin
            RoutingLine.Get(RoutingNo, VersionCode, GraphViewController.GetNodeIdAsText(Node.AsObject()));
            RecRef.GetTable(RoutingLine);
            TooltipsArray.Add(GraphViewController.GetNodeTooltip(RecRef, Format(RoutingLine."Operation No."), GetDefaultNodeSet()));
        end;

        exit(TooltipsArray);
    end;

    local procedure SetRoutingNodeProperties(var Node: JsonToken; RoutingNo: Code[20]; VersionCode: Code[20])
    var
        NodeSetField: Record "Node Set Field CS";
        RoutingLine: Record "Routing Line";
        RecRef: RecordRef;
        TableFieldRef: FieldRef;
    begin
        NodeSetField.SetRange("Node Set Code", GetDefaultNodeSet());
        NodeSetField.SetRange("Include in Node Data", true);

        RoutingLine.Get(RoutingNo, VersionCode, GraphViewController.GetNodeIdAsText(Node.AsObject()));
        RecRef.GetTable(RoutingLine);

        // Not checking the return value here, since at least the Entry No. must be included
        NodeSetField.FindSet();
        repeat
            TableFieldRef := RecRef.Field(NodeSetField."Field No.");
            if TableFieldRef.Class = FieldClass::FlowField then
                TableFieldRef.CalcField();

            GraphViewController.AddFieldValueConvertedToFieldType(Node, NodeSetField."Json Property Name", TableFieldRef);
        until NodeSetField.Next() = 0;
    end;

    var
        GraphViewController: Codeunit "Graph View Controller CS";
        VisitedNodes: List of [Code[30]];
}
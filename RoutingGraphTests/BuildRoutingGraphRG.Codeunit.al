codeunit 60250 "Build Routing Graph RG"
{
    Subtype = Test;

    var
        NodesArrayMustBeEmptyErr: Label 'Nodes array must be empty.';
        EdgesArrayMustBeEmptyErr: Label 'Edges array must be empty.';
        NodesArrayMustContainXEntriesErr: Label 'Nodes array must contain %1 entries.', Comment = '%1: The expected number of entries.';
        EdgesArrayMustContainXEntriesErr: Label 'Edges array must contain %1 entries.', Comment = '%1: The expected number of entries.';
        NodeMustBeInArrayErr: Label 'Node %1 must be in the array.', Comment = '%1: Node ID';
        EdgePointingToWrongNodesErr: Label 'Edge is pointing to wrong nodes';
        EdgeMissingInArrayErr: Label 'Edge from %1 to %2 is missing in the array.', Comment = '%1, %2: IDs of the source and target nodes of the edge.';
        WrongNextOperationErr: Label 'Next operation is incorrect in routing line.';
        WrongPreviousOperationErr: Label 'Previous operation is incorrect in routing line.';

    [Test]
    procedure BuildGraphFromEmptyRoutingReturnEmptyGraph()
    var
        RoutingHeader: Record "Routing Header";
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [GIVEN]
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        // [WHEN]
        RoutingGraph.BuildGraph(RoutingHeader."No.", '', Nodes, Edges);

        // [THEN]
        LibraryAssert.AreEqual(0, Nodes.Count(), NodesArrayMustBeEmptyErr);
        LibraryAssert.AreEqual(0, Edges.Count(), EdgesArrayMustBeEmptyErr);
    end;

    [Test]
    procedure BuildGraphRoutingWithOneOperation()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [GIVEN]
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryManufacturing.CreateRoutingLine(
            RoutingHeader, RoutingLine, '', LibraryUtility.GenerateGUID(), RoutingLine.Type::"Work Center", CreateWorkCenterNo());
        LibraryManufacturing.UpdateRoutingStatus(RoutingHeader, RoutingHeader.Status::Certified);

        // [WHEN]
        RoutingGraph.BuildGraph(RoutingHeader."No.", '', Nodes, Edges);

        // [THEN]
        LibraryAssert.AreEqual(1, Nodes.Count(), StrSubstNo(NodesArrayMustContainXEntriesErr, 1));
        LibraryAssert.AreEqual(0, Edges.Count(), EdgesArrayMustBeEmptyErr);

        LibraryAssert.AreEqual(RoutingLine."Operation No.", GetNodeValue(Nodes, 0), StrSubstNo(NodeMustBeInArrayErr, RoutingLine."Operation No."));
    end;

    [Test]
    procedure BuildGraphSerialRoutingThreeSequentialOperations()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
        I: Integer;
    begin
        // [GIVEN]
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        for I := 1 to 3 do
            LibraryManufacturing.CreateRoutingLine(
                RoutingHeader, RoutingLine, '', LibraryUtility.GenerateGUID(), RoutingLine.Type::"Work Center", CreateWorkCenterNo());

        LibraryManufacturing.UpdateRoutingStatus(RoutingHeader, RoutingHeader.Status::Certified);

        // [WHEN]
        RoutingGraph.BuildGraph(RoutingHeader."No.", '', Nodes, Edges);

        // [THEN]
        VerifyRoutingNodes(RoutingHeader."No.", '', Nodes);
        VerifySerialRoutingEdges(RoutingHeader."No.", '', Edges);
    end;

    [Test]
    procedure BuildRoutingGraphTwoParallelOperations()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLines: array[4] of Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
        I: Integer;
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Parallel);

        // [GIVEN] 
        for I := 1 to ArrayLen(RoutingLines) do
            LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLines[I], '', Format(I), RoutingLines[I].Type::"Work Center", CreateWorkCenterNo());

        SetNextOperationNo(RoutingLines[1], StrSubstNo('%1|%2', RoutingLines[2]."Operation No.", RoutingLines[3]."Operation No."));
        SetNextOperationNo(RoutingLines[2], RoutingLines[4]."Operation No.");
        SetNextOperationNo(RoutingLines[3], RoutingLines[4]."Operation No.");

        LibraryManufacturing.UpdateRoutingStatus(RoutingHeader, RoutingHeader.Status::Certified);

        // [WHEN]
        RoutingGraph.BuildGraph(RoutingHeader."No.", '', Nodes, Edges);

        // [THEN]
        VerifyRoutingNodes(RoutingHeader."No.", '', Nodes);

        LibraryAssert.AreEqual(4, Edges.Count(), StrSubstNo(EdgesArrayMustContainXEntriesErr, 4));
        AssertEdgeInArray(RoutingLines[1]."Operation No.", RoutingLines[2]."Operation No.", Edges);
        AssertEdgeInArray(RoutingLines[1]."Operation No.", RoutingLines[3]."Operation No.", Edges);
        AssertEdgeInArray(RoutingLines[2]."Operation No.", RoutingLines[4]."Operation No.", Edges);
        AssertEdgeInArray(RoutingLines[3]."Operation No.", RoutingLines[4]."Operation No.", Edges);
    end;

    [Test]
    procedure UpdateSerialRoutingFromGraph()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
        I: Integer;
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        for I := 1 to 3 do
            Nodes.Add(CreateNodeObject(Format(I)));

        Edges.Add(CreateEdgeObject(GetNodeValue(Nodes, 0), GetNodeValue(Nodes, 1)));
        Edges.Add(CreateEdgeObject(GetNodeValue(Nodes, 1), GetNodeValue(Nodes, 2)));

        RoutingGraph.UpdatRoutingFromGraph(Nodes, Edges, RoutingHeader."No.", '');

        RoutingLine.SetRange("Routing No.", RoutingHeader."No.");
        LibraryAssert.RecordCount(RoutingLine, Nodes.Count());

#pragma warning disable AA0139 
        VerifyOperationSequence(RoutingHeader."No.", '', GetNodeValue(Nodes, 0), '', GetNodeValue(Nodes, 1));
        VerifyOperationSequence(RoutingHeader."No.", '', GetNodeValue(Nodes, 1), GetNodeValue(Nodes, 0), GetNodeValue(Nodes, 2));
        VerifyOperationSequence(RoutingHeader."No.", '', GetNodeValue(Nodes, 2), GetNodeValue(Nodes, 1), '');
#pragma warning restore
    end;

    [Test]
    procedure UpdateParallelRoutingFromGraph()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
        I: Integer;
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Parallel);

        for I := 1 to 4 do
            Nodes.Add(CreateNodeObject(Format(I)));

        Edges.Add(CreateEdgeObject(GetNodeValue(Nodes, 0), GetNodeValue(Nodes, 1)));
        Edges.Add(CreateEdgeObject(GetNodeValue(Nodes, 0), GetNodeValue(Nodes, 2)));
        Edges.Add(CreateEdgeObject(GetNodeValue(Nodes, 1), GetNodeValue(Nodes, 3)));
        Edges.Add(CreateEdgeObject(GetNodeValue(Nodes, 2), GetNodeValue(Nodes, 3)));

        RoutingGraph.UpdatRoutingFromGraph(Nodes, Edges, RoutingHeader."No.", '');

        RoutingLine.SetRange("Routing No.", RoutingHeader."No.");
        LibraryAssert.RecordCount(RoutingLine, Nodes.Count());

#pragma warning disable AA0139
        VerifyOperationSequence(RoutingHeader."No.", '', GetNodeValue(Nodes, 0), '', StrSubstNo('%1|%2', GetNodeValue(Nodes, 1), GetNodeValue(Nodes, 2)));
        VerifyOperationSequence(RoutingHeader."No.", '', GetNodeValue(Nodes, 1), GetNodeValue(Nodes, 0), GetNodeValue(Nodes, 3));
        VerifyOperationSequence(RoutingHeader."No.", '', GetNodeValue(Nodes, 2), GetNodeValue(Nodes, 0), GetNodeValue(Nodes, 3));
        VerifyOperationSequence(RoutingHeader."No.", '', GetNodeValue(Nodes, 3), StrSubstNo('%1|%2', GetNodeValue(Nodes, 1), GetNodeValue(Nodes, 2)), '');
#pragma warning restore
    end;

    [Test]
    procedure UpdateRoutingWithExistingLines()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
        I: Integer;
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine, '', '1', RoutingLine.Type::"Work Center", CreateWorkCenterNo());
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine, '', '3', RoutingLine.Type::"Work Center", CreateWorkCenterNo());

        for I := 1 to 4 do
            Nodes.Add(CreateNodeObject(Format(I)));

        for I := 1 to 3 do
            Edges.Add(CreateEdgeObject(Format(I), Format(I + 1)));

        RoutingGraph.UpdatRoutingFromGraph(Nodes, Edges, RoutingHeader."No.", '');

        RoutingLine.SetRange("Routing No.", RoutingHeader."No.");
        LibraryAssert.RecordCount(RoutingLine, 4);

        VerifyOperationSequence(RoutingHeader."No.", '', '1', '', '2');
        VerifyOperationSequence(RoutingHeader."No.", '', '2', '1', '3');
        VerifyOperationSequence(RoutingHeader."No.", '', '3', '2', '4');
        VerifyOperationSequence(RoutingHeader."No.", '', '4', '3', '');
    end;

    [Test]
    procedure GraphFromDraftRoutingWithMultipleDisconnectedNodes()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLines: array[3] of Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
        I: Integer;
    begin
        // [GIVEN] Create a routing header with 3 lines, operation sequence is not assigned
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        for I := 1 to ArrayLen(RoutingLines) do
            LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLines[I], '', Format(I), RoutingLines[I].Type::"Work Center", CreateWorkCenterNo());

        RoutingGraph.BuildGraph(RoutingHeader."No.", '', Nodes, Edges);

        LibraryAssert.AreEqual(ArrayLen(RoutingLines), Nodes.Count(), StrSubstNo(NodesArrayMustContainXEntriesErr, ArrayLen(RoutingLines)));
        LibraryAssert.AreEqual(0, Edges.Count(), EdgesArrayMustBeEmptyErr);
    end;

    [Test]
    procedure UpdateRoutingWithDefinedSequence()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLines: array[2] of Record "Routing Line";
        Nodes: JsonArray;
        Edges: JsonArray;
    begin
        // [GIVEN] A routing with two operations "01" and "02"
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLines[1], '', '01', RoutingLines[1].Type::"Work Center", CreateWorkCenterNo());
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLines[2], '', '02', RoutingLines[2].Type::"Work Center", CreateWorkCenterNo());

        // [GIVEN] Operation sequence is set up. Operation "02" follows "01". Both Next Operation No. and Previous Operation No. are set.
        SetNextOperationNo(RoutingLines[1], '02');
        SetPreviousOperationNo(RoutingLines[2], '01');

        // [GIVEN] Graph with two nodes corresponding to operations "02" and "02" and one edge pointing from "02" to "01".
        Nodes.Add(CreateNodeObject('01'));
        Nodes.Add(CreateNodeObject('02'));
        Edges.Add(CreateEdgeObject('02', '01'));

        // [WHEN] Update the routing from graph data
        RoutingGraph.UpdatRoutingFromGraph(Nodes, Edges, RoutingHeader."No.", '');

        // [THEN] The operations flow in the routing is reversed, "02" is the first operation, "01" is last
        VerifyOperationSequence(RoutingHeader."No.", '', RoutingLines[1]."Operation No.", RoutingLines[2]."Operation No.", '');
        VerifyOperationSequence(RoutingHeader."No.", '', RoutingLines[2]."Operation No.", '', RoutingLines[1]."Operation No.");
    end;

    local procedure AssertEdgeInArray(SourceNodeId: Code[30]; TargetNodeId: Code[30]; var Edges: JsonArray)
    var
        Edge: JsonToken;
        SourceNodeValue: JsonToken;
        TargetNodeValue: JsonToken;
    begin
        foreach Edge in Edges do begin
            Edge.AsObject().Get('source', SourceNodeValue);
            Edge.AsObject().Get('target', TargetNodeValue);

            if (SourceNodeValue.AsValue().AsText() = SourceNodeId) and (TargetNodeValue.AsValue().AsText() = TargetNodeId) then
                exit;
        end;

        Error(EdgeMissingInArrayErr, SourceNodeId, TargetNodeId);
    end;

    local procedure CreateEdgeObject(SourceNodeId: Text; TargetNodeId: Text): JsonObject
    var
        Edge: JsonObject;
    begin
        Edge.Add('source', SourceNodeId);
        Edge.Add('target', TargetNodeId);
        exit(Edge);
    end;

    local procedure CreateNodeObject(NodeId: Text): JsonObject
    var
        Node: JsonObject;
    begin
        Node.Add('id', NodeId);
        exit(Node);
    end;

    local procedure CreateWorkCenterNo(): Code[20]
    var
        WorkCenter: Record "Work Center";
    begin
        LibraryManufacturing.CreateWorkCenter(WorkCenter);
        exit(WorkCenter."No.");
    end;

    local procedure GetNodeValue(var Nodes: JsonArray; Index: Integer): Text
    var
        Node: JsonToken;
        NodeValue: JsonToken;
    begin
        Nodes.Get(Index, Node);
        Node.AsObject().Get('id', NodeValue);
        exit(NodeValue.AsValue().AsText());
    end;

    local procedure SetNextOperationNo(var RoutingLine: Record "Routing Line"; NextOperationNo: Code[30])
    begin
        RoutingLine.Validate("Next Operation No.", NextOperationNo);
        RoutingLine.Modify(true);
    end;

    local procedure SetPreviousOperationNo(var RoutingLine: Record "Routing Line"; PreviousOperationNo: Code[30])
    begin
        RoutingLine.Validate("Previous Operation No.", PreviousOperationNo);
        RoutingLine.Modify(true);
    end;

    local procedure VerifyOperationSequence(RoutingNo: Code[20]; VersionCode: Code[20]; OperationNo: Code[30]; ExpectedPrevOperationNo: Code[30]; ExpectedNextOperationNo: Code[30])
    var
        RoutingLine: Record "Routing Line";
    begin
        RoutingLine.Get(RoutingNo, VersionCode, OperationNo);
        LibraryAssert.AreEqual(ExpectedPrevOperationNo, RoutingLine."Previous Operation No.", WrongPreviousOperationErr);
        LibraryAssert.AreEqual(ExpectedNextOperationNo, RoutingLine."Next Operation No.", WrongNextOperationErr);
    end;

    local procedure VerifyRoutingNodes(RoutingNo: Code[20]; VersionCode: Code[20]; var Nodes: JsonArray)
    var
        RoutingLine: Record "Routing Line";
        Node: JsonToken;
        NodeValue: JsonToken;
    begin
        RoutingLine.Reset();
        RoutingLine.SetRange("Routing No.", RoutingNo);
        RoutingLine.SetRange("Version Code", VersionCode);
        LibraryAssert.AreEqual(RoutingLine.Count(), Nodes.Count(), StrSubstNo(NodesArrayMustContainXEntriesErr, RoutingLine.Count()));

        foreach Node in Nodes do begin
            Node.AsObject().Get('id', NodeValue);
            RoutingLine.SetRange("Operation No.", NodeValue.AsValue().AsText());
            LibraryAssert.RecordIsNotEmpty(RoutingLine);
        end;
    end;

    local procedure VerifySerialRoutingEdges(RoutingNo: Code[20]; VersionCode: Code[20]; var Edges: JsonArray)
    var
        RoutingLine: Record "Routing Line";
        Edge: JsonToken;
        NodeValue: JsonToken;
    begin
        RoutingLine.Reset();
        RoutingLine.SetRange("Routing No.", RoutingNo);
        RoutingLine.SetRange("Version Code", VersionCode);
        LibraryAssert.AreEqual(RoutingLine.Count() - 1, Edges.Count(), StrSubstNo(EdgesArrayMustContainXEntriesErr, RoutingLine.Count() - 1));

        foreach Edge in Edges do begin
            Edge.AsObject().Get('source', NodeValue);
            RoutingLine.Get(RoutingNo, VersionCode, NodeValue.AsValue().AsText());

            Edge.AsObject().Get('target', NodeValue);
            LibraryAssert.AreEqual(RoutingLine."Next Operation No.", NodeValue.AsValue().AsText(), EdgePointingToWrongNodesErr);
        end;
    end;

    var
        RoutingGraph: Codeunit "Routing Graph RG";
        LibraryManufacturing: Codeunit "Library - Manufacturing";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAssert: Codeunit "Library Assert";
}
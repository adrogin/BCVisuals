codeunit 60101 "Graph Data Mgt. Tests CS"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure ConvertAlphanumericFieldNameToJsonToken()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable2: Record "Node Data Test Table 2 CS";
        NodeSetField: Record "Node Set Field CS";
        ConvertedName: Text;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table 2 CS", NodeDataTestTable2.FieldNo(AlphanumericFieldName123));
        NodeSetField.Get(NodeSet.Code, NodeDataTestTable2.FieldNo(AlphanumericFieldName123));
        ConvertedName := GraphDataManagement.ConvertFieldNameToJsonToken(NodeSetField);

        LibraryAssert.AreEqual('AlphanumericFieldName123', ConvertedName, IncorrectTokenConversionErr);
    end;

    [Test]
    procedure ConvertFieldNameWithNonAlphanumericCharacters()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable2: Record "Node Data Test Table 2 CS";
        NodeSetField: Record "Node Set Field CS";
        ConvertedName: Text;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table 2 CS", NodeDataTestTable2.FieldNo("Non-Alphanumeric Field Name"));
        NodeSetField.Get(NodeSet.Code, NodeDataTestTable2.FieldNo("Non-Alphanumeric Field Name"));
        ConvertedName := GraphDataManagement.ConvertFieldNameToJsonToken(NodeSetField);

        LibraryAssert.AreEqual('Non-Alphanumeric_Field_Name', ConvertedName, IncorrectTokenConversionErr);
    end;

    [Test]
    procedure ValidateNodeSetPrimaryKeyFieldJsonTokenUpdated()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable2: Record "Node Data Test Table 2 CS";
        NodeSetField: Record "Node Set Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table 2 CS");

        NodeSetField."Node Set Code" := NodeSet.Code;
        NodeSetField."Table No." := NodeSet."Table No.";
        NodeSetField.Validate("Field No.", NodeDataTestTable2.FieldNo("PK Guid Field"));

        LibraryAssert.AreEqual('id', NodeSetField."Json Property Name", IncorrectTokenConversionErr);
    end;

    [Test]
    procedure ValidateNodeSetNonPKFieldJsonTokenUpdated()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable2: Record "Node Data Test Table 2 CS";
        NodeSetField: Record "Node Set Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table 2 CS");

        NodeSetField."Node Set Code" := NodeSet.Code;
        NodeSetField."Table No." := NodeSet."Table No.";
        NodeSetField.Validate("Field No.", NodeDataTestTable2.FieldNo(AlphanumericFieldName123));

        LibraryAssert.AreEqual('AlphanumericFieldName123', NodeSetField."Json Property Name", IncorrectTokenConversionErr);
    end;

    [Test]
    procedure FormatSelectorTextWithTwoFilters()
    var
        NodeSet: Record "Node Set CS";
        Style: Record "Style CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");
        Style.Get(LibraryGraphView.CreateStyleWithSelector(Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Code Field")));
        LibraryGraphView.CreateSelectorFilter(Style."Selector Code", NodeDataTestTable.FieldNo("Decimal Field"));

        SetSelectorFilterValue(Style."Selector Code", NodeDataTestTable.FieldNo("Code Field"), '="test"');
        SetSelectorFilterValue(Style."Selector Code", NodeDataTestTable.FieldNo("Decimal Field"), '>0');

        LibraryAssert.AreEqual('node[Code_Field="test"][Decimal_Field>0]', GraphDataManagement.FormatSelectorText(Style."Selector Code"), IncorrectSelectorFilterErr);
    end;

    [Test]
    procedure AddTextNodeToArray()
    var
        Nodes: JsonArray;
    begin
        GraphJsonArray.AddNodeToArray(Nodes, 'NodeA');
        GraphJsonArray.AddNodeToArray(Nodes, 'NodeB');
        GraphJsonArray.AddNodeToArray(Nodes, 'NodeC');

        LibraryAssert.AreEqual(3, Nodes.Count, IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeA', GetValueAsText(GetArrayElement(Nodes, 0), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeB', GetValueAsText(GetArrayElement(Nodes, 1), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeC', GetValueAsText(GetArrayElement(Nodes, 2), 'id'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure AddIntNodeToArray()
    var
        Nodes: JsonArray;
    begin
        GraphJsonArray.AddNodeToArray(Nodes, 1);
        GraphJsonArray.AddNodeToArray(Nodes, 2);
        GraphJsonArray.AddNodeToArray(Nodes, 3);

        LibraryAssert.AreEqual(3, Nodes.Count, IncorrectArrayElementErr);
        LibraryAssert.AreEqual(1, GetValueAsInteger(GetArrayElement(Nodes, 0), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual(2, GetValueAsInteger(GetArrayElement(Nodes, 1), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual(3, GetValueAsInteger(GetArrayElement(Nodes, 2), 'id'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure CollectNodeCompositionProperties()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        TestRecRef: RecordRef;
        Properties: Dictionary of [Text, Text];
        PropertyValue: Text;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Decimal Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("PK Integer Field"));

        NodeDataTestTable := CreateNodeDataTestRec();

        TestRecRef.GetTable(NodeDataTestTable);
        Properties := GraphDataManagement.GetNodeCompositionProperties(TestRecRef, NodeSet.Code);

        LibraryAssert.AreEqual(2, Properties.Count, IncorrectNodeGroupErr);

        Properties.Get('Code_Field', PropertyValue);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field", PropertyValue, IncorrectNodeGroupErr);

        Properties.Get('PK_Integer_Field', PropertyValue);
        LibraryAssert.AreEqual(Format(NodeDataTestTable."PK Integer Field"), PropertyValue, IncorrectNodeGroupErr);
    end;

    [Test]
    procedure GetNodeGroupIdFromGroupingProperties()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        TestRecRef: RecordRef;
        GroupId: Text;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Decimal Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("PK Integer Field"));

        NodeDataTestTable := CreateNodeDataTestRec();

        TestRecRef.GetTable(NodeDataTestTable);
        GroupId := GraphDataManagement.GetNodeGroupId(TestRecRef, NodeSet.Code);

        LibraryAssert.AreEqual(Format(NodeDataTestTable."PK Integer Field") + ' ' + NodeDataTestTable."Code Field", GroupId, IncorrectNodeGroupErr);
    end;

    [Test]
    procedure SetNodePropertiesOnCompoundNode()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        TestRecRef: RecordRef;
        GroupNodes: Dictionary of [Text, JsonObject];
        Node: JsonToken;
        GroupNode: JsonObject;
        PropertyTok: JsonToken;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Decimal Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));

        Node.ReadFrom('{"id": "A"}');
        NodeDataTestTable := CreateNodeDataTestRec();
        TestRecRef.GetTable(NodeDataTestTable);

        GraphDataManagement.SetNodeProperties(Node, GroupNodes, TestRecRef, NodeSet.Code);

        Node.AsObject().Get('parent', PropertyTok);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field", PropertyTok.AsValue().AsText(), UnexpectedTokenErr);

        GroupNodes.Get(NodeDataTestTable."Code Field", GroupNode);

        GroupNode.Get('id', PropertyTok);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field", PropertyTok.AsValue().AsText(), UnexpectedTokenErr);

        GroupNode.Get('compound', PropertyTok);
        LibraryAssert.AreEqual(true, PropertyTok.AsValue().AsBoolean(), UnexpectedTokenErr);

        GroupNode.Get('Code_Field', PropertyTok);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field", PropertyTok.AsValue().AsText(), UnexpectedTokenErr);
    end;

    [Test]
    procedure CheckIfCompoundNode()
    var
        Node: JsonObject;
    begin
        Node.ReadFrom('{"id": "A", "compound": true}');
        LibraryAssert.IsTrue(GraphDataManagement.IsCompoundNode(Node), UnexpectedTokenErr);
    end;

    [Test]
    procedure AddEdgeToArray()
    var
        Edges: JsonArray;
        Edge: JsonObject;
    begin
        GraphJsonArray.AddEdgeToArray(Edges, 'SourceNode', 'TargetNode');
        Edge := GetArrayElement(Edges, 0);
        LibraryAssert.AreEqual('SourceNode', GetValueAsText(Edge, 'source'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('TargetNode', GetValueAsText(Edge, 'target'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure MergeNodeArrays()
    var
        SourceArray: JsonArray;
        TargetArray: JsonArray;
    begin
        // [SCENARIO] Merging two node arrays with overlapping nodes

        // [GIVEN] The source array contains two nodes: "NodeA" and "NodeB"
        GraphJsonArray.AddNodeToArray(TargetArray, 'NodeA');
        GraphJsonArray.AddNodeToArray(TargetArray, 'NodeB');

        // [GIVEN] The target array contains two nodes: "NodeB" and "NodeC"
        GraphJsonArray.AddNodeToArray(SourceArray, 'NodeB');
        GraphJsonArray.AddNodeToArray(SourceArray, 'NodeC');

        // [WHEN] Merging the source array into the target array
        GraphJsonArray.MergeNodeArrays(TargetArray, SourceArray);

        // [THEN] The target array should contain three nodes: "NodeA", "NodeB", and "NodeC"
        LibraryAssert.AreEqual(3, TargetArray.Count, IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeA', GetValueAsText(GetArrayElement(TargetArray, 0), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeB', GetValueAsText(GetArrayElement(TargetArray, 1), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeC', GetValueAsText(GetArrayElement(TargetArray, 2), 'id'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure MergeEdgeArrays()
    var
        SourceArray: JsonArray;
        TargetArray: JsonArray;
    begin
        // [SCENARIO] Merging two edge arrays with overlapping edges

        // [GIVEN] The source array contains two edges: "A - B" and "B - C"
        GraphJsonArray.AddEdgeToArray(TargetArray, 'NodeA', 'NodeB');
        GraphJsonArray.AddEdgeToArray(TargetArray, 'NodeB', 'NodeC');

        // [GIVEN] The target array contains two edges: "B - C" and "C - D"
        GraphJsonArray.AddEdgeToArray(SourceArray, 'NodeB', 'NodeC');
        GraphJsonArray.AddEdgeToArray(SourceArray, 'NodeC', 'NodeD');

        // [WHEN] Merging the source array into the target array
        GraphJsonArray.MergeEdgeArrays(TargetArray, SourceArray);

        // [THEN] The target array should contain three edges: "A - B", "B - C", and "C - D"
        LibraryAssert.AreEqual(3, TargetArray.Count, IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeA', GetValueAsText(GetArrayElement(TargetArray, 0), 'source'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeB', GetValueAsText(GetArrayElement(TargetArray, 0), 'target'), IncorrectArrayElementErr);

        LibraryAssert.AreEqual('NodeB', GetValueAsText(GetArrayElement(TargetArray, 1), 'source'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeC', GetValueAsText(GetArrayElement(TargetArray, 1), 'target'), IncorrectArrayElementErr);

        LibraryAssert.AreEqual('NodeC', GetValueAsText(GetArrayElement(TargetArray, 2), 'source'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('NodeD', GetValueAsText(GetArrayElement(TargetArray, 2), 'target'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure GetGroupIdOneField()
    var
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeSet: Record "Node Set CS";
        NodeDataRecRef: RecordRef;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Decimal Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));

        NodeDataTestTable := CreateNodeDataTestRec();

        NodeDataRecRef.GetTable(NodeDataTestTable);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field", GraphDataManagement.GetNodeGroupId(NodeDataRecRef, NodeSet.Code), IncorrectNodeGroupErr);
    end;

    [Test]
    procedure GetGroupIdMultipleFields()
    var
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeSet: Record "Node Set CS";
        NodeDataRecRef: RecordRef;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Decimal Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        LibraryGraphView.AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"));

        NodeDataTestTable := CreateNodeDataTestRec();

        NodeDataRecRef.GetTable(NodeDataTestTable);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field" + ' ' + Format(NodeDataTestTable."Decimal Field"), GraphDataManagement.GetNodeGroupId(NodeDataRecRef, NodeSet.Code), IncorrectNodeGroupErr);
    end;

    local procedure CreateNodeDataTestRec(): Record "Node Data Test Table CS"
    var
        NodeDataTestTable: Record "Node Data Test Table CS";
    begin
        NodeDataTestTable."PK Code Field" := LibraryUtility.GenerateGUID();
        NodeDataTestTable."PK Integer Field" := Random(10);
        NodeDataTestTable."Code Field" := LibraryUtility.GenerateGUID();
        NodeDataTestTable."Decimal Field" := Random(100);
        NodeDataTestTable.Insert();
        exit(NodeDataTestTable);
    end;

    local procedure CreateNodeSetWithOneField(var NodeSet: Record "Node Set CS"; TableNo: Integer; FieldNo: Integer)
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, TableNo);
        LibraryGraphView.AddFieldToNodeSet(NodeSet.Code, FieldNo, false);
    end;

    local procedure GetArrayElement(JArr: JsonArray; Index: Integer): JsonObject
    var
        Result: JsonToken;
    begin
        JArr.Get(Index, Result);
        exit(Result.AsObject());
    end;

    local procedure GetValueAsText(JObject: JsonObject; KeyName: Text): Text
    var
        Result: JsonToken;
    begin
        JObject.Get(KeyName, Result);
        exit(Result.AsValue().AsText());
    end;

    local procedure GetValueAsInteger(JObject: JsonObject; KeyName: Text): Integer
    var
        Result: JsonToken;
    begin
        JObject.Get(KeyName, Result);
        exit(Result.AsValue().AsInteger());
    end;

    local procedure SetSelectorFilterValue(SelectorCode: Code[20]; FieldNo: Integer; FilterValue: Text)
    var
        SelectorFilter: Record "Selector Filter CS";
    begin
        SelectorFilter.Get(SelectorCode, FieldNo);
        SelectorFilter.Validate("Field Filter", FilterValue);
        SelectorFilter.Modify(true);
    end;

    var
        GraphDataManagement: Codeunit "Graph Data Management CS";
        GraphJsonArray: Codeunit "Graph Json Array CS";
        LibraryGraphView: Codeunit "Library - Graph View CS";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAssert: Codeunit "Library Assert";
        IncorrectTokenConversionErr: Label 'Field name was incorrectly converted to JSON token.';
        IncorrectSelectorFilterErr: Label 'Selector filter is incorrect.';
        IncorrectArrayElementErr: Label 'Array elements are incorrect.';
        IncorrectNodeGroupErr: Label 'Node group was assigned incorrectly.';
        UnexpectedTokenErr: Label 'Unexpected JSON token value.';
}
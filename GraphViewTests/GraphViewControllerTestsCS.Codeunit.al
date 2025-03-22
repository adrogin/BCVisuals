codeunit 60101 "Graph View Controller Tests CS"
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
        ConvertedName := GraphViewController.ConvertFieldNameToJsonToken(NodeSetField);

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
        ConvertedName := GraphViewController.ConvertFieldNameToJsonToken(NodeSetField);

        LibraryAssert.AreEqual('Non-Alphanumeric_Field_Name', ConvertedName, IncorrectTokenConversionErr);
    end;

    [Test]
    procedure ValidateNodeSetFieldJsonTokenUpdated()
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

        LibraryAssert.AreEqual('PK_Guid_Field', NodeSetField."Json Property Name", IncorrectTokenConversionErr);
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

        LibraryAssert.AreEqual('node[Code_Field="test"][Decimal_Field>0]', GraphViewController.FormatSelectorText(Style."Selector Code"), IncorrectSelectorFilterErr);
    end;

    [Test]
    procedure AddTextNodeToArray()
    var
        Nodes: JsonArray;
    begin
        GraphViewController.AddNodeToArray(Nodes, 'NodeA');
        GraphViewController.AddNodeToArray(Nodes, 'NodeB');
        GraphViewController.AddNodeToArray(Nodes, 'NodeC');

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
        GraphViewController.AddNodeToArray(Nodes, 1);
        GraphViewController.AddNodeToArray(Nodes, 2);
        GraphViewController.AddNodeToArray(Nodes, 3);

        LibraryAssert.AreEqual(3, Nodes.Count, IncorrectArrayElementErr);
        LibraryAssert.AreEqual(1, GetValueAsInteger(GetArrayElement(Nodes, 0), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual(2, GetValueAsInteger(GetArrayElement(Nodes, 1), 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual(3, GetValueAsInteger(GetArrayElement(Nodes, 2), 'id'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure AddCompoundNodeToArray()
    var
        Nodes: JsonArray;
        Node: JsonObject;
    begin
        GraphViewController.AddCompoundNodeToArray(Nodes, 'NodeId');

        Node := GetArrayElement(Nodes, 0);
        LibraryAssert.AreEqual('NodeId', GetValueAsText(Node, 'id'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('true', GetValueAsText(Node, 'compound'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure AddEdgeToArray()
    var
        Edges: JsonArray;
        Edge: JsonObject;
    begin
        GraphViewController.AddEdgeToArray(Edges, 'SourceNode', 'TargetNode');
        Edge := GetArrayElement(Edges, 0);
        LibraryAssert.AreEqual('SourceNode', GetValueAsText(Edge, 'source'), IncorrectArrayElementErr);
        LibraryAssert.AreEqual('TargetNode', GetValueAsText(Edge, 'target'), IncorrectArrayElementErr);
    end;

    [Test]
    procedure GetGroupIdOneField()
    var
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeSet: Record "Node Set CS";
        NodeDataRecRef: RecordRef;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Decimal Field"));
        AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));

        NodeDataTestTable."PK Code Field" := LibraryUtility.GenerateGUID();
        NodeDataTestTable."Code Field" := LibraryUtility.GenerateGUID();
        NodeDataTestTable."Decimal Field" := 1;
        NodeDataTestTable.Insert(true);

        NodeDataRecRef.GetTable(NodeDataTestTable);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field", GraphViewController.GetNodeGroupId(NodeDataRecRef, NodeSet.Code), IncorrectNodeGroupErr);
    end;

    [Test]
    procedure GetGroupIdMultipleFields()
    var
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeSet: Record "Node Set CS";
        NodeDataRecRef: RecordRef;
    begin
        CreateNodeSetWithOneField(NodeSet, Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Decimal Field"));
        AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        AddNodeSetGroupField(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"));

        NodeDataTestTable."PK Code Field" := LibraryUtility.GenerateGUID();
        NodeDataTestTable."Code Field" := LibraryUtility.GenerateGUID();
        NodeDataTestTable."Decimal Field" := 1;
        NodeDataTestTable.Insert(true);

        NodeDataRecRef.GetTable(NodeDataTestTable);
        LibraryAssert.AreEqual(NodeDataTestTable."Code Field" + ' ' + Format(NodeDataTestTable."Decimal Field"), GraphViewController.GetNodeGroupId(NodeDataRecRef, NodeSet.Code), IncorrectNodeGroupErr);
    end;

    local procedure AddNodeSetGroupField(NodeSetCode: Code[20]; FieldNo: Integer)
    var
        NodeSetGroupField: Record "Node Set Group Field CS";
    begin
        NodeSetGroupField.Validate("Node Set Code", NodeSetCode);
        NodeSetGroupField.Validate("Field No.", FieldNo);
        NodeSetGroupField.Insert(true);
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
        GraphViewController: Codeunit "Graph View Controller CS";
        LibraryGraphView: Codeunit "Library - Graph View CS";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAssert: Codeunit "Library Assert";
        IncorrectTokenConversionErr: Label 'Field name was incorrectly converted to JSON token.';
        IncorrectSelectorFilterErr: Label 'Selector filter is incorrect.';
        IncorrectArrayElementErr: Label 'Array elements are incorrect.';
        IncorrectNodeGroupErr: Label 'Node group was assigned incorrectly.';
}
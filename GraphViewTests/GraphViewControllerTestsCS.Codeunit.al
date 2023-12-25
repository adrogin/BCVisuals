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
        ConvertedName := GraphViewController.ConverFieldNameToJsonToken(NodeSetField);

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
        ConvertedName := GraphViewController.ConverFieldNameToJsonToken(NodeSetField);

        LibraryAssert.AreEqual('Non_Alphanumeric_Field_Name', ConvertedName, IncorrectTokenConversionErr);
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

    local procedure CreateNodeSetWithOneField(var NodeSet: Record "Node Set CS"; TableNo: Integer; FieldNo: Integer)
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, TableNo);
        LibraryGraphView.AddFieldToNodeSet(NodeSet.Code, FieldNo, false);
    end;

    var
        GraphViewController: Codeunit "Graph View Controller CS";
        LibraryGraphView: Codeunit "Library - Graph View CS";
        LibraryAssert: Codeunit "Library Assert";
        IncorrectTokenConversionErr: Label 'Field name was incorrectly converted to JSON token.';
}
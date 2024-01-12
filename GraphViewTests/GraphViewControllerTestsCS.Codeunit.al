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

    local procedure CreateNodeSetWithOneField(var NodeSet: Record "Node Set CS"; TableNo: Integer; FieldNo: Integer)
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, TableNo);
        LibraryGraphView.AddFieldToNodeSet(NodeSet.Code, FieldNo, false);
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
        LibraryAssert: Codeunit "Library Assert";
        IncorrectTokenConversionErr: Label 'Field name was incorrectly converted to JSON token.';
        IncorrectSelectorFilterErr: Label 'Selector filter is incorrect';
}
codeunit 60100 "Node Data Mgt. Tests CS"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure UpdateNodeDataFromTableMetadataInEmptySet()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table CS");

        GraphNodeDataMgt.UpdateNodeSetFields(NodeSet.Code, Database::"Node Data Test Table CS");

        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("PK Code Field"));
        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("PK Integer Field"));
        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"));
        VerifyFieldNotInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("BLOB Field"));
        VerifyFieldNotInNodeSet(NodeSet.Code, GetFieldNoByName(Database::"Node Data Test Table CS", 'Obsolete Field'));

        VerifyPrimaryKeyFieldsIncludedInNodeData(NodeSet.Code);
    end;

    [Test]
    procedure UpdateNodeSetFromTableMetadataExistingSet()
    var
        NodeSet: Record "Node Set CS";
        NodeSetField: Record "Node Set Field CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeDataMustNotBeResetErr: Label 'Node set fields must not be reset when updating fields.';
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table CS");

        NodeSetField.Validate("Node Set Code", NodeSet.Code);
        NodeSetField.Validate("Field No.", NodeDataTestTable.FieldNo("Code Field"));
        NodeSetField.Validate("Include in Node Data", true);
        NodeSetField.Insert(true);

        GraphNodeDataMgt.UpdateNodeSetFields(NodeSet.Code, Database::"Node Data Test Table CS");

        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("PK Code Field"));
        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("PK Integer Field"));
        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        VerifyFieldInNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"));

        NodeSetField.Get(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        LibraryAssert.IsTrue(NodeSetField."Include in Node Data", NodeDataMustNotBeResetErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ChangeNodeSetTableNodesUpdatedAfterConfirmation()
    var
        NodeSet: Record "Node Set CS";
        NodeSetTestTable2: Record "Node Data Test Table 2 CS";
        ConfirmChangeTableMsg: Label 'The node set setup, including tooltips and style settings, will be reset to default. Do you want to continue?';
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table CS");

        GraphNodeDataMgt.UpdateNodeSetFields(NodeSet.Code, Database::"Node Data Test Table CS");

        NodeSet.Validate("Table No.", Database::"Node Data Test Table 2 CS");

        LibraryVariableStorage.Enqueue(ConfirmChangeTableMsg);
        NodeSet.Modify(true);

        VerifyFieldInNodeSet(NodeSet.Code, NodeSetTestTable2.FieldNo("PK Guid Field"));
        VerifyFieldNotInNodeSet(NodeSet.Code, NodeSetTestTable2.FieldNo("Media Field"));
    end;

    [Test]
    procedure UpdateTableNoInNodeSetUpdatesNodeData()
    var
        NodeSet: Record "Node Set CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        NodeSet.Validate("Table No.", Database::"Node Data Test Table CS");
        NodeSet.Modify(true);

        VerifyPrimaryKeyFieldsIncludedInNodeData(NodeSet.Code);
    end;

    [Test]
    procedure UpdateNodeSetDataObsoleteFieldRemovedFromSet()
    var
        NodeSet: Record "Node Set CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table CS");

        LibraryGraphView.AddFieldToNodeSet(NodeSet.Code, GetFieldNoByName(Database::"Node Data Test Table CS", 'Obsolete Field'), false);

        GraphNodeDataMgt.UpdateNodeSetFields(NodeSet.Code, Database::"Node Data Test Table CS");

        VerifyFieldNotInNodeSet(NodeSet.Code, GetFieldNoByName(Database::"Node Data Test Table CS", 'Obsolete Field'));
    end;

    [Test]
    procedure InsertNewNodeSetValidateTableNo()
    var
        NodeSet: Record "Node Set CS";
    begin
        // [SCENARIO] When a new node set with a table reference is inserted, node set fields are updated, including JSON tokens for all nodes

        NodeSet.Validate(Code, LibraryUtility.GenerateGUID());
        NodeSet.Validate("Table No.", Database::"Node Data Test Table CS");
        NodeSet.Insert(true);

        VerifyPrimaryKeyFieldsIncludedInNodeData(NodeSet.Code);
        VerifyNodeSetFieldsJsonTokensNotBlank(NodeSet.Code);
    end;

    [Test]
    procedure ModifyNodeSetDescriptionNoTable()
    var
        NodeSet: Record "Node Set CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        NodeSet.Validate(Description, LibraryUtility.GenerateRandomText(MaxStrLen(NodeSet.Description)));
        NodeSet.Modify(true);
    end;

    [Test]
    procedure DeleteNodeSetFieldsDeleted()
    var
        NodeSet: Record "Node Set CS";
        NodeSetField: Record "Node Set Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table CS");

        // [WHEN]
        NodeSet.Delete(true);

        NodeSetField.SetRange("Node Set Code", NodeSet.Code);
        LibraryAssert.RecordIsEmpty(NodeSetField);
    end;

    [Test]
    procedure DeleteNodeSetFieldTooltipDeleted()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeSetField: Record "Node Set Field CS";
        NodeTooltipField: Record "Node Tooltip Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.AddFieldToNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), true);
        AddNodeTooltipField(NodeSet.Code, 1, NodeDataTestTable.FieldNo("Code Field"));

        // [WHEN]
        NodeSetField.Get(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        NodeSetField.Delete(true);

        // [THEN]
        NodeTooltipField.SetRange("Node Set Code", NodeSet.Code);
        NodeTooltipField.SetRange("Field No.", NodeDataTestTable.FieldNo("Code Field"));
        LibraryAssert.RecordIsEmpty(NodeTooltipField);
    end;

    local procedure AddNodeTooltipField(NodeSetCode: Code[20]; SequenceNo: Integer; FieldNo: Integer)
    var
        NodeTooltipField: Record "Node Tooltip Field CS";
    begin
        NodeTooltipField.Validate("Node Set Code", NodeSetCode);
        NodeTooltipField.Validate("Sequence No.", SequenceNo);
        NodeTooltipField.Validate("Field No.", FieldNo);
        NodeTooltipField.Insert(true);
    end;

    local procedure GetFieldNoByName(TableNo: Integer; FieldName: Text[30]): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(FieldName, FieldName);
        Field.FindFirst();
        exit(Field."No.");
    end;

    local procedure VerifyFieldInNodeSet(NodeSetCode: Code[20]; FieldNo: Integer)
    var
        NodeSetField: Record "Node Set Field CS";
    begin
        NodeSetField.SetRange("Node Set Code", NodeSetCode);
        NodeSetField.SetRange("Field No.", FieldNo);
        LibraryAssert.RecordCount(NodeSetField, 1);
    end;

    local procedure VerifyFieldNotInNodeSet(NodeSetCode: Code[20]; FieldNo: Integer)
    var
        NodeSetField: Record "Node Set Field CS";
    begin
        NodeSetField.SetRange("Node Set Code", NodeSetCode);
        NodeSetField.SetRange("Field No.", FieldNo);
        LibraryAssert.RecordIsEmpty(NodeSetField);
    end;

    local procedure VerifyNodeSetFieldsJsonTokensNotBlank(NodeSetCode: Code[20])
    var
        NodeSetField: Record "Node Set Field CS";
    begin
        NodeSetField.SetRange("Node Set Code", NodeSetCode);
        NodeSetField.SetRange("Json Property Name", '');
        LibraryAssert.RecordIsEmpty(NodeSetField);
    end;

    local procedure VerifyPrimaryKeyFieldsIncludedInNodeData(NodeSetCode: Code[20])
    var
        NodeSetField: Record "Node Set Field CS";
        NodeSet: Record "Node Set CS";
        RecRef: RecordRef;
        PKRef: KeyRef;
        I: Integer;
        FieldMustBeinNodeDataErr: Label 'Primary key fields must be included in node data.';
    begin
        NodeSet.Get(NodeSetCode);
        NodeSetField.SetRange("Node Set Code", NodeSetCode);

        RecRef.Open(NodeSet."Table No.");
        PKRef := RecRef.KeyIndex(1);
        for I := 1 to PKRef.FieldCount do begin
            NodeSetField.Get(NodeSetCode, PKRef.FieldIndex(I).Number);
            LibraryAssert.IsTrue(NodeSetField."Include in Node Data", FieldMustBeinNodeDataErr);
        end;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;

    var
        GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAssert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryGraphView: Codeunit "Library - Graph View CS";
}
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
        ConfirmChangeTableMsg: Label 'The node set setup, including tooltips and style settings, will be deleted. Do you want to continue?';
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table CS");

        GraphNodeDataMgt.UpdateNodeSetFields(NodeSet.Code, Database::"Node Data Test Table CS");

        LibraryVariableStorage.Enqueue(ConfirmChangeTableMsg);
        NodeSet.Validate("Table No.", Database::"Node Data Test Table 2 CS");

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
        // [SCENARIO] Modification of the node set description doesn't require confimation
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
        NodeTextField: Record "Node Text Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet);
        LibraryGraphView.UpdateNodeSetTableNo(NodeSet, Database::"Node Data Test Table CS");
        LibraryGraphView.AddFieldToNodeSet(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), true);
        LibraryGraphView.AddNodeTextField(NodeSet.Code, 1, NodeDataTestTable.FieldNo("Code Field"), Enum::"Node Text Type CS"::Tooltip);

        // [WHEN]
        NodeSetField.Get(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"));
        NodeSetField.Delete(true);

        // [THEN]
        NodeTextField.SetRange("Node Set Code", NodeSet.Code);
        NodeTextField.SetRange("Field No.", NodeDataTestTable.FieldNo("Code Field"));
        LibraryAssert.RecordIsEmpty(NodeTextField);
    end;

    [Test]
    procedure FieldSelectedInTooltipIncludedInNodeData()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeTextField: Record "Node Text Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");

        LibraryGraphView.AddNodeTextField(NodeSet.Code, 1, NodeDataTestTable.FieldNo("Code Field"), Enum::"Node Text Type CS"::Tooltip);
        LibraryGraphView.AddNodeTextField(NodeSet.Code, 2, NodeDataTestTable.FieldNo("Code Field"), Enum::"Node Text Type CS"::Tooltip);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), true);

        NodeTextField.SetRange("Node Set Code", NodeSet.Code);
        NodeTextField.DeleteAll(true);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), false);
    end;

    [Test]
    procedure ChangeTooltipFieldIncludeInNodeDataUpdated()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeTextField: Record "Node Text Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");
        LibraryGraphView.AddNodeTextField(NodeSet.Code, 1, NodeDataTestTable.FieldNo("Code Field"), Enum::"Node Text Type CS"::Tooltip);

        NodeTextField.Get(NodeSet.Code, Enum::"Node Text Type CS"::Tooltip, 1);
        NodeTextField.Validate("Field No.", NodeDataTestTable.FieldNo("Decimal Field"));
        NodeTextField.Modify(true);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), false);
        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"), true);
    end;

    [Test]
    procedure AddFieldToSelectorFilterIncludeInNodeDataEnabled()
    var
        NodeSets: array[3] of Record "Node Set CS";
        Style: Record "Style CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        I: Integer;
    begin
        Style.Get(LibraryGraphView.CreateStyleWithSelector(Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Code Field")));

        for I := 1 to ArrayLen(NodeSets) do begin
            LibraryGraphView.CreateNodeSet(NodeSets[I], Database::"Node Data Test Table CS");
            LibraryGraphView.AddStyleToNodeSet(NodeSets[I].Code, Style.Code);
        end;

        LibraryGraphView.CreateSelectorFilter(Style."Selector Code", NodeDataTestTable.FieldNo("Decimal Field"));

        for I := 1 to ArrayLen(NodeSets) do begin
            VerifyFieldInNodeData(NodeSets[I].Code, NodeDataTestTable.FieldNo("Code Field"), true);
            VerifyFieldInNodeData(NodeSets[I].Code, NodeDataTestTable.FieldNo("Decimal Field"), true);
        end;
    end;

    [Test]
    procedure DeleteSelectorFilterIncludeInNodeDataDisabledForFilterField()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        SelectorFilter: Record "Selector Filter CS";
        Style: Record "Style CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");
        Style.Get(LibraryGraphView.CreateStyleWithSelector(Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Code Field")));
        LibraryGraphView.AddStyleToNodeSet(NodeSet.Code, Style.Code);

        LibraryGraphView.CreateSelectorFilter(Style."Selector Code", NodeDataTestTable.FieldNo("Decimal Field"));

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), true);
        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"), true);

        SelectorFilter.Get(Style."Selector Code", NodeDataTestTable.FieldNo("Code Field"));
        SelectorFilter.Delete(true);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), false);
        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"), true);
    end;

    [Test]
    procedure ModifyFieldInSelectorFilterNodeDataUpdated()
    var
        NodeSet: Record "Node Set CS";
        Style: Record "Style CS";
        SelectorFilter: Record "Selector Filter CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");
        Style.Get(LibraryGraphView.CreateStyleWithSelector(Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Code Field")));
        LibraryGraphView.AddStyleToNodeSet(NodeSet.Code, Style.Code);

        SelectorFilter.Get(Style."Selector Code", NodeDataTestTable.FieldNo("Code Field"));
        SelectorFilter.Rename(SelectorFilter."Selector Code", NodeDataTestTable.FieldNo("Decimal Field"));

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), false);
        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Decimal Field"), true);
    end;

    [Test]
    procedure RemoveStyleFromNodeSetIncludeInDataOnFilterFieldsDeselected()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        StyleCode: Code[20];
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");
        StyleCode := LibraryGraphView.CreateStyleWithSelector(Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Code Field"));
        LibraryGraphView.AddStyleToNodeSet(NodeSet.Code, StyleCode);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), true);

        LibraryGraphView.RemoveStyleFromNodeSet(NodeSet.Code, StyleCode);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), false);
    end;

    [Test]
    procedure RemoveFieldFromTooltipFieldRemainsInDataIfPresentInFilter()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeTextField: Record "Node Text Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");
        LibraryGraphView.AddNodeTextField(NodeSet.Code, 1, NodeDataTestTable.FieldNo("Code Field"), Enum::"Node Text Type CS"::Tooltip);

        LibraryGraphView.AddStyleToNodeSet(
            NodeSet.Code,
            LibraryGraphView.CreateStyleWithSelector(Database::"Node Data Test Table CS", NodeDataTestTable.FieldNo("Code Field")));

        NodeTextField.SetRange("Node Set Code", NodeSet.Code);
        NodeTextField.DeleteAll(true);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), true);
    end;

    [Test]
    procedure ModifyNodeTextFieldPreviousValueZero()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeTextField: Record "Node Text Field CS";
        NodeTextFieldMustBeUpdatedErr: Label 'Node text field must be updated.';
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");

        NodeTextField.Validate("Node Set Code", NodeSet.Code);
        NodeTextField.Validate("Sequence No.", 1);
        NodeTextField.Validate(Type, Enum::"Node Text Type CS"::Label);
        NodeTextField.Insert(true);

        NodeTextField.Validate("Field No.", NodeDataTestTable.FieldNo("Code Field"));
        NodeTextField.Modify(true);

#pragma warning disable AA0181
        NodeTextField.Find();
#pragma warning restore

        LibraryAssert.AreEqual(NodeDataTestTable.FieldNo("Code Field"), NodeTextField."Field No.", NodeTextFieldMustBeUpdatedErr);
    end;

    [Test]
    procedure RemoveFieldFromTooltipSameFieldInLabelIncludeInDataRemainsEnabled()
    var
        NodeSet: Record "Node Set CS";
        NodeDataTestTable: Record "Node Data Test Table CS";
        NodeTextField: Record "Node Text Field CS";
    begin
        LibraryGraphView.CreateNodeSet(NodeSet, Database::"Node Data Test Table CS");
        LibraryGraphView.AddNodeTextField(NodeSet.Code, 1, NodeDataTestTable.FieldNo("Code Field"), Enum::"Node Text Type CS"::Tooltip);
        LibraryGraphView.AddNodeTextField(NodeSet.Code, 1, NodeDataTestTable.FieldNo("Code Field"), Enum::"Node Text Type CS"::Label);

        NodeTextField.Get(NodeSet.Code, Enum::"Node Text Type CS"::Tooltip, 1);
        NodeTextField.Delete(true);

        VerifyFieldInNodeData(NodeSet.Code, NodeDataTestTable.FieldNo("Code Field"), true);
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

    local procedure VerifyFieldInNodeData(NodeSetCode: Code[20]; FieldNo: Integer; IsExpectedInNodeData: Boolean)
    var
        NodeSetField: Record "Node Set Field CS";
    begin
        NodeSetField.Get(NodeSetCode, FieldNo);

        if IsExpectedInNodeData then
            LibraryAssert.IsTrue(NodeSetField."Include in Node Data", FieldMustbeInNodeDataErr)
        else
            LibraryAssert.IsFalse(NodeSetField."Include in Node Data", FieldMustBeRemovedFromNodeDataErr);
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
        NodeSet: Record "Node Set CS";
        RecRef: RecordRef;
        PKRef: KeyRef;
        I: Integer;
    begin
        NodeSet.Get(NodeSetCode);
        RecRef.Open(NodeSet."Table No.");
        PKRef := RecRef.KeyIndex(1);
        for I := 1 to PKRef.FieldCount do
            VerifyFieldInNodeData(NodeSetCode, PKRef.FieldIndex(I).Number, true);
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
        FieldMustbeInNodeDataErr: Label 'Field  must be included in node data';
        FieldMustBeRemovedFromNodeDataErr: Label 'Field must be removed from node data';
}

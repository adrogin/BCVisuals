codeunit 60102 "Library - Graph View CS"
{
    procedure AddFieldToNodeSet(NodeSetCode: Code[20]; FieldNo: Integer; IncludeInNodeData: Boolean)
    var
        NodeSet: Record "Node Set CS";
        NodeSetField: Record "Node Set Field CS";
    begin
        NodeSet.SetLoadFields("Table No.");
        NodeSet.Get(NodeSetCode);
        NodeSetField.Validate("Node Set Code", NodeSetCode);
        NodeSetField.Validate("Table No.", NodeSet."Table No.");
        NodeSetField.Validate("Field No.", FieldNo);
        NodeSetField.Validate("Include in Node Data", IncludeInNodeData);
        NodeSetField.Insert(true);
    end;

    procedure AddNodeTextField(NodeSetCode: Code[20]; SequenceNo: Integer; FieldNo: Integer; FieldType: Enum "Node Text Type CS")
    var
        NodeTextField: Record "Node Text Field CS";
    begin
        NodeTextField.Validate("Node Set Code", NodeSetCode);
        NodeTextField.Validate("Sequence No.", SequenceNo);
        NodeTextField.Validate("Field No.", FieldNo);
        NodeTextField.Validate(Type, FieldType);
        NodeTextField.Insert(true);
    end;

    procedure AddStyleToNodeSet(NodeSetCode: Code[20]; StyleCode: Code[20])
    var
        StyleSet: Record "Style Set CS";
    begin
        StyleSet.Validate("Node Set Code", NodeSetCode);
        StyleSet.Validate("Style Code", StyleCode);
        StyleSet.Insert(true);
    end;

    procedure CreateNodeSet(var NodeSet: Record "Node Set CS")
    begin
        NodeSet.Validate(Code, LibraryUtility.GenerateGUID());
        NodeSet.Insert(true);
    end;

    procedure CreateNodeSet(var NodeSet: Record "Node Set CS"; TableNo: Integer)
    begin
        NodeSet.Validate(Code, LibraryUtility.GenerateGUID());
        NodeSet.Validate("Table No.", TableNo);
        NodeSet.Insert(true);
    end;

    procedure CreateSelector(var Selector: Record "Selector CS"; TableNo: Integer)
    begin
        Selector.Validate(Code, LibraryUtility.GenerateGUID());
        Selector.Validate("Table No.", TableNo);
        Selector.Insert(true);
    end;

    procedure CreateSelectorFilter(SelectorCode: Code[20]; FieldNo: Integer)
    var
        SelectorFilter: Record "Selector Filter CS";
    begin
        SelectorFilter.Validate("Selector Code", SelectorCode);
        SelectorFilter.Validate("Field No.", FieldNo);
        SelectorFilter.Insert(true);
    end;

    procedure CreateStyle(SelectorCode: Code[20]): Code[20]
    var
        Style: Record "Style CS";
    begin
        Style.Validate(Code, LibraryUtility.GenerateGUID());
        Style.Validate("Selector Code", SelectorCode);
        Style.Insert(true);

        exit(Style.Code);
    end;

    procedure CreateStyleWithSelector(SelectorTableNo: Integer; SelectorFieldNo: Integer): Code[20]
    var
        Selector: Record "Selector CS";
    begin
        CreateSelector(Selector, SelectorTableNo);
        CreateSelectorFilter(Selector.Code, SelectorFieldNo);
        exit(CreateStyle(Selector.Code));
    end;

    procedure RemoveStyleFromNodeSet(NodeSetCode: Code[20]; StyleCode: Code[20])
    var
        StyleSet: Record "Style Set CS";
    begin
        StyleSet.SetRange("Node Set Code", NodeSetCode);
        StyleSet.SetRange("Style Code", StyleCode);
        StyleSet.DeleteAll(true);
    end;

    procedure UpdateNodeSetTableNo(var NodeSet: Record "Node Set CS"; TableNo: Integer)
    begin
        NodeSet."Table No." := TableNo;
        NodeSet.Modify();
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
}
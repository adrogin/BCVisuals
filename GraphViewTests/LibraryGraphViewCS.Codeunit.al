codeunit 60102 "Library - Graph View CS"
{
    procedure CreateNodeSet(var NodeSet: Record "Node Set CS")
    begin
        NodeSet.Validate(Code, LibraryUtility.GenerateGUID());
        NodeSet.Insert(true);
    end;

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

    procedure UpdateNodeSetTableNo(var NodeSet: Record "Node Set CS"; TableNo: Integer)
    begin
        NodeSet."Table No." := TableNo;
        NodeSet.Modify();
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
}
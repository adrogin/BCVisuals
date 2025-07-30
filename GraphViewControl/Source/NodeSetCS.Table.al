table 50100 "Node Set CS"
{
    DataClassification = CustomerContent;
    Caption = 'Node Set';
    LookupPageId = "Node Sets List CS";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));

            trigger OnValidate()
            var
                NodeSetField: Record "Node Set Field CS";
                ConfirmChangeTableMsg: Label 'The node set setup, including tooltips and style settings, will be deleted. Do you want to continue?';
                UpdateConfirmed: Boolean;
            begin
                UpdateConfirmed := true;
                if (Rec."Table No." <> xRec."Table No.") and (xRec."Table No." <> 0) then
                    UpdateConfirmed := Confirm(ConfirmChangeTableMsg);

                if UpdateConfirmed then begin
                    NodeSetField.SetRange("Node Set Code", Code);
                    NodeSetField.DeleteAll(true);
                    GraphNodeDataMgt.UpdateNodeSetFields(Code, "Table No.");
                end;
            end;
        }
        field(4; "Table Caption"; Text[249])
        {
            Caption = 'Table Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        NodeSetField: Record "Node Set Field CS";
        NodeTextField: Record "Node Text Field CS";
        StyleSet: Record "Style Set CS";
    begin
        NodeSetField.SetRange("Node Set Code", Code);
        NodeSetField.DeleteAll();

        NodeTextField.SetRange("Node Set Code", Code);
        NodeTextField.DeleteAll();

        StyleSet.SetRange("Node Set Code", Code);
        StyleSet.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if "Table No." <> 0 then
            GraphNodeDataMgt.UpdateNodeSetFields(Code, "Table No.");
    end;

    var
        GraphNodeDataMgt: Codeunit "Graph Node CS";
}

table 50102 "Node Tooltip Field CS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Node Set Code"; code[20])
        {
            Caption = 'Node Set Code';
            TableRelation = "Node Set CS";
        }
        field(2; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = "Node Set Field CS"."Field No." where("Node Set Code" = field("Node Set Code"));
        }
        field(4; "Field Caption"; Text[80])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(5; Delimiter; Option)
        {
            Caption = 'Delimiter';
            OptionMembers = "None","Space","New Line";
            OptionCaption = 'None,Space,New Line';
        }
        field(6; "Show Caption"; Boolean)
        {
            Caption = 'Show Caption';
        }
        field(7; "Table No."; Integer)
        {
            Caption = 'Table No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Node Set CS"."Table No." where(Code = field("Node Set Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Node Set Code", "Sequence No.")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    begin
        // Update "Include in Node Data"
    end;
}
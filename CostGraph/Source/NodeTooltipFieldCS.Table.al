table 50102 "Node Tooltip Field CS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = "Graph Node Data CS"."Field No.";
        }
        field(3; "Field Caption"; Text[80])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = const(Database::"Item Ledger Entry"), "No." = field("Field No.")));
            Editable = false;
        }
        field(4; Delimiter; Option)
        {
            Caption = 'Delimiter';
            OptionMembers = "None","Space","New Line";
            OptionCaption = 'None,Space,New Line';
        }
        field(5; "Show Caption"; Boolean)
        {
            Caption = 'Show Caption';
        }
    }

    keys
    {
        key(PK; "Sequence No.")
        {
            Clustered = true;
        }
    }
}
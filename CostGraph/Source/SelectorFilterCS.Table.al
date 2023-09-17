table 50104 "Selector Filter CS"
{
    DataClassification = CustomerContent;
    Caption = 'Selector Filter';
    LookupPageId = "Selector Filters CS";

    fields
    {
        field(1; "Selector Code"; Code[20])
        {
            Caption = 'Selector Code';
            TableRelation = "Selector CS".Code;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'No.';
            TableRelation = "Graph Node Data CS"."Field No." where("Include in Node Data" = const(true));
        }
        field(3; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = filter(Database::"Item Ledger Entry"), "No." = field("Field No.")));
        }
        field(4; "Field Filter"; Text[250])
        {
            Caption = 'Field Filter';
        }
    }

    keys
    {
        key(PK; "Selector Code", "Field No.")
        {
            Clustered = true;
        }
    }
}

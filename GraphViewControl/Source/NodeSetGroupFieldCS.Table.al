table 50108 "Node Set Group Field CS"
{
    fields
    {
        field(1; "Node Set Code"; Code[20])
        {
            Caption = 'Node Set Code';
            DataClassification = CustomerContent;
            TableRelation = "Node Set CS".Code;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;

            trigger OnLookup()
            var
                NodeSet: Record "Node Set CS";
                FieldRec: Record Field;
                FieldsLookup: Page "Fields Lookup";
            begin
                if "Node Set Code" = '' then
                    exit;

                NodeSet.Get("Node Set Code");
                FieldRec.FilterGroup(2);
                FieldRec.SetRange(TableNo, NodeSet."Table No.");
                FieldRec.FilterGroup(0);
                FieldsLookup.LookupMode(true);
                FieldsLookup.SetTableView(FieldRec);
                if FieldsLookup.RunModal() = Action::LookupOK then begin
                    FieldsLookup.GetRecord(FieldRec);
                    Validate("Field No.", FieldRec."No.");
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Node Set Code", "Field No.")
        {
            Clustered = true;
        }
    }
}
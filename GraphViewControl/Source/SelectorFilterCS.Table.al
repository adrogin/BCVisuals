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

            trigger OnValidate()
            var
                Selector: Record "Selector CS";
                Field: Record Field;
                GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
                FieldCannotBeFilterErr: Label 'Field %1 cannot be used for filtering.', Comment = '%1: Field No.';
            begin
                TestField("Selector Code");
                Selector.Get("Selector Code");
                Selector.TestField("Table No.");
                GraphNodeDataMgt.FilterTableFieldsForNodeData(Field, Selector."Table No.");
                Field.SetRange("No.", "Field No.");
                if Field.IsEmpty() then
                    Error(FieldCannotBeFilterErr, "Field No.");
            end;

            trigger OnLookup()
            var
                Selector: Record "Selector CS";
                Field: Record Field;
                FieldsLookup: Page "Fields Lookup";
            begin
                TestField("Selector Code");
                Selector.Get("Selector Code");
                Selector.TestField("Table No.");

                Field.FilterGroup(2);
                Field.SetRange(TableNo, Selector."Table No.");
                Field.FilterGroup(0);
                FieldsLookup.LookupMode(true);
                FieldsLookup.SetTableView(Field);

                if FieldsLookup.RunModal() = Action::LookupOK then begin
                    FieldsLookup.GetRecord(Field);
                    "Field No." := Field."No.";
                end;
            end;
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

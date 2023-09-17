table 50101 "Graph Node Data CS"
{
    Caption = 'Graph Node Data';
    DataClassification = CustomerContent;
    LookupPageId = "Graph Node Data CS";

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            var
                GraphViewController: Codeunit "Graph View Controller CS";
            begin
                "Json Property Name" := GraphViewController.ConverFieldNameToJsonToken(Rec);
            end;
        }
        field(3; "Table Name"; Text[249])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
        field(4; "Table Caption"; Text[249])
        {
            Caption = 'Table Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
        field(5; "Field Name"; Text[80])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(6; "Field Caption"; Text[80])
        {
            Caption = 'Field Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;

        }
        field(7; "Json Property Name"; Text[80])
        {
            Caption = 'JSON Property Name';
        }
        field(8; "Include in Node Data"; Boolean)
        {
            Caption = 'Include in Node Data';

            trigger OnValidate()
            var
                GraphViewController: Codeunit "Graph View Controller CS";
                CannotRemoveEntryNoErr: Label 'Entry No. field cannot be removed from node data.';
            begin
                if "Include in Node Data" then
                    exit;

                if GraphViewController.IsEntryNoField(Rec) then
                    Error(CannotRemoveEntryNoErr);

                // TODO: Reset style selectors
            end;
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Field No.", "Field Caption") { }
    }
}

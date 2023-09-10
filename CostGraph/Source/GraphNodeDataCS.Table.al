table 50101 "Graph Node Data CS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
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

            trigger OnValidate()
            var
                GraphViewController: Codeunit "Graph View Controller CS";
            begin
                "JSON Field Name" := CopyStr(GraphViewController.ConverFieldNameToJsonToken(Rec), 1, MaxStrLen("JSON Field Name"));
            end;
        }
        field(6; "Field Caption"; Text[80])
        {
            Caption = 'Field Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;

        }
        field(7; "JSON Field Name"; Text[80])
        {
            Caption = 'JSON Field Name';
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

                "Show in Node Label" := false;
                "Show in Static Text" := false;
                "Show in Tooltip" := false;
                // TODO: Reset style selectors
            end;
        }
        field(9; "Show in Node Label"; Boolean)
        {
            Caption = 'Show in Node Label';

            trigger OnValidate()
            begin
                ValidateShowField();
            end;
        }
        field(10; "Show in Static Text"; Boolean)
        {
            Caption = 'Show in Static Text';

            trigger OnValidate()
            begin
                ValidateShowField();
            end;
        }
        field(11; "Show in Tooltip"; Boolean)
        {
            Caption = 'Show in Tooltip';

            trigger OnValidate()
            begin
                ValidateShowField();
            end;
        }
        field(12; Delimiter; Option)
        {
            Caption = 'Delimiter';
            OptionMembers = "None","Space","New Line";
            OptionCaption = 'None,Space,New Line';
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

    local procedure ValidateShowField()
    begin
        if "Show in Node Label" or "Show in Static Text" or "Show in Tooltip" and not "Include in Node Data" then
            "Include in Node Data" := true;
    end;
}

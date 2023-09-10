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
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
        }
        field(4; "Field Name"; Text[80])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
        }
        field(5; "Include in Node Data"; Boolean)
        {
            Caption = 'Include in Node Data';

            trigger OnValidate()
            var
                CannotRemoveEntryNoErr: Label 'Entry No. field cannot be removed from node data.';
            begin
                if "Include in Node Data" then
                    exit;

                if ("Table No." = Database::"Item Ledger Entry") and ("Field No." = 1) then
                    Error(CannotRemoveEntryNoErr);

                "Show in Node Data" := false;
                "Show in Static Text" := false;
                "Show in Tooltip" := false;
                // TODO: Reset style selectors
            end;
        }
        field(6; "Show in Node Data"; Boolean)
        {
            Caption = 'Show in Node Data';

            trigger OnValidate()
            begin
                ValidateShowField();
            end;
        }
        field(7; "Show in Static Text"; Boolean)
        {
            Caption = 'Show in Static Text';

            trigger OnValidate()
            begin
                ValidateShowField();
            end;
        }
        field(8; "Show in Tooltip"; Boolean)
        {
            Caption = 'Show in Tooltip';

            trigger OnValidate()
            begin
                ValidateShowField();
            end;
        }
        field(9; Delimiter; Option)
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
        if "Show in Node Data" and not "Include in Node Data" then
            "Include in Node Data" := true;
    end;
}
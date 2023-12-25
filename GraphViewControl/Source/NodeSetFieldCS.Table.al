table 50101 "Node Set Field CS"
{
    Caption = 'Node Set Field';
    DataClassification = CustomerContent;
    LookupPageId = "Node Set Fields CS";

    fields
    {
        field(1; "Node Set Code"; Code[20])
        {
            Caption = 'Node Set Code';
            TableRelation = "Node Set CS";
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            var
                GraphViewController: Codeunit "Graph View Controller CS";
            begin
                "Json Property Name" := GraphViewController.ConverFieldNameToJsonToken(Rec);
            end;
        }
        field(6; "Field Name"; Text[80])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(7; "Field Caption"; Text[80])
        {
            Caption = 'Field Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;

        }
        field(8; "Json Property Name"; Text[80])
        {
            Caption = 'JSON Property Name';
        }
        field(9; "Include in Node Data"; Boolean)
        {
            Caption = 'Include in Node Data';

            trigger OnValidate()
            var
                GraphViewController: Codeunit "Graph View Controller CS";
                CannotRemoveEntryNoErr: Label 'Entry No. field cannot be removed from node data.';
            begin
                if "Include in Node Data" then
                    exit;

                if GraphViewController.IsMandatoryField(Rec) then
                    Error(CannotRemoveEntryNoErr);

                // TODO: Reset style selectors
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

    fieldgroups
    {
        fieldgroup(DropDown; "Field No.", "Field Caption") { }
    }

    trigger OnDelete()
    var
        NodeTooltipField: Record "Node Tooltip Field CS";
    begin
        NodeTooltipField.SetRange("Node Set Code", "Node Set Code");
        NodeTooltipField.SetRange("Field No.", "Field No.");
        NodeTooltipField.DeleteAll(true);
    end;
}
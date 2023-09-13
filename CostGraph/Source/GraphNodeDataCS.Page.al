page 50101 "Graph Node Data CS"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Graph Node Data CS";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(TableFields)
            {
                Caption = 'Table Fields';

                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field("Include in Node Data"; Rec."Include in Node Data")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(TooltipFields)
            {
                Caption = 'Tooltip Fields';
                ApplicationArea = All;
                ToolTip = 'Select table fields which will be displayed in node tooltips';
                RunObject = page "Node Tooltip Fields CS";
                Image = SelectField;
            }
        }
    }
}

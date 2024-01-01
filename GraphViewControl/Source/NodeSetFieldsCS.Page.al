page 50101 "Node Set Fields CS"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    Caption = 'Graph Node Data';
    SourceTable = "Node Set Field CS";
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
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The system field number.';
                    Editable = false;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The name of the field.';
                    Editable = false;
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
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select table fields which will be displayed in node tooltips';
                RunObject = page "Node Tooltip Fields CS";
                RunPageLink = "Node Set Code" = field("Node Set Code");
                Image = SelectField;
            }
        }
        area(Promoted)
        {
            actionref(PromotedTooltipFields; TooltipFields) { }
        }
    }
}

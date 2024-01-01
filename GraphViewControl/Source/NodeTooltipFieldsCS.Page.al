page 50102 "Node Tooltip Fields CS"
{
    PageType = ListPart;
    SourceTable = "Node Tooltip Field CS";
    Caption = 'Tooltip Fields';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(TooltipFields)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The system field number.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The caption of the field selected for the tooltip';
                }
                field(Delimiter; Rec.Delimiter)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The delimiter added after the current field value in the tooltip, such as a whitespace or a line break.';
                }
                field("Show Caption"; Rec."Show Caption")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the field caption should be added to the tooltip. If this value is not selected, only the field value is displayed.';
                }
            }
        }
    }
}

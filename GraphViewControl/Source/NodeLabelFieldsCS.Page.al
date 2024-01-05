page 50110 "Node Label Fields CS"
{
    PageType = ListPart;
    SourceTable = "Node Text Field CS";
    SourceTableView = where(Type = const(Label));
    Caption = 'Label Fields';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(LabelFields)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The system field number.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The caption of the field selected for the node label';
                }
                field(Delimiter; Rec.Delimiter)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The delimiter added after the current field value in the label, such as a whitespace or a line break.';
                }
                field("Show Caption"; Rec."Show Caption")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the field caption should be added to the label. If this value is not selected, only the field value is displayed.';
                }
            }
        }
    }
}

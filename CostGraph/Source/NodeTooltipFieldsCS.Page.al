page 50102 "Node Tooltip Fields CS"
{
    PageType = List;
    SourceTable = "Node Tooltip Field CS";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(TooltipFields)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                }
                field(Delimiter; Rec.Delimiter)
                {
                    ApplicationArea = All;
                }
                field("Show Caption"; Rec."Show Caption")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
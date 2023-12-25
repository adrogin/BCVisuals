page 50108 "Style Sets CS"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Style Set CS";
    Caption = 'Styles';

    layout
    {
        area(Content)
        {
            repeater(Styles)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code uniquely identifying the style set.';
                }
                field(Description; Rec.Desciption)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'A text description providing basic information about the style set intent.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ViewStyles)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Styles';
                ToolTip = 'View and edit style sheets included in this set.';
                RunObject = page "Styles List CS";
                RunPageLink = "Style Set" = field(Code);
            }
        }
        area(Promoted)
        {
            actionref(StylesPromoted; ViewStyles) { }
        }
    }
}
page 50100 "Cost Source"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Settings)
            {
                Caption = 'Settings';

            }
            group(Graph)
            {
                Caption = 'Graph';

                usercontrol(GraphControl; "Graph View")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
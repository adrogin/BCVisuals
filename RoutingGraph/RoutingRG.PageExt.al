pageextension 50250 "Routing RG" extends Routing
{
    actions
    {
        addfirst("&Routing")
        {
            action(ViewAsGraph)
            {
                Caption = 'View as Graph';
                ToolTip = 'View and edit the visual layout of the routing.';
                ApplicationArea = Manufacturing;
                Image = Route;

                trigger OnAction()
                var
                    RoutingGraphPage: Page "Routing Graph RG";
                begin
                    RoutingGraphPage.SetRouting(Rec."No.", '');
                    RoutingGraphPage.Run();
                end;
            }
        }
    }
}
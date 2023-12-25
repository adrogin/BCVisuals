pageextension 50251 "Routing Graph Setup RG" extends "Graph View Setup CS"
{
    layout
    {
        addlast(Content)
        {
            group(RoutingGraphSetup)
            {
                Caption = 'Routing Graph';

                // Property is currently not supported. Graph is always rendered with the Breadth First layout.
                // field(RoutingGraphLayoutRG; Rec."Routing Graph Layout RG")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Routing Graph Layout';
                //     ToolTip = 'Select the default layout for the routing graph.';
                // }
                field("Routing Node Set RG"; Rec."Routing Node Set RG")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Routing Graph Node Set';
                    ToolTip = 'Select the default node set for the routing graph.';
                }
                field("Routing Node Style CS"; Rec."Routing Style Set RG")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Routing Graph Styles';
                    ToolTip = 'Select the default styles for the routing graph''s nodes and edges.';
                }
            }
        }
    }
}
pageextension 50150 "Graph View Setup CS" extends "Graph View Setup CS"
{
    layout
    {
        addlast(Content)
        {
            group(CostTraceSetup)
            {
                Caption = 'Cost Trace';

                field("Cost Trace Node Set CS"; Rec."Cost Trace Node Set CS")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Trace Graph Node Set';
                    ToolTip = 'Select the default node set for the cost application graph.';
                }
                field("Cost Trace Graph Layout CS"; Rec."Cost Trace Graph Layout CS")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Trace Graph Layout';
                    ToolTip = 'Select the default layout for the cost application graph.';
                }
            }
        }
    }
}
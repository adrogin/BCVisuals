pageextension 50150 "Graph View Setup CS" extends "Graph View Setup CS"
{
    layout
    {
        addlast(Content)
        {
            group(CostTraceSetup)
            {
                Caption = 'Cost Trace';

                // Property is currently not supported. Graph is always rendered with the Breadt First layout, which can be changed in the UI after rendering.
                // field("Cost Trace Graph Layout CS"; Rec."Cost Trace Graph Layout CS")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Cost Trace Graph Layout';
                //     ToolTip = 'Select the default layout for the cost application graph.';
                // }
                field("Cost Trace Node Set CS"; Rec."Cost Trace Node Set CS")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Trace Graph Node Set';
                    ToolTip = 'Select the default node set for the cost application graph.';
                }
            }
        }
    }
}
pageextension 50154 "Production Order CS" extends "Finished Production Order"
{
    actions
    {
        addlast("E&ntries")
        {
            action(TraceInboundCostApplications)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trace Inbound Cost Applications';
                ToolTip = 'Trace the inbound cost applications for all item ledger entries in the selected production order and present the cost sources in a graph view.';
                Image = Return;

                trigger OnAction()
                begin
                    CostSource.SetTraceStart(Rec);
                    CostSource.SetTraceDirection(Enum::"Cost Trace Direction CS"::Backward);
                    CostSource.Run();
                end;
            }
            action(TraceOutboundCostApplications)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trace Outbound Cost Applications';
                ToolTip = 'Trace the outbound cost applications for all item ledger entries in the selected production order and present the affected ledger entries in a graph view.';
                Image = GoTo;

                trigger OnAction()
                begin
                    CostSource.SetTraceStart(Rec);
                    CostSource.SetTraceDirection(Enum::"Cost Trace Direction CS"::Forward);
                    CostSource.Run();
                end;
            }
        }
    }
    var
        CostSource: Page "Cost Source CS";
}

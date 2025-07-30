pageextension 50167 "Posted Return Receipt CS" extends "Posted Return Receipt"
{
    actions
    {
        addlast("&Return Rcpt.")
        {
            action(TraceInboundCostApplications)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trace Inbound Cost Applications';
                ToolTip = 'Trace the inbound cost applications for all item ledger entries in the selected posted return receipt and present the cost sources in a graph view.';
                Image = Return;

                trigger OnAction()
                begin
                    NodeSourceDocument.RunCostTrace(Rec, Enum::"Cost Trace Direction CS"::Backward);
                end;
            }
            action(TraceOutboundCostApplications)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trace Outbound Cost Applications';
                ToolTip = 'Trace the outbound cost applications for all item ledger entries in the selected posted return receipt and present the affected ledger entries in a graph view.';
                Image = GoTo;

                trigger OnAction()
                begin
                    NodeSourceDocument.RunCostTrace(Rec, Enum::"Cost Trace Direction CS"::Forward);
                end;
            }
        }
    }
    var
        NodeSourceDocument: Codeunit "Node Source Document CS";
}

pageextension 50155 "Posted Sales Shipments CS" extends "Posted Sales Shipments"
{
    actions
    {
        addlast("&Shipment")
        {
            action(TraceInboundCostApplications)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trace Inbound Cost Applications';
                ToolTip = 'Trace the inbound cost applications for all item ledger entries in the selected posted sales shipment and present the cost sources in a graph view.';
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
                ToolTip = 'Trace the outbound cost applications for all item ledger entries in the selected posted sales shipment and present the affected ledger entries in a graph view.';
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

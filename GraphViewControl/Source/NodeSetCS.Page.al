page 50109 "Node Set CS"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Node Set CS";
    Caption = 'Node Set';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code uniquely identifying the node set configuration.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Text description of the node set explaining its intent';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Application table associated with this node set. Fields of the selected table can be displayed as node text or tooltips.';
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The text caption of the table associated with the node set.';
                }
            }
            part(LabelFields; "Node Label Fields CS")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Node Set Code" = field(Code);
            }
            part(TooltipFields; "Node Tooltip Fields CS")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Node Set Code" = field(Code);
            }
            part(NodeSetStyles; "Node Set Styles CS")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.NodeSetStyles.Page.SetNodeSetCode(Rec.Code);
    end;
}
page 50100 "Node Sets List CS"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Node Set CS";
    Caption = 'Graph Node Sets';
    AboutText = 'Set up graph node parameters for any table that can be displayed in a graph. Node configuration includes visualisation styles, staic node text, and tooltips.';
    CardPageId = "Node Set CS";

    layout
    {
        area(Content)
        {
            repeater(NodeSet)
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
        }
    }

    actions
    {
        area(Navigation)
        {
            action(NodeData)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Node Data';
                ToolTip = 'Set up node texts and tooltips, and node visualisation styles.';
                Image = DataEntry;
                RunObject = page "Node Set Fields CS";
                RunPageLink = "Node Set Code" = field(Code);
            }
        }

        area(Promoted)
        {
            actionref(PromotedNodeData; NodeData) { }
        }
    }
}
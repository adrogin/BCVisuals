page 50105 "Graph View Setup CS"
{
    Caption = 'Graph View Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Graph View Setup CS";

    actions
    {
        area(Navigation)
        {
            action(NodeSets)
            {
                Caption = 'Node Sets';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select table fields to be displayed in node labels and tooltips.';
                Image = Comment;
                RunObject = page "Node Sets List CS";
            }
            action(Styles)
            {
                Caption = 'Styles';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Configure distinct styles for different graph nodes.';
                Image = StyleSheet;
                RunObject = page "Styles List CS";
            }
        }
        area(Promoted)
        {
            actionref(PromotedNodeData; NodeSets) { }
            actionref(PromotedStyles; Styles) { }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
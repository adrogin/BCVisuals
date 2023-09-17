page 50104 "Selectors CS"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Selector CS";
    Caption = 'Selectors';
    AboutText = 'Selector are set of filters which are applied to graph elements (nodes or edges) to select a subset matching the provided criteria.';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code that identifies the selector';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'A text description of the selector explaining its purpose.';
                }
                field("Selector Text"; Rec."Selector Text")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The set of filters to be applied to table fields.';

                    trigger OnAssistEdit()
                    var
                        SelectorFilter: Record "Selector Filter CS";
                        GraphViewController: Codeunit "Graph View Controller CS";
                    begin
                        SelectorFilter.SetRange("Selector Code", Rec.Code);
                        if Page.RunModal(0, SelectorFilter) = Action::LookupOK then
                            Rec."Selector Text" := CopyStr(GraphViewController.FormatSelectorText(Rec.Code), 1, MaxStrLen(Rec."Selector Text"));
                    end;
                }
            }
        }
    }
}

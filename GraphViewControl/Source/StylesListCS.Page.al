page 50107 "Styles List CS"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    SourceTable = "Style CS";
    Caption = 'Styles';
    CardPageId = "Style Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code identifying the style.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Text description explaining the purpose of the style.';
                }
                field(SelectorCode; Rec."Selector Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code of the selector which will be applied to graph elements. The style will be assigned to the elements satisfying the selector.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupSelector();
                    end;
                }
                field(SelectorText; Rec."Selector Text")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Selector filters which will be applied to graph elements. The style will be assigned to the elements satisfying the selector.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupSelector();
                    end;
                }
            }
        }
    }

    local procedure LookupSelector()
    var
        Selector: Record "Selector CS";
        SelectorsPage: Page "Selectors CS";
    begin
        if Rec."Selector Code" <> '' then
            Selector.Get(Rec."Selector Code");

        SelectorsPage.LookupMode(true);
        SelectorsPage.SetTableView(Selector);
        if SelectorsPage.RunModal() = Action::LookupOK then begin
            SelectorsPage.GetRecord(Selector);
            Rec.Validate("Selector Code", Selector.Code);
        end;
    end;
}

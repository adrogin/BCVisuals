page 50108 "Node Set Styles CS"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    SourceTable = "Style Set CS";
    SourceTableView = sorting("Sorting Order") order(ascending);
    Caption = 'Styles';

    layout
    {
        area(Content)
        {
            repeater(Styles)
            {
                field(SortingOrder; Rec."Sorting Order")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order in which styles are applied to the node set. Styles applied later (higher order value) will override styles applied to the same node earler.';
                }
                field(Code; Rec."Style Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code of the style to apply to graph nodes.';

                    trigger OnValidate()
                    begin
                        if Style.Get(Rec."Style Code") then;
                    end;
                }
                field(Description; Style.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Text description explaining the purpose of the style.';
                    Editable = false;
                }
                field(SelectorCode; Style."Selector Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code of the selector which will be applied to graph elements. The style will be assigned to the elements satisfying the selector.';
                    Editable = false;
                }
                field(SelectorText; Style."Selector Text")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Selector filters which will be applied to graph elements. The style will be assigned to the elements satisfying the selector.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Stylesheet)
            {
                Caption = 'Stylesheet';

                action(StyleCard)
                {
                    Caption = 'Style';
                    ApplicationArea = All;
                    ToolTip = 'Configure the selectors and the style sheet for the selected style';
                    Image = StyleSheet;
                    RunObject = page "Style Card";
                    RunPageLink = Code = field("Style Code");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Clear(Style);
        if Rec."Style Code" = '' then
            exit;

        if Style.Get(Rec."Style Code") then;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(Style);
    end;

    var
        Style: Record "Style CS";
}

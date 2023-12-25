page 50103 "Style Card"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    SourceTable = "Style CS";
    Caption = 'Style';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                }
                field(SelectorText; Rec."Selector Text")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Selector filters which will be applied to graph elements. The style will be assigned to the elements satisfying the selector.';
                }
            }
            group(StyleSheetEditor)
            {
                Caption = 'StyleSheet';

                field(StyleSheet; StyleText)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                    RowSpan = 6;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        Rec.WriteStyleSheetText(StyleText);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleText := Rec.ReadStyleSheetText();
    end;

    var
        StyleText: Text;
}

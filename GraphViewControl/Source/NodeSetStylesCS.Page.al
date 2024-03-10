page 50108 "Node Set Styles CS"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    SourceTable = "Style CS";
    SourceTableTemporary = true;
    Caption = 'Styles';

    layout
    {
        area(Content)
        {
            repeater(Styles)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code of the style to apply to graph nodes.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupStyle(Text));
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Text description explaining the purpose of the style.';
                    Editable = false;
                }
                field(SelectorCode; Rec."Selector Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code of the selector which will be applied to graph elements. The style will be assigned to the elements satisfying the selector.';
                    Editable = false;
                }
                field(SelectorText; Rec."Selector Text")
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
                    RunPageLink = Code = field(Code);
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        StyleSet: Record "Style Set CS";
    begin
        StyleSet.Validate("Node Set Code", NodeSetCode);
        StyleSet.Validate("Style Code", Rec.Code);
        StyleSet.Insert(true);

        InitCurrentRec(Rec.Code);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        StyleSet: Record "Style Set CS";
    begin
        StyleSet."Node Set Code" := NodeSetCode;
        StyleSet."Style Code" := Rec.Code;
        StyleSet.Delete(true);
    end;

    procedure SetNodeSetCode(NewNodeSetCode: Code[20])
    begin
        NodeSetCode := NewNodeSetCode;
        InitializeSourceTable();
    end;

    local procedure InitializeSourceTable()
    var
        StyleSet: Record "Style Set CS";
    begin
        Rec.Reset();
        Rec.DeleteAll();

        StyleSet.SetRange("Node Set Code", NodeSetCode);
        if StyleSet.FindSet() then
            repeat
                InitCurrentRec(StyleSet."Style Code");
                Rec.Insert();
            until StyleSet.Next() = 0;

        //        CurrPage.Update(false);
    end;

    local procedure LookupStyle(var StyleCode: Text): Boolean
    var
        Style: Record "Style CS";
        StylesList: Page "Styles List CS";
    begin
        StylesList.LookupMode(true);
        if StylesList.RunModal() <> Action::LookupOK then
            exit(false);

        StylesList.GetRecord(Style);
        StyleCode := Style.Code;
        exit(true);
    end;

    local procedure InitCurrentRec(StyleCode: Code[20])
    var
        Style: Record "Style CS";
    begin
        Style.SetLoadFields(Code, Description, "Selector Code", "Selector Text");
        Style.Get(StyleCode);
        Rec.Copy(Style);
    end;

    var
        NodeSetCode: Code[20];
}

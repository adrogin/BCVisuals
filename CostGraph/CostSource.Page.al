page 50100 "Cost Source"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Settings)
            {
                Caption = 'Settings';

                field(EntryInfoControl; EntryInfo)
                {
                    Caption = 'Item Ledger Entry';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        CostSourceTrace: Codeunit "Cost Source Trace";
                        Nodes: JsonArray;
                        Edges: JsonArray;
                    begin
                        if SelectEntry(EntryNo) then begin
                            EntryInfo := FormatEntryInfo(EntryNo);
                            CostSourceTrace.BuildCostSourceGraph(EntryNo, Nodes, Edges);
                            CurrPage.GraphControl.DrawGraph('controlAddIn', Nodes, Edges);
                            CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(GraphViewController.GetNodeTooltipsArray(Nodes));
                            CurrPage.GraphControl.CreateTooltips();
                            CurrPage.GraphControl.BindTooltipEvents();
                        end;
                    end;
                }
                field(GraphLayoutControl; GraphLayout)
                {
                    Caption = 'Graph Layout';

                    trigger OnValidate()
                    begin
                        CurrPage.GraphControl.SetLayout(GraphViewController.GraphLayoutEnumToText(GraphLayout));
                    end;
                }
            }
            group(Graph)
            {
                Caption = 'Graph';

                usercontrol(GraphControl; "Graph View")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInit()
    begin
        GraphLayout := GraphLayout::Breadthfirst;
    end;

    local procedure SelectEntry(var NewEntryNo: Integer): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if Page.RunModal(0, ItemLedgerEntry) = Action::LookupOK then begin
            NewEntryNo := ItemLedgerEntry."Entry No.";
            exit(true);
        end;

        exit(false);
    end;

    local procedure FormatEntryInfo(EntryNo: Integer): Text
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetLoadFields("Document Type", "Document No.");
        ItemLedgerEntry.Get(EntryNo);
        exit(StrSubstNo('%1: %2 %3', EntryNo, ItemLedgerEntry."Document Type", ItemLedgerEntry."Document No."));
    end;

    var
        GraphViewController: Codeunit "Graph View Controller";
        GraphLayout: Enum "Graph Layout Name";
        EntryNo: Integer;
        EntryInfo: Text;
}
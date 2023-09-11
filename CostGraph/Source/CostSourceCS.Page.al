page 50100 "Cost Source CS"
{
    Caption = 'Cost Source';
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
                    ToolTip = 'Select an item ledger entry to trace its cost source.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        CostSourceTrace: Codeunit "Cost Application Trace CS";
                        Nodes: JsonArray;
                        Edges: JsonArray;
                    begin
                        if SelectEntry(EntryNo) then begin
                            EntryInfo := FormatEntryInfo(EntryNo);
                            CostSourceTrace.BuildCostSourceGraph(EntryNo, Nodes, Edges);
                            GraphViewController.AddNodesDisplayContent(Nodes);
                            CurrPage.GraphControl.DrawGraph('controlAddIn', Nodes, Edges);
                            CurrPage.GraphControl.CreateTooltips();
                            //CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(GraphViewController.GetNodeTooltipsArray(Nodes));
                            //CurrPage.GraphControl.CreateTooltips();
                            //CurrPage.GraphControl.BindTooltipEvents();
                        end;
                    end;
                }
                field(GraphLayoutControl; GraphLayout)
                {
                    Caption = 'Graph Layout';
                    ToolTip = 'Select the preferred graph layout which will be applied to the cost graph.';

                    trigger OnValidate()
                    begin
                        CurrPage.GraphControl.SetLayout(GraphViewController.GraphLayoutEnumToText(GraphLayout));
                    end;
                }
            }
            group(Graph)
            {
                Caption = 'Graph';

                usercontrol(GraphControl; "Graph View CS")
                {
                    ApplicationArea = All;

                    trigger OnNodeClick(NodeId: Text)
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin
                        ItemLedgerEntry.Get(GraphViewController.NodeId2ItemLedgEntryNo(NodeId));
                        Page.Run(Page::"Item Ledger Entries", ItemLedgerEntry);
                    end;
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

    local procedure FormatEntryInfo(ItemLedgEntryNo: Integer): Text
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        EntryInfoFormatTok: Label '%1: %2 %3', Comment = '%1: Entry No.; %2: Document Type; %3: Document No.';
    begin
        ItemLedgerEntry.SetLoadFields("Document Type", "Document No.");
        ItemLedgerEntry.Get(ItemLedgEntryNo);
        exit(StrSubstNo(EntryInfoFormatTok, ItemLedgEntryNo, ItemLedgerEntry."Document Type", ItemLedgerEntry."Document No."));
    end;

    var
        GraphViewController: Codeunit "Graph View Controller CS";
        GraphLayout: Enum "Graph Layout Name CS";
        EntryNo: Integer;
        EntryInfo: Text;
}

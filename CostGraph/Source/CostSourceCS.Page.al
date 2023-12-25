page 50150 "Cost Source CS"
{
    Caption = 'Cost Source';
    PageType = Card;
    ApplicationArea = Basic, Suite;
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
                            CostViewController.SetNodesData(Nodes);
                            CurrPage.GraphControl.DrawGraphWithStyles('controlAddIn', Nodes, Edges, GraphViewController.GetStylesAsJson(CostViewController.GetDefaultStyleSet()));
                            CurrPage.GraphControl.SetTooltipTextOnMultipleNodes(CostViewController.GetNodeTooltipsArray(Nodes));
                            CurrPage.GraphControl.CreateTooltips();
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
                    ApplicationArea = Basic, Suite;

                    trigger OnNodeClick(NodeId: Text)
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin
                        ItemLedgerEntry.Get(CostViewController.NodeId2ItemLedgEntryNo(NodeId));
                        Page.Run(Page::"Item Ledger Entries", ItemLedgerEntry);
                    end;
                }
            }
        }
    }

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
                RunObject = page "Node Sets CS";
            }
            action(Styles)
            {
                Caption = 'Styles';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Configure distinct styles for different graph nodes.';
                Image = StyleSheet;
                RunObject = page "Style Sets CS";
            }
            action(GraphViewSetup)
            {
                Caption = 'Graph View Setup';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Configure the graph presentation parameters, such as node labels, tooltips, and graph element styles.';
                Image = Setup;
                RunObject = page "Graph View Setup CS";
            }
        }
        area(Promoted)
        {
            actionref(PromotedGraphViewSetup; GraphViewSetup) { }
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
        CostViewController: Codeunit "Cost View Controller CS";
        GraphLayout: Enum "Graph Layout Name CS";
        EntryNo: Integer;
        EntryInfo: Text;
}

codeunit 50152 "Appln. Worksheet - Edit CS"
{
    procedure BuildApplnWorksheetGraph(var FilteredItemLedgEntry: Record "Item Ledger Entry"; var Nodes: JsonArray; var Edges: JsonArray)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        CostApplicationTrace: Codeunit "Cost Application Trace CS";
    begin
        ItemLedgerEntry.CopyFilters(FilteredItemLedgEntry);
        if ItemLedgerEntry.FindSet() then
            repeat
                CostApplicationTrace.TraceCostBackward(ItemLedgerEntry, 1);
            until ItemLedgerEntry.Next() = 0;

        CostApplicationTrace.GetGraphElements(Nodes, Edges);
    end;

    procedure OpenGraphView(var ItemLdgerEntry: Record "Item Ledger Entry")
    var
        ILEApplication: Page "ILE Application CS";
    begin
        ILEApplication.SetItemLedgEntryFilters(ItemLdgerEntry);
        ILEApplication.Run();
    end;

    procedure ApplyRec(GraphEdge: JsonObject): Boolean
    begin
        exit(RunCodeunitWithJsonParam(Codeunit::"Apply Item Ledger Entries CS", GraphEdge));
    end;

    procedure RemoveApplications(GraphEdge: JsonObject): Boolean
    begin
        exit(RunCodeunitWithJsonParam(Codeunit::"Unapply Item Ledger Entries CS", GraphEdge));
    end;

    local procedure RunCodeunitWithJsonParam(CodeunitNo: Integer; JObject: JsonObject): Boolean
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
        JsonText: Text;
    begin
        JObject.WriteTo(JsonText);
        TempJsonBuffer.SetValueWithoutModifying(JsonText);
        exit(Codeunit.Run(CodeunitNo, TempJsonBuffer));
    end;

    procedure ApplyRec(SourceEntryNo: Integer; TargetEntryNo: Integer)
    var
        SourceItemLedgerEntry: Record "Item Ledger Entry";
        TargetItemLedgerEntry: Record "Item Ledger Entry";
        NoAvailableQtyToApplyErr: Label 'No available quantitiy to apply.';
    begin
        if SourceEntryNo <> 0 then begin
            TargetItemLedgerEntry.Get(TargetEntryNo);
            SourceItemLedgerEntry.Get(SourceEntryNo);
            ItemJnlPostLine.ReApply(SourceItemLedgerEntry, TargetEntryNo);
            ItemJnlPostLine.LogApply(SourceItemLedgerEntry, TargetItemLedgerEntry);
        end;

        if TargetItemLedgerEntry.Positive then
            RemoveDuplicateApplication(TargetEntryNo);

        if not VerifyEntriesApplied(SourceItemLedgerEntry, TargetItemLedgerEntry) then
            Error(NoAvailableQtyToApplyErr);
    end;

    procedure RemoveApplications(Inbound: Integer; Outbound: Integer)
    var
        Application: Record "Item Application Entry";
    begin
        Application.SetCurrentKey("Inbound Item Entry No.", "Outbound Item Entry No.");
        Application.SetRange("Inbound Item Entry No.", Inbound);
        Application.SetRange("Outbound Item Entry No.", Outbound);
        if Application.FindSet() then
            repeat
                ItemJnlPostLine.UnApply(Application);
                ItemJnlPostLine.LogUnapply(Application);
            until Application.Next() = 0;
    end;

    procedure EvaluateTextToInt(TextValue: Text) IntValue: Integer
    begin
        Evaluate(IntValue, TextValue);
    end;

    local procedure RemoveDuplicateApplication(ItemLedgerEntryNo: Integer)
    var
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        ItemApplicationEntry.SetCurrentKey("Inbound Item Entry No.", "Item Ledger Entry No.", "Outbound Item Entry No.", "Cost Application");
        ItemApplicationEntry.SetRange("Inbound Item Entry No.", ItemLedgerEntryNo);
        ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        ItemApplicationEntry.SetFilter("Outbound Item Entry No.", '<>0');
        if not ItemApplicationEntry.IsEmpty() then begin
            ItemApplicationEntry.SetRange("Outbound Item Entry No.", 0);
            ItemApplicationEntry.DeleteAll();
        end
    end;

    local procedure VerifyEntriesApplied(SourceItemLedgerEntry: Record "Item Ledger Entry"; TargetItemLedgerEntry: Record "Item Ledger Entry"): Boolean
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if SourceItemLedgerEntry.Positive then begin
            ItemApplnEntry.SetRange("Inbound Item Entry No.", SourceItemLedgerEntry."Entry No.");
            ItemApplnEntry.SetRange("Outbound Item Entry No.", TargetItemLedgerEntry."Entry No.");
        end
        else begin
            ItemApplnEntry.SetRange("Inbound Item Entry No.", TargetItemLedgerEntry."Entry No.");
            ItemApplnEntry.SetRange("Outbound Item Entry No.", SourceItemLedgerEntry."Entry No.");
        end;

        exit(not ItemApplnEntry.IsEmpty());
    end;

    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
}

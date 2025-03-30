codeunit 50154 "Unapply Item Ledger Entries CS"
{
    TableNo = "JSON Buffer";

    trigger OnRun()
    var
        GraphEdge: JsonObject;
    begin
        GraphEdge.ReadFrom(Rec.GetValue());
        RemoveApplications(GraphEdge);
    end;

    local procedure RemoveApplications(GraphEdge: JsonObject)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        GraphJsonObject: Codeunit "Graph Json Object";
        SourceId, TargetId : Integer;
    begin
        SourceId := ApplnWorksheetEdit.EvaluateTextToInt(GraphJsonObject.GetValueFromObject(GraphEdge.AsToken(), 'source'));
        TargetId := ApplnWorksheetEdit.EvaluateTextToInt(GraphJsonObject.GetValueFromObject(GraphEdge.AsToken(), 'target'));
        ItemLedgerEntry.Get(SourceId);

        if ItemLedgerEntry.Positive then
            ApplnWorksheetEdit.RemoveApplications(SourceId, TargetId)
        else
            ApplnWorksheetEdit.RemoveApplications(TargetId, SourceId);
    end;

    procedure GetContext(var ApplnWorksheetEditInstance: Codeunit "Appln. Worksheet - Edit CS")
    begin
        ApplnWorksheetEditInstance := ApplnWorksheetEdit;
    end;

    procedure SetContext(ApplnWorksheetEditInstance: Codeunit "Appln. Worksheet - Edit CS")
    begin
        ApplnWorksheetEdit := ApplnWorksheetEditInstance;
    end;

    var
        ApplnWorksheetEdit: Codeunit "Appln. Worksheet - Edit CS";
}
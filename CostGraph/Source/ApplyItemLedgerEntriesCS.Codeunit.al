codeunit 50153 "Apply Item Ledger Entries CS"
{
    TableNo = "JSON Buffer";

    trigger OnRun()
    var
        GraphJsonObject: Codeunit "Graph Json Object";
        GraphEdge: JsonObject;
    begin
        GraphEdge.ReadFrom(Rec.GetValue());
        ApplnWorksheetEdit.ApplyRec(
            ApplnWorksheetEdit.EvaluateTextToInt(GraphJsonObject.GetValueFromObject(GraphEdge.AsToken(), 'source')),
            ApplnWorksheetEdit.EvaluateTextToInt(GraphJsonObject.GetValueFromObject(GraphEdge.AsToken(), 'target')));
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
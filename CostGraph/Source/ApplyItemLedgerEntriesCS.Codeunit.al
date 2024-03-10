codeunit 50153 "Apply Item Ledger Entries CS"
{
    TableNo = "JSON Buffer";

    trigger OnRun()
    var
        GraphnodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
        GraphEdge: JsonObject;
    begin
        GraphEdge.ReadFrom(Rec.GetValue());
        ApplnWorksheetEdit.ApplyRec(
            ApplnWorksheetEdit.EvaluateTextToInt(GraphNodeDataMgt.GetValueFromObject(GraphEdge.AsToken(), 'source')),
            ApplnWorksheetEdit.EvaluateTextToInt(GraphNodeDataMgt.GetValueFromObject(GraphEdge.AsToken(), 'target')));
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
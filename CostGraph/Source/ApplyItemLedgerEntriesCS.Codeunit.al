codeunit 50153 "Apply Item Ledger Entries CS"
{
    TableNo = "JSON Buffer";

    trigger OnRun()
    var
        ApplnWorksheetEdit: Codeunit "Appln. Worksheet - Edit CS";
        GraphnodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
        GraphEdge: JsonObject;
    begin
        GraphEdge.ReadFrom(Rec.GetValue());
        ApplnWorksheetEdit.ApplyRec(
            ApplnWorksheetEdit.EvaluateTextToInt(GraphNodeDataMgt.GetValueFromObject(GraphEdge.AsToken(), 'source')),
            ApplnWorksheetEdit.EvaluateTextToInt(GraphNodeDataMgt.GetValueFromObject(GraphEdge.AsToken(), 'target')));
    end;
}
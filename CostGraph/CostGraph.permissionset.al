permissionset 50100 CostGraph
{
    Caption = 'Cost Graph';
    Assignable = true;

    Permissions = tabledata "Graph Node Data CS" = RIMD,
        tabledata "Item Cost Flow Buf. CS" = RIMD,
        table "Graph Node Data CS" = X,
        table "Item Cost Flow Buf. CS" = X,
        codeunit "Cost Application Trace CS" = X,
        codeunit "Graph View Controller CS" = X,
        page "Cost Source CS" = X,
        page "Graph Node Data CS" = X,
        tabledata "Node Tooltip Field CS" = RIMD,
        table "Node Tooltip Field CS" = X,
        codeunit "Graph Setup - Initialize" = X,
        tabledata "Selector CS" = RIMD,
        tabledata "Selector Filter CS" = RIMD,
        tabledata "Style CS" = RIMD,
        table "Selector CS" = X,
        table "Selector Filter CS" = X,
        table "Style CS" = X,
        page "Node Tooltip Fields CS" = X,
        page "Selectors CS" = X;
}
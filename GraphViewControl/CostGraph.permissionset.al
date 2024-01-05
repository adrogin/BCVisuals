permissionset 50100 CostGraph
{
    Caption = 'Cost Graph';
    Assignable = true;
    Permissions = tabledata "Node Set Field CS" = RIMD,
        table "Node Set Field CS" = X,
        codeunit "Graph View Controller CS" = X,
        page "Node Set Fields CS" = X,
        tabledata "Node Text Field CS" = RIMD,
        table "Node Text Field CS" = X,
        tabledata "Selector CS" = RIMD,
        tabledata "Selector Filter CS" = RIMD,
        tabledata "Style CS" = RIMD,
        table "Selector CS" = X,
        table "Selector Filter CS" = X,
        table "Style CS" = X,
        page "Node Tooltip Fields CS" = X,
        page "Selectors CS" = X,
        tabledata "Node Set CS" = RIMD,
        table "Node Set CS" = X,
        page "Node Sets List CS" = X,
        page "Selector Filters CS" = X,
        page "Style Card" = X,
        page "Styles List CS" = X,
        tabledata "Graph View Setup CS" = RIMD,
        table "Graph View Setup CS" = X,
        codeunit "Graph Node Data Mgt. CS" = X,
        tabledata "Style Set CS" = RIMD,
        table "Style Set CS" = X,
        page "Graph View Setup CS" = X;
}
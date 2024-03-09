pageextension 50151 "Appln. Worksheet CS" extends "Application Worksheet"
{
    actions
    {
        addlast(processing)
        {
            action(ViewAsGraph)
            {
                Caption = 'View as graph';
                Image = ApplyEntries;
                ToolTip = 'View and edit the application worksheet in a graph layout.';
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                var
                    ApplnWorksheetEdit: Codeunit "Appln. Worksheet - Edit CS";
                begin
                    ApplnWorksheetEdit.OpenGraphView(Rec);
                end;
            }
        }
    }
}
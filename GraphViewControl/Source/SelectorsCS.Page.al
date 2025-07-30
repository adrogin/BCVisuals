page 50104 "Selectors CS"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Selector CS";
    Caption = 'Selectors';
    AboutText = 'Selector are set of filters which are applied to graph elements (nodes or edges) to select a subset matching the provided criteria.';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The code that identifies the selector';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'A text description of the selector explaining its purpose.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The ID of the table this selector applies to.';

                    trigger OnValidate()
                    begin
                        TableName := GetTableName(Rec."Table No.");
                    end;
                }
                field(TableName; TableName)
                {
                    Caption = 'Table Name';
                    ToolTip = 'The name of the table this selector applies to.';
                    Editable = false;
                }
                field("Selector Text"; Rec."Selector Text")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The set of filters to be applied to table fields.';

                    trigger OnAssistEdit()
                    var
                        SelectorFilter: Record "Selector Filter CS";
                        GraphDataManagement: Codeunit "Graph Data Management CS";
                    begin
                        SelectorFilter.SetRange("Selector Code", Rec.Code);
                        if Page.RunModal(0, SelectorFilter) = Action::LookupOK then
                            Rec."Selector Text" := CopyStr(GraphDataManagement.FormatSelectorText(Rec.Code), 1, MaxStrLen(Rec."Selector Text"));
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TableName := GetTableName(Rec."Table No.");
    end;

    local procedure GetTableName(TableNo: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TableNo = 0 then
            exit('');

        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableNo);
        exit(AllObjWithCaption."Object Caption");
    end;

    var
        TableName: Text;
}

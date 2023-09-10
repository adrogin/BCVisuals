page 50101 "Graph Node Data CS"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Graph Node Data CS";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(TableFields)
            {
                Caption = 'Table Fields';

                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field("Include in Node Data"; Rec."Include in Node Data")
                {
                    ApplicationArea = All;
                }
                field("Show in Node Data"; Rec."Show in Node Data")
                {
                    ApplicationArea = All;
                }
                field("Show in Static Text"; Rec."Show in Static Text")
                {
                    ApplicationArea = All;
                }
                field("Show in Tooltip"; Rec."Show in Tooltip")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

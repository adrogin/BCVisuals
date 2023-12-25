page 50106 "Selector Filters CS"
{
    Caption = 'Selector Filters';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Selector Filter CS";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(FieldNo; Rec."Field No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The system number of the field the filter will be applied to.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The name of the field the filter will be applied to.';
                }
                field(FieldFilter; Rec."Field Filter")
                {
                    Caption = 'Filter';
                    ToolTip = 'The filter to apply to the selected field. Filters should follow the conventions defined in the Cytoscape documentation: https://js.cytoscape.org/#selectors/data';
                }
            }
        }
    }
}

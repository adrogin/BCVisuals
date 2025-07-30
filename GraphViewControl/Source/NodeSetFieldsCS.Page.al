page 50101 "Node Set Fields CS"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Caption = 'Graph Node Data';
    SourceTable = "Node Set Field CS";
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
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The system field number.';
                    Editable = false;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The name of the field.';
                    Editable = false;
                }
                field("Include in Node Data"; Rec."Include in Node Data")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select this value if you want the field to be included in the node data structure. Selected fields can be used in style selectors.';
                    Editable = CanExcludeField;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(TooltipFields)
            {
                Caption = 'Tooltip Fields';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select table fields which will be displayed in node tooltips';
                RunObject = page "Node Tooltip Fields CS";
                RunPageLink = "Node Set Code" = field("Node Set Code");
                Image = SelectField;
            }
        }
        area(Promoted)
        {
            actionref(PromotedTooltipFields; TooltipFields) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CanExcludeField := GraphNodeDataMgt.CanRemoveFieldFromNodeData(Rec."Node Set Code", Rec."Field No.");
    end;

    var
        GraphNodeDataMgt: Codeunit "Graph Node CS";
        CanExcludeField: Boolean;
}

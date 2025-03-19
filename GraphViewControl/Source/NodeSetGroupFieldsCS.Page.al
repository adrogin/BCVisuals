page 50111 "Node Set Group Fields CS"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Node Set Group Field CS";
    Caption = 'Group Fields';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;

                field(FieldNoControl; Rec."Field No.")
                {
                    ToolTip = 'Table fields to group graph nodes on.';
                }
                field(CaptionControl; FieldCaption)
                {
                    Editable = false;
                    Caption = 'Field Caption';
                    ToolTip = 'Table fields to group graph nodes on.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FieldCaption := GetFieldCaption(Rec."Node Set Code", Rec."Field No.");
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FieldCaption := GetFieldCaption(Rec."Node Set Code", Rec."Field No.");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        FieldCaption := '';
    end;

    local procedure GetFieldCaption(NodeSetCode: Code[20]; FieldNo: Integer): Text
    var
        NodeSet: Record "Node Set CS";
        RecRef: RecordRef;
    begin
        if NodeSetCode = '' then
            exit('');

        NodeSet.Get(NodeSetCode);
        if NodeSet."Table No." = 0 then
            exit('');

        RecRef.Open(NodeSet."Table No.");
        exit(RecRef.Field(FieldNo).Caption());
    end;

    var
        FieldCaption: Text;
}
table 50103 "Selector CS"
{
    Caption = 'Selector';
    LookupPageId = "Selectors CS";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Selector Text"; Text[1024])
        {
            Caption = 'Selector Text';
        }
        field(4; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}

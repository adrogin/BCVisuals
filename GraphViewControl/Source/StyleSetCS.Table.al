table 50107 "Style Set CS"
{
    DataClassification = CustomerContent;
    LookupPageId = "Style Sets CS";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Style Set';
            NotBlank = true;
        }
        field(2; Desciption; Text[100])
        {
            Caption = 'Description';
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
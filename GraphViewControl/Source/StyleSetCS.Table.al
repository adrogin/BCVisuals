table 50107 "Style Set CS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Node Set Code"; Code[20])
        {
            Caption = 'Node Set Code';
            TableRelation = "Node Set CS".Code;
            NotBlank = true;
        }
        field(2; "Style Code"; Code[20])
        {
            Caption = 'Style Code';
            TableRelation = "Style CS".Code;
            NotBlank = true;
        }
    }

    keys
    {
        key(PK; "Node Set Code", "Style Code")
        {
            Clustered = true;
        }
    }
}
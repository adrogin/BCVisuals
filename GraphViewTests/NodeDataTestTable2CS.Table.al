table 60101 "Node Data Test Table 2 CS"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "PK Guid Field"; Guid)
        {
        }
        field(2; "Media Field"; Media)
        {
        }
        field(3; "AlphanumericFieldName123"; Text[30])
        {
        }
        field(4; "Non-Alphanumeric Field Name"; Text[30])
        {
        }
    }

    keys
    {
        key(PK; "PK Guid Field")
        {
            Clustered = true;
        }
    }
}
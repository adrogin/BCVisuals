table 60100 "Node Data Test Table CS"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "PK Code Field"; Code[20])
        {
        }
        field(2; "PK Integer Field"; Integer)
        {
        }
        field(3; "Code Field"; Code[20])
        {
        }
        field(4; "Decimal Field"; Decimal)
        {
        }
        field(5; "BLOB Field"; Blob)
        {
        }
        field(6; "Obsolete Field"; Integer)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Used in tests to verify handling of obsoleted fields';
        }
    }

    keys
    {
        key(PK; "PK Code Field", "PK Integer Field")
        {
            Clustered = true;
        }
    }
}
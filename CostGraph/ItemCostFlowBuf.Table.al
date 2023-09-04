table 50100 "Item Cost Flow Buf."
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "From Item Ledg. Entry No."; Integer)
        {
            Caption = 'From Item Ledg. Entry No.';
        }
        field(3; "To Item Ledg. Entry No."; Integer)
        {
            Caption = 'To Item Ledg. Entry No.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(FlowEntries; "From Item Ledg. Entry No.", "To Item Ledg. Entry No.") { }
    }
}

tableextension 50150 "Graph View Setup CS" extends "Graph View Setup CS"
{
    fields
    {
        field(50150; "Cost Trace Node Set CS"; Code[20])
        {
            Caption = 'Cost Trace Node Set';
            TableRelation = "Node Set CS".Code where("Table No." = const(Database::"Item Ledger Entry"));
        }
        field(50151; "Cost Trace Style Set CS"; Code[20])
        {
            Caption = 'Cost Trace Style Set';
            TableRelation = "Style Set CS";
        }
        field(50152; "Cost Trace Graph Layout CS"; Enum "Graph Layout Name CS")
        {
            Caption = 'Cost Trace Graph Layout';
        }
    }
}
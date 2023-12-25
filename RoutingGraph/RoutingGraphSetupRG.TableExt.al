tableextension 50250 "Routing Graph Setup RG" extends "Graph View Setup CS"
{
    fields
    {
        field(50250; "Routing Node Set RG"; Code[20])
        {
            Caption = 'Routing Node Set';
            TableRelation = "Node Set CS".Code where("Table No." = const(Database::"Routing Line"));
        }
        field(50251; "Routing Style Set RG"; Code[20])
        {
            Caption = 'Routing Style Set';
            TableRelation = "Style Set CS";
        }
        field(50252; "Routing Graph Layout RG"; Enum "Graph Layout Name CS")
        {
            Caption = 'Routing Graph Layout';
        }
    }
}
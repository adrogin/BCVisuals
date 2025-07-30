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
        field(3; "Sorting Order"; Integer)
        {
            Caption = 'Sorting Order';
        }
    }

    keys
    {
        key(PK; "Node Set Code", "Style Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        Style: Record "Style CS";
        SelectorFilter: Record "Selector Filter CS";
    begin
        Style.SetLoadFields("Selector Code");
        Style.Get("Style Code");

        SelectorFilter.SetLoadFields("Field No.");
        SelectorFilter.SetRange("Selector Code", Style."Selector Code");
        if SelectorFilter.FindSet() then
            repeat
                if SelectorFilter."Field No." <> 0 then
                    GraphNodeDataMgt.UpdateNodeSetFieldInData("Node Set Code", SelectorFilter."Field No.", true);
            until SelectorFilter.Next() = 0;
    end;

    trigger OnDelete()
    var
        Style: Record "Style CS";
        SelectorFilter: Record "Selector Filter CS";
    begin
        Style.Get("Style Code");
        SelectorFilter.SetRange("Selector Code", Style."Selector Code");
        if SelectorFilter.FindSet() then
            repeat
                GraphNodeDataMgt.RemoveFieldFromNodeDataIfNotNeeded("Node Set Code", SelectorFilter."Field No.", Enum::"Node Text Type CS"::None, SelectorFilter."Selector Code");
            until SelectorFilter.Next() = 0;
    end;

    var
        GraphNodeDataMgt: Codeunit "Graph Node CS";
}
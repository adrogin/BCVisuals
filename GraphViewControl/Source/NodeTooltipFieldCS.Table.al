table 50102 "Node Tooltip Field CS"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Node Set Code"; Code[20])
        {
            Caption = 'Node Set Code';
            TableRelation = "Node Set CS";
        }
        field(2; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = "Node Set Field CS"."Field No." where("Node Set Code" = field("Node Set Code"));
        }
        field(4; "Field Caption"; Text[80])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(5; Delimiter; Option)
        {
            Caption = 'Delimiter';
            OptionMembers = "None","Space","New Line";
            OptionCaption = 'None,Space,New Line';
        }
        field(6; "Show Caption"; Boolean)
        {
            Caption = 'Show Caption';
        }
        field(7; "Table No."; Integer)
        {
            Caption = 'Table No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Node Set CS"."Table No." where(Code = field("Node Set Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Node Set Code", "Sequence No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if Rec."Field No." <> 0 then
            GraphNodeDataMgt.UpdateNodeSetFieldInData("Node Set Code", "Field No.", true);
    end;

    trigger OnModify()
    var
        xNodeTooltipField: Record "Node Tooltip Field CS";
    begin
        xNodeTooltipField.SetLoadFields("Field No.");
        xNodeTooltipField.Get(Rec."Node Set Code", Rec."Sequence No.");
        if xNodeTooltipField."Field No." <> Rec."Field No." then begin
            if Rec."Field No." <> 0 then
                GraphNodeDataMgt.UpdateNodeSetFieldInData("Node Set Code", "Field No.", true);

            if GraphNodeDataMgt.CanRemoveFieldFromNodeData(xNodeTooltipField."Node Set Code", xNodeTooltipField."Field No.") then
                if not GraphNodeDataMgt.IsFieldRequiredInSelectorFilters(xNodeTooltipField."Node Set Code", xNodeTooltipField."Field No.", '') then
                    GraphNodeDataMgt.UpdateNodeSetFieldInData(xNodeTooltipField."Node Set Code", xNodeTooltipField."Field No.", false);
        end;
    end;

    trigger OnDelete()
    begin
        if GraphNodeDataMgt.CanRemoveFieldFromNodeData(Rec."Node Set Code", Rec."Field No.") then
            if not GraphNodeDataMgt.IsFieldRequiredInSelectorFilters(Rec."Node Set Code", Rec."Field No.", '') then
                GraphNodeDataMgt.UpdateNodeSetFieldInData("Node Set Code", "Field No.", false);
    end;

    var
        GraphNodeDataMgt: Codeunit "Graph Node Data Mgt. CS";
}

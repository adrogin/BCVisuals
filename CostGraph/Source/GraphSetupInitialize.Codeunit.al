codeunit 50102 "Graph Setup - Initialize"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        GraphNodeData: Record "Graph Node Data CS";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TableField: Record Field;
    begin
        GraphNodeData.DeleteAll();

        TableField.SetRange(TableNo, Database::"Item Ledger Entry");
        TableField.SetFilter(Type, '<>%1&<>%2', TableField.Type::BLOB, TableField.Type::DateFormula);
        TableField.SetFilter(Class, '<>%1', TableField.Class::FlowFilter);
        TableField.FindSet();
        repeat
            GraphNodeData.Init();
            GraphNodeData.Validate("Table No.", TableField.TableNo);
            GraphNodeData.Validate("Field No.", TableField."No.");

            if TableField."No." in [
                ItemLedgerEntry.FieldNo("Entry No."),
                ItemLedgerEntry.FieldNo("Document Type"),
                ItemLedgerEntry.FieldNo("Document No."),
                ItemLedgerEntry.FieldNo("Entry Type"),
                ItemLedgerEntry.FieldNo(Positive)]
            then
                GraphNodeData.Validate("Include in Node Data", true);

            GraphNodeData.Insert(true);
        until TableField.Next() = 0;

        InitTooltipFields();
    end;

    local procedure InitTooltipFields()
    var
        NodeTooltipField: Record "Node Tooltip Field CS";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        NodeTooltipField.DeleteAll();

        InsertTooltipField(10000, ItemLedgerEntry.FieldNo("Entry Type"), NodeTooltipField.Delimiter::"New Line");
        InsertTooltipField(20000, ItemLedgerEntry.FieldNo("Document Type"), NodeTooltipField.Delimiter::Space);
        InsertTooltipField(30000, ItemLedgerEntry.FieldNo("Document No."), NodeTooltipField.Delimiter::None);
    end;

    local procedure InsertTooltipField(SequenceNo: Integer; FieldNo: Integer; FieldDelimiter: Option)
    var
        NodeTooltipField: Record "Node Tooltip Field CS";
    begin
        NodeTooltipField.Validate("Sequence No.", SequenceNo);
        NodeTooltipField.Validate("Field No.", FieldNo);
        NodeTooltipField.Validate(Delimiter, FieldDelimiter);
        NodeTooltipField.Insert(true);
    end;
}

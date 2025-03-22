codeunit 60151 "Library - Data Mocks"
{
    Permissions = tabledata "Item Ledger Entry" = i;

    procedure MockItemLedgerEntry(EntryNo: Integer; DocumentNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry."Entry No." := EntryNo;
        ItemLedgerEntry."Document No." := DocumentNo;
        ItemLedgerEntry.Insert();
    end;
}
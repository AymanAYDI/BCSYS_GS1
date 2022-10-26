pageextension 50006 "BC6_CustomerLedgerEntries" extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("BC6_Applies-to ID Code"; Rec."BC6_Applies-to ID Code") { }
        }
    }
}

pageextension 50007 "BC6_VendorLedgerEntries" extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("BC6_Applies-to ID Code"; Rec."BC6_Applies-to ID Code") { }
        }
    }
}

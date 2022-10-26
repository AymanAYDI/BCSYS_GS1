pageextension 50009 "BC6_DetailedVendorLedgEntries" extends "Detailed Vendor Ledg. Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("BC6_Applies-to ID Code"; Rec."BC6_Applies-to ID Code") { }
        }
    }
}

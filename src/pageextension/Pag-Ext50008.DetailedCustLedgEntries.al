pageextension 50008 "BC6_DetailedCustLedgEntries" extends "Detailed Cust. Ledg. Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("BC6_Applies-to ID Code"; Rec."BC6_Applies-to ID Code") { }
        }
    }
}

pageextension 50007 "BC6__Det. Vend. Ledg. Entries" extends "Detailed Vendor Ledg. Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("BC6_Applies-to ID Code"; Rec."BC6_Applies-to ID Code") { }
        }
    }


}

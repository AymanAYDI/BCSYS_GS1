pageextension 50006 "BC6_Det. Cust. Ledg. Entries" extends "Detailed Cust. Ledg. Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("BC6_Applies-to ID Code"; Rec."BC6_Applies-to ID Code") { }
        }
    }

}

tableextension 50006 "BC6_DetailedCustLedgEntry" extends "Detailed Cust. Ledg. Entry"
{
    fields
    {
        field(50000; "BC6_Applies-to ID Code"; Text[10])
        {
            Caption = 'Applies-to ID Code';
            DataClassification = CustomerContent;
        }
    }
}

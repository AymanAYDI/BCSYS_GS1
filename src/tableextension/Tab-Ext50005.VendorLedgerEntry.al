tableextension 50005 "BC6_VendorLedgerEntry" extends "Vendor Ledger Entry"
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

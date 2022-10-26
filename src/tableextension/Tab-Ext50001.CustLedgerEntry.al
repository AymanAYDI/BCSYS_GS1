tableextension 50001 "BC6_CustLedgerEntry" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50000; "BC6_Applies-to ID Code"; Text[10])
        {
            Caption = 'Applies-to ID Code', Comment = 'FRA="Code ID lettrage"';
            DataClassification = CustomerContent;
        }
    }
}

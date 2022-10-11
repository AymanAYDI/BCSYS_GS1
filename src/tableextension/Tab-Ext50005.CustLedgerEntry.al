tableextension 50005 "BC6_CustLedgerEntry" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50000; BC6_letter; Text[4])
        {
            Caption = 'letter', Comment = '"FRA=Lettre"';
            DataClassification = CustomerContent;
        }
    }
}

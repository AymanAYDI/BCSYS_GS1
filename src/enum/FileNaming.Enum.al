enum 50002 "File Naming"
{
    Extensible = true;

    value(0; Standard)
    {
        Caption = 'Standard', Comment = 'FRA="Standard"';
    }
    value(1; Invoice)
    {
        Caption = 'Invoice', Comment = 'FRA="Facture"';
    }
    value(2; "Credit Memo")
    {
        Caption = 'Credit Memo', Comment = 'FRA="Avoir"';
    }
    value(3; Customer)
    {
        Caption = 'Customer', Comment = 'FRA="Client"';
    }
}

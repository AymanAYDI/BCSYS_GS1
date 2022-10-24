enum 50006 "BC6_Document Type"
{
    Extensible = true;
    Caption = 'Document Type', Comment = 'FRA="Type document"';

    value(0; " ") { Caption = ' '; }

    value(1; "Payment") { Caption = 'Payment', Comment = 'FRA="Paiement"'; ; }

    value(2; "Invoice") { Caption = 'Invoice', Comment = 'FRA="Facture"'; ; }
    value(3; "Credit Memo") { Caption = 'Credit Memo', Comment = 'FRA="Avoir"'; ; }
}

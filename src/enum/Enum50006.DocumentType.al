enum 50006 "BC6_Document Type"
{
    Extensible = true;
    Caption = 'Document Type';

    value(0; " ") { Caption = 'None'; }

    value(1; "Payment") { Caption = 'Payment'; }

    value(2; "Invoice") { Caption = 'Invoice'; }
    value(3; "Credit Memo") { Caption = 'Credit Memo'; }
}

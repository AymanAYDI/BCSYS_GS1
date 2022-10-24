enum 50010 "BC6_ImportTypeNDF/Paie"
{

    Extensible = true;
    Caption = 'ImportTypeNDF/Paie', Comment = 'FRA="Type d''import"';

    value(0; "Expense") { Caption = 'Expense', Comment = '"Note de frais"'; }

    value(1; "Payroll") { Caption = 'Payroll', Comment = '"Paie"'; }
}

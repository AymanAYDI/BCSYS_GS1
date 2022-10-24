enum 50009 "BC6_Account Type"
{
    Extensible = true;
    Caption = 'Account Type', Comment = 'FRA="Type compte"';

    value(0; "G/L Account") { Caption = 'G/L Account', Comment = 'FRA="Général"'; }

    value(1; "Customer") { Caption = 'Customer', Comment = 'FRA="Client"'; }

    value(2; "Vendor") { Caption = 'Vendor', Comment = 'FRA="Fournisseur"'; }
    value(3; "Dimension") { Caption = 'Dimension', Comment = 'FRA="Analytique"'; }
}

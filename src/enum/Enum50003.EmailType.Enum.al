enum 50003 "Email Type"
{
    Extensible = true;

    value(0; "To")
    {
        Caption = 'To', Comment = 'FRA="A"';
    }
    value(1; Cc)
    {
        Caption = 'Cc', Comment = 'FRA="Cc"';
    }
    value(2; Bcc)
    {
        Caption = 'Bcc', Comment = 'FRA="Cci"';
    }
    value(3; From)
    {
        Caption = 'From', Comment = 'FRA="De"';
    }
}

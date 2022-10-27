enum 50003 "BC6_Message Status.Enum"
{
    Extensible = true;

    value(0; Success)
    {
        Caption = 'Success', Comment = 'FRA="Succès"';
    }
    value(1; Error)
    {
        Caption = 'Error', Comment = 'FRA="Erreur"';
    }
    value(2; Information)
    {
        Caption = 'Information', Comment = 'FRA="Information"';
    }
    value(3; Warning)
    {
        Caption = 'Warning', Comment = 'FRA="Attention"';
    }
}

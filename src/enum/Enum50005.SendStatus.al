enum 50005 "BC6_Send Status"
{
    Extensible = true;
    Caption = 'Send Status', Comment = 'FRA=="Statut d''envoi"';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Sent)
    {
        Caption = 'Sent', Comment = 'FRA="Envoyé"';
    }
    value(2; "Not Sent")
    {
        Caption = 'Not Sent', Comment = 'FRA="Non Envoyé"';
    }
}

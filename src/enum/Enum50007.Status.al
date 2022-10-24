enum 50007 "BC6_Status"
{
    Extensible = true;
    Caption = 'Status', Comment = 'FRA="Statut"';

    value(0; "On Hold") { Caption = 'On Hold', Comment = 'FRA="En attente"'; }

    value(1; "Error") { Caption = 'Error', Comment = 'FRA="Erreur"'; }

    value(2; "Check") { Caption = 'Check', Comment = 'FRA="Prêt"'; }
    value(3; "Post") { Caption = 'Post', Comment = 'FRA="Traité"'; }
}

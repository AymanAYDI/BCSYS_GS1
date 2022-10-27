tableextension 50010 "BC6_SalesCrMemoHeader" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50000; "BC6_Invoice Title"; Code[20])
        {
            Caption = 'Invoice Title', Comment = 'FRA="Titre facture"';
            TableRelation = "Standard Text".Code;
            DataClassification = CustomerContent;
        }
        field(50001; "BC6_Send Status"; enum "BC6_Send Status")
        {
            Caption = 'Send Status', Comment = 'FRA="Statut d''envoi"';
            DataClassification = CustomerContent;
        }
    }
}

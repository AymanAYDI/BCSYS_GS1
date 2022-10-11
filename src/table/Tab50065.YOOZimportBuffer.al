table 50065 "BC6_YOOZ import Buffer"
{
    Caption = 'YOOZ import Buffer', Comment = 'FRA="Tampon import YOOZ"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', Comment = 'FRA="N° séquence"';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(2; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.', Comment = 'FRA="N° transaction"';
            DataClassification = CustomerContent;
        }
        field(3; Status; enum BC6_Status)
        {
            Caption = 'Status', Comment = 'FRA="Statut"';
            DataClassification = CustomerContent;
        }
        field(4; "Import Type"; enum "BC6_Import Type")
        {
            Caption = 'Import Type', Comment = 'FRA="Type import"';
            DataClassification = CustomerContent;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'FRA="N° ligne"';
            DataClassification = CustomerContent;
        }
        field(10; "Source Code"; Code[10])
        {
            Caption = 'Source Code', Comment = 'FRA="Code journal"';
            DataClassification = CustomerContent;
        }
        field(11; "YOOZ Posting Date"; Date)
        {
            Caption = 'YOOZ Posting Date', Comment = 'FRA="Date Compta YOOZ"';
            DataClassification = CustomerContent;
        }
        field(12; "Document Type"; enum "BC6_Document Type")
        {
            Caption = 'Document Type', Comment = 'FRA="Type document"';
            DataClassification = CustomerContent;
        }
        field(13; "Document No."; Code[20])
        {
            Caption = 'Document No.', Comment = 'FRA="N° document"';
            DataClassification = CustomerContent;
        }
        field(20; "Import Source Code"; Text[10])
        {
            Caption = 'Import Source Code', Comment = 'FRA="Code journal import"';
            DataClassification = CustomerContent;
        }
        field(21; "Import Document Date"; Text[10])
        {
            Caption = 'Import Document Date', Comment = 'FRA="Date Document  import"';
            DataClassification = CustomerContent;
        }
        field(22; "Import Document Type"; Text[20])
        {
            Caption = 'Import Document Type', Comment = 'FRA="Type document import"';
            DataClassification = CustomerContent;
        }
        field(24; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.', Comment = 'FRA="N° compte général"';
            DataClassification = CustomerContent;
        }
        field(25; "Import Account Type"; Text[20])
        {
            Caption = 'Import Account Type', Comment = 'FRA="Type de Compte Import"';
            DataClassification = CustomerContent;
        }
        field(26; "Employe Identifier"; Code[20])
        {
            Caption = 'Employe Identifier', Comment = 'FRA="Initial du salarié"';
            DataClassification = CustomerContent;
        }
        field(27; "YOOZ No."; Code[35])
        {
            Caption = 'YOOZ No.', Comment = 'FRA="N° doc YOOZ"';
            DataClassification = CustomerContent;
        }
        field(28; Description; Text[100])
        {
            Caption = 'Description', Comment = 'FRA="Libellé de l''écriture"';
            DataClassification = CustomerContent;
        }
        field(29; "Import Payment Method"; Text[20])
        {
            Caption = 'Import Payment Method', Comment = 'FRA="Mode de règlement import"';
            DataClassification = CustomerContent;
        }
        field(30; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code', Comment = 'FRA="Code mode de règlement"';
            DataClassification = CustomerContent;
        }
        field(31; "Import Due Date"; Text[10])
        {
            Caption = 'Import Due Date', Comment = 'FRA="Date d''échéance import"';
            DataClassification = CustomerContent;
        }
        field(32; "Due Date"; Date)
        {
            Caption = 'Due Date', Comment = 'FRA="Date d''échéance"';
            DataClassification = CustomerContent;
        }
        field(33; "Sense of Amount"; Text[10])
        {
            Caption = 'Sense of Amount', Comment = 'FRA="Sens du montant"';
            DataClassification = CustomerContent;
        }
        field(34; "Import Amount"; Text[20])
        {
            Caption = 'Import Amount', Comment = 'FRA="Montant import"';
            DataClassification = CustomerContent;
        }
        field(35; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount', Comment = 'FRA="Montant débit"';
            DataClassification = CustomerContent;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code', Comment = 'FRA="Code devise"';
            DataClassification = CustomerContent;
        }
        field(37; "Import Amount (LCY)"; Text[20])
        {
            Caption = 'Import Amount (LCY)', Comment = 'FRA="Montant import DS"';
            DataClassification = CustomerContent;
        }
        field(38; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)', Comment = 'FRA="Montant DS"';
            DataClassification = CustomerContent;
        }
        field(39; "Company Currency Code"; Code[10])
        {
            Caption = 'Company Currency Code', Comment = 'FRA="Code devise société"';
            DataClassification = CustomerContent;
        }
        field(40; "Position Dimension"; Code[10])
        {
            Caption = 'Position Dimension', Comment = 'FRA="Position analytique"';
            DataClassification = CustomerContent;
        }
        field(41; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code', Comment = 'FRA="Code axe"';
            DataClassification = CustomerContent;
        }
        field(42; "Dimension Value 1"; Code[25])
        {
            Caption = 'Dimension Value 1', Comment = 'FRA="Valeur axe 1"';
            DataClassification = CustomerContent;
        }
        field(43; "Part Number"; Code[10])
        {
            Caption = 'Part Number', Comment = 'FRA="N° pièce"';
            DataClassification = CustomerContent;
        }
        field(44; "Account Type"; enum "BC6_Account Type")
        {
            Caption = 'Account Type', Comment = 'FRA="Type compte"';
            DataClassification = CustomerContent;
        }
        field(45; "Dimension Value 2"; Code[20])
        {
            Caption = 'Dimension Value 2', Comment = 'FRA="Valeur axe 2"';
            DataClassification = CustomerContent;
        }
        field(46; "Dimension Value 3"; Code[20])
        {
            Caption = 'Dimension Value 3', Comment = 'FRA="Valeur axe 3"';
            DataClassification = CustomerContent;
        }
        field(47; "Dimension Value 4"; Code[20])
        {
            Caption = 'Dimension Value 4', Comment = 'FRA="Valeur axe 4"';
            DataClassification = CustomerContent;
        }
        field(50; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.', Comment = 'FRA="N° ligne source"';
            DataClassification = CustomerContent;
        }
        field(51; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount', Comment = 'FRA="Montant Crédit"';
            DataClassification = CustomerContent;
        }
        field(52; "Import Journ. Template Name"; Text[10])
        {
            Caption = 'Import Journ. Template Name', Comment = 'FRA="Nom Modèle Feuille Import"';
            DataClassification = CustomerContent;
        }
        field(53; "Import Journ Batch Name"; Text[10])
        {
            Caption = 'Import Journ Batch Name', Comment = 'FRA="Nom Feuille Import"';
            DataClassification = CustomerContent;
        }
        field(54; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier', Comment = 'FRA="Identifiant TVA"';
            DataClassification = CustomerContent;
        }
        field(100; "Comment Zone 1"; Text[50])
        {
            Caption = 'Comment Zone 1', Comment = 'FRA="Zone reservée 1"';
            DataClassification = CustomerContent;
        }
        field(200; "Import File Name"; Text[250])
        {
            Caption = 'Import File Name', Comment = 'FRA="Nom fichier d''import"';
            DataClassification = CustomerContent;
        }
        field(201; "Import DateTime"; DateTime)
        {
            Caption = 'Import DateTime', Comment = 'FRA="Date-heure import"';
            DataClassification = CustomerContent;
        }
        field(202; "User ID"; Code[50])
        {
            Caption = 'User ID', Comment = 'FRA="Code utilisateur"';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Pk1; "Import Type", Status)
        {

        }
    }
    trigger OnDelete()
    begin
        DeleteErrorLine();
    end;

    procedure DeleteErrorLine()
    var
        ErrorLine: Record "BC6_YOOZ Error Log";
    begin
        ErrorLine.SETRANGE("Entry No.", "Entry No.");
        ErrorLine.DELETEALL();
    end;
}

table 50065 "BC6_YOOZ import Buffer"
{
    Caption = 'YOOZ import Buffer', Comment = 'FRA="Tampon import YOOZ"';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', Comment = 'FRA="N° séquence"';
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.', Comment = 'FRA="N° transaction"';
            DataClassification = ToBeClassified;
        }
        field(3; Status; Enum BC6_Status)
        {
            Caption = 'Status', Comment = 'FRA="Statut"';
            DataClassification = ToBeClassified;
        }
        field(4; "Import Type"; Enum "BC6_Import Type")
        {
            Caption = 'Import Type', Comment = 'FRA="Type import"';
            DataClassification = ToBeClassified;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'FRA="N° ligne"';
            DataClassification = ToBeClassified;
        }
        field(10; "Source Code"; Code[10])
        {
            Caption = 'Source Code', Comment = 'FRA="Code journal"';
            DataClassification = ToBeClassified;
        }
        field(11; "YOOZ Posting Date"; Date)
        {
            Caption = 'YOOZ Posting Date', Comment = 'FRA="Date Compta YOOZ"';
            DataClassification = ToBeClassified;
        }
        field(12; "Document Type"; enum "BC6_Document Type")
        {
            Caption = 'Document Type', Comment = 'FRA="Type document"';
            DataClassification = ToBeClassified;
        }
        field(13; "Document No."; Code[20])
        {
            Caption = 'Document No.', Comment = 'FRA="N° document"';
            DataClassification = ToBeClassified;
        }
        field(20; "Import Source Code"; Text[10])
        {
            Caption = 'Import Source Code', Comment = 'FRA="Code journal import"';
            DataClassification = ToBeClassified;
        }
        field(21; "Import Document Date"; Text[10])
        {
            Caption = 'Import Document Date', Comment = 'FRA="Date Document  import"';
            DataClassification = ToBeClassified;
        }
        field(22; "Import Document Type"; Text[20])
        {
            Caption = 'Import Document Type', Comment = 'FRA="Type document import"';
            DataClassification = ToBeClassified;
        }
        field(24; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.', Comment = 'FRA="N° compte général"';
            DataClassification = ToBeClassified;
        }
        field(25; "Import Account Type"; Text[20])
        {
            Caption = 'Import Account Type', Comment = 'FRA="Type de Compte Import"';
            DataClassification = ToBeClassified;
        }
        field(26; "Employe Identifier"; Code[20])
        {
            Caption = 'Employe Identifier', Comment = 'FRA="Initial du salarié"';
            DataClassification = ToBeClassified;
        }
        field(27; "YOOZ No."; Code[35])
        {
            Caption = 'YOOZ No.', Comment = 'FRA="N° doc YOOZ"';
            DataClassification = ToBeClassified;
        }
        field(28; Description; Text[100])
        {
            Caption = 'Description', Comment = 'FRA="Libellé de l''écriture"';
            DataClassification = ToBeClassified;
        }
        field(29; "Import Payment Method"; Text[20])
        {
            Caption = 'Import Payment Method', Comment = 'FRA="Mode de règlement import"';
            DataClassification = ToBeClassified;
        }
        field(30; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code', Comment = 'FRA="Code mode de règlement"';
            DataClassification = ToBeClassified;
        }
        field(31; "Import Due Date"; Text[10])
        {
            Caption = 'Import Due Date', Comment = 'FRA="Date d''échéance import"';
            DataClassification = ToBeClassified;
        }
        field(32; "Due Date"; Date)
        {
            Caption = 'Due Date', Comment = 'FRA="Date d''échéance"';
            DataClassification = ToBeClassified;
        }
        field(33; "Sense of Amount"; Text[10])
        {
            Caption = 'Sense of Amount', Comment = 'FRA="Sens du montant"';
            DataClassification = ToBeClassified;
        }
        field(34; "Import Amount"; Text[20])
        {
            Caption = 'Import Amount', Comment = 'FRA="Montant import"';
            DataClassification = ToBeClassified;
        }
        field(35; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount', Comment = 'FRA="Montant débit"';
            DataClassification = ToBeClassified;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code', Comment = 'FRA="Code devise"';
            DataClassification = ToBeClassified;
        }
        field(37; "Import Amount (LCY)"; Text[20])
        {
            Caption = 'Import Amount (LCY)', Comment = 'FRA="Montant import DS"';
            DataClassification = ToBeClassified;
        }
        field(38; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)', Comment = 'FRA="Montant DS"';
            DataClassification = ToBeClassified;
        }
        field(39; "Company Currency Code"; Code[10])
        {
            Caption = 'Company Currency Code', Comment = 'FRA="Code devise société"';
            DataClassification = ToBeClassified;
        }
        field(40; "Position Dimension"; Code[10])
        {
            Caption = 'Position Dimension', Comment = 'FRA="Position analytique"';
            DataClassification = ToBeClassified;
        }
        field(41; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code', Comment = 'FRA="Code axe"';
            DataClassification = ToBeClassified;
        }
        field(42; "Dimension Value 1"; Code[25])
        {
            Caption = 'Dimension Value 1', Comment = 'FRA="Valeur axe 1"';
            DataClassification = ToBeClassified;
        }
        field(43; "Part Number"; Code[10])
        {
            Caption = 'Part Number', Comment = 'FRA="N° pièce"';
            DataClassification = ToBeClassified;
        }
        field(44; "Account Type"; Enum "BC6_Account Type")
        {
            Caption = 'Account Type', Comment = 'FRA="Type compte"';
            DataClassification = ToBeClassified;
        }
        field(45; "Dimension Value 2"; Code[20])
        {
            Caption = 'Dimension Value 2', Comment = 'FRA="Valeur axe 2"';
            DataClassification = ToBeClassified;
        }
        field(46; "Dimension Value 3"; Code[20])
        {
            Caption = 'Dimension Value 3', Comment = 'FRA="Valeur axe 3"';
            DataClassification = ToBeClassified;
        }
        field(47; "Dimension Value 4"; Code[20])
        {
            Caption = 'Dimension Value 4', Comment = 'FRA="Valeur axe 4"';
            DataClassification = ToBeClassified;
        }
        field(50; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.', Comment = 'FRA="N° ligne source"';
            DataClassification = ToBeClassified;
        }
        field(51; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount', Comment = 'FRA="Montant Crédit"';
            DataClassification = ToBeClassified;
        }
        field(52; "Import Journ. Template Name"; Text[10])
        {
            Caption = 'Import Journ. Template Name', Comment = 'FRA="Nom Modèle Feuille Import"';
            DataClassification = ToBeClassified;
        }
        field(53; "Import Journ Batch Name"; Text[10])
        {
            Caption = 'Import Journ Batch Name', Comment = 'FRA="Nom Feuille Import"';
            DataClassification = ToBeClassified;
        }
        field(54; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier', Comment = 'FRA="Identifiant TVA"';
            DataClassification = ToBeClassified;
        }
        field(100; "Comment Zone 1"; Text[50])
        {
            Caption = 'Comment Zone 1', Comment = 'FRA="Zone reservée 1"';
            DataClassification = ToBeClassified;
        }
        field(200; "Import File Name"; Text[250])
        {
            Caption = 'Import File Name', Comment = 'FRA="Nom fichier d''import"';
            DataClassification = ToBeClassified;
        }
        field(201; "Import DateTime"; DateTime)
        {
            Caption = 'Import DateTime', Comment = 'FRA="Date-heure import"';
            DataClassification = ToBeClassified;
        }
        field(202; "User ID"; Code[50])
        {
            Caption = 'User ID', Comment = 'FRA="Code utilisateur"';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
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

table 50006 "BC6_GS1 Setup"
{
    Caption = 'GS1 Setup', Comment = 'FRA="Paramètres GS1"';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key', Comment = 'FRA="Clé primaire"';
            DataClassification = ToBeClassified;

        }
        field(21; "Expense Journal Template Name"; Code[10])
        {
            Caption = 'Expense Journal Template Name', Comment = 'FRA="Nom modèle feuille note de frais"';
            TableRelation = "Gen. Journal Template";
            DataClassification = ToBeClassified;

        }
        field(31; "Expense Journal Batch Name"; Code[10])
        {
            Caption = 'Expense Journal Batch Name', Comment = 'FRA="Nom feuille note de frais"';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Expense Journal Template Name"));
            DataClassification = ToBeClassified;

        }
        field(41; "Payroll Journal Template Name"; Code[10])
        {
            Caption = 'Payroll Journal Template Name', Comment = 'FRA="Nom modèle feuille paie"';
            TableRelation = "Gen. Journal Template";
            DataClassification = ToBeClassified;

        }
        field(51; "Payroll Journal Batch Name"; Code[10])
        {
            Caption = 'Payroll Journal Batch Name', Comment = 'FRA="Nom feuille paie"';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Payroll Journal Template Name"));
            DataClassification = ToBeClassified;

        }
        field(61; "Expense Shortcut Dim. 1 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Dimension;
            Caption = 'Expense Shortcut Dim. 1 Code', Comment = 'FRA="Code raccourci axe 1 note de frais"';
        }
        field(71; "Expense Shortcut Dim. 2 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Dimension;
            Caption = 'Expense Shortcut Dim. 2 Code', Comment = 'FRA="Code raccourci axe 2 note de frais"';
        }
        field(72; "Expense Shortcut Dim. 3 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Dimension;
            Caption = 'Expense Shortcut Dim. 3 Code', Comment = 'FRA="Code raccourci axe 3 note de frais"';
        }
        field(73; "Expense Shortcut Dim. 4 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Dimension;
            Caption = 'Expense Shortcut Dim. 4 Code', Comment = 'FRA="Code raccourci axe 4 note de frais"';
        }

        field(74; "Payroll Shortcut Dim. 1 Code"; Code[20])
        {
            Caption = 'Payroll Shortcut Dim. 1 Code', Comment = 'FRA="Code raccourci axe 1 paie"';
            TableRelation = Dimension;
            DataClassification = ToBeClassified;

        }
        field(75; "Payroll Shortcut Dim. 2 Code"; Code[20])
        {
            Caption = 'Payroll Shortcut Dim. 2 Code', Comment = 'FRA="Code raccourci axe 2 paie"';
            TableRelation = Dimension;
            DataClassification = ToBeClassified;

        }
        field(76; "Payroll Shortcut Dim. 3 Code"; Code[20])
        {
            Caption = 'Payroll Shortcut Dim. 3 Code', Comment = 'FRA="Code raccourci axe 3 paie"';
            TableRelation = Dimension;
            DataClassification = ToBeClassified;

        }
        field(77; "Payroll Shortcut Dim. 4 Code"; Code[20])
        {
            Caption = 'Payroll Shortcut Dim. 4 Code', Comment = 'FRA="Code raccourci axe 4 paie"';
            TableRelation = Dimension;
            DataClassification = ToBeClassified;

        }
        field(50520; "YOOZ Journ. Temp. Name"; Code[10])
        {
            Caption = 'YOOZ Journ. Temp. Name', Comment = 'FRA="Nom Modèle Feuille YOOZ"';
            DataClassification = ToBeClassified;
        }
        field(50521; "YOOZ Journ. Batch Name"; Code[10])
        {
            Caption = 'YOOZ Journ. Batch Name', Comment = 'FRA="Nom de Feuille YOOZ"';
            DataClassification = ToBeClassified;

        }
        field(50522; "YOOZ Source Code"; Code[10])
        {
            Caption = 'YOOZ Source Code', Comment = 'FRA="Code Journal YOOZ"';
            DataClassification = ToBeClassified;


        }
        field(50523; "YOOZ File Import"; Text[250])
        {
            Caption = 'YOOZ File Import', Comment = 'FRA="Chemin d''import YOOZ"';
            DataClassification = ToBeClassified;


        }
        field(50524; "YOOZ File Archive"; Text[250])
        {
            Caption = 'YOOZ File Archive', Comment = 'FRA="Chemin d''archive YOOZ"';
            DataClassification = ToBeClassified;
            Editable = true;

        }

        // field(50012; "Default Model Code Untitl. Inv"; Code[20])
        // {
        //     Caption = 'Default code for untitled invoices', Comment = 'FRA="Code modèle par défaut pour facture sans titre"';
        //     DataClassification = ToBeClassified;
        //     TableRelation = "BC6_Email Model";
        // }

    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}

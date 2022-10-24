table 50029 "BC6_Email Model"
{

    Caption = 'Email model', Comment = 'FRA="Modèle email"';
    DrillDownPageID = "BC6_Email Models";
    LookupPageID = "BC6_Email Models";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code', Comment = 'FRA="Code"';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Object', Comment = 'FRA="Désignation"';
            DataClassification = CustomerContent;
        }
        field(22; Inactive; Boolean)
        {
            Caption = 'Inactive', Comment = 'FRA="Inactif"';
            DataClassification = CustomerContent;
        }
        field(24; "Document Title"; Code[20])
        {
            Caption = 'Document Titel', Comment = 'FRA="Titre document"';
            TableRelation = "Standard Text";
            DataClassification = CustomerContent;
        }
        field(50000; "Not Show Empty Lines"; Boolean)
        {
            Caption = 'Not Show Empty Lines', Comment = 'FRA="Ne pas afficher les lignes vides"';
            DataClassification = CustomerContent;
        }
        field(50001; "No. Attachments"; Integer)
        {
            CalcFormula = count("BC6_Email Attachment" where("Email Setup Code" = field(Code)));
            Caption = 'Nbre de pièces jointes', Comment = 'FRA="Nbre de pièces jointes"';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50002; "No. Recipients"; Integer)
        {
            CalcFormula = count("BC6_Email Recipient" where("Email Setup Code" = field(Code)));
            Caption = 'Nbre de destinataires', Comment = 'FRA="Nbre de destinataires"';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50003; "No. Translations"; Integer)
        {
            CalcFormula = count("BC6_Language Template Mail" where("Parameter String" = field(Code)));
            Caption = 'Nbre de traductions', Comment = 'FRA="Nbre de traductions"';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Document Title")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnRename()
    var
        LanguageTemplateMail: Record "BC6_Language Template Mail";
    begin
        if xRec.Code = '' then exit;
        LanguageTemplateMail.SETRANGE("Parameter String", xRec.Code);
        if LanguageTemplateMail.FINDSET() then
            repeat
                LanguageTemplateMail.RENAME(Code, LanguageTemplateMail."Language Code");
            until LanguageTemplateMail.NEXT() = 0;
    end;

}


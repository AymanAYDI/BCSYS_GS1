table 50029 "BC6_Email Model"
{

    Caption = 'Email model';
    //TODO: DrillDownPageID = 50050;
    //TODO:  LookupPageID = 50050;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code', Comment = 'FRA="Code"';
        }
        field(10; Description; Text[250])
        {
            Caption = 'Object', Comment = 'FRA="Désignation"';
        }
        field(22; Inactive; Boolean)
        {
            Caption = 'Inactive', Comment = 'FRA="Inactif"';
        }
        field(24; "Document Title"; Code[20])
        {
            Caption = 'Document Titel', Comment = 'FRA="Titre document"';
            TableRelation = "Standard Text";
        }
        field(50000; "Not Show Empty Lines"; Boolean)
        {
            Caption = 'Not Show Empty Lines', Comment = 'FRA="Ne pas afficher les lignes vides"';
        }
        field(50001; "No. Attachments"; Integer)
        {
            CalcFormula = Count("BC6_Email Attachment" WHERE("Email Setup Code" = FIELD(Code)));
            Caption = 'Nbre de pièces jointes', Comment = 'FRA="Nbre de pièces jointes"';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50002; "No. Recipients"; Integer)
        {
            CalcFormula = Count("BC6_Email Recipient" WHERE("Email Setup Code" = FIELD(Code)));
            Caption = 'Nbre de destinataires', Comment = 'FRA="Nbre de destinataires"';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50003; "No. Translations"; Integer)
        {
            CalcFormula = Count("BC6_Language Template Mail" WHERE("Parameter String" = FIELD(Code)));
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

    // trigger OnRename()  TODO: Table "8073297" is missing
    // var
    //     LanguageTemplateMail: Record "8073297"; 
    // begin
    //     IF xRec.Code = '' THEN EXIT;
    //     LanguageTemplateMail.SETRANGE("Parameter String", xRec.Code);
    //     IF LanguageTemplateMail.FINDSET THEN
    //         REPEAT
    //             LanguageTemplateMail.RENAME(Code, LanguageTemplateMail."Language Code");
    //         UNTIL LanguageTemplateMail.NEXT = 0;
    // end;

    local procedure FctCorrectAndValidateEmailList(var EmailAddresses: Text[250])
    var
        MailManagement: Codeunit "Mail Management";
    begin
        EmailAddresses := CONVERTSTR(EmailAddresses, ',', ';');
        EmailAddresses := DELCHR(EmailAddresses, '<>');
        MailManagement.CheckValidEmailAddresses(EmailAddresses);
    end;
}


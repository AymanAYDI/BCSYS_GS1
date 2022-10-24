codeunit 50021 "BC6_GS1 : DMS Managment"
{
    Permissions = tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Cr.Memo Header" = rm;

    trigger OnRun()
    begin
        SendDocument(_RecordID, _EmailModelCode);
    end;

    var
        _RecordID: RecordID;
        _EmailModelCode: Code[20];
        _LastEmailModelCode: Code[20];
        ConstAlreadySent: label 'Sent already.', Comment = 'FRA="L''envoi a déjà été effectué. Etes-vous sûr de vouloir continuer ?"';
        ConstEmailModelBlocked: label 'Email template %1 is blocked', Comment = 'FRA="Le modèle email %1 est bloqué"';
        ConstNoContactCrMemo: label 'They are no email in Contact for the bill to customer %1 for Sales Credit Memo %2', Comment = 'FRA="Il n''y a pas d''email dans le(s) contact(s) du client facturé %1 pour l''avoir %2"';
        ConstNoContactCustomer: label 'They are no email in Contact for the bill to customer %1 for Sales Credit Memo %2', Comment = 'FRA="Il n''y a pas d''email dans le(s) contact(s) du client %1"';
        ConstNoContactInvoice: label 'They are no email in Contact for the bill to customer %1 for Sales Invoice %2', Comment = 'FRA="Il n''y a pas d''email dans le(s) contact(s) du client facturé %1 pour la facture %2"';
        ConstNoCustGLN: label 'Customer %1 haven''t GLN.', Comment = 'FRA="Le client %1 ne possède pas de GLN."';
        ConstNoEmailModelCode: label 'No email model code is defined.', Comment = 'FRA="Aucun code modèle email n''est défini."';
        ConstSendCanceled: label 'Send canceled', Comment = 'FRA="Envoi annulé"';
        ConstSendSuccess: label 'Sending successful', Comment = 'FRA="Envoi réalisé avec succès"';


    procedure Send(RecordIdentifier: RecordID; EmailModelCode: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
        MessageStatus: enum "BC6_Message Status.Enum";
    begin
        CLEARLASTERROR();
        GS1DMSManagment.SetGlobalParameters(RecordIdentifier, EmailModelCode);
        if GS1DMSManagment.RUN() then begin
            GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."BC6_Send Status"::Sent.AsInteger());
            GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode(), RecordIdentifier, MessageStatus::Error, ConstSendSuccess);
            if GUIALLOWED then
                MESSAGE(ConstSendSuccess);
        end else begin
            if GETLASTERRORTEXT <> ConstSendCanceled then begin
                GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."BC6_Send Status"::"Not Sent".AsInteger());
                GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode(), RecordIdentifier, MessageStatus::Information, GETLASTERRORTEXT);
            end;
            if GUIALLOWED then
                ERROR(GETLASTERRORTEXT);
        end;
    end;

    local procedure SendDocument(RecID: RecordID; EmailModelCode: Code[20])
    var
        EmailAttachment: Record "BC6_Email Attachment";
        TempEmailAttachmentType: Record "BC6_Email Attachment Type" temporary;
        EmailModel: Record "BC6_Email Model";
        LanguageTemplateMail: Record "BC6_Language Template Mail";
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1EmailManagement: codeunit "BC6_GS1 : Email Management";
        // TDOD: "Codeunit Web Api Documents Mgt." WebApiDocumentsMgt: Codeunit "50042";
        Language: codeunit Language;
        TempBlob: codeunit "Temp Blob";
        RecRef: RecordRef;
        LanguageCode: Code[10];
        CustomerNo: Code[20];
        DocumentNo: Code[20];
        SendStatus: enum "BC6_Send Status";
        EmailBodyText: Text;
        ErrorTextNoContact: Text;
        FileName: Text;
        Recipients: array[4] of Text;
    begin
        if not RecRef.GET(RecID) then
            exit;

        _LastEmailModelCode := '';
        case RecRef.NUMBER of
            18:
                begin
                    RecRef.SETTABLE(Customer);
                    if EmailModelCode = '' then
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, '');

                    SendStatus := -1;
                    DocumentNo := Customer."No.";
                    CustomerNo := Customer."No.";
                    LanguageCode := Customer."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ErrorTextNoContact, ConstNoContactCustomer, CustomerNo);
                end;
            112:
                begin
                    RecRef.SETTABLE(SalesInvoiceHeader);
                    if EmailModelCode = '' then
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, CopyStr(SalesInvoiceHeader."BC6_Invoice Title", 1, 10));

                    SendStatus := SalesInvoiceHeader."BC6_Send Status";
                    DocumentNo := SalesInvoiceHeader."No.";
                    CustomerNo := SalesInvoiceHeader."Bill-to Customer No.";
                    LanguageCode := SalesInvoiceHeader."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactInvoice, CustomerNo, SalesInvoiceHeader."No.");
                end;
            114:
                begin
                    RecRef.SETTABLE(SalesCrMemoHeader);
                    if EmailModelCode = '' then
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, '');

                    SendStatus := SalesInvoiceHeader."BC6_Send Status";
                    DocumentNo := SalesCrMemoHeader."No.";
                    CustomerNo := SalesCrMemoHeader."Bill-to Customer No.";
                    LanguageCode := SalesCrMemoHeader."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactCrMemo, CustomerNo, SalesCrMemoHeader."No.");
                end;
        end;

        _LastEmailModelCode := EmailModelCode;

        if GUIALLOWED and (SendStatus = SalesInvoiceHeader."BC6_Send Status"::Sent) then
            if not CONFIRM(ConstAlreadySent) then
                ERROR(ConstSendCanceled);

        if EmailModelCode = '' then
            ERROR(ConstNoEmailModelCode);

        EmailModel.GET(EmailModelCode);

        if EmailModel.Inactive then
            ERROR(ConstEmailModelBlocked, EmailModelCode);

        Customer.GET(CustomerNo);
        if Customer.GLN = '' then
            ERROR(ConstNoCustGLN, CustomerNo);

        if LanguageCode = '' then
            LanguageCode := Language.GetUserLanguageCode();

        GetEmailRecipients(EmailModel.Code, Customer.GetContact(), Recipients);

        if STRPOS(Recipients[1], '@') = 0 then
            ERROR(ErrorTextNoContact);

        CompanyInformation.GET();
        if Recipients[4] = '' then
            Recipients[4] := CompanyInformation."E-Mail";

        GS1EmailManagement.FctGetTemplateWithLanguage(EmailModel.Code, LanguageCode, TempBlob);
        GS1EmailManagement.FctLoadMailBody(RecRef, TempBlob, '', '', EmailBodyText);

        if not LanguageTemplateMail.GET(EmailModel.Code, LanguageCode) then
            LanguageTemplateMail.GET(EmailModel.Code, 'FRA');

        GS1EmailManagement.CreateMailMessage(Recipients[1], Recipients[2], Recipients[3], LanguageTemplateMail.Object, EmailBodyText);

        EmailAttachment.SETRANGE("Email Setup Code", EmailModel.Code);
        if EmailAttachment.FINDSET() then
            repeat
                GenerateAttachment(EmailAttachment."Attachment Type Code", CopyStr(LanguageCode, 1, 10), RecRef.RECORDID, DocumentNo, CustomerNo, TempEmailAttachmentType, FileName, TempBlob);
                GS1EmailManagement.AddMailAttachment(TempBlob, CopyStr(FileName, 1, 250));
            until EmailAttachment.NEXT() = 0;

        GS1EmailManagement.SendMail(true);

        if TempEmailAttachmentType.FINDSET() then
            repeat
            //TODO WebApiDocumentsMgt.SaveDocument(Customer."No.", Customer.GLN, Customer."BC6_Company ID", Customer."BC6_SIREN/SIRET", 'Dynamics NAV', TempEmailAttachmentType."File Path", TRUE, FileManagement.GetFileName(TempEmailAttachmentType."File Path"), '', TempEmailAttachmentType."WebApi Type", TempEmailAttachmentType."WebApi Sub Type", DocumentNo);
            until TempEmailAttachmentType.NEXT() = 0;
    end;

    local procedure GetEmailRecipients(EmailModelCode: Code[20]; ContactCompanyNo: Code[20]; var Recipients: array[4] of Text)
    var
        EmailRecipient: Record "BC6_Email Recipient";
        Contact: Record Contact;
        EmailAddress: Text;
    begin
        CLEAR(Recipients);
        EmailRecipient.SETRANGE("Email Setup Code", EmailModelCode);
        if EmailRecipient.FINDSET() then
            repeat
                if EmailRecipient."Recipient Type" = EmailRecipient."Recipient Type"::Contact then begin
                    if EmailRecipient."Recipient Type Code" <> '' then begin
                        Contact.SETRANGE("Company No.", ContactCompanyNo);
                        Contact.SETRANGE("Organizational Level Code", EmailRecipient."Recipient Type Code");
                        if Contact.FINDSET() then begin
                            EmailAddress := '';
                            repeat
                                if EmailAddress <> '' then EmailAddress += ';';
                                EmailAddress += Contact."E-Mail";
                            until Contact.NEXT() = 0;
                        end;
                    end else begin
                        Contact.GET(ContactCompanyNo);
                        EmailAddress := Contact."E-Mail";
                    end;
                end else
                    EmailAddress := EmailRecipient.Email;

                EmailAddress := DELCHR(EmailAddress, '<>');
                if (EmailAddress <> '') then begin
                    if Recipients[EmailRecipient."Email Type".AsInteger() + 1] <> '' then
                        Recipients[EmailRecipient."Email Type".AsInteger() + 1] += ';';

                    Recipients[EmailRecipient."Email Type".AsInteger() + 1] += EmailAddress;
                end;
            until EmailRecipient.NEXT() = 0;
    end;

    local procedure GenerateAttachment(AttachmentTypeCode: Code[20]; LanguageCode: Code[10]; RecID: RecordID; DocumentNo: Code[20]; CustomerNo: Code[20]; var TempEmailAttachmentType: Record "BC6_Email Attachment Type" temporary; var _FileName: Text; var TempBlob: codeunit "Temp Blob")
    var
        EmailAttachTypeTranslation: Record "BC6_Email Attach. Type Trans.";
        EmailAttachmentType: Record "BC6_Email Attachment Type";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
        ExportFormat: ReportFormat;
        FileNameCustLbl: label '%1 - %2.%3';
        FileNameLbl: label 'GS1_%1_%2.%3';
        FileExtension: Text;
    begin
        EmailAttachmentType.GET(AttachmentTypeCode);
        EmailAttachTypeTranslation.GET(EmailAttachmentType.Code, LanguageCode);

        RecRef.GET(RecID);

        if EmailAttachmentType."Output Format" = EmailAttachmentType."Output Format"::Word then begin
            FileExtension := 'docx';
            ExportFormat := REPORTFORMAT::Word;
        end else begin
            FileExtension := 'pdf';
            ExportFormat := REPORTFORMAT::Pdf;
        end;

        if ReportSaveAs(EmailAttachTypeTranslation."Report ID", ExportFormat, RecRef, EmailAttachTypeTranslation."Custom Report Layout Code", TempBlob) then begin
            case EmailAttachmentType."File Naming" of
                EmailAttachmentType."File Naming"::Invoice:
                    begin
                        RecRef.SETTABLE(SalesInvoiceHeader);
                        _FileName := STRSUBSTNO(FileNameLbl, FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesInvoiceHeader."No.", FileExtension);
                    end;
                EmailAttachmentType."File Naming"::"Credit Memo":
                    begin
                        RecRef.SETTABLE(SalesCrMemoHeader);
                        _FileName := STRSUBSTNO(FileNameLbl, FORMAT(SalesCrMemoHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesCrMemoHeader."No.", FileExtension);

                    end;
                EmailAttachmentType."File Naming"::Customer:
                    _FileName := STRSUBSTNO(FileNameCustLbl, EmailAttachTypeTranslation.Description, CustomerNo, FileExtension);

                else
                    _FileName := STRSUBSTNO(FileNameCustLbl, EmailAttachTypeTranslation.Description, DocumentNo, FileExtension);
            end;
            TempEmailAttachmentType := EmailAttachmentType;
            TempEmailAttachmentType."File Path" := CopyStr(_FileName, 1, MaxStrLen(TempEmailAttachmentType."File Path"));
            TempEmailAttachmentType.INSERT();
        end else
            ERROR(GETLASTERRORTEXT);
    end;

    local procedure GetEmailModelCode(TableNo: Integer; DocumentTitle: Code[10]): Code[20]
    var
        EmailModel: Record "BC6_Email Model";
        GS1Setup: Record "BC6_GS1 Setup";
        EmailModelCode: Code[20];
    begin
        GS1Setup.GET();
        case TableNo of
            112:

                if DocumentTitle = '' then begin
                    GS1Setup.TESTFIELD("Default Model Code Untitl. Inv");
                    EmailModelCode := GS1Setup."Default Model Code Untitl. Inv";
                end else begin
                    EmailModel.SETCURRENTKEY("Document Title");
                    EmailModel.SETRANGE("Document Title", DocumentTitle);
                    if EmailModel.FINDFIRST() then
                        EmailModelCode := EmailModel.Code;
                end;

            114:

                EmailModelCode := GS1Setup."Sales Credit Memo Model Code";

        end;
        exit(EmailModelCode);
    end;

    local procedure ReportSaveAs(ReportID: Integer; ExportFormat: ReportFormat; RecRef: RecordRef; CustomReportLayoutCode: Code[20]; var TempBlob: codeunit "Temp Blob") Success: Boolean
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        RecRef.SETRECFILTER();

        ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutCode);
        Success := REPORT.SAVEAS(ReportID, '', ExportFormat, OutStream, RecRef);
        ReportLayoutSelection.SetTempLayoutSelected('');
    end;

    procedure SetGlobalParameters(RecID: RecordID; EmailModelCode: Code[20])
    begin
        _RecordID := RecID;
        _EmailModelCode := EmailModelCode;
    end;


    procedure UpdateStatus(RecordIdentifier: RecordID; NewStatus: Integer)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if not (RecordIdentifier.TABLENO in [112, 114]) then
            exit;

        if not RecRef.GET(RecordIdentifier) then
            exit;

        FldRef := RecRef.FIELD(50001);
        FldRef.VALUE(NewStatus);
        RecRef.MODIFY();
        COMMIT();
    end;


    procedure InsertLog(EmailModelCode: Code[20]; RecordIdentifier: RecordID; MessageStatus: enum "BC6_Message Status.Enum"; MessageText: Text)
    var
        EmailLog: Record "BC6_Email Log";
    begin
        EmailLog.INIT();
        EmailLog."Email Model Code" := EmailModelCode;
        EmailLog."Record Identifier" := RecordIdentifier;
        EmailLog."Search Record ID" := FORMAT(EmailLog."Record Identifier");
        EmailLog."Message Status" := MessageStatus;
        EmailLog.Message := COPYSTR(MessageText, 1, 250);
        EmailLog.INSERT(true);
        COMMIT();
    end;


    procedure GetLastEmailModelCode(): Code[20]
    begin
        exit(_LastEmailModelCode);
    end;


    procedure ViewLog(RecordIdentifier: RecordID)
    var
        EmailLog: Record "BC6_Email Log";
    begin
        EmailLog.SETRANGE("Record Identifier", RecordIdentifier);
        PAGE.RUNMODAL(PAGE::"BC6_Email Log", EmailLog);
    end;


    procedure SelectModelAndSendlEmail(RecordIdentifier: RecordID): Code[20]
    var
        EmailModel: Record "BC6_Email Model";
        GS1Setup: Record "BC6_GS1 Setup";
    begin
        EmailModel.FILTERGROUP(2);
        if RecordIdentifier.TABLENO = 18 then begin
            GS1Setup.GET();
            EmailModel.SETFILTER(Code, '<>%1', GS1Setup."Default Model Code Untitl. Inv");
            EmailModel.SETRANGE("Document Title", '');
        end else
            EmailModel.SETFILTER("Document Title", '<>%1', '');

        EmailModel.SETRANGE(Inactive, false);
        EmailModel.FILTERGROUP(0);
        if PAGE.RUNMODAL(PAGE::"BC6_Email Models", EmailModel) = ACTION::LookupOK then
            Send(RecordIdentifier, EmailModel.Code);
    end;

}


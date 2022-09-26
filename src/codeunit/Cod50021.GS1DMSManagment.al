codeunit 50021 "BC6_GS1 : DMS Managment"
{
    Permissions = TableData 112 = rm,
                  TableData 114 = rm;

    trigger OnRun()
    begin
        SendDocument(_RecordID, _EmailModelCode);
    end;

    var
        _RecordID: RecordID;
        ConstNoContactInvoice: Label 'they are no email in Contact for the bill to customer %1 for Sales Invoice %2';
        ConstNoContactCrMemo: Label 'they are no email in Contact for the bill to customer %1 for Sales Credit Memo %2';
        ConstNoContactCustomer: Label 'they are no email in Contact for the bill to customer %1 for Sales Credit Memo %2';
        ConstEmailModelBlocked: Label 'Le modèle email %1 est bloqué';
        _EmailModelCode: Code[20];
        ConstAlreadySent: Label 'Sent already.';
        ConstNoEmailModelCode: Label 'Aucun code modèle email n''est défini.';
        ConstSendCanceled: Label 'Send canceled';
        _LastEmailModelCode: Code[20];
        ConstNoCustGLN: Label 'Customer %1 haven''t GLN.';
        ConstSendSuccess: Label 'Sending successful';
        ConstLoadDocQuestion: Label 'The document has been edited in Word.\\Do you want to import the changes?';


    procedure Send(RecordIdentifier: RecordID; EmailModelCode: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
    begin
        CLEARLASTERROR();
        GS1DMSManagment.SetGlobalParameters(RecordIdentifier, EmailModelCode);
        IF GS1DMSManagment.RUN() THEN BEGIN
            GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."BC6_Send Status"::Sent.AsInteger());
            GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode(), RecordIdentifier, 0, ConstSendSuccess);
            IF GUIALLOWED THEN
                MESSAGE(ConstSendSuccess);
        END ELSE BEGIN
            IF GETLASTERRORTEXT <> ConstSendCanceled THEN BEGIN
                GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."BC6_Send Status"::"Not Sent".AsInteger());
                GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode(), RecordIdentifier, 1, GETLASTERRORTEXT);
            END;
            IF GUIALLOWED THEN
                ERROR(GETLASTERRORTEXT);
        END;
    end;

    local procedure SendDocument(RecID: RecordID; EmailModelCode: Code[20])
    var
        EmailModel: Record "BC6_Email Model";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Language: Record Language;
        Customer: Record Customer;
        LanguageTemplateMail: Record "BC6_Language Template Mail";
        CompanyInformation: Record "Company Information";
        EmailAttachment: Record "BC6_Email Attachment";
        TempEmailAttachmentType: Record "BC6_Email Attachment Type" temporary;
        GS1EmailManagement: Codeunit "BC6_GS1 : Email Management";
        // TDOD: "Codeunit Web Api Documents Mgt." WebApiDocumentsMgt: Codeunit "50042";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        LanguageCode: Code[20];
        CustomerNo: Code[20];
        DocumentNo: Code[20];
        EmailBodyText: Text;
        FilePath: Text;
        ErrorTextNoContact: Text;
        Recipients: array[4] of Text;
        SendStatus: Integer;
    begin
        IF NOT RecRef.GET(RecID) THEN
            EXIT;

        _LastEmailModelCode := '';
        CASE RecRef.NUMBER OF
            18:
                BEGIN
                    RecRef.SETTABLE(Customer);
                    IF EmailModelCode = '' THEN
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, '');

                    SendStatus := -1;
                    DocumentNo := Customer."No.";
                    CustomerNo := Customer."No.";
                    LanguageCode := Customer."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactCustomer, CustomerNo);
                END;
            112:
                BEGIN
                    RecRef.SETTABLE(SalesInvoiceHeader);
                    IF EmailModelCode = '' THEN
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, CopyStr(SalesInvoiceHeader."BC6_Invoice Title", 1, 10));

                    SendStatus := SalesInvoiceHeader."BC6_Send Status".AsInteger();
                    DocumentNo := SalesInvoiceHeader."No.";
                    CustomerNo := SalesInvoiceHeader."Bill-to Customer No.";
                    LanguageCode := SalesInvoiceHeader."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactInvoice, CustomerNo, SalesInvoiceHeader."No.");
                END;
            114:
                BEGIN
                    RecRef.SETTABLE(SalesCrMemoHeader);
                    IF EmailModelCode = '' THEN
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, '');

                    SendStatus := SalesInvoiceHeader."BC6_Send Status".AsInteger();
                    DocumentNo := SalesCrMemoHeader."No.";
                    CustomerNo := SalesCrMemoHeader."Bill-to Customer No.";
                    LanguageCode := SalesCrMemoHeader."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactCrMemo, CustomerNo, SalesCrMemoHeader."No.");
                END;
        END;

        _LastEmailModelCode := EmailModelCode;

        IF GUIALLOWED AND (SendStatus = SalesInvoiceHeader."BC6_Send Status"::Sent.AsInteger()) THEN
            IF NOT CONFIRM(ConstAlreadySent) THEN
                ERROR(ConstSendCanceled);

        IF EmailModelCode = '' THEN
            ERROR(ConstNoEmailModelCode);

        EmailModel.GET(EmailModelCode);

        IF EmailModel.Inactive THEN
            ERROR(ConstEmailModelBlocked, EmailModelCode);

        Customer.GET(CustomerNo);
        IF Customer.GLN = '' THEN
            ERROR(ConstNoCustGLN, CustomerNo);

        IF LanguageCode = '' THEN
            LanguageCode := Language.GetUserLanguage();

        GetEmailRecipients(EmailModel.Code, Customer.GetContact(), Recipients);

        IF STRPOS(Recipients[1], '@') = 0 THEN
            ERROR(ErrorTextNoContact);

        CompanyInformation.GET();
        IF Recipients[4] = '' THEN
            Recipients[4] := CompanyInformation."E-Mail";

        GS1EmailManagement.FctGetTemplateWithLanguage(EmailModel.Code, CopyStr(LanguageCode, 1, 10), TempBlob);
        GS1EmailManagement.FctLoadMailBody(RecRef, TempBlob, '', '', EmailBodyText);
        //EmailBodyText := TempBlob.ReadTextLine();

        IF NOT LanguageTemplateMail.GET(EmailModel.Code, LanguageCode) THEN
            LanguageTemplateMail.GET(EmailModel.Code, 'FRA');

        GS1EmailManagement.FctCreateMailMessage(CompanyInformation.Name, Recipients[4], Recipients[1], Recipients[2], Recipients[3], LanguageTemplateMail.Object, EmailBodyText, TRUE);

        EmailAttachment.SETRANGE("Email Setup Code", EmailModel.Code);
        IF EmailAttachment.FINDSET() THEN
            REPEAT
                FilePath := GenerateAttachment(EmailAttachment."Attachment Type Code", CopyStr(LanguageCode, 1, 10), RecRef.RECORDID, DocumentNo, CustomerNo, TempEmailAttachmentType);
                GS1EmailManagement.FctAddMailAttachment(FilePath, FileManagement.GetFileName(FilePath));
            UNTIL EmailAttachment.NEXT() = 0;

        GS1EmailManagement.FctSendMail(TRUE);

        IF TempEmailAttachmentType.FINDSET() THEN
            REPEAT
                WebApiDocumentsMgt.SaveDocument(Customer."No.", Customer.GLN, Customer."BC6_Company ID", Customer."BC6_SIREN/SIRET", 'Dynamics NAV', TempEmailAttachmentType."File Path", TRUE, FileManagement.GetFileName(TempEmailAttachmentType."File Path"), '', TempEmailAttachmentType."WebApi Type", TempEmailAttachmentType."WebApi Sub Type", DocumentNo);
                FileManagement.DeleteServerFile(TempEmailAttachmentType."File Path");
            UNTIL TempEmailAttachmentType.NEXT() = 0;

    end;

    local procedure GetEmailRecipients(EmailModelCode: Code[20]; ContactCompanyNo: Code[20]; var Recipients: array[4] of Text)
    var
        // TODO: SMTPMail: Codeunit "400";
        SMTPMail: Codeunit "Email Message";
        EmailRecipient: Record "BC6_Email Recipient";
        Contact: Record Contact;
        EmailAddress: Text;
    begin
        CLEAR(Recipients);
        EmailRecipient.SETRANGE("Email Setup Code", EmailModelCode);
        IF EmailRecipient.FINDSET() THEN
            REPEAT
                IF EmailRecipient."Recipient Type" = EmailRecipient."Recipient Type"::Contact THEN BEGIN
                    IF EmailRecipient."Recipient Type Code" <> '' THEN BEGIN
                        Contact.SETRANGE("Company No.", ContactCompanyNo);
                        Contact.SETRANGE("Organizational Level Code", EmailRecipient."Recipient Type Code");
                        IF Contact.FINDSET() THEN BEGIN
                            EmailAddress := '';
                            REPEAT
                                IF EmailAddress <> '' THEN EmailAddress += ';';
                                EmailAddress += Contact."E-Mail";
                            UNTIL Contact.NEXT() = 0;
                        END;
                    END ELSE BEGIN
                        Contact.GET(ContactCompanyNo);
                        EmailAddress := Contact."E-Mail";
                    END;
                END ELSE
                    EmailAddress := EmailRecipient.Email;

                EmailAddress := DELCHR(EmailAddress, '<>');
                IF (EmailAddress <> '') THEN BEGIN
                    IF Recipients[EmailRecipient."Email Type".AsInteger() + 1] <> '' THEN
                        Recipients[EmailRecipient."Email Type".AsInteger() + 1] += ';';

                    Recipients[EmailRecipient."Email Type".AsInteger() + 1] += EmailAddress;
                END;
            UNTIL EmailRecipient.NEXT() = 0;
    end;

    local procedure GenerateAttachment(AttachmentTypeCode: Code[20]; LanguageCode: Code[10]; RecID: RecordID; DocumentNo: Code[20]; CustomerNo: Code[20]; var TempEmailAttachmentType: Record "BC6_Email Attachment Type" temporary): Text
    var

        EmailAttachmentType: Record "BC6_Email Attachment Type";
        EmailAttachTypeTranslation: Record "BC6_Email Attach. Type Trans.";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        FileManagement: Codeunit "File Management";
        RecRef: RecordRef;
        ServerTempFilePath: Text;
        ServerFilePath: Text;
        FileExtension: Text;
        ExportFormat: ReportFormat;
    begin
        EmailAttachmentType.GET(AttachmentTypeCode);
        EmailAttachTypeTranslation.GET(EmailAttachmentType.Code, LanguageCode);

        RecRef.GET(RecID);

        IF EmailAttachmentType."Output Format" = EmailAttachmentType."Output Format"::Word THEN BEGIN
            FileExtension := 'docx';
            ExportFormat := REPORTFORMAT::Word;
        END ELSE BEGIN
            FileExtension := 'pdf';
            ExportFormat := REPORTFORMAT::Pdf;
        END;

        ServerTempFilePath := FileManagement.ServerTempFileName(FileExtension);
        IF ReportSaveAs(EmailAttachTypeTranslation."Report ID", ExportFormat, ServerTempFilePath, RecRef, EmailAttachTypeTranslation."Custom Report Layout Code") THEN BEGIN
            CASE EmailAttachmentType."File Naming" OF
                EmailAttachmentType."File Naming"::Invoice:
                    BEGIN
                        RecRef.SETTABLE(SalesInvoiceHeader);
                        ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath),
                            STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesInvoiceHeader."No.", FileExtension));
                    END;
                EmailAttachmentType."File Naming"::"Credit Memo":
                    BEGIN
                        RecRef.SETTABLE(SalesCrMemoHeader);
                        ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath),
                            STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesCrMemoHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesCrMemoHeader."No.", FileExtension));
                    END;
                EmailAttachmentType."File Naming"::Customer:
                    ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath), STRSUBSTNO('%1 - %2.%3', EmailAttachTypeTranslation.Description, CustomerNo, FileExtension));
                ELSE
                    ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath), STRSUBSTNO('%1 - %2.%3', EmailAttachTypeTranslation.Description, DocumentNo, FileExtension));
            END;
            FileManagement.CopyServerFile(ServerTempFilePath, ServerFilePath, TRUE);
            FileManagement.DeleteServerFile(ServerTempFilePath);
            TempEmailAttachmentType := EmailAttachmentType;
            TempEmailAttachmentType."File Path" := CopyStr(ServerFilePath, 1, MaxStrLen(TempEmailAttachmentType."File Path"));
            TempEmailAttachmentType.INSERT();
        END ELSE
            ERROR(GETLASTERRORTEXT);
        EXIT(ServerFilePath);
    end;

    local procedure GetEmailModelCode(TableNo: Integer; DocumentTitle: Code[10]): Code[20]
    var
        EmailModel: Record "BC6_Email Model";
        GS1Setup: Record "BC6_GS1 Setup";
        EmailModelCode: Code[20];
    begin
        GS1Setup.GET();
        CASE TableNo OF
            112:

                IF DocumentTitle = '' THEN BEGIN
                    GS1Setup.TESTFIELD("Default Model Code Untitl. Inv");
                    EmailModelCode := GS1Setup."Default Model Code Untitl. Inv";
                END ELSE BEGIN
                    EmailModel.SETCURRENTKEY("Document Title");
                    EmailModel.SETRANGE("Document Title", DocumentTitle);
                    IF EmailModel.FINDFIRST() THEN
                        EmailModelCode := EmailModel.Code;
                END;

            114:

                EmailModelCode := GS1Setup."Sales Credit Memo Model Code";

        END;
        EXIT(EmailModelCode);
    end;

    local procedure ReportSaveAs(ReportID: Integer; ExportFormat: ReportFormat; ServerFilePath: Text; RecRef: RecordRef; CustomReportLayoutCode: Code[20]) Success: Boolean
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        FileManagement.DeleteServerFile(ServerFilePath);
        TempBlob.CreateOutStream(OutStr);
        RecRef.SETRECFILTER();

        ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutCode);
        Success := REPORT.SAVEAS(ReportID, '', ExportFormat, OutStr, RecRef);
        ReportLayoutSelection.SetTempLayoutSelected('');

        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
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
        IF NOT (RecordIdentifier.TABLENO IN [112, 114]) THEN
            EXIT;

        IF NOT RecRef.GET(RecordIdentifier) THEN
            EXIT;

        FldRef := RecRef.FIELD(50001);
        FldRef.VALUE(NewStatus);
        RecRef.MODIFY();
        COMMIT();
    end;


    procedure InsertLog(EmailModelCode: Code[20]; RecordIdentifier: RecordID; MessageStatus: Option Success,Error,Information,Warning; MessageText: Text)
    var
        EmailLog: Record "BC6_Email Log";
    begin
        EmailLog.INIT();
        EmailLog."Email Model Code" := EmailModelCode;
        EmailLog."Record Identifier" := RecordIdentifier;
        EmailLog."Search Record ID" := FORMAT(EmailLog."Record Identifier");
        EmailLog."Message Status" := MessageStatus;
        EmailLog.Message := COPYSTR(MessageText, 1, 250);
        EmailLog.INSERT(TRUE);
        COMMIT();
    end;


    procedure GetLastEmailModelCode(): Code[20]
    begin
        EXIT(_LastEmailModelCode);
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
        IF RecordIdentifier.TABLENO = 18 THEN BEGIN
            GS1Setup.GET();
            EmailModel.SETFILTER(Code, '<>%1', GS1Setup."Default Model Code Untitl. Inv");
            EmailModel.SETRANGE("Document Title", '');
        END ELSE
            EmailModel.SETFILTER("Document Title", '<>%1', '');

        EmailModel.SETRANGE(Inactive, FALSE);
        EmailModel.FILTERGROUP(0);
        IF PAGE.RUNMODAL(PAGE::"BC6_Email Models", EmailModel) = ACTION::LookupOK THEN
            Send(RecordIdentifier, EmailModel.Code);
    end;


    procedure OpenWordDocument(LanguageTemplateMail: Record "BC6_Language Template Mail")
    var
        EmailModel: Record "BC6_Email Model";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        [RunOnClient]
        WordApplication: DotNet ApplicationClass;
        [RunOnClient]
        WordDocument: DotNet Document;
        [RunOnClient]
        WdWindowState: DotNet WdWindowState;
        [RunOnClient]
        WdSaveFormat: DotNet WdSaveFormat;
        [RunOnClient]
        WordHelper: DotNet WordHelper;
        [RunOnClient]
        WordHandler: DotNet WordHandler;
        ErrorMessage: Text;
        FilePath: Text;
        NewFilePath: Text;
    begin
        EmailModel.GET(LanguageTemplateMail."Parameter String");

        WordApplication := WordHelper.GetApplication(ErrorMessage);
        IF ISNULL(WordApplication) THEN
            ERROR(ErrorMessage);

        LanguageTemplateMail.CALCFIELDS("Template mail");
        IF LanguageTemplateMail."Template mail".HASVALUE THEN BEGIN
            TempBlob.FromRecord(LanguageTemplateMail, LanguageTemplateMail.FieldNo("Template mail"));

            FilePath := FileManagement.BLOBExport(TempBlob, 'Temp.htm', FALSE);
        END ELSE BEGIN
            FilePath := FileManagement.ClientTempFileName('htm');
            WordDocument := WordHelper.AddDocument(WordApplication);
            WordHelper.CallSaveAsFormat(WordDocument, FilePath, WdSaveFormat.wdFormatFilteredHTML);
        END;

        // Open word and wait for the document to be closed
        WordHandler := WordHandler.WordHandler;
        WordDocument := WordHelper.CallOpen(WordApplication, FilePath, FALSE, FALSE);
        WordDocument.ActiveWindow.Caption := EmailModel.Description;
        WordDocument.Application.Visible := TRUE; // Visible before WindowState KB176866 - http://support.microsoft.com/kb/176866
        WordDocument.ActiveWindow.WindowState := WdWindowState.wdWindowStateNormal;

        // Push the word app to foreground
        WordApplication.WindowState := WdWindowState.wdWindowStateMinimize;
        WordApplication.Visible := TRUE;
        WordApplication.Activate;
        WordApplication.WindowState := WdWindowState.wdWindowStateNormal;
        WordDocument.Saved := TRUE;
        WordDocument.Application.Activate;

        NewFilePath := WordHandler.WaitForDocument(WordDocument);
        CLEAR(WordApplication);

        IF CONFIRM(ConstLoadDocQuestion) THEN BEGIN
            FileManagement.BLOBImport(TempBlob, NewFilePath);

            // LanguageTemplateMail."Template mail" := TempBlob.Blob;
            RecRef.GetTable(LanguageTemplateMail);
            TempBlob.ToRecordRef(RecRef, LanguageTemplateMail.FieldNo("Template mail"));
            RecRef.SetTable(LanguageTemplateMail);

            LanguageTemplateMail.MODIFY();
        END;

        FileManagement.DeleteClientFile(FilePath);
        IF FilePath <> NewFilePath THEN
            FileManagement.DeleteClientFile(NewFilePath);

        WordHandler.Dispose;
        CLEAR(WordHandler);
    end;
}


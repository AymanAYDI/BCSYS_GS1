codeunit 50021 "BC6_GS1 : DMS Managment"
{
    Permissions = TableData 112 = rm,
                  TableData 114 = rm;

    trigger OnRun()
    begin
        SendDocument(_RecordID, _EmailModelCode);
    end;

    var
        ConstNoContactInvoice: Label 'they are no email in Contact for the bill to customer %1 for Sales Invoice %2';
        ConstNoContactCrMemo: Label 'they are no email in Contact for the bill to customer %1 for Sales Credit Memo %2';
        _RecordID: RecordID;
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
        GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        CLEARLASTERROR;
        GS1DMSManagment.SetGlobalParameters(RecordIdentifier, EmailModelCode);
        IF GS1DMSManagment.RUN() THEN BEGIN
            GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."Send Status"::Sent);
            GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode, RecordIdentifier, 0, ConstSendSuccess);
            IF GUIALLOWED THEN
                MESSAGE(ConstSendSuccess);
        END ELSE BEGIN
            IF GETLASTERRORTEXT <> ConstSendCanceled THEN BEGIN
                GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."Send Status"::"Not Sent");
                GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode, RecordIdentifier, 1, GETLASTERRORTEXT);
            END;
            IF GUIALLOWED THEN
                ERROR(GETLASTERRORTEXT);
        END;
    end;

    local procedure SendDocument(RecID: RecordID; EmailModelCode: Code[20])
    var
        // TODO: "Codeunit GS1 : Email Management" GS1EmailManagement: Codeunit "50022";
        GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
        // TDOD: "Codeunit Web Api Documents Mgt." WebApiDocumentsMgt: Codeunit "50042";
        FileManagement: Codeunit "File Management";
        EmailModel: Record "BC6_Email Model";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Language: Record Language;
        Customer: Record Customer;
        Contact: Record Contact;
        // TODO: "record templBlob" TempBlob: Record "99008535";
        LanguageTemplateMail: Record "BC6_Language Template Mail";
        CompanyInformation: Record "Company Information";
        EmailAttachment: Record "BC6_Email Attachment";
        TempEmailAttachmentType: Record "BC6_Email Attachment Type" temporary;
        RecRef: RecordRef;
        LanguageCode: Code[20];
        CustomerNo: Code[20];
        DocumentNo: Code[20];
        EmailBodyText: Text;
        SendTo: Text;
        SendCC: Text;
        FilePath: Text;
        ErrorTextNoContact: Text;
        Recipients: array[4] of Text;
        OutStream: OutStream;
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
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, SalesInvoiceHeader."BC6_Invoice Title");

                    SendStatus := SalesInvoiceHeader."BC6_Send Status";
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

                    SendStatus := SalesInvoiceHeader."BC6_Send Status";
                    DocumentNo := SalesCrMemoHeader."No.";
                    CustomerNo := SalesCrMemoHeader."Bill-to Customer No.";
                    LanguageCode := SalesCrMemoHeader."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactCrMemo, CustomerNo, SalesCrMemoHeader."No.");
                END;
        END;

        _LastEmailModelCode := EmailModelCode;

        IF GUIALLOWED AND (SendStatus = SalesInvoiceHeader."BC6_Send Status"::Sent) THEN
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
            LanguageCode := Language.GetUserLanguage;

        GetEmailRecipients(EmailModel.Code, Customer.GetContact(), Recipients);

        IF STRPOS(Recipients[1], '@') = 0 THEN
            ERROR(ErrorTextNoContact);

        CompanyInformation.GET;
        IF Recipients[4] = '' THEN
            Recipients[4] := CompanyInformation."E-Mail";

        GS1EmailManagement.FctGetTemplateWithLanguage(EmailModel.Code, LanguageCode, TempBlob);
        GS1EmailManagement.FctLoadMailBody(RecRef, TempBlob, '', '', EmailBodyText);
        //EmailBodyText := TempBlob.ReadTextLine();

        IF NOT LanguageTemplateMail.GET(EmailModel.Code, LanguageCode) THEN
            LanguageTemplateMail.GET(EmailModel.Code, 'FRA');

        GS1EmailManagement.FctCreateMailMessage(CompanyInformation.Name, Recipients[4], Recipients[1], Recipients[2], Recipients[3], LanguageTemplateMail.Object, EmailBodyText, TRUE);

        EmailAttachment.SETRANGE("Email Setup Code", EmailModel.Code);
        IF EmailAttachment.FINDSET THEN
            REPEAT
                FilePath := GenerateAttachment(EmailAttachment."Attachment Type Code", LanguageCode, RecRef.RECORDID, DocumentNo, CustomerNo, TempEmailAttachmentType);
                GS1EmailManagement.FctAddMailAttachment(FilePath, FileManagement.GetFileName(FilePath));
            UNTIL EmailAttachment.NEXT = 0;

        GS1EmailManagement.FctSendMail(TRUE);

        WITH TempEmailAttachmentType DO BEGIN
            IF FINDSET THEN
                REPEAT
                    WebApiDocumentsMgt.SaveDocument(Customer."No.", Customer.GLN, Customer."Company ID", Customer."SIREN/SIRET", 'Dynamics NAV', "File Path", TRUE, FileManagement.GetFileName("File Path"), '', "WebApi Type", "WebApi Sub Type", DocumentNo);
                    FileManagement.DeleteServerFile("File Path");
                UNTIL NEXT = 0;
        END;
    end;

    local procedure GetEmailRecipients(EmailModelCode: Code[20]; ContactCompanyNo: Code[20]; var Recipients: array[4] of Text)
    var
        // TODO: SMTPMail: Codeunit "400";
        EmailRecipient: Record "BC6_Email Recipient";
        Contact: Record Contact;
        EmailAddress: Text;
    begin
        CLEAR(Recipients);
        WITH EmailRecipient DO BEGIN
            SETRANGE("Email Setup Code", EmailModelCode);
            IF FINDSET THEN BEGIN
                REPEAT
                    IF "Recipient Type" = "Recipient Type"::Contact THEN BEGIN
                        IF "Recipient Type Code" <> '' THEN BEGIN
                            Contact.SETRANGE("Company No.", ContactCompanyNo);
                            Contact.SETRANGE("Organizational Level Code", "Recipient Type Code");
                            IF Contact.FINDSET THEN BEGIN
                                EmailAddress := '';
                                REPEAT
                                    IF EmailAddress <> '' THEN EmailAddress += ';';
                                    EmailAddress += Contact."E-Mail";
                                UNTIL Contact.NEXT = 0;
                            END;
                        END ELSE BEGIN
                            Contact.GET(ContactCompanyNo);
                            EmailAddress := Contact."E-Mail";
                        END;
                    END ELSE
                        EmailAddress := Email;

                    EmailAddress := DELCHR(EmailAddress, '<>');
                    IF (EmailAddress <> '') THEN BEGIN
                        IF Recipients[EmailRecipient."Email Type" + 1] <> '' THEN
                            Recipients[EmailRecipient."Email Type" + 1] += ';';

                        Recipients[EmailRecipient."Email Type" + 1] += EmailAddress;
                    END;
                UNTIL NEXT = 0;
            END;
        END;
    end;

    local procedure GenerateAttachment(AttachmentTypeCode: Code[20]; LanguageCode: Code[10]; RecID: RecordID; DocumentNo: Code[20]; CustomerNo: Code[20]; var TempEmailAttachmentType: Record "50032" temporary): Text
    var
        FileManagement: Codeunit "File Management";
        EmailAttachmentType: Record "BC6_Email Attachment Type";
        EmailAttachTypeTranslation: Record "BC6_Email Attach. Type Trans.";
        Attachment: Record Attachment;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecRef: RecordRef;
        ServerTempFilePath: Text;
        ServerFilePath: Text;
        FileExtension: Text;
        ExportFormat: ReportFormat;
    begin
        WITH EmailAttachmentType DO BEGIN
            GET(AttachmentTypeCode);
            EmailAttachTypeTranslation.GET(Code, LanguageCode);

            RecRef.GET(RecID);

            IF "Output Format" = "Output Format"::Word THEN BEGIN
                FileExtension := 'docx';
                ExportFormat := REPORTFORMAT::Word;
            END ELSE BEGIN
                FileExtension := 'pdf';
                ExportFormat := REPORTFORMAT::Pdf;
            END;

            ServerTempFilePath := FileManagement.ServerTempFileName(FileExtension);
            IF ReportSaveAs(EmailAttachTypeTranslation."Report ID", ExportFormat, ServerTempFilePath, RecRef, EmailAttachTypeTranslation."Custom Report Layout Code") THEN BEGIN
                CASE "File Naming" OF
                    "File Naming"::Invoice:
                        BEGIN
                            RecRef.SETTABLE(SalesInvoiceHeader);
                            ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath),
                                STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesInvoiceHeader."No.", FileExtension));
                        END;
                    "File Naming"::"Credit Memo":
                        BEGIN
                            RecRef.SETTABLE(SalesCrMemoHeader);
                            ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath),
                                STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesCrMemoHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesCrMemoHeader."No.", FileExtension));
                        END;
                    "File Naming"::Customer:
                        ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath), STRSUBSTNO('%1 - %2.%3', EmailAttachTypeTranslation.Description, CustomerNo, FileExtension));
                    ELSE
                        ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath), STRSUBSTNO('%1 - %2.%3', EmailAttachTypeTranslation.Description, DocumentNo, FileExtension));
                END;
                FileManagement.CopyServerFile(ServerTempFilePath, ServerFilePath, TRUE);
                FileManagement.DeleteServerFile(ServerTempFilePath);
                TempEmailAttachmentType := EmailAttachmentType;
                TempEmailAttachmentType."File Path" := ServerFilePath;
                TempEmailAttachmentType.INSERT;
            END ELSE BEGIN
                ERROR(GETLASTERRORTEXT);
            END;
        END;
        EXIT(ServerFilePath);
    end;

    local procedure GetEmailModelCode(TableNo: Integer; DocumentTitle: Code[10]): Code[20]
    var
        EmailModel: Record "BC6_Email Model";
        // TODO: GS1Setup: Record "50006";
        StandardText: Record "Standard Text";
        EmailModelCode: Code[20];
    begin
        GS1Setup.GET;
        CASE TableNo OF
            112:
                BEGIN
                    IF DocumentTitle = '' THEN BEGIN
                        GS1Setup.TESTFIELD("Default Model Code Untitl. Inv");
                        EmailModelCode := GS1Setup."Default Model Code Untitl. Inv";
                    END ELSE BEGIN
                        EmailModel.SETCURRENTKEY("Document Title");
                        EmailModel.SETRANGE("Document Title", DocumentTitle);
                        IF EmailModel.FINDFIRST THEN
                            EmailModelCode := EmailModel.Code;
                    END;
                END;
            114:
                BEGIN
                    EmailModelCode := GS1Setup."Sales Credit Memo Model Code";
                END;
        END;
        EXIT(EmailModelCode);
    end;

    local procedure ReportSaveAs(ReportID: Integer; ExportFormat: ReportFormat; ServerFilePath: Text; RecRef: RecordRef; CustomReportLayoutCode: Code[20]) Success: Boolean
    var
        FileManagement: Codeunit "File Management";
        // TODO: TempBlob: Record "99008535" temporary;
        ReportLayoutSelection: Record "Report Layout Selection";
        OutStr: OutStream;
    begin
        FileManagement.DeleteServerFile(ServerFilePath);
        TempBlob.Blob.CREATEOUTSTREAM(OutStr);
        RecRef.SETRECFILTER;

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
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        IF NOT (RecordIdentifier.TABLENO IN [112, 114]) THEN
            EXIT;

        IF NOT RecRef.GET(RecordIdentifier) THEN
            EXIT;

        FldRef := RecRef.FIELD(50001);
        FldRef.VALUE(NewStatus);
        RecRef.MODIFY;
        COMMIT;
    end;


    procedure InsertLog(EmailModelCode: Code[20]; RecordIdentifier: RecordID; MessageStatus: Option Success,Error,Information,Warning; MessageText: Text)
    var
        EmailLog: Record "BC6_Email Log";
    begin
        WITH EmailLog DO BEGIN
            INIT;
            "Email Model Code" := EmailModelCode;
            "Record Identifier" := RecordIdentifier;
            "Search Record ID" := FORMAT("Record Identifier");
            "Message Status" := MessageStatus;
            Message := COPYSTR(MessageText, 1, 250);
            INSERT(TRUE);
        END;
        COMMIT;
    end;


    procedure GetLastEmailModelCode(): Code[20]
    begin
        EXIT(_LastEmailModelCode);
    end;


    procedure ViewLog(RecordIdentifier: RecordID)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EmailLog: Record "BC6_Email Log";
        RecRef: RecordRef;
    begin
        EmailLog.SETRANGE("Record Identifier", RecordIdentifier);
        PAGE.RUNMODAL(PAGE::"BC6_Email Log", EmailLog);
    end;


    procedure SelectModelAndSendlEmail(RecordIdentifier: RecordID): Code[20]
    var
        EmailModel: Record "BC6_Email Model";
    // TODO: "GS1 Setup" GS1Setup: Record "50006";
    begin
        EmailModel.FILTERGROUP(2);
        IF RecordIdentifier.TABLENO = 18 THEN BEGIN
            GS1Setup.GET;
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
        FileManagement: Codeunit "File Management";
        EmailModel: Record "BC6_Email Model";
        //TODO: TempBlob: Record "99008535";
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
        HtmlFilePath: Text;
    begin
        EmailModel.GET(LanguageTemplateMail."Parameter String");

        WordApplication := WordHelper.GetApplication(ErrorMessage);
        IF ISNULL(WordApplication) THEN
            ERROR(ErrorMessage);

        LanguageTemplateMail.CALCFIELDS("Template mail");
        IF LanguageTemplateMail."Template mail".HASVALUE THEN BEGIN
            TempBlob.INIT;
            TempBlob.Blob := LanguageTemplateMail."Template mail";
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
            LanguageTemplateMail."Template mail" := TempBlob.Blob;
            LanguageTemplateMail.MODIFY;
        END;

        FileManagement.DeleteClientFile(FilePath);
        IF FilePath <> NewFilePath THEN
            FileManagement.DeleteClientFile(NewFilePath);

        WordHandler.Dispose;
        CLEAR(WordHandler);
    end;
}


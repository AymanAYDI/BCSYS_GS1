codeunit 50021 "BC6_GS1 : DMS Managment"
{
    Permissions = tabledata 112 = rm,
                  tabledata 114 = rm;

    trigger OnRun()
    begin
        SendDocument(_RecordID, _EmailModelCode);
    end;

    var
        _RecordID: RecordID;
        _EmailModelCode: Code[20];
        _LastEmailModelCode: Code[20];
        ConstAlreadySent: label 'Sent already.';
        ConstEmailModelBlocked: label 'Le modèle email %1 est bloqué';
        ConstLoadDocQuestion: label 'The document has been edited in Word.\\Do you want to import the changes?';
        ConstNoContactCrMemo: label 'they are no email in Contact for the bill to customer %1 for Sales Credit Memo %2';
        ConstNoContactCustomer: label 'they are no email in Contact for the bill to customer %1 for Sales Credit Memo %2';
        ConstNoContactInvoice: label 'they are no email in Contact for the bill to customer %1 for Sales Invoice %2';
        ConstNoCustGLN: label 'Customer %1 haven''t GLN.';
        ConstNoEmailModelCode: label 'Aucun code modèle email n''est défini.';
        ConstSendCanceled: label 'Send canceled';
        ConstSendSuccess: label 'Sending successful';


    procedure Send(RecordIdentifier: RecordID; EmailModelCode: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
    begin
        CLEARLASTERROR();
        GS1DMSManagment.SetGlobalParameters(RecordIdentifier, EmailModelCode);
        if GS1DMSManagment.RUN() then begin
            GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."BC6_Send Status"::Sent.AsInteger());
            GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode(), RecordIdentifier, 0, ConstSendSuccess);
            if GUIALLOWED then
                MESSAGE(ConstSendSuccess);
        end else begin
            if GETLASTERRORTEXT <> ConstSendCanceled then begin
                GS1DMSManagment.UpdateStatus(RecordIdentifier, SalesInvoiceHeader."BC6_Send Status"::"Not Sent".AsInteger());
                GS1DMSManagment.InsertLog(GS1DMSManagment.GetLastEmailModelCode(), RecordIdentifier, 1, GETLASTERRORTEXT);
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
        Language: Record Language;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1EmailManagement: codeunit "BC6_GS1 : Email Management";
        // TDOD: "Codeunit Web Api Documents Mgt." WebApiDocumentsMgt: Codeunit "50042";
        FileManagement: codeunit "File Management";
        TempBlob: codeunit "Temp Blob";
        RecRef: RecordRef;
        CustomerNo: Code[20];
        DocumentNo: Code[20];
        LanguageCode: Code[20];
        SendStatus: Integer;
        EmailBodyText: Text;
        ErrorTextNoContact: Text;
        FilePath: Text;
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
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactCustomer, CustomerNo);
                end;
            112:
                begin
                    RecRef.SETTABLE(SalesInvoiceHeader);
                    if EmailModelCode = '' then
                        EmailModelCode := GetEmailModelCode(RecRef.NUMBER, CopyStr(SalesInvoiceHeader."BC6_Invoice Title", 1, 10));

                    SendStatus := SalesInvoiceHeader."BC6_Send Status".AsInteger();
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

                    SendStatus := SalesInvoiceHeader."BC6_Send Status".AsInteger();
                    DocumentNo := SalesCrMemoHeader."No.";
                    CustomerNo := SalesCrMemoHeader."Bill-to Customer No.";
                    LanguageCode := SalesCrMemoHeader."Language Code";
                    ErrorTextNoContact := STRSUBSTNO(ConstNoContactCrMemo, CustomerNo, SalesCrMemoHeader."No.");
                end;
        end;

        _LastEmailModelCode := EmailModelCode;

        if GUIALLOWED and (SendStatus = SalesInvoiceHeader."BC6_Send Status"::Sent.AsInteger()) then
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
            LanguageCode := Language.GetUserLanguage();

        GetEmailRecipients(EmailModel.Code, Customer.GetContact(), Recipients);

        if STRPOS(Recipients[1], '@') = 0 then
            ERROR(ErrorTextNoContact);

        CompanyInformation.GET();
        if Recipients[4] = '' then
            Recipients[4] := CompanyInformation."E-Mail";

        GS1EmailManagement.FctGetTemplateWithLanguage(EmailModel.Code, CopyStr(LanguageCode, 1, 10), TempBlob);
        GS1EmailManagement.FctLoadMailBody(RecRef, TempBlob, '', '', EmailBodyText);
        //EmailBodyText := TempBlob.ReadTextLine();

        if not LanguageTemplateMail.GET(EmailModel.Code, LanguageCode) then
            LanguageTemplateMail.GET(EmailModel.Code, 'FRA');

        GS1EmailManagement.FctCreateMailMessage(CompanyInformation.Name, Recipients[4], Recipients[1], Recipients[2], Recipients[3], LanguageTemplateMail.Object, EmailBodyText, true);

        EmailAttachment.SETRANGE("Email Setup Code", EmailModel.Code);
        if EmailAttachment.FINDSET() then
            repeat
                FilePath := GenerateAttachment(EmailAttachment."Attachment Type Code", CopyStr(LanguageCode, 1, 10), RecRef.RECORDID, DocumentNo, CustomerNo, TempEmailAttachmentType);
                GS1EmailManagement.FctAddMailAttachment(FilePath, FileManagement.GetFileName(FilePath));
            until EmailAttachment.NEXT() = 0;

        GS1EmailManagement.FctSendMail(true);

        if TempEmailAttachmentType.FINDSET() then
            repeat
            // WebApiDocumentsMgt.SaveDocument(Customer."No.", Customer.GLN, Customer."BC6_Company ID", Customer."BC6_SIREN/SIRET", 'Dynamics NAV', TempEmailAttachmentType."File Path", TRUE, FileManagement.GetFileName(TempEmailAttachmentType."File Path"), '', TempEmailAttachmentType."WebApi Type", TempEmailAttachmentType."WebApi Sub Type", DocumentNo);
            //TODO FileManagement.DeleteServerFile(TempEmailAttachmentType."File Path");
            until TempEmailAttachmentType.NEXT() = 0;

    end;

    local procedure GetEmailRecipients(EmailModelCode: Code[20]; ContactCompanyNo: Code[20]; var Recipients: array[4] of Text)
    var
        //TODO SMTPMail: Codeunit "400";
        //SMTPMail: codeunit "Email Message";
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

    local procedure GenerateAttachment(AttachmentTypeCode: Code[20]; LanguageCode: Code[10]; RecID: RecordID; DocumentNo: Code[20]; CustomerNo: Code[20]; var TempEmailAttachmentType: Record "BC6_Email Attachment Type" temporary): Text
    var

        EmailAttachTypeTranslation: Record "BC6_Email Attach. Type Trans.";
        EmailAttachmentType: Record "BC6_Email Attachment Type";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ExportFormat: ReportFormat;
        FileManagement: codeunit "File Management";
        RecRef: RecordRef;
        FileExtension: Text;
        ServerFilePath: Text;
        TempFilePath: Text;
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

        //TODOServerTempFilePath := FileManagement.ServerTempFileName(FileExtension);
        TempFilePath := FileManagement.CreateFileNameWithExtension('File', FileExtension);

        if ReportSaveAs(EmailAttachTypeTranslation."Report ID", ExportFormat, TempFilePath, RecRef, EmailAttachTypeTranslation."Custom Report Layout Code") then begin
            case EmailAttachmentType."File Naming" of
                EmailAttachmentType."File Naming"::Invoice:
                    begin
                        RecRef.SETTABLE(SalesInvoiceHeader);
                        // ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath),
                        //     STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesInvoiceHeader."No.", FileExtension));
                        ServerFilePath := FileManagement.GetDirectoryName(TempFilePath) +
    STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesInvoiceHeader."No.", FileExtension);


                    end;
                EmailAttachmentType."File Naming"::"Credit Memo":
                    begin
                        RecRef.SETTABLE(SalesCrMemoHeader);
                        //TODO ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath),
                        //     STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesCrMemoHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesCrMemoHeader."No.", FileExtension));
                        ServerFilePath := FileManagement.GetDirectoryName(TempFilePath) +
   STRSUBSTNO('GS1_%1_%2.%3', FORMAT(SalesCrMemoHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>'), SalesCrMemoHeader."No.", FileExtension);

                    end;
                EmailAttachmentType."File Naming"::Customer:
                    //TODO ServerFilePath := FileManagement.CombinePath(FileManagement.GetDirectoryName(ServerTempFilePath), STRSUBSTNO('%1 - %2.%3', EmailAttachTypeTranslation.Description, CustomerNo, FileExtension));
                    ServerFilePath := FileManagement.GetDirectoryName(TempFilePath) + STRSUBSTNO('%1 - %2.%3', EmailAttachTypeTranslation.Description, CustomerNo, FileExtension);

                else
                    ServerFilePath := FileManagement.GetDirectoryName(TempFilePath) + STRSUBSTNO('%1 - %2.%3', EmailAttachTypeTranslation.Description, DocumentNo, FileExtension);
            end;
            //TODO FileManagement.CopyServerFile(ServerTempFilePath, ServerFilePath, TRUE);
            //TODO FileManagement.DeleteServerFile(ServerTempFilePath);
            TempEmailAttachmentType := EmailAttachmentType;
            TempEmailAttachmentType."File Path" := CopyStr(ServerFilePath, 1, MaxStrLen(TempEmailAttachmentType."File Path"));
            TempEmailAttachmentType.INSERT();
        end else
            ERROR(GETLASTERRORTEXT);
        exit(ServerFilePath);
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

    local procedure ReportSaveAs(ReportID: Integer; ExportFormat: ReportFormat; ServerFilePath: Text; RecRef: RecordRef; CustomReportLayoutCode: Code[20]) Success: Boolean
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        FileManagement: codeunit "File Management";
        TempBlob: codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        //TODO FileManagement.DeleteServerFile(ServerFilePath);
        TempBlob.CreateOutStream(OutStr);
        RecRef.SETRECFILTER();

        ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutCode);
        Success := REPORT.SAVEAS(ReportID, '', ExportFormat, OutStr, RecRef);
        ReportLayoutSelection.SetTempLayoutSelected('');

        //TODO FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
        FileManagement.BLOBExport(TempBlob, ServerFilePath, true);
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


    //TODO procedure OpenWordDocument(LanguageTemplateMail: Record "BC6_Language Template Mail")
    // var
    //     EmailModel: Record "BC6_Email Model";
    //     FileManagement: Codeunit "File Management";
    //     TempBlob: Codeunit "Temp Blob";
    //     RecRef: RecordRef;
    //     [RunOnClient]
    //     WordApplication: DotNet ApplicationClass;
    //     [RunOnClient]
    //     WordDocument: DotNet Document;
    //     [RunOnClient]
    //     WdSaveFormat: DotNet WdSaveFormat;
    //     [RunOnClient]
    //     WdWindowState: DotNet WdWindowState;
    //     [RunOnClient]
    //     WordHandler: DotNet WordHandler;
    //     [RunOnClient]
    //     WordHelper: DotNet WordHelper;
    //     ErrorMessage: Text;
    //     FilePath: Text;
    //     NewFilePath: Text;
    // begin
    //     EmailModel.GET(LanguageTemplateMail."Parameter String");

    //     // WordApplication := WordHelper.GetApplication(ErrorMessage);
    //     // IF ISNULL(WordApplication) THEN
    //     //     ERROR(ErrorMessage);

    //     LanguageTemplateMail.CALCFIELDS("Template mail");
    //     IF LanguageTemplateMail."Template mail".HASVALUE THEN BEGIN
    //         TempBlob.FromRecord(LanguageTemplateMail, LanguageTemplateMail.FieldNo("Template mail"));

    //         FilePath := FileManagement.BLOBExport(TempBlob, 'Temp.htm', FALSE);
    //     END ELSE BEGIN
    //         FilePath := FileManagement.ClientTempFileName('htm');
    //         WordDocument := WordHelper.AddDocument(WordApplication);
    //         WordHelper.CallSaveAsFormat(WordDocument, FilePath, WdSaveFormat.wdFormatFilteredHTML);
    //     END;

    //     // Open word and wait for the document to be closed
    //     WordHandler := WordHandler.WordHandler;
    //     WordDocument := WordHelper.CallOpen(WordApplication, FilePath, FALSE, FALSE);
    //     WordDocument.ActiveWindow.Caption := EmailModel.Description;
    //     WordDocument.Application.Visible := TRUE; // Visible before WindowState KB176866 - http://support.microsoft.com/kb/176866
    //     WordDocument.ActiveWindow.WindowState := WdWindowState.wdWindowStateNormal;

    //     // Push the word app to foreground
    //     WordApplication.WindowState := WdWindowState.wdWindowStateMinimize;
    //     WordApplication.Visible := TRUE;
    //     WordApplication.Activate;
    //     WordApplication.WindowState := WdWindowState.wdWindowStateNormal;
    //     WordDocument.Saved := TRUE;
    //     WordDocument.Application.Activate;

    //     NewFilePath := WordHandler.WaitForDocument(WordDocument);
    //     CLEAR(WordApplication);

    //     IF CONFIRM(ConstLoadDocQuestion) THEN BEGIN
    //         FileManagement.BLOBImport(TempBlob, NewFilePath);

    //         // LanguageTemplateMail."Template mail" := TempBlob.Blob;
    //         RecRef.GetTable(LanguageTemplateMail);
    //         TempBlob.ToRecordRef(RecRef, LanguageTemplateMail.FieldNo("Template mail"));
    //         RecRef.SetTable(LanguageTemplateMail);

    //         LanguageTemplateMail.MODIFY();
    //     END;

    //     FileManagement.DeleteClientFile(FilePath);
    //     IF FilePath <> NewFilePath THEN
    //         FileManagement.DeleteClientFile(NewFilePath);

    //     WordHandler.Dispose;
    //     CLEAR(WordHandler);
    // end;

}


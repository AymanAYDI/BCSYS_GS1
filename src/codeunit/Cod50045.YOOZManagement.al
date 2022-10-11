codeunit 50045 "BC6_YOOZ Management"
{
    procedure ImportData()
    var
        TempBlob: codeunit "Temp Blob";
        IStream: InStream;
        Excel2007FileType: label 'Excel Files (*.xlsx;*.xls)|*.csv;*.csv', Comment = '{Split=r''\|''}{Locked=s''1''}';
        ClientFileName: Text;
        ClientFileName2: Text;
        DataArray: array[50] of Text;
        DataText: Text;
    begin
        ClientFileName := FileManagement.BLOBImportWithFilter(TempBlob, CstTxt006, '', Excel2007FileType, 'csv');

        if ClientFileName = '' then
            exit;
        // Check exist Line
        ClientFileName2 := FileManagement.GetFileNameWithoutExtension(ClientFileName);
        GFileName := ClientFileName2;
        YOOZBuffer.RESET();
        YOOZBuffer.SETRANGE("Import File Name", ClientFileName2);
        if not YOOZBuffer.ISEMPTY then
            ERROR(CstTxt009, ClientFileName2);
        GS1Setup.GET();
        GS1Setup.TESTFIELD("YOOZ Journ. Batch Name");
        GS1Setup.TESTFIELD("YOOZ Journ. Temp. Name");
        GS1Setup.TESTFIELD("YOOZ Source Code");
        TempBlob.CREATEINSTREAM(IStream, TEXTENCODING::UTF8);
        while not IStream.EOS do begin
            IStream.READTEXT(DataText);
            ExtractCSVData(DataText, ';', DataArray);
            InitYoozBuffer(DataArray, CopyStr(ClientFileName2, 1, 250));
        end;

        CheckAllData();
    end;

    procedure CheckAllData()
    var
        ImportYOOZBuffer: Record "BC6_YOOZ import Buffer";
        RecNo: Integer;
        TotalRecNo: Integer;
    begin
        GLSetup.GET();

        ImportYOOZBuffer.RESET();
        ImportYOOZBuffer.SETRANGE("Import Type", ImportYOOZBuffer."Import Type"::YOOZ);
        ImportYOOZBuffer.SETFILTER(Status, '<>%1', ImportYOOZBuffer.Status::Post);
        if ImportYOOZBuffer.ISEMPTY then
            exit;

        Window.OPEN(CstTxt005 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\' +
                    CstTxt007 + '@2@@@@@@@@@@@@@@@@@@@@@@@@@\');

        TotalRecNo := ImportYOOZBuffer.COUNT;

        ImportYOOZBuffer.FINDSET();
        repeat
            RecNo += 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

            if ImportYOOZBuffer.Status = ImportYOOZBuffer.Status::Error then
                ImportYOOZBuffer.DeleteErrorLine();

            CheckData(ImportYOOZBuffer);
        until ImportYOOZBuffer.NEXT() = 0;

        CheckTransaction();
    end;

    local procedure CheckData(ImportBuffer: Record "BC6_YOOZ import Buffer")
    var
        ErrorLog: Record "BC6_YOOZ Error Log";
        GLAcc: Record "G/L Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        Vendor: Record Vendor;
        CalcDateF: Date;
    begin
        ImportBuffer.Status := ImportBuffer.Status::"On Hold";

        // Vérif date compta
        if ImportBuffer."YOOZ Posting Date" = 0D then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("YOOZ Posting Date")),
              ImportBuffer."Import File Name",
              CopyStr(ImportBuffer.FIELDCAPTION("YOOZ Posting Date"), 1, 250),
              FORMAT(ImportBuffer."YOOZ Posting Date"));
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end;

        // Verif Document No
        if ImportBuffer."Document No." = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Document No.")),
              ImportBuffer."Import File Name",
              CopyStr(ImportBuffer.FIELDCAPTION("Document No."), 1, 250),
              ImportBuffer."Document No.");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end;

        // Vérif import Document Date
        if ImportBuffer."Import Document Date" = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Document Date")),
              ImportBuffer."Import File Name",
              CopyStr(ImportBuffer.FIELDCAPTION("Import Document Date"), 1, 250),
              ImportBuffer."Import Document Date");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end else
            if not EVALUATE(CalcDateF, ImportBuffer."Import Document Date") then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt001, ImportBuffer.FIELDCAPTION("Import Document Date")),
                  ImportBuffer."Import File Name",
                  CopyStr(ImportBuffer.FIELDCAPTION("Import Document Date"), 1, 250),
                  ImportBuffer."Import Document Date");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;

        //Verif Import Journal Template Name
        if ImportBuffer."Import Journ. Template Name" = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Journ. Template Name")),
              ImportBuffer."Import File Name",
              CopyStr(ImportBuffer.FIELDCAPTION("Import Journ. Template Name"), 1, 250),
              ImportBuffer."Import Journ. Template Name");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end else
            if not GenJournalTemplate.GET(ImportBuffer."Import Journ. Template Name") then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt002, ImportBuffer.FIELDCAPTION("Import Journ. Template Name"), GenJournalTemplate.TABLECAPTION),
                  ImportBuffer."Import File Name",
                  CopyStr(ImportBuffer.FIELDCAPTION("Import Journ. Template Name"), 1, 250),
                  ImportBuffer."Import Journ. Template Name");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;

        // import Document Type
        if ImportBuffer."Import Document Type" = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Document Type")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Import Document Type"),
              ImportBuffer."Import Document Type");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end else
            if (ImportBuffer."Import Document Type" <> 'FA') and (ImportBuffer."Import Document Type" <> 'AV') then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt001, ImportBuffer.FIELDCAPTION("Import Document Type")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Import Document Type"),
                  ImportBuffer."Import Document Type");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;

        // Verif import account type
        if ImportBuffer."Import Account Type" = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Journ. Template Name")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Import Journ. Template Name"),
              ImportBuffer."Import Journ. Template Name");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end;

        // G/L Account No.
        if ImportBuffer."G/L Account No." = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("G/L Account No.")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("G/L Account No."),
              ImportBuffer."G/L Account No.");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end else
            if ImportBuffer."Account Type" = ImportBuffer."Account Type"::"G/L Account" then begin
                if not GLAcc.GET(ImportBuffer."G/L Account No.") then begin
                    ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                      STRSUBSTNO(CstTxt002, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.TABLECAPTION),
                      ImportBuffer."Import File Name",
                      ImportBuffer.FIELDCAPTION("G/L Account No."),
                      ImportBuffer."G/L Account No.");
                    ImportBuffer.Status := ImportBuffer.Status::Error;
                end else begin
                    if not GLAcc."Direct Posting" then begin
                        ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                          STRSUBSTNO(CstTxt003, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.FIELDCAPTION("Direct Posting"), GLAcc."Direct Posting"),
                          ImportBuffer."Import File Name",
                          ImportBuffer.FIELDCAPTION("G/L Account No."),
                          ImportBuffer."G/L Account No.");
                        ImportBuffer.Status := ImportBuffer.Status::Error;
                    end;
                    if GLAcc.Blocked then begin
                        ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                          STRSUBSTNO(CstTxt003, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.FIELDCAPTION(Blocked), GLAcc.Blocked),
                          ImportBuffer."Import File Name",
                          ImportBuffer.FIELDCAPTION("G/L Account No."),
                          ImportBuffer."G/L Account No.");
                        ImportBuffer.Status := ImportBuffer.Status::Error;
                    end;
                end;
            end else
                if ImportBuffer."Account Type" = ImportBuffer."Account Type"::Vendor then
                    if not Vendor.GET(ImportBuffer."G/L Account No.") then begin
                        ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                        STRSUBSTNO(CstTxt002, ImportBuffer.FIELDCAPTION("G/L Account No."), Vendor.TABLECAPTION),
                        ImportBuffer."Import File Name",
                        ImportBuffer.FIELDCAPTION("G/L Account No."),
                        ImportBuffer."G/L Account No.");
                        ImportBuffer.Status := ImportBuffer.Status::Error;
                    end else
                        if (Vendor.Blocked = Vendor.Blocked::All) then begin
                            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                              STRSUBSTNO(CstTxt003, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.FIELDCAPTION(Blocked), GLAcc.Blocked),
                              ImportBuffer."Import File Name",
                              ImportBuffer.FIELDCAPTION("G/L Account No."),
                              ImportBuffer."G/L Account No.");
                            ImportBuffer.Status := ImportBuffer.Status::Error;
                        end;

        // Verif Description
        if ImportBuffer.Description = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION(Description)),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION(Description),
              ImportBuffer.Description);
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end;

        // Verif YOOZ No
        if ImportBuffer."YOOZ No." = '' then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("YOOZ No.")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("YOOZ No."),
              ImportBuffer."YOOZ No.");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end;

        //doc type
        if ImportBuffer."Document Type" = ImportBuffer."Document Type"::" " then begin
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Document Type")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Document Type"),
              FORMAT(ImportBuffer."Document Type"));
            ImportBuffer.Status := ImportBuffer.Status::Error;
        end else
            if (ImportBuffer."Document Type" <> ImportBuffer."Document Type"::Invoice) and (ImportBuffer."Document Type" <> ImportBuffer."Document Type"::"Credit Memo") then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt001, ImportBuffer.FIELDCAPTION("Document Type")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Document Type"),
                  FORMAT(ImportBuffer."Document Type"));
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;

        if (ImportBuffer."Account Type" = ImportBuffer."Account Type"::"G/L Account") and (COPYSTR(ImportBuffer."G/L Account No.", 1, 1) <> '4') then begin
            // Verif Dimvalue1 mandatory
            if ImportBuffer."Dimension Value 1" = '' then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 1")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 1"),
                  ImportBuffer."Dimension Value 1");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;

            // Verif Dimvalue2 mandatory
            if ImportBuffer."Dimension Value 2" = '' then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 2")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 2"),
                  ImportBuffer."Dimension Value 2");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;

            // Verif Dimvalue3 mandatory
            if ImportBuffer."Dimension Value 3" = '' then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 3")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 3"),
                  ImportBuffer."Dimension Value 3");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;

            // Verif Dimvalue4 mandatory
            if ImportBuffer."Dimension Value 4" = '' then begin
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 4")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 4"),
                  ImportBuffer."Dimension Value 4");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            end;
        end;
        if ImportBuffer.Status = ImportBuffer.Status::"On Hold" then
            ImportBuffer.Status := ImportBuffer.Status::Check;
        ImportBuffer.MODIFY();
    end;

    local procedure CheckTransaction()
    var
        ErrorLog: Record "BC6_YOOZ Error Log";
        ImportBufferTransaction: Record "BC6_YOOZ import Buffer";
        ImportYOOZBuffer: Record "BC6_YOOZ import Buffer";
        RecNo: Integer;
        TotalRecNo: Integer;
    begin
        ImportYOOZBuffer.RESET();
        ImportYOOZBuffer.SETRANGE("Import Type", ImportYOOZBuffer."Import Type"::YOOZ);
        ImportYOOZBuffer.SETFILTER(Status, '<>%1', ImportYOOZBuffer.Status::Post);
        if ImportYOOZBuffer.ISEMPTY then
            exit;

        TotalRecNo := ImportYOOZBuffer.COUNT;

        ImportYOOZBuffer.FINDSET();
        repeat
            RecNo += 1;
            Window.UPDATE(2, ROUND(RecNo / TotalRecNo * 10000, 1));

            ImportBufferTransaction.SETRANGE("Import Type", ImportBufferTransaction."Import Type"::YOOZ);
            ImportBufferTransaction.SETRANGE("Import File Name", ImportYOOZBuffer."Import File Name");
            ImportBufferTransaction.SETRANGE("Document No.", ImportYOOZBuffer."Document No.");
            ImportBufferTransaction.CALCSUMS("Debit Amount", "Credit Amount");
            if ((ImportBufferTransaction."Credit Amount" - ImportBufferTransaction."Debit Amount") <> 0) then begin
                ErrorLog.InsertLogEntry(ImportYOOZBuffer."Entry No.",
                  CstTxt004,
                  ImportYOOZBuffer."Import File Name",
                  'Somme des Montants',
                  FORMAT(ImportBufferTransaction."Credit Amount" - ImportBufferTransaction."Debit Amount"));
                ImportBufferTransaction.MODIFYALL(Status, ImportBufferTransaction.Status::Error);
            end;
        until ImportYOOZBuffer.NEXT() = 0;

        Window.CLOSE();
    end;

    procedure CheckStatus()
    begin
        YOOZBuffer.SETRANGE("Import Type", YOOZBuffer."Import Type"::YOOZ);
        YOOZBuffer.SETRANGE(Status, YOOZBuffer.Status::"On Hold", YOOZBuffer.Status::Error);
        if not YOOZBuffer.ISEMPTY then
            ERROR(CstTxt008);
    end;

    procedure InitGenLineData(RecPGenJnlTemplate: Record "Gen. Journal Template"; RecPGenJnlBatch: Record "Gen. Journal Batch"; IntPLastLineNo: Integer)
    begin
        RecGGenJnlTemplate := RecPGenJnlTemplate;
        RecGGenJnlBatch := RecPGenJnlBatch;
        IntGLineNo := IntPLastLineNo;
    end;

    procedure InitNewGLLine(RecPImportBuffer: Record "BC6_YOOZ import Buffer")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        IntGLineNo += 10000;
        RecGGenJournalLine.INIT();
        RecGGenJournalLine."Line No." := IntGLineNo;
        RecGGenJournalLine.VALIDATE("Journal Template Name", RecGGenJnlBatch."Journal Template Name");
        RecGGenJournalLine.VALIDATE("Journal Batch Name", RecGGenJnlBatch.Name);

        RecGGenJournalLine."Source Code" := RecPImportBuffer."Source Code";
        RecGGenJournalLine."Reason Code" := RecGGenJnlBatch."Reason Code";
        RecGGenJournalLine."Posting No. Series" := RecGGenJnlBatch."Posting No. Series";

        RecGGenJournalLine.INSERT(true);

        RecGGenJournalLine.VALIDATE("Posting Date", RecPImportBuffer."YOOZ Posting Date");
        RecGGenJournalLine.VALIDATE("Document Date", CToDate(RecPImportBuffer."Import Document Date", 'dd/MM/yyyy'));
        RecGGenJournalLine.VALIDATE("Document Type", RecPImportBuffer."Document Type");
        //RecGGenJournalLine.VALIDATE("Document No.",RecPImportBuffer."Document No.");
        RecGGenJournalLine.VALIDATE("External Document No.", RecPImportBuffer."Document No.");
        RecGGenJournalLine.VALIDATE("Account Type", RecPImportBuffer."Account Type");
        RecGGenJournalLine.VALIDATE("Account No.", RecPImportBuffer."G/L Account No.");
        RecGGenJournalLine.VALIDATE(Description, RecPImportBuffer.Description);
        if RecPImportBuffer."Debit Amount" <> 0 then
            RecGGenJournalLine.VALIDATE("Debit Amount", RecPImportBuffer."Debit Amount");
        if RecPImportBuffer."Credit Amount" <> 0 then
            RecGGenJournalLine.VALIDATE("Credit Amount", RecPImportBuffer."Credit Amount");

        RecGGenJournalLine.VALIDATE("Shortcut Dimension 1 Code", RecPImportBuffer."Dimension Value 1");
        RecGGenJournalLine.VALIDATE("Shortcut Dimension 2 Code", RecPImportBuffer."Dimension Value 2");
        RecGGenJournalLine.ValidateShortcutDimCode(3, RecPImportBuffer."Dimension Value 3");
        RecGGenJournalLine.ValidateShortcutDimCode(4, RecPImportBuffer."Dimension Value 4");

        if RecPImportBuffer."VAT Identifier" <> '' then begin
            VATPostingSetup.RESET();
            VATPostingSetup.SETRANGE("VAT Identifier", RecPImportBuffer."VAT Identifier");
            if VATPostingSetup.FINDFIRST() then begin
                RecGGenJournalLine.VALIDATE("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
                RecGGenJournalLine.VALIDATE("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            end;
        end;

        RecGGenJournalLine.MODIFY(true);
    end;

    procedure UpdateAllStatus()
    begin
        YOOZBuffer.RESET();
        YOOZBuffer.SETRANGE("Import Type", YOOZBuffer."Import Type"::YOOZ);
        YOOZBuffer.SETRANGE(Status, YOOZBuffer.Status::Check);
        YOOZBuffer.MODIFYALL(Status, YOOZBuffer.Status::Post);
    end;

    procedure RemoveStatus(var P_YOOZBuffer: Record "BC6_YOOZ import Buffer")
    var
        OldCustLedgEntry: Record "Cust. Ledger Entry";

    begin
        if not CONFIRM(CstTxt010, false, P_YOOZBuffer."Import File Name") then
            ERROR(CstTxt011);

        YOOZBuffer.SETRANGE("Import File Name", P_YOOZBuffer."Import File Name");
        YOOZBuffer.SETRANGE("Import Type", P_YOOZBuffer."Import Type");
        if YOOZBuffer.ISEMPTY then
            exit;

        YOOZBuffer.FINDSET();
        repeat
            OldCustLedgEntry.SETRANGE("Document No.", YOOZBuffer."Document No.");
            OldCustLedgEntry.SETRANGE("Document Type", YOOZBuffer."Document Type");
            if not OldCustLedgEntry.ISEMPTY then
                ERROR(CstTxt012, YOOZBuffer."Document Type", YOOZBuffer."Document No.");
        until YOOZBuffer.NEXT() = 0;

        YOOZBuffer.MODIFYALL(Status, YOOZBuffer.Status::"On Hold");

        CheckAllData();
    end;

    procedure DeleteImportLine(P_YOOZBuffer: Record "BC6_YOOZ import Buffer")
    begin

        if not CONFIRM(CstTxt013, false, P_YOOZBuffer."Import File Name") then
            ERROR(CstTxt011);

        YOOZBuffer.SETRANGE("Import File Name", P_YOOZBuffer."Import File Name");
        YOOZBuffer.SETRANGE("Import Type", P_YOOZBuffer."Import Type");
        if YOOZBuffer.ISEMPTY then
            exit;

        YOOZBuffer.DELETEALL(true);
    end;

    procedure ExtractCSVData(DataText: Text; CSVFieldSeparator: Text[1]; var DataArray: array[50] of Text)
    var
        Index: Integer;
        Pos: Integer;
        Separator: Text;
    begin
        CLEAR(DataArray);
        while DataText <> '' do begin
            Index += 1;
            if DataText[1] = '"' then
                Separator := STRSUBSTNO('"%1', CSVFieldSeparator)
            else
                Separator := CSVFieldSeparator;

            Pos := STRPOS(DataText, Separator);
            if Pos = 0 then begin
                DataArray[Index] := COPYSTR(DataText, STRLEN(Separator));
                exit;
            end;
            DataArray[Index] := COPYSTR(DataText, STRLEN(Separator), Pos - STRLEN(Separator));
            DataText := COPYSTR(DataText, Pos + STRLEN(Separator));
        end;
    end;

    procedure InitYoozBuffer(var DataArray: array[50] of Text; FileName: Text[250])
    var
        YOOZimportBuffer: Record "BC6_YOOZ import Buffer";
    begin
        YOOZimportBuffer.INIT();
        YOOZimportBuffer."Import File Name" := FileName;
        YOOZimportBuffer."User ID" := CopyStr(UserId, 1, MaxStrLen(YOOZimportBuffer."User ID"));
        YOOZimportBuffer."Import DateTime" := CURRENTDATETIME;
        YOOZimportBuffer."Import Type" := YOOZimportBuffer."Import Type"::YOOZ;
        YOOZimportBuffer."Line No." := CToInteger(DataArray[2]); // N° de ligne
        YOOZimportBuffer."Source Code" := GS1Setup."YOOZ Source Code";
        YOOZimportBuffer."Import Journ. Template Name" := GS1Setup."YOOZ Journ. Temp. Name";
        YOOZimportBuffer."Import Journ Batch Name" := GS1Setup."YOOZ Journ. Batch Name";
        YOOZimportBuffer."YOOZ Posting Date" := CToDate(DataArray[7], 'dd/MM/yyyy');//'fr-FR'); //Date compta
        YOOZimportBuffer."Document No." := DataArray[6]; //N° doc
        YOOZimportBuffer."Import Document Date" := DataArray[8]; //Date Document
        YOOZimportBuffer."Import Document Type" := DataArray[4]; //type document
        YOOZimportBuffer."G/L Account No." := DataArray[10]; //N° compte
        YOOZimportBuffer."Import Account Type" := DataArray[9]; //type de compte
        YOOZimportBuffer."YOOZ No." := DataArray[5]; //N° doc YOOZ
        YOOZimportBuffer."Debit Amount" := CToDecimal(DataArray[17], 'fr-FR');
        YOOZimportBuffer."Credit Amount" := CToDecimal(DataArray[18], 'fr-FR');
        //YOOZimportBuffer.Description:='YOOZ_'+DataArray[6]+'_'+DataArray[8];
        YOOZimportBuffer.Description := DataArray[11];
        YOOZimportBuffer."VAT Identifier" := DataArray[16];
        case DataArray[4] of
            'FA':
                YOOZimportBuffer."Document Type" := YOOZimportBuffer."Document Type"::Invoice;
            'AV':
                YOOZimportBuffer."Document Type" := YOOZimportBuffer."Document Type"::"Credit Memo";
        end;

        case COPYSTR(DataArray[9], 1, 1) of
            'G':
                YOOZimportBuffer."Account Type" := YOOZimportBuffer."Account Type"::"G/L Account";
            'F':
                YOOZimportBuffer."Account Type" := YOOZimportBuffer."Account Type"::Vendor;
        end;

        if COPYSTR(DataArray[10], 1, 1) = '4' then
            YOOZimportBuffer."Account Type" := YOOZimportBuffer."Account Type"::"G/L Account";

        YOOZimportBuffer."Dimension Value 1" := DataArray[21];
        YOOZimportBuffer."Dimension Value 2" := DataArray[22];
        YOOZimportBuffer."Dimension Value 3" := DataArray[23];
        YOOZimportBuffer."Dimension Value 4" := DataArray[24];

        YOOZimportBuffer.INSERT();
    end;

    procedure MajYoozDescription()
    var
        YOOZimportBuffer: Record "BC6_YOOZ import Buffer";
        YOOZimportBuffer2: Record "BC6_YOOZ import Buffer";
    begin
        YOOZimportBuffer.RESET();
        YOOZimportBuffer.SETRANGE("Import Type", YOOZimportBuffer."Import Type"::YOOZ);
        YOOZimportBuffer.SETRANGE("Account Type", YOOZimportBuffer."Account Type"::Vendor);
        YOOZimportBuffer.SETFILTER(Status, '<>%1', YOOZimportBuffer.Status::Post);
        if YOOZimportBuffer.ISEMPTY then
            exit;

        YOOZimportBuffer.FINDSET();
        repeat
            YOOZimportBuffer.Description := CopyStr(YOOZimportBuffer.Description + '_' + YOOZimportBuffer."G/L Account No.", 1, MaxStrLen(YOOZimportBuffer.Description));
            YOOZimportBuffer.MODIFY();
            YOOZimportBuffer2.RESET();
            YOOZimportBuffer2.SETRANGE("Import Type", YOOZimportBuffer2."Import Type"::YOOZ);
            YOOZimportBuffer2.SETFILTER(Status, '<>%1', YOOZimportBuffer2.Status::Post);
            YOOZimportBuffer2.SETFILTER("Account Type", '<>%1', YOOZimportBuffer2."Account Type"::Vendor);
            YOOZimportBuffer2.SETRANGE("Document No.", YOOZimportBuffer."Document No.");
            if YOOZimportBuffer2.FINDFIRST() then
                repeat
                    YOOZimportBuffer2.Description := YOOZimportBuffer.Description;
                    YOOZimportBuffer2.MODIFY();
                until YOOZimportBuffer2.NEXT() = 0;
        until YOOZimportBuffer.NEXT() = 0;
    end;

    procedure CToDate(Value: Text; FormatName: Text): Date
    var
        TypeHelper: codeunit "Type Helper";
        DateVariant: Variant;
    begin
        if Value = '' then exit(0D);
        DateVariant := 0D;
        TypeHelper.Evaluate(DateVariant, Value, FormatName, '');
        exit(DateVariant);
    end;

    procedure CToDecimal(Value: Text; CultureName: Text): Decimal
    var
        TypeHelper: codeunit "Type Helper";
        DecimalVariant: Variant;
    begin
        if Value = '' then exit(0);
        DecimalVariant := 0.0;
        TypeHelper.Evaluate(DecimalVariant, Value, '', CultureName);
        exit(DecimalVariant);
    end;

    procedure CToInteger(Value: Text): Integer
    var
        Int: Integer;
    begin
        if Value = '' then exit(0);
        EVALUATE(Int, Value);
        exit(Int);
    end;

    procedure CToBoolean(Value: Text): Boolean
    var
        Bool: Boolean;
    begin
        if Value = '' then exit(false);
        EVALUATE(Bool, Value);
        exit(Bool);
    end;

    procedure FormatInteger(Value: Decimal; BlankZero: Boolean): Text
    var
        ValueText: Text;
    begin
        ValueText := FORMAT(Value, 0, '<Sign><Integer>');
        if BlankZero and (ValueText = '0') then
            exit('');
        exit(ValueText);
    end;

    var
        GS1Setup: Record "BC6_GS1 Setup";
        YOOZBuffer: Record "BC6_YOOZ import Buffer";
        RecGGenJnlBatch: Record "Gen. Journal Batch";
        RecGGenJournalLine: Record "Gen. Journal Line";
        RecGGenJnlTemplate: Record "Gen. Journal Template";
        GLSetup: Record "General Ledger Setup";
        FileManagement: codeunit "File Management";
        Window: Dialog;
        IntGLineNo: Integer;

        CstTxt000: label '%1 is Mandatory', Comment = 'FRA="%1 est obligatoire."';
        CstTxt001: label '%1 is not correct data.', Comment = 'FRA="%1 n''est pas une donnée valide."';
        CstTxt002: label '%1 does not exist in%2.', Comment = 'FRA="%1 n''existe pas dans %2."';
        CstTxt003: label '%1 should not be%2 %3.', Comment = 'FRA="%1 ne doit pas être %2 %3."';
        CstTxt004: label 'The transaction is not balanced', Comment = 'FRA="La transaction n''est pas équilibré."';
        CstTxt005: label 'Checking Data...\\', Comment = 'FRA="Contrôle des données...\\"';
        CstTxt006: label 'Select file to import', Comment = 'FRA="Fichier à importer"';
        CstTxt007: label 'Analyzing Amount Data...\\', Comment = 'FRA="Analyse des montants...\\"';
        CstTxt008: label 'Almost One line is on Error.', Comment = 'FRA="Il existe au moins une ligne en erreur."';
        CstTxt009: label 'File %1 has already been imported.', Comment = 'FRA="Le fichier %1  a déjà été importé."';
        CstTxt010: label 'Are you sure you want to roll back File %1 on buffer table?', Comment = 'FRA="Voulez-vous vraiment rebasculer le fichier %1 dans la table tampon?"';
        CstTxt011: label 'The update has been interrupted to respect the warning.', Comment = 'FRA="La mise à jour a été interrompue pour respecter l''alerte."';
        CstTxt012: label 'Sales %1 %2 already exists.The update has been interrupted to respect the warning.', Comment = 'FRA="Le document %1 vente %2 a fait l''objet d''une validation.La mise à jour a été interrompue pour respecter l''alerte."';
        CstTxt013: label 'Are you sure you want to delete File %1 on import table?', Comment = 'FRA="Voulez-vous vraiment supprimer le fichier %1 dans la table d''import?"';
        GFileName: Text;
}

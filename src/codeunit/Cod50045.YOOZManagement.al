codeunit 50045 "BC6_YOOZ Management"
{

    procedure ImportData()
    var
        IStream: InStream;
        ClientFileName: Text;
        ClientFileName2: Text;
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        DataText: Text;
        Excel2007FileType: Label 'Excel Files (*.xlsx;*.xls)|*.csv;*.csv', Comment = '{Split=r''\|''}{Locked=s''1''}';
        DataArray: ARRAY[50] OF Text;
    begin
        // FileNameFilter := FileManagement.CombinePath('', '*.csv');
        //ClientFileName := FileManagement.OpenFileDialog(CstTxt006, FileNameFilter, '');
        ClientFileName := FileManagement.BLOBImportWithFilter(TempBlob, CstTxt006, '', Excel2007FileType, 'csv');

        IF ClientFileName = '' THEN
            EXIT;

        // Check exist Line
        ClientFileName2 := FileManagement.GetFileNameWithoutExtension(ClientFileName);
        GFileName := ClientFileName2;
        YOOZBuffer.RESET();
        YOOZBuffer.SETRANGE("Import File Name", ClientFileName2);
        IF NOT YOOZBuffer.ISEMPTY THEN
            ERROR(CstTxt009, ClientFileName2);

        //TODO   ServerFileName := FileManagement.UploadFileSilent(ClientFileName);
        GS1Setup.GET();
        GS1Setup.TESTFIELD("YOOZ Journ. Batch Name");
        GS1Setup.TESTFIELD("YOOZ Journ. Temp. Name");
        GS1Setup.TESTFIELD("YOOZ Source Code");

        //Gestion de l'import dans la table tampon par Instream
        //chargement du fichier dans un blob temporaire
        //UPLOADINTOSTREAM('Fichier à importer','','|*.csv',ServerFileName,IStream);
        //TODO  FileManagement.BLOBImportFromServerFile(TempBlob, ServerFileName);
        TempBlob.CREATEINSTREAM(IStream, TEXTENCODING::UTF8);
        //TODO TempBlob.CALCFIELDS(Blob);

        //si le fichier contient une entete , réactiver ces lignes de codes.
        //IF NOT IStream.EOS THEN
        //  IStream.READTEXT(DataText);

        WHILE NOT IStream.EOS DO BEGIN
            IStream.READTEXT(DataText);
            ExtractCSVData(DataText, ';', DataArray);
            InitYoozBuffer(DataArray, ClientFileName2);
        END;

        //MajYoozDescription;

        //suppresion du fichier du serveur
        // ERASE(ServerFileName);

        // Check Data
        CheckAllData();
    end;

    procedure CheckAllData()
    var
        ImportYOOZBuffer: Record "BC6_YOOZ import Buffer";
        TotalRecNo: Integer;
        RecNo: Integer;
    begin
        GLSetup.GET();

        ImportYOOZBuffer.RESET();
        ImportYOOZBuffer.SETRANGE("Import Type", ImportYOOZBuffer."Import Type"::YOOZ);
        //ImportYOOZBuffer.SETRANGE("Import File Name",GFileName);
        ImportYOOZBuffer.SETFILTER(Status, '<>%1', ImportYOOZBuffer.Status::Post);
        IF ImportYOOZBuffer.ISEMPTY THEN
            EXIT;

        Window.OPEN(CstTxt005 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\' +
                    CstTxt007 + '@2@@@@@@@@@@@@@@@@@@@@@@@@@\');

        TotalRecNo := ImportYOOZBuffer.COUNT;

        ImportYOOZBuffer.FINDSET();
        REPEAT
            RecNo += 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

            IF ImportYOOZBuffer.Status = ImportYOOZBuffer.Status::Error THEN
                ImportYOOZBuffer.DeleteErrorLine();

            CheckData(ImportYOOZBuffer);
        UNTIL ImportYOOZBuffer.NEXT() = 0;

        CheckTransaction();

    end;

    local procedure CheckData(ImportBuffer: Record "BC6_YOOZ import Buffer")
    var
        GLAcc: Record "G/L Account";
        CalcDateF: Date;
        GenJournalTemplate: Record "Gen. Journal Template";
        Vendor: Record Vendor;
        ErrorLog: Record "BC6_YOOZ Error Log";
    begin
        ImportBuffer.Status := ImportBuffer.Status::"On Hold";

        // Vérif date compta
        IF ImportBuffer."YOOZ Posting Date" = 0D THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("YOOZ Posting Date")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("YOOZ Posting Date"),
              FORMAT(ImportBuffer."YOOZ Posting Date"));
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END;

        // Verif Document No
        IF ImportBuffer."Document No." = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Document No.")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Document No."),
              ImportBuffer."Document No.");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END;

        // Vérif import Document Date
        IF ImportBuffer."Import Document Date" = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Document Date")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Import Document Date"),
              ImportBuffer."Import Document Date");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END ELSE
            IF NOT EVALUATE(CalcDateF, ImportBuffer."Import Document Date") THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt001, ImportBuffer.FIELDCAPTION("Import Document Date")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Import Document Date"),
                  ImportBuffer."Import Document Date");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;

        //Verif Import Journal Template Name
        IF ImportBuffer."Import Journ. Template Name" = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Journ. Template Name")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Import Journ. Template Name"),
              ImportBuffer."Import Journ. Template Name");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END ELSE
            IF NOT GenJournalTemplate.GET(ImportBuffer."Import Journ. Template Name") THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt002, ImportBuffer.FIELDCAPTION("Import Journ. Template Name"), GenJournalTemplate.TABLECAPTION),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Import Journ. Template Name"),
                  ImportBuffer."Import Journ. Template Name");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;

        // import Document Type 
        IF ImportBuffer."Import Document Type" = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Document Type")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Import Document Type"),
              ImportBuffer."Import Document Type");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END ELSE
            IF (ImportBuffer."Import Document Type" <> 'FA') AND (ImportBuffer."Import Document Type" <> 'AV') THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt001, ImportBuffer.FIELDCAPTION("Import Document Type")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Import Document Type"),
                  ImportBuffer."Import Document Type");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;

        // Verif import account type
        IF ImportBuffer."Import Account Type" = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Import Journ. Template Name")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Import Journ. Template Name"),
              ImportBuffer."Import Journ. Template Name");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END;

        // G/L Account No.
        IF ImportBuffer."G/L Account No." = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("G/L Account No.")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("G/L Account No."),
              ImportBuffer."G/L Account No.");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END ELSE
            IF ImportBuffer."Account Type" = ImportBuffer."Account Type"::"G/L Account" THEN BEGIN
                IF NOT GLAcc.GET(ImportBuffer."G/L Account No.") THEN BEGIN
                    ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                      STRSUBSTNO(CstTxt002, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.TABLECAPTION),
                      ImportBuffer."Import File Name",
                      ImportBuffer.FIELDCAPTION("G/L Account No."),
                      ImportBuffer."G/L Account No.");
                    ImportBuffer.Status := ImportBuffer.Status::Error;
                END ELSE BEGIN
                    IF NOT GLAcc."Direct Posting" THEN BEGIN
                        ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                          STRSUBSTNO(CstTxt003, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.FIELDCAPTION("Direct Posting"), GLAcc."Direct Posting"),
                          ImportBuffer."Import File Name",
                          ImportBuffer.FIELDCAPTION("G/L Account No."),
                          ImportBuffer."G/L Account No.");
                        ImportBuffer.Status := ImportBuffer.Status::Error;
                    END;
                    IF GLAcc.Blocked THEN BEGIN
                        ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                          STRSUBSTNO(CstTxt003, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.FIELDCAPTION(Blocked), GLAcc.Blocked),
                          ImportBuffer."Import File Name",
                          ImportBuffer.FIELDCAPTION("G/L Account No."),
                          ImportBuffer."G/L Account No.");
                        ImportBuffer.Status := ImportBuffer.Status::Error;
                    END;
                END;
            END ELSE
                IF ImportBuffer."Account Type" = ImportBuffer."Account Type"::Vendor THEN
                    IF NOT Vendor.GET(ImportBuffer."G/L Account No.") THEN BEGIN
                        ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                        STRSUBSTNO(CstTxt002, ImportBuffer.FIELDCAPTION("G/L Account No."), Vendor.TABLECAPTION),
                        ImportBuffer."Import File Name",
                        ImportBuffer.FIELDCAPTION("G/L Account No."),
                        ImportBuffer."G/L Account No.");
                        ImportBuffer.Status := ImportBuffer.Status::Error;
                    END ELSE
                        IF (Vendor.Blocked = Vendor.Blocked::All) THEN BEGIN
                            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                              STRSUBSTNO(CstTxt003, ImportBuffer.FIELDCAPTION("G/L Account No."), GLAcc.FIELDCAPTION(Blocked), GLAcc.Blocked),
                              ImportBuffer."Import File Name",
                              ImportBuffer.FIELDCAPTION("G/L Account No."),
                              ImportBuffer."G/L Account No.");
                            ImportBuffer.Status := ImportBuffer.Status::Error;
                        END;

        // Verif Description
        IF ImportBuffer.Description = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION(Description)),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION(Description),
              ImportBuffer.Description);
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END;

        // Verif YOOZ No
        IF ImportBuffer."YOOZ No." = '' THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("YOOZ No.")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("YOOZ No."),
              ImportBuffer."YOOZ No.");
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END;

        //doc type
        IF ImportBuffer."Document Type" = ImportBuffer."Document Type"::" " THEN BEGIN
            ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
              STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Document Type")),
              ImportBuffer."Import File Name",
              ImportBuffer.FIELDCAPTION("Document Type"),
              FORMAT(ImportBuffer."Document Type"));
            ImportBuffer.Status := ImportBuffer.Status::Error;
        END ELSE
            IF (ImportBuffer."Document Type" <> ImportBuffer."Document Type"::Invoice) AND (ImportBuffer."Document Type" <> ImportBuffer."Document Type"::"Credit Memo") THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt001, ImportBuffer.FIELDCAPTION("Document Type")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Document Type"),
                  FORMAT(ImportBuffer."Document Type"));
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;

        IF (ImportBuffer."Account Type" = ImportBuffer."Account Type"::"G/L Account") AND (COPYSTR(ImportBuffer."G/L Account No.", 1, 1) <> '4') THEN BEGIN
            // Verif Dimvalue1 mandatory
            IF ImportBuffer."Dimension Value 1" = '' THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 1")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 1"),
                  ImportBuffer."Dimension Value 1");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;

            // Verif Dimvalue2 mandatory
            IF ImportBuffer."Dimension Value 2" = '' THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 2")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 2"),
                  ImportBuffer."Dimension Value 2");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;

            // Verif Dimvalue3 mandatory
            IF ImportBuffer."Dimension Value 3" = '' THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 3")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 3"),
                  ImportBuffer."Dimension Value 3");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;

            // Verif Dimvalue4 mandatory
            IF ImportBuffer."Dimension Value 4" = '' THEN BEGIN
                ErrorLog.InsertLogEntry(ImportBuffer."Entry No.",
                  STRSUBSTNO(CstTxt000, ImportBuffer.FIELDCAPTION("Dimension Value 4")),
                  ImportBuffer."Import File Name",
                  ImportBuffer.FIELDCAPTION("Dimension Value 4"),
                  ImportBuffer."Dimension Value 4");
                ImportBuffer.Status := ImportBuffer.Status::Error;
            END;
        END;
        IF ImportBuffer.Status = ImportBuffer.Status::"On Hold" THEN
            ImportBuffer.Status := ImportBuffer.Status::Check;
        ImportBuffer.MODIFY();
    end;

    local procedure CheckTransaction()
    var
        ImportYOOZBuffer: Record "BC6_YOOZ import Buffer";
        ImportBufferTransaction: Record "BC6_YOOZ import Buffer";
        TotalRecNo: Integer;
        RecNo: Integer;
        ErrorLog: Record "BC6_YOOZ Error Log";
    begin
        ImportYOOZBuffer.RESET();
        ImportYOOZBuffer.SETRANGE("Import Type", ImportYOOZBuffer."Import Type"::YOOZ);
        ImportYOOZBuffer.SETFILTER(Status, '<>%1', ImportYOOZBuffer.Status::Post);
        IF ImportYOOZBuffer.ISEMPTY THEN
            EXIT;

        TotalRecNo := ImportYOOZBuffer.COUNT;

        ImportYOOZBuffer.FINDSET();
        REPEAT
            RecNo += 1;
            Window.UPDATE(2, ROUND(RecNo / TotalRecNo * 10000, 1));

            ImportBufferTransaction.SETRANGE("Import Type", ImportBufferTransaction."Import Type"::YOOZ);
            ImportBufferTransaction.SETRANGE("Import File Name", ImportYOOZBuffer."Import File Name");
            ImportBufferTransaction.SETRANGE("Document No.", ImportYOOZBuffer."Document No.");
            ImportBufferTransaction.CALCSUMS("Debit Amount", "Credit Amount");
            IF ((ImportBufferTransaction."Credit Amount" - ImportBufferTransaction."Debit Amount") <> 0) THEN BEGIN
                ErrorLog.InsertLogEntry(ImportYOOZBuffer."Entry No.",
                  CstTxt004,
                  ImportYOOZBuffer."Import File Name",
                  'Somme des Montants',
                  FORMAT(ImportBufferTransaction."Credit Amount" - ImportBufferTransaction."Debit Amount"));
                ImportBufferTransaction.MODIFYALL(Status, ImportBufferTransaction.Status::Error);
            END;

        UNTIL ImportYOOZBuffer.NEXT() = 0;

        Window.CLOSE();
    end;

    procedure CheckStatus()
    begin
        YOOZBuffer.SETRANGE("Import Type", YOOZBuffer."Import Type"::YOOZ);
        YOOZBuffer.SETRANGE(Status, YOOZBuffer.Status::"On Hold", YOOZBuffer.Status::Error);
        IF NOT YOOZBuffer.ISEMPTY THEN
            ERROR(CstTxt008);
    end;

    local procedure EvaluateDecimal(TxtDecimal: Text; VAR CalculatedDecimal: Decimal): Boolean
    begin
        IF NOT EVALUATE(CalculatedDecimal, TxtDecimal) THEN BEGIN
            IF STRPOS(TxtDecimal, '.') <> 0 THEN
                TxtDecimal := CONVERTSTR(TxtDecimal, '.', ',')
            ELSE
                IF STRPOS(TxtDecimal, ',') <> 0 THEN
                    TxtDecimal := CONVERTSTR(TxtDecimal, ',', '.');
            IF NOT EVALUATE(CalculatedDecimal, TxtDecimal) THEN
                EXIT(FALSE);
            EXIT(TRUE);
        END;
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

        RecGGenJournalLine.INSERT(TRUE);

        RecGGenJournalLine.VALIDATE("Posting Date", RecPImportBuffer."YOOZ Posting Date");
        RecGGenJournalLine.VALIDATE("Document Date", CToDate(RecPImportBuffer."Import Document Date", 'dd/MM/yyyy'));
        RecGGenJournalLine.VALIDATE("Document Type", RecPImportBuffer."Document Type");
        //RecGGenJournalLine.VALIDATE("Document No.",RecPImportBuffer."Document No.");
        RecGGenJournalLine.VALIDATE("External Document No.", RecPImportBuffer."Document No.");
        RecGGenJournalLine.VALIDATE("Account Type", RecPImportBuffer."Account Type");
        RecGGenJournalLine.VALIDATE("Account No.", RecPImportBuffer."G/L Account No.");
        RecGGenJournalLine.VALIDATE(Description, RecPImportBuffer.Description);
        IF RecPImportBuffer."Debit Amount" <> 0 THEN
            RecGGenJournalLine.VALIDATE("Debit Amount", RecPImportBuffer."Debit Amount");
        IF RecPImportBuffer."Credit Amount" <> 0 THEN
            RecGGenJournalLine.VALIDATE("Credit Amount", RecPImportBuffer."Credit Amount");

        RecGGenJournalLine.VALIDATE("Shortcut Dimension 1 Code", RecPImportBuffer."Dimension Value 1");
        RecGGenJournalLine.VALIDATE("Shortcut Dimension 2 Code", RecPImportBuffer."Dimension Value 2");
        RecGGenJournalLine.ValidateShortcutDimCode(3, RecPImportBuffer."Dimension Value 3");
        RecGGenJournalLine.ValidateShortcutDimCode(4, RecPImportBuffer."Dimension Value 4");

        IF RecPImportBuffer."VAT Identifier" <> '' THEN BEGIN
            VATPostingSetup.RESET();
            VATPostingSetup.SETRANGE("VAT Identifier", RecPImportBuffer."VAT Identifier");
            IF VATPostingSetup.FINDFIRST() THEN BEGIN
                RecGGenJournalLine.VALIDATE("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
                RecGGenJournalLine.VALIDATE("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            END;
        END;


        RecGGenJournalLine.MODIFY(TRUE);
    end;

    procedure UpdateAllStatus()
    begin
        YOOZBuffer.RESET();
        YOOZBuffer.SETRANGE("Import Type", YOOZBuffer."Import Type"::YOOZ);
        YOOZBuffer.SETRANGE(Status, YOOZBuffer.Status::Check);
        YOOZBuffer.MODIFYALL(Status, YOOZBuffer.Status::Post);
    end;

    procedure RemoveStatus(VAR P_YOOZBuffer: Record "BC6_YOOZ import Buffer")
    var
        YOOZBuffer: Record "BC6_YOOZ import Buffer";
        OldCustLedgEntry: Record "Cust. Ledger Entry";
    Begin
        IF NOT CONFIRM(CstTxt010, FALSE, P_YOOZBuffer."Import File Name") THEN
            ERROR(CstTxt011);

        YOOZBuffer.SETRANGE("Import File Name", P_YOOZBuffer."Import File Name");
        YOOZBuffer.SETRANGE("Import Type", P_YOOZBuffer."Import Type");
        IF YOOZBuffer.ISEMPTY THEN
            EXIT;

        YOOZBuffer.FINDSET();
        REPEAT
            OldCustLedgEntry.SETRANGE("Document No.", YOOZBuffer."Document No.");
            OldCustLedgEntry.SETRANGE("Document Type", YOOZBuffer."Document Type");
            IF NOT OldCustLedgEntry.ISEMPTY THEN
                ERROR(CstTxt012, YOOZBuffer."Document Type", YOOZBuffer."Document No.");
        UNTIL YOOZBuffer.NEXT() = 0;

        YOOZBuffer.MODIFYALL(Status, YOOZBuffer.Status::"On Hold");

        CheckAllData();
    End;

    procedure DeleteImportLine(P_YOOZBuffer: Record "BC6_YOOZ import Buffer")
    begin

        IF NOT CONFIRM(CstTxt013, FALSE, P_YOOZBuffer."Import File Name") THEN
            ERROR(CstTxt011);

        YOOZBuffer.SETRANGE("Import File Name", P_YOOZBuffer."Import File Name");
        YOOZBuffer.SETRANGE("Import Type", P_YOOZBuffer."Import Type");
        IF YOOZBuffer.ISEMPTY THEN
            EXIT;

        YOOZBuffer.DELETEALL(TRUE);
    end;

    procedure ExtractCSVData(DataText: Text; CSVFieldSeparator: Text[1]; VAR DataArray: ARRAY[50] OF Text)
    var
        Pos: Integer;
        Index: Integer;
        Separator: Text;
    begin
        CLEAR(DataArray);
        WHILE DataText <> '' DO BEGIN
            Index += 1;
            IF DataText[1] = '"' THEN
                Separator := STRSUBSTNO('"%1', CSVFieldSeparator)
            ELSE
                Separator := CSVFieldSeparator;

            Pos := STRPOS(DataText, Separator);
            IF Pos = 0 THEN BEGIN
                DataArray[Index] := COPYSTR(DataText, STRLEN(Separator));
                EXIT;
            END;
            DataArray[Index] := COPYSTR(DataText, STRLEN(Separator), Pos - STRLEN(Separator));
            DataText := COPYSTR(DataText, Pos + STRLEN(Separator));
        END;
    end;

    procedure InitYoozBuffer(VAR DataArray: ARRAY[50] OF Text; FileName: Text)
    var
        YOOZimportBuffer: Record "BC6_YOOZ import Buffer";
    begin
        YOOZimportBuffer.INIT();
        YOOZimportBuffer."Import File Name" := CopyStr(FileName, 1, MaxStrLen(YOOZimportBuffer."Import File Name"));
        YOOZimportBuffer."User ID" := CopyStr(USERID, 1, MaxStrLen(YOOZimportBuffer."User ID"));
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
        CASE DataArray[4] OF
            'FA':
                YOOZimportBuffer."Document Type" := YOOZimportBuffer."Document Type"::Invoice;
            'AV':
                YOOZimportBuffer."Document Type" := YOOZimportBuffer."Document Type"::"Credit Memo";
        END;

        CASE COPYSTR(DataArray[9], 1, 1) OF
            'G':
                YOOZimportBuffer."Account Type" := YOOZimportBuffer."Account Type"::"G/L Account";
            'F':
                YOOZimportBuffer."Account Type" := YOOZimportBuffer."Account Type"::Vendor;
        END;

        IF COPYSTR(DataArray[10], 1, 1) = '4' THEN
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
        IF YOOZimportBuffer.ISEMPTY THEN
            EXIT;

        YOOZimportBuffer.FINDSET();
        REPEAT
            YOOZimportBuffer.Description := CopyStr(YOOZimportBuffer.Description + '_' + YOOZimportBuffer."G/L Account No.", 1, MaxStrLen(YOOZimportBuffer.Description));
            YOOZimportBuffer.MODIFY();
            YOOZimportBuffer2.RESET();
            YOOZimportBuffer2.SETRANGE("Import Type", YOOZimportBuffer2."Import Type"::YOOZ);
            YOOZimportBuffer2.SETFILTER(Status, '<>%1', YOOZimportBuffer2.Status::Post);
            YOOZimportBuffer2.SETFILTER("Account Type", '<>%1', YOOZimportBuffer2."Account Type"::Vendor);
            YOOZimportBuffer2.SETRANGE("Document No.", YOOZimportBuffer."Document No.");
            IF YOOZimportBuffer2.FINDFIRST() THEN
                REPEAT
                    YOOZimportBuffer2.Description := YOOZimportBuffer.Description;
                    YOOZimportBuffer2.MODIFY();
                UNTIL YOOZimportBuffer2.NEXT() = 0;
        UNTIL YOOZimportBuffer.NEXT() = 0;
    end;

    procedure CToDate(Value: Text; FormatName: Text): Date
    var
        TypeHelper: Codeunit "Type Helper";
        DateVariant: Variant;
    begin
        IF Value = '' THEN EXIT(0D);
        DateVariant := 0D;
        TypeHelper.Evaluate(DateVariant, Value, FormatName, '');
        EXIT(DateVariant);
    end;

    procedure CToDecimal(Value: Text; CultureName: Text): Decimal
    var
        TypeHelper: Codeunit "Type Helper";
        DecimalVariant: Variant;
    begin
        IF Value = '' THEN EXIT(0);
        DecimalVariant := 0.0;
        TypeHelper.Evaluate(DecimalVariant, Value, '', CultureName);
        EXIT(DecimalVariant);
    end;

    procedure CToInteger(Value: Text): Integer
    var
        Int: Integer;
    begin
        IF Value = '' THEN EXIT(0);
        EVALUATE(Int, Value);
        EXIT(Int);
    end;

    procedure CToBoolean(Value: Text): Boolean
    var
        Bool: Boolean;
    begin
        IF Value = '' THEN EXIT(FALSE);
        EVALUATE(Bool, Value);
        EXIT(Bool);
    end;

    procedure FormatInteger(Value: Decimal; BlankZero: Boolean): Text
    var
        ValueText: Text;
    begin
        ValueText := FORMAT(Value, 0, '<Sign><Integer>');
        IF BlankZero AND (ValueText = '0') THEN
            EXIT('');
        EXIT(ValueText);
    end;

    var
        GS1Setup: Record "BC6_GS1 Setup";
        YOOZBuffer: Record "BC6_YOOZ import Buffer";
        GLSetup: Record "General Ledger Setup";
        RecGGenJournalLine: Record "Gen. Journal Line";
        RecGGenJnlTemplate: Record "Gen. Journal Template";
        RecGGenJnlBatch: Record "Gen. Journal Batch";
        IntGLineNo: Integer;
        Window: Dialog;
        GFileName: Text;
        CstTxt000: Label '%1 est obligatoire.';
        CstTxt001: Label '%1 n''est pas une donnée valide.';
        CstTxt002: Label '%1 n''existe pas dans %2.';
        CstTxt003: Label '%1 ne doit pas être %2 %3.';
        CstTxt004: Label 'La transaction n''est pas équilibré.';
        CstTxt005: Label 'Contrôle des données...\\';
        CstTxt006: Label 'Fichier à importer';
        CstTxt007: Label 'Analyse des montants...\\';
        CstTxt008: Label 'Il existe au moins une ligne en erreur.';
        CstTxt009: Label 'Le fichier %1  a déjà été importé.';
        CstTxt010: Label 'Voulez-vous vraiment rebasculer le fichier %1 dans la table tampon?';
        CstTxt011: Label 'La mise à jour a été interrompue pour respecter l''alerte.';
        CstTxt012: Label 'Le document %1 vente %2 a fait l''objet d''une validation.La mise à jour a été interrompue pour respecter l''alerte.';
        CstTxt013: Label 'Voulez-vous vraiment supprimer le fichier %1 dans la table d''import?';

}

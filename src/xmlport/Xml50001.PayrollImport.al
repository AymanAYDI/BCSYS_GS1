xmlport 50001 "BC6_Payroll Import"
{
    Caption = 'Payroll Import', Comment = 'FRA="Import paie"';
    Direction = Import;
    Format = FixedText;
    UseRequestPage = false;
    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            tableelement(Line; Integer)
            {
                AutoSave = false;
                LinkTableForceInsert = false;
                MaxOccurs = Unbounded;
                MinOccurs = Zero;
                XmlName = 'Line';
                textelement(sourcecode)
                {
                    XmlName = 'SourceCode';
                    Width = 2;
                }
                textelement(filler)
                {
                    MinOccurs = Zero;
                    XmlName = 'Filler';
                    Width = 1;
                }
                textelement(postingdate)
                {
                    XmlName = 'PostingDate';
                    Width = 6;
                }
                textelement(filler1)
                {
                    MinOccurs = Zero;
                    XmlName = 'Filler1';
                    Width = 2;
                }
                textelement(accountno)
                {
                    MinOccurs = Zero;
                    XmlName = 'AccountNo';
                    Width = 13;
                }
                textelement(accounttype)
                {
                    MinOccurs = Zero;
                    XmlName = 'AccountType';
                    Width = 1;
                }
                textelement(dimension)
                {
                    MinOccurs = Zero;
                    XmlName = 'Dimension';
                    Width = 2;
                }
                textelement(dimensionvalue)
                {
                    MinOccurs = Zero;
                    XmlName = 'DimensionValue';
                    Width = 11;
                }
                textelement(documentno)
                {
                    MinOccurs = Zero;
                    XmlName = 'DocumentNo';
                    Width = 13;
                }
                textelement(entrydescription)
                {
                    MinOccurs = Zero;
                    XmlName = 'EntryDescription';
                    Width = 25;
                }
                textelement(paymentmethod)
                {
                    MinOccurs = Zero;
                    XmlName = 'PaymentMethod';
                    Width = 1;
                }
                textelement(duedate)
                {
                    MinOccurs = Zero;
                    XmlName = 'DueDate';
                    Width = 6;
                }
                textelement(amountdirection)
                {
                    MinOccurs = Zero;
                    XmlName = 'AmountDirection';
                    Width = 1;
                }
                textelement(amount)
                {
                    MinOccurs = Zero;
                    XmlName = 'Amount';
                    Width = 20;
                }
                textelement(entrytype)
                {
                    MinOccurs = Zero;
                    XmlName = 'EntryType';
                    Width = 1;
                }
                textelement(filler2)
                {
                    MinOccurs = Zero;
                    XmlName = 'Filler2';
                    Width = 33;
                }
                textelement(currencycode)
                {
                    MinOccurs = Zero;
                    XmlName = 'CurrencyCode';
                    Width = 3;
                }

                trigger OnAfterInsertRecord()
                begin
                    //>>FE002.001
                    case UPPERCASE(AccountType) of
                        'X':
                            InsertGenJournalLine();
                        'A':

                            if Dimension = '01' then
                                InsertGenJournalLine()
                            else
                                ModifyGenJournalLine();
                    end;
                    //<<FE002.001
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort()
    begin
        if (RecGGenJournalLine.COUNT > 0) then begin
            if not CONFIRM(
              STRSUBSTNO(
                CstG004,
                  RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                  RecGGS1Setup."Payroll Journal Template Name",
                  RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                  RecGGS1Setup."Payroll Journal Batch Name"))
            then
                MESSAGE(CstG005)
            else
                PAGE.RUN(RecGGenJournalTemplate."Page ID", RecGGenJournalLine);

        end else
            MESSAGE(CstG006);
    end;

    trigger OnPreXmlPort()

    begin
        TxtGFilename := FileManagement.GetFileName(currXMLport.FILENAME);

        if not CONFIRM(STRSUBSTNO(CstG001, TxtGFilename)) then
            ERROR(CstG002);

        RecGGS1Setup.GET();
        RecGGS1Setup.TESTFIELD("Payroll Journal Template Name");
        RecGGS1Setup.TESTFIELD("Payroll Journal Batch Name");
        RecGGenJournalTemplate.GET(RecGGS1Setup."Payroll Journal Template Name");
        RecGGenJournalTemplate.TESTFIELD("Page ID");
        RecGGenJournalBatch.GET(RecGGS1Setup."Payroll Journal Template Name", RecGGS1Setup."Payroll Journal Batch Name");
        RecGGenJournalLine.SETRANGE("Journal Template Name", RecGGS1Setup."Payroll Journal Template Name");
        RecGGenJournalLine.SETRANGE("Journal Batch Name", RecGGS1Setup."Payroll Journal Batch Name");
        if not RecGGenJournalLine.ISEMPTY then begin
            if not CONFIRM(STRSUBSTNO(
                CstG007,
                RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                RecGGS1Setup."Payroll Journal Template Name",
                RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                RecGGS1Setup."Payroll Journal Batch Name")) then
                ERROR('');
            RecGGenJournalLine.DELETEALL();
        end;

        RecGGeneralLedgerSetup.GET();
        RecGGeneralLedgerSetup.TESTFIELD("LCY Code");
        COMMIT();
        CLEAR(IntGLineNo);
    end;

    var
        RecGGS1Setup: Record "BC6_GS1 Setup";
        RecGGenJournalBatch: Record "Gen. Journal Batch";
        RecGGenJournalLine: Record "Gen. Journal Line";
        RecGGenJournalTemplate: Record "Gen. Journal Template";
        RecGGeneralLedgerSetup: Record "General Ledger Setup";
        FileManagement: codeunit "File Management";
        DatGPostingDate: Date;
        DecGAmount: Decimal;
        IntGLineNo: Integer;
        CstG001: label 'Import file %1 ?', Comment = 'FRA="Importer le fichier %1 ?"';
        CstG002: label 'Operation canceled.', Comment = 'FRA="Opération annulée."';
        CstG004: label 'Open %1 %2 %3 %4 ?', Comment = 'FRA="Ouvrir %1 %2 %3 %4 ?"';
        CstG005: label 'Operation completed.', Comment = 'FRA="Opération terminée."';
        CstG006: label 'No lines have been integrated.', Comment = 'FRA="Aucune ligne n''a été intégrée."';
        CstG007: label '%1 %2 %3 %4 contains unposted lines.', Comment = 'FRA="%1 %2 %3 %4 contient des lignes non validées.Voulez-vous les supprimer ?"';
        TxtGFilename: Text;

    local procedure InsertGenJournalLine()
    var
        RecLSourceCode: Record "Source Code";
    begin
        IntGLineNo := IntGLineNo + 10000;

        RecGGenJournalLine.INIT();
        RecGGenJournalLine.VALIDATE("Journal Template Name", RecGGS1Setup."Payroll Journal Template Name");
        RecGGenJournalLine.VALIDATE("Journal Batch Name", RecGGS1Setup."Payroll Journal Batch Name");
        RecGGenJournalLine.VALIDATE("Line No.", IntGLineNo);
        RecGGenJournalLine.INSERT(true);
        if not RecLSourceCode.GET(SourceCode) then
            currXMLport.SKIP();
        RecGGenJournalLine.VALIDATE("Source Code", SourceCode);
        if not EVALUATE(DatGPostingDate, PostingDate) then
            currXMLport.SKIP();
        RecGGenJournalLine.VALIDATE("Posting Date", DatGPostingDate);
        RecGGenJournalLine.VALIDATE("Document No.", DocumentNo);
        RecGGenJournalLine.VALIDATE("Account Type", RecGGenJournalLine."Account Type"::"G/L Account");
        RecGGenJournalLine.VALIDATE("Account No.", AccountNo);
        EVALUATE(DecGAmount, Amount);
        case UPPERCASE(AmountDirection) of
            'C':
                RecGGenJournalLine.VALIDATE("Credit Amount", DecGAmount);
            'D':
                RecGGenJournalLine.VALIDATE("Debit Amount", DecGAmount);
        end;

        RecGGenJournalLine.VALIDATE(Description, EntryDescription);
        if (CurrencyCode <> '') and (UPPERCASE(CurrencyCode) <> RecGGeneralLedgerSetup."LCY Code") then
            RecGGenJournalLine.VALIDATE("Currency Code", CurrencyCode);
        RecGGenJournalLine.VALIDATE(Description, (COPYSTR(EntryDescription, 1, 50)));
        RecGGenJournalLine.MODIFY(true);
        if AccountType = 'A' then
            ModifyGenJournalLine();
    end;

    local procedure ModifyGenJournalLine()
    var
        DimMgt: codeunit DimensionManagement;
        CodLDimValue: Code[20];
        IntLDimNo: Integer;
    begin
        IntLDimNo := 0;
        CodLDimValue := '';

        case UPPERCASE(Dimension) of
            '01':
                begin
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 1 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 1 Code", DimensionValue);
                end;
            '02':
                begin
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 2 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 2 Code", DimensionValue);
                end;
            '03':
                begin
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 3 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 3 Code", DimensionValue);
                end;
            '04':
                begin
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 4 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 4 Code", DimensionValue);
                end;
        end;

        if (IntLDimNo <> 0) and (CodLDimValue <> '') then begin
            DimMgt.ValidateShortcutDimValues(IntLDimNo, CodLDimValue, RecGGenJournalLine."Dimension Set ID");
            DimMgt.UpdateGenJnlLineDim(RecGGenJournalLine, RecGGenJournalLine."Dimension Set ID");
            RecGGenJournalLine.MODIFY(true);
        end;
    end;

    local procedure GetGLDimensionNo(CodPDim: Code[20]): Integer
    var
        RecLDimValue: Record "Dimension Value";
    begin
        RecLDimValue.SETRANGE("Dimension Code", CodPDim);
        if RecLDimValue.FINDFIRST() then
            exit(RecLDimValue."Global Dimension No.");
        exit(0);
    end;

    local procedure GetDimValueCorresp(CodPDim: Code[20]; CodPDimValue: Code[20]): Code[20]
    var
        RecLCorresp: Record "BC6_File Import Dim. Corresp.";
        RecLDimValue: Record "Dimension Value";
    begin
        RecLCorresp.RESET();
        RecLCorresp.SETRANGE("Import Type", RecLCorresp."Import Type"::Payroll);
        RecLCorresp.SETRANGE("Dimension Code", CodPDim);
        RecLCorresp.SETRANGE("File Value Code", CodPDimValue);
        if RecLCorresp.FINDFIRST() then
            if RecLDimValue.GET(CodPDim, RecLCorresp."NAV Value Code") then
                exit(RecLCorresp."NAV Value Code");

        if RecLDimValue.GET(CodPDim, CodPDimValue) then
            exit(CodPDimValue);

        exit('');
    end;
}

xmlport 50000 "BC6_Expense Import"
{
    Caption = 'Expense Import', Comment = 'FRA="Import note de frais"';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    UseRequestPage = true;
    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            tableelement(Integer; Integer)
            {
                AutoSave = false;
                LinkTableForceInsert = false;
                MaxOccurs = Unbounded;
                MinOccurs = Zero;
                XmlName = 'Line';
                textelement(sourcecode)
                {
                    XmlName = 'SourceCode';
                }
                textelement(accountno)
                {
                    XmlName = 'AccountNo';
                }
                textelement(amountdirection)
                {
                    XmlName = 'AmountDirection';
                }
                textelement(amount)
                {
                    XmlName = 'Amount';
                }
                textelement(postingdescription)
                {
                    XmlName = 'PostingDescription';
                }
                textelement(externaldocumentno)
                {
                    XmlName = 'ExternalDocumentNo';
                }
                textelement(filler1)
                {
                    XmlName = 'Filler1';
                }
                textelement(filler2)
                {
                    XmlName = 'Filler2';
                }
                textelement(dimension)
                {
                    XmlName = 'Dimension';
                }
                textelement(dimensionvalue)
                {
                    XmlName = 'DimensionValue';
                }
                textelement(filler3)
                {
                    XmlName = 'Filler3';
                }
                textelement(postingdate)
                {
                    XmlName = 'PostingDate';
                }
                textelement(postingtype)
                {
                    XmlName = 'PostingType';
                }

                trigger OnAfterInsertRecord()
                begin
                    case UPPERCASE(PostingType) of
                        'G':
                            InsertGenJournalLine();
                        'A':
                            ModifyGenJournalLine();
                    end;
                end;
            }
        }
    }

    trigger OnPostXmlPort()
    begin
        if (RecGGenJournalLine.COUNT > 0) then begin
            if not CONFIRM(
              STRSUBSTNO(
                CstG004,
                  RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                  RecGGS1Setup."Expense Journal Template Name",
                  RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                  RecGGS1Setup."Expense Journal Batch Name"))
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

        RecGGLSetup.GET();

        RecGGS1Setup.GET();
        RecGGS1Setup.TESTFIELD("Expense Journal Template Name");
        RecGGS1Setup.TESTFIELD("Expense Journal Batch Name");
        RecGGS1Setup.TESTFIELD("Expense Shortcut Dim. 1 Code");
        RecGGS1Setup.TESTFIELD("Expense Shortcut Dim. 2 Code");

        RecGGenJournalTemplate.GET(RecGGS1Setup."Expense Journal Template Name");
        RecGGenJournalTemplate.TESTFIELD("Page ID");
        RecGGenJournalBatch.GET(RecGGS1Setup."Expense Journal Template Name", RecGGS1Setup."Expense Journal Batch Name");
        RecGGenJournalBatch.TESTFIELD("No. Series");
        RecGGenJournalLine.SETRANGE("Journal Template Name", RecGGS1Setup."Expense Journal Template Name");
        RecGGenJournalLine.SETRANGE("Journal Batch Name", RecGGS1Setup."Expense Journal Batch Name");
        if not RecGGenJournalLine.ISEMPTY then begin
            if not CONFIRM(STRSUBSTNO(
                CstG007,
                RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                RecGGS1Setup."Expense Journal Template Name",
                RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                RecGGS1Setup."Expense Journal Batch Name")) then
                ERROR('');
            RecGGenJournalLine.DELETEALL();
        end;

        COMMIT();
        CodGDocumentNo := CduGNoSeriesManagement.TryGetNextNo(RecGGenJournalBatch."No. Series", WORKDATE());
        CLEAR(IntGLineNo);
    end;

    var
        RecGGS1Setup: Record "BC6_GS1 Setup";
        RecGGenJournalBatch: Record "Gen. Journal Batch";
        RecGGenJournalLine: Record "Gen. Journal Line";
        RecGGenJournalTemplate: Record "Gen. Journal Template";
        RecGGLSetup: Record "General Ledger Setup";
        FileManagement: codeunit "File Management";
        CduGNoSeriesManagement: codeunit NoSeriesManagement;
        TxtGFilename: Text;
        CodGDocumentNo: Code[20];
        DatGPostingDate: Date;
        DecGAmount: Decimal;
        IntGLineNo: Integer;
        CstG001: label 'Import file %1 ?', Comment = 'FRA="Importer le fichier %1 ?"';
        CstG002: label 'Operation canceled.', Comment = 'FRA="Opération annulée."';
        CstG004: label 'Open %1 %2 %3 %4 ?', Comment = 'FRA="Ouvrir %1 %2 %3 %4 ?"';
        CstG005: label 'Operation completed.', Comment = 'FRA="Opération terminée."';
        CstG006: label 'No lines have been integrated.', Comment = 'FRA="Aucune ligne n''a été intégrée."';
        CstG007: label '%1 %2 %3 %4 contains unposted lines.', Comment = 'FRA="%1 %2 %3 %4 contient des lignes non validées. Voulez-vous les supprimer ?"';

    local procedure InsertGenJournalLine()
    var
        RecLBankAccount: Record "Bank Account";
        RecLGLAccount: Record "G/L Account";
        RecLSourceCode: Record "Source Code";
    begin
        IntGLineNo := IntGLineNo + 10000;

        RecGGenJournalLine.INIT();
        RecGGenJournalLine.VALIDATE("Journal Template Name", RecGGS1Setup."Expense Journal Template Name");
        RecGGenJournalLine.VALIDATE("Journal Batch Name", RecGGS1Setup."Expense Journal Batch Name");
        RecGGenJournalLine.VALIDATE("Line No.", IntGLineNo);
        RecGGenJournalLine.INSERT(true);

        RecLSourceCode.GET(SourceCode);
        RecGGenJournalLine.VALIDATE("Source Code", SourceCode);

        EVALUATE(DatGPostingDate, PostingDate);
        RecGGenJournalLine.VALIDATE("Posting Date", DatGPostingDate);

        RecGGenJournalLine.VALIDATE("Document No.", CodGDocumentNo);

        if COPYSTR(AccountNo, 1, 2) = '51' then begin
            RecLBankAccount.GET(AccountNo);
            RecGGenJournalLine.VALIDATE("Account Type", RecGGenJournalLine."Account Type"::"Bank Account");
        end else begin
            RecLGLAccount.GET(AccountNo);
            RecGGenJournalLine.VALIDATE("Account Type", RecGGenJournalLine."Account Type"::"G/L Account");
        end;
        RecGGenJournalLine.VALIDATE("Account No.", AccountNo);

        EVALUATE(DecGAmount, Amount);
        case UPPERCASE(AmountDirection) of
            'C':
                RecGGenJournalLine.VALIDATE("Credit Amount", DecGAmount);
            'D':
                RecGGenJournalLine.VALIDATE("Debit Amount", DecGAmount);
        end;

        RecGGenJournalLine.VALIDATE(Description, COPYSTR(PostingDescription, 1, 50));
        RecGGenJournalLine.VALIDATE("External Document No.", COPYSTR(ExternalDocumentNo, 1, 35));
        RecGGenJournalLine.MODIFY(true);
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
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 1 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 1 Code", DimensionValue);
                end;
            '02':
                begin
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 2 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 2 Code", DimensionValue);
                end;
            '03':
                begin
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 3 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 3 Code", DimensionValue);
                end;
            '04':
                begin
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 4 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 4 Code", DimensionValue);
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
        RecLDimValue: Record "Dimension Value";
        RecLCorresp: Record "BC6_File Import Dim. Corresp.";
    begin
        RecLCorresp.RESET();
        RecLCorresp.SETRANGE("Import Type", RecLCorresp."Import Type"::Expense);
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

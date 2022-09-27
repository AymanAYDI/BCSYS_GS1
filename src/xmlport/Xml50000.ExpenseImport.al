xmlport 50000 "BC6_Expense Import"
{
    // +----------------------------------------------------------------------------------------------------------------+
    // | ProdWare - GS1                                                                                                 |
    // | http://www.prodware.fr                                                                                         |
    // |                                                                                                                |
    // +----------------------------------------------------------------------------------------------------------------+
    // 
    //       - FED-01: Import NDF
    // 
    // +----------------------------------------------------------------------------------------------------------------+

    Caption = 'Expense Import';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;

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
                    //>>FE001.001
                    CASE UPPERCASE(PostingType) OF
                        'G':
                            InsertGenJournalLine();
                        'A':
                            ModifyGenJournalLine();
                    END;
                    //<<FE001.001
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
        //>>FE001.001
        IF (RecGGenJournalLine.COUNT > 0) THEN BEGIN
            IF NOT CONFIRM(
              STRSUBSTNO(
                CstG004,
                  RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                  RecGGS1Setup."Expense Journal Template Name",
                  RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                  RecGGS1Setup."Expense Journal Batch Name"))
            THEN
                MESSAGE(CstG005)
            ELSE
                PAGE.RUN(RecGGenJournalTemplate."Page ID", RecGGenJournalLine);
        END ELSE
            MESSAGE(CstG006);
        //<<FE001.001
    end;

    trigger OnPreXmlPort()
    begin
        //>>FE001.001
        // TxtGFilename := DotGPath.GetFileName(currXMLport.FILENAME);

        IF NOT CONFIRM(STRSUBSTNO(CstG001, TxtGFilename)) THEN
            ERROR(CstG002);

        RecGGLSetup.GET();

        RecGGS1Setup.GET();
        RecGGS1Setup.TESTFIELD("Expense Journal Template Name");
        RecGGS1Setup.TESTFIELD("Expense Journal Batch Name");
        RecGGS1Setup.TESTFIELD("Expense Shortcut Dim. 1 Code");
        RecGGS1Setup.TESTFIELD("Expense Shortcut Dim. 2 Code");

        RecGGenJournalTemplate.GET(RecGGS1Setup."Expense Journal Template Name");
        RecGGenJournalTemplate.TESTFIELD("Page ID");
        //RecGGenJournalTemplate.TESTFIELD("Source Code");

        RecGGenJournalBatch.GET(RecGGS1Setup."Expense Journal Template Name", RecGGS1Setup."Expense Journal Batch Name");
        RecGGenJournalBatch.TESTFIELD("No. Series");
        //RecGGenJournalBatch.TESTFIELD("Posting No. Series");

        RecGGenJournalLine.SETRANGE("Journal Template Name", RecGGS1Setup."Expense Journal Template Name");
        RecGGenJournalLine.SETRANGE("Journal Batch Name", RecGGS1Setup."Expense Journal Batch Name");
        IF NOT RecGGenJournalLine.ISEMPTY THEN BEGIN
            IF NOT CONFIRM(STRSUBSTNO(
                CstG007,
                RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                RecGGS1Setup."Expense Journal Template Name",
                RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                RecGGS1Setup."Expense Journal Batch Name")) THEN
                ERROR('');
            RecGGenJournalLine.DELETEALL();
        END;

        COMMIT();
        CodGDocumentNo := CduGNoSeriesManagement.TryGetNextNo(RecGGenJournalBatch."No. Series", WORKDATE());
        CLEAR(IntGLineNo);
        //<<FE001.001
    end;

    var
        RecGGS1Setup: Record "BC6_GS1 Setup";
        RecGGenJournalTemplate: Record "Gen. Journal Template";
        RecGGenJournalBatch: Record "Gen. Journal Batch";
        RecGGenJournalLine: Record "Gen. Journal Line";
        RecGGLSetup: Record "General Ledger Setup";
        CduGNoSeriesManagement: Codeunit NoSeriesManagement;
        TxtGFilename: Text;
        // DotGPath: DotNet Path;
        CstG001: Label 'Import file %1 ?';
        CstG002: Label 'Operation canceled.';
        //CstG003: Label '%1 %2 %3 %4 contains unposted lines.';
        CodGDocumentNo: Code[20];
        IntGLineNo: Integer;
        DatGPostingDate: Date;
        DecGAmount: Decimal;
        CstG004: Label 'Open %1 %2 %3 %4 ?';
        CstG005: Label 'Operation completed.';
        CstG006: Label 'No lines have been integrated.';
        CstG007: Label '%1 %2 %3 %4 contient des lignes non validées. Voulez-vous les supprimer ?';

    local procedure InsertGenJournalLine()
    var
        RecLSourceCode: Record "Source Code";
        RecLGLAccount: Record "G/L Account";
        RecLBankAccount: Record "Bank Account";
    begin
        //>>FE001.001
        IntGLineNo := IntGLineNo + 10000;

        RecGGenJournalLine.INIT();
        RecGGenJournalLine.VALIDATE("Journal Template Name", RecGGS1Setup."Expense Journal Template Name");
        RecGGenJournalLine.VALIDATE("Journal Batch Name", RecGGS1Setup."Expense Journal Batch Name");
        RecGGenJournalLine.VALIDATE("Line No.", IntGLineNo);
        RecGGenJournalLine.INSERT(TRUE);

        RecLSourceCode.GET(SourceCode);
        RecGGenJournalLine.VALIDATE("Source Code", SourceCode);

        EVALUATE(DatGPostingDate, PostingDate);
        RecGGenJournalLine.VALIDATE("Posting Date", DatGPostingDate);

        RecGGenJournalLine.VALIDATE("Document No.", CodGDocumentNo);

        IF COPYSTR(AccountNo, 1, 2) = '51' THEN BEGIN
            RecLBankAccount.GET(AccountNo);
            RecGGenJournalLine.VALIDATE("Account Type", RecGGenJournalLine."Account Type"::"Bank Account");
        END ELSE BEGIN
            RecLGLAccount.GET(AccountNo);
            RecGGenJournalLine.VALIDATE("Account Type", RecGGenJournalLine."Account Type"::"G/L Account");
        END;
        RecGGenJournalLine.VALIDATE("Account No.", AccountNo);

        EVALUATE(DecGAmount, Amount);
        CASE UPPERCASE(AmountDirection) OF
            'C':
                RecGGenJournalLine.VALIDATE("Credit Amount", DecGAmount);
            'D':
                RecGGenJournalLine.VALIDATE("Debit Amount", DecGAmount);
        END;

        RecGGenJournalLine.VALIDATE(Description, COPYSTR(PostingDescription, 1, 50));
        RecGGenJournalLine.VALIDATE("External Document No.", COPYSTR(ExternalDocumentNo, 1, 35));
        RecGGenJournalLine.MODIFY(TRUE);
        //<<FE001.001
    end;

    local procedure ModifyGenJournalLine()
    var
        DimMgt: Codeunit DimensionManagement;
        IntLDimNo: Integer;
        CodLDimValue: Code[20];
    begin
        //>>FE001.001
        IntLDimNo := 0;
        CodLDimValue := '';

        CASE UPPERCASE(Dimension) OF
            '01':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 1 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 1 Code", DimensionValue);
                END;
            '02':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 2 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 2 Code", DimensionValue);
                END;
            '03':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 3 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 3 Code", DimensionValue);
                END;
            '04':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Expense Shortcut Dim. 4 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Expense Shortcut Dim. 4 Code", DimensionValue);
                END;
        //RecGGS1Setup."Expense Shortcut Dim. 1 Code" : RecGGenJournalLine.VALIDATE("Shortcut Dimension 1 Code",DimensionValue);
        //RecGGS1Setup."Expense Shortcut Dim. 2 Code" : RecGGenJournalLine.VALIDATE("Shortcut Dimension 2 Code",DimensionValue);
        END;

        IF (IntLDimNo <> 0) AND (CodLDimValue <> '') THEN BEGIN
            DimMgt.ValidateShortcutDimValues(IntLDimNo, CodLDimValue, RecGGenJournalLine."Dimension Set ID");
            DimMgt.UpdateGenJnlLineDim(RecGGenJournalLine, RecGGenJournalLine."Dimension Set ID");
            RecGGenJournalLine.MODIFY(TRUE);
        END;
        //<<FE001.001
    end;

    local procedure GetGLDimensionNo(CodPDim: Code[20]): Integer
    var
        RecLDimValue: Record "Dimension Value";
    begin
        RecLDimValue.SETRANGE("Dimension Code", CodPDim);
        IF RecLDimValue.FINDFIRST() THEN
            EXIT(RecLDimValue."Global Dimension No.");
        EXIT(0);
    end;

    local procedure GetDimValueCorresp(CodPDim: Code[20]; CodPDimValue: Code[20]): Code[20]
    var
        RecLCorresp: Record "File Import Dimension Corresp.";
        RecLDimValue: Record "Dimension Value";
    begin
        RecLCorresp.RESET();
        RecLCorresp.SETRANGE("Import Type", RecLCorresp."Import Type"::Expense);
        RecLCorresp.SETRANGE("Dimension Code", CodPDim);
        RecLCorresp.SETRANGE("File Value Code", CodPDimValue);
        IF RecLCorresp.FINDFIRST() THEN
            IF RecLDimValue.GET(CodPDim, RecLCorresp."NAV Value Code") THEN
                EXIT(RecLCorresp."NAV Value Code");

        IF RecLDimValue.GET(CodPDim, CodPDimValue) THEN
            EXIT(CodPDimValue);

        EXIT('');
    end;
}


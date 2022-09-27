xmlport 50001 "BC6_Payroll Import"
{
    // +----------------------------------------------------------------------------------------------------------------+
    // | ProdWare - GS1                                                                                                 |
    // | http://www.prodware.fr                                                                                         |
    // |                                                                                                                |
    // +----------------------------------------------------------------------------------------------------------------+
    // 
    //       - FED-02: Import de la paie
    // 
    // +----------------------------------------------------------------------------------------------------------------+

    Caption = 'Payroll Import';
    Direction = Import;
    //FieldDelimiter =;
    // FieldSeparator = '<TAB>';
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
                    CASE UPPERCASE(AccountType) OF
                        'X':
                            InsertGenJournalLine();
                        'A':

                            IF Dimension = '01' THEN
                                InsertGenJournalLine()
                            ELSE
                                ModifyGenJournalLine();

                    END;
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

    trigger OnInitXmlPort()
    begin
        //Format du fichier
        //-----------------------------------------------------------------------------------------------------------------------------
        //|  POSILINE   |   LENGTH   |                              Description                                                       |
        //|      1      |      3     |  Code journal Source code                                                                      |
        //|      4      |      6     |  Date de pièce (JJMMAA) Posting Date                                                           |
        //|     10      |      2     |  Nature de pièce : OD non utilisé                                                              |
        //|     12      |     13     |  Code compte général Account No.                                                               |
        //|     25      |      1     |  Type compte complémentaire*** (X : auxiliaire, A : Analytique, blanc : aucun)                 |
        //|     26      |     13     |  Code compte auxiliaire ou analytique Comportement de la zone                                  |
        //|     39      |     13     |  Référence Cncaténatioon des 2 champs dans le champ Description                                |
        //|     52      |     25     |  Libellé                                                                                       |
        //|     77      |      1     |  Mode de paiement (C : chèque, O : espèces, T : traite, S : sans paiement)                     |
        //|     78      |      6     |  Date d'échéance Due Date                                                                      |
        //|     84      |      1     |  Débit (D) ou Crédit (C) permet de savoir si le montant est inséré au crédit ou au débit       |
        //|     85      |     20     |  Montant                                                                                       |
        //|    105      |      1     |  Type d'écriture (N : Normal, S : Simulation)                                                  |
        //|    106      |     33     |  Zone réservée non utilisé                                                                     |
        //|    139      |      3     |  Code ISO de la monnaie de tenue de Paie. Currency Code                                        |
        //-----------------------------------------------------------------------------------------------------------------------------
    end;

    trigger OnPostXmlPort()
    begin
        //>>FE002.001
        IF (RecGGenJournalLine.COUNT > 0) THEN BEGIN
            IF NOT CONFIRM(
              STRSUBSTNO(
                CstG004,
                  RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                  RecGGS1Setup."Payroll Journal Template Name",
                  RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                  RecGGS1Setup."Payroll Journal Batch Name"))
            THEN
                MESSAGE(CstG005)
            ELSE
                PAGE.RUN(RecGGenJournalTemplate."Page ID", RecGGenJournalLine);

        END ELSE
            MESSAGE(CstG006);

        //<<FE002.001
    end;

    trigger OnPreXmlPort()
    begin
        //>>FE002.001
        // TxtGFilename := DotGPath.GetFileName(currXMLport.FILENAME);

        IF NOT CONFIRM(STRSUBSTNO(CstG001, TxtGFilename)) THEN
            ERROR(CstG002);


        RecGGS1Setup.GET();
        RecGGS1Setup.TESTFIELD("Payroll Journal Template Name");
        RecGGS1Setup.TESTFIELD("Payroll Journal Batch Name");

        RecGGenJournalTemplate.GET(RecGGS1Setup."Payroll Journal Template Name");
        RecGGenJournalTemplate.TESTFIELD("Page ID");
        //RecGGenJournalTemplate.TESTFIELD("Source Code");

        RecGGenJournalBatch.GET(RecGGS1Setup."Payroll Journal Template Name", RecGGS1Setup."Payroll Journal Batch Name");
        //RecGGenJournalBatch.TESTFIELD("No. Series");
        //RecGGenJournalBatch.TESTFIELD("Posting No. Series");

        RecGGenJournalLine.SETRANGE("Journal Template Name", RecGGS1Setup."Payroll Journal Template Name");
        RecGGenJournalLine.SETRANGE("Journal Batch Name", RecGGS1Setup."Payroll Journal Batch Name");
        IF NOT RecGGenJournalLine.ISEMPTY THEN BEGIN
            IF NOT CONFIRM(STRSUBSTNO(
                CstG007,
                RecGGenJournalLine.FIELDCAPTION("Journal Template Name"),
                RecGGS1Setup."Payroll Journal Template Name",
                RecGGenJournalLine.FIELDCAPTION("Journal Batch Name"),
                RecGGS1Setup."Payroll Journal Batch Name")) THEN
                ERROR('');
            RecGGenJournalLine.DELETEALL();
        END;

        RecGGeneralLedgerSetup.GET();
        RecGGeneralLedgerSetup.TESTFIELD("LCY Code");

        COMMIT();

        //CodGDocumentNo := CduGNoSeriesManagement.TryGetNextNo(RecGGenJournalBatch."No. Series",WORKDATE);
        CLEAR(IntGLineNo);
        //<<FE002.001
    end;

    var
        RecGGS1Setup: Record "BC6_GS1 Setup";
        RecGGenJournalBatch: Record "Gen. Journal Batch";
        RecGGenJournalLine: Record "Gen. Journal Line";
        RecGGenJournalTemplate: Record "Gen. Journal Template";
        RecGGeneralLedgerSetup: Record "General Ledger Setup";
        DatGPostingDate: Date;
        DecGAmount: Decimal;
        // DotGPath: DotNet Path;
        // CduGNoSeriesManagement: Codeunit "396";
        IntGLineNo: Integer;
        CstG001: Label 'Import file %1 ?';
        CstG002: Label 'Operation canceled.';
        CstG004: Label 'Open %1 %2 %3 %4 ?';
        CstG005: Label 'Operation completed.';
        CstG006: Label 'No lines have been integrated.';
        CstG007: Label '%1 %2 %3 %4 contains unposted lines.';
        TxtGFilename: Text;

    local procedure InsertGenJournalLine()
    var
        RecLSourceCode: Record "Source Code";
    // CduLAnsiAscii: Codeunit "8069133";
    begin
        //>>FE002.001
        IntGLineNo := IntGLineNo + 10000;

        RecGGenJournalLine.INIT();
        RecGGenJournalLine.VALIDATE("Journal Template Name", RecGGS1Setup."Payroll Journal Template Name");
        RecGGenJournalLine.VALIDATE("Journal Batch Name", RecGGS1Setup."Payroll Journal Batch Name");
        RecGGenJournalLine.VALIDATE("Line No.", IntGLineNo);
        RecGGenJournalLine.INSERT(TRUE);

        IF NOT RecLSourceCode.GET(SourceCode) THEN
            currXMLport.SKIP();

        RecGGenJournalLine.VALIDATE("Source Code", SourceCode);

        /*
        IF (STRLEN(TxtGColumn2) = 1) THEN BEGIN
          TxtGColumn2 := '0' + TxtGColumn2;
        END;
        
        IF (STRLEN(TxtGColumn3) = 1) THEN BEGIN
          TxtGColumn3 := '0' + TxtGColumn3;
        END;
        
        IF (STRLEN(TxtGColumn4) = 1) THEN BEGIN
          TxtGColumn4 := '0' + TxtGColumn4;
        END;
        */

        IF NOT EVALUATE(DatGPostingDate, PostingDate) THEN
            currXMLport.SKIP();
        RecGGenJournalLine.VALIDATE("Posting Date", DatGPostingDate);

        RecGGenJournalLine.VALIDATE("Document No.", DocumentNo);
        RecGGenJournalLine.VALIDATE("Account Type", RecGGenJournalLine."Account Type"::"G/L Account");
        RecGGenJournalLine.VALIDATE("Account No.", AccountNo);

        EVALUATE(DecGAmount, Amount);
        CASE UPPERCASE(AmountDirection) OF
            'C':
                RecGGenJournalLine.VALIDATE("Credit Amount", DecGAmount);
            'D':
                RecGGenJournalLine.VALIDATE("Debit Amount", DecGAmount);
        END;

        RecGGenJournalLine.VALIDATE(Description, EntryDescription);

        IF (CurrencyCode <> '') AND (UPPERCASE(CurrencyCode) <> RecGGeneralLedgerSetup."LCY Code") THEN
            RecGGenJournalLine.VALIDATE("Currency Code", CurrencyCode);


        // RecGGenJournalLine.VALIDATE(Description, CduLAnsiAscii.Ansi2Ascii(COPYSTR(EntryDescription, 1, 50)));
        //RecGGenJournalLine.VALIDATE("External Document No.",COPYSTR(ExternalDocumentNo,1,35));

        RecGGenJournalLine.MODIFY(TRUE);
        //<<FE002.001

        IF AccountType = 'A' THEN
            ModifyGenJournalLine();

    end;

    local procedure ModifyGenJournalLine()
    var
        DimMgt: Codeunit DimensionManagement;
        CodLDimValue: Code[20];
        IntLDimNo: Integer;
    begin
        IntLDimNo := 0;
        CodLDimValue := '';

        CASE UPPERCASE(Dimension) OF
            '01':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 1 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 1 Code", DimensionValue);
                END;
            '02':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 2 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 2 Code", DimensionValue);
                END;
            '03':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 3 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 3 Code", DimensionValue);
                END;
            '04':
                BEGIN
                    IntLDimNo := GetGLDimensionNo(RecGGS1Setup."Payroll Shortcut Dim. 4 Code");
                    CodLDimValue := GetDimValueCorresp(RecGGS1Setup."Payroll Shortcut Dim. 4 Code", DimensionValue);
                END;
        END;

        IF (IntLDimNo <> 0) AND (CodLDimValue <> '') THEN BEGIN
            DimMgt.ValidateShortcutDimValues(IntLDimNo, CodLDimValue, RecGGenJournalLine."Dimension Set ID");
            DimMgt.UpdateGenJnlLineDim(RecGGenJournalLine, RecGGenJournalLine."Dimension Set ID");
            RecGGenJournalLine.MODIFY(TRUE);
        END;
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
        RecLCorresp.SETRANGE("Import Type", RecLCorresp."Import Type"::Payroll);
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


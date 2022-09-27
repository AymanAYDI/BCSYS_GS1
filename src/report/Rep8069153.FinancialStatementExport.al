report 8069153 "BC6_Financial Statement Export"
{
    Caption = 'ECF Sage Export';
    ProcessingOnly = true;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.")
                                WHERE("Account Type" = FILTER(Posting));

            trigger OnAfterGetRecord()
            begin
                Win.UPDATE(1, "No.");
                Win.UPDATE(2, Name);

                DecGMntC := 0;
                DecGMntD := 0;

                IF BooGUseConvert THEN
                    TxtGTampon := COPYSTR(FORMAT("G/L Account"."No."), 1, 9) + ';' + PADSTR(COPYSTR("G/L Account".Name, 1, 31), 31, ' ')
                ELSE
                    TxtGTampon := COPYSTR(FORMAT("G/L Account"."No."), 1, 9) + ';' + PADSTR(COPYSTR("G/L Account".Name, 1, 31), 31, ' ');

                TxtGTampon := CduGConvert.Ascii2Ansi(TxtGTampon);

                "G/L Account".SETFILTER("G/L Account"."Date Filter", '..%1', DatGDateF);
                "G/L Account".CALCFIELDS("G/L Account"."Debit Amount", "G/L Account"."Credit Amount");
                TxtGTampon := TxtGTampon + ';' + DELCHR(FORMAT("G/L Account"."Debit Amount", 19, 1), '=') + ';' + DELCHR(FORMAT("G/L Account"."Credit Amount", 19, 1), '=');

                IF ("G/L Account"."Debit Amount" > "G/L Account"."Credit Amount") THEN BEGIN
                    DecGMntD := "G/L Account"."Debit Amount" - "G/L Account"."Credit Amount";
                    DecGMntC := 0;
                END ELSE BEGIN
                    DecGMntD := 0;
                    DecGMntC := "G/L Account"."Credit Amount" - "G/L Account"."Debit Amount";
                END;
                TxtGTampon := TxtGTampon + ';' +
                          DELCHR(FORMAT(DecGMntD, 19, 1), '=') + ';' +
                          DELCHR(FORMAT(DecGMntC, 19, 1), '=');

                TempBlob.CreateOutStream(OutStr, TextEncoding::Windows);
                OutStr.Write(TxtGTampon);
                TempBlob.CreateInStream(InStr)
            end;

            trigger OnPreDataItem()
            begin
                Win.OPEN(' ' + PADSTR(FIELDCAPTION("No."), 20) + '########1#,\' + ' ' + PADSTR(FIELDCAPTION(Name), 20) + '########################2#');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group("Option")
                {
                    field(DatGDateD_; DatGDateD)
                    {
                        Caption = 'Starting Date';
                        Visible = false;
                    }
                    field(DatGDateF_; DatGDateF)
                    {
                        Caption = 'Ending Date';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            DatGDateD := DMY2DATE(1, 1, DATE2DMY(WORKDATE(), 3));
            DatGDateF := DMY2DATE(31, 12, DATE2DMY(WORKDATE(), 3));
            TxtGFichier := 'C:\ETATFI.txt';
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        IF NOT CONFIRM(CstGLaunch) THEN
            ERROR(CstGCancelledOp);
    end;

    trigger OnPostReport()
    begin
        TxtGToFile := CstGDefault + '.txt';
        IF NOT DownloadFromStream(InStr, CstGExport, '', CstGXML, TxtGFileName) THEN
            EXIT;
        MESSAGE(CstGFileCreated);
    end;

    trigger OnPreReport()
    var
        CduLRBMgt: Codeunit "File Management";
    begin
        TxtGFileName := CduLRBMgt.GetFileName(TxtGFichier);
    end;

    var
        CduGConvert: Codeunit "BC6_Convert Ansi-Ascii Manag";
        TempBlob: Codeunit "Temp Blob";
        CstGCancelledOp: Label 'Cancelled Operation !';
        CstGLaunch: Label 'Do you want to launch the ECF Sage export ?';
        CstGExport: Label 'Export to Txt File';
        CstGXML: Label 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*';
        CstGFileCreated: Label 'Txt File created successfully.';
        CstGDefault: Label 'Default';
        BooGUseConvert: Boolean;
        DatGDateF: Date;
        DatGDateD: Date;
        DecGMntD: Decimal;
        DecGMntC: Decimal;
        Win: Dialog;
        TxtGFichier: Text[1024];
        TxtGTampon: Text[1024];
        TxtGFileName: Text;
        TxtGToFile: Text[1024];
        InStr: InStream;
        OutStr: OutStream;

}


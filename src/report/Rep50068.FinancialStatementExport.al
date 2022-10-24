report 50068 "BC6_Financial Statement Export"
{
    Caption = 'ECF Sage Export', Comment = 'FRA="Export vers ECF Sage"';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.")
                                where("Account Type" = filter(Posting));

            trigger OnAfterGetRecord()
            var
                TxtTampon: Text;
            begin
                Win.UPDATE(1, "No.");
                Win.UPDATE(2, Name);

                DecGMntC := 0;
                DecGMntD := 0;

                if BooGUseConvert then
                    TxtTampon := COPYSTR(FORMAT("G/L Account"."No."), 1, 9) + ';' + PADSTR(COPYSTR("G/L Account".Name, 1, 31), 31, ' ')
                else
                    TxtTampon := COPYSTR(FORMAT("G/L Account"."No."), 1, 9) + ';' + PADSTR(COPYSTR("G/L Account".Name, 1, 31), 31, ' ');
                "G/L Account".SETFILTER("G/L Account"."Date Filter", '..%1', DatGDateF);
                "G/L Account".CALCFIELDS("G/L Account"."Debit Amount", "G/L Account"."Credit Amount");
                TxtTampon := TxtTampon + ';' + DELCHR(FORMAT("G/L Account"."Debit Amount", 19, 1), '=') + ';' + DELCHR(FORMAT("G/L Account"."Credit Amount", 19, 1), '=');

                if ("G/L Account"."Debit Amount" > "G/L Account"."Credit Amount") then begin
                    DecGMntD := "G/L Account"."Debit Amount" - "G/L Account"."Credit Amount";
                    DecGMntC := 0;
                end else begin
                    DecGMntD := 0;
                    DecGMntC := "G/L Account"."Credit Amount" - "G/L Account"."Debit Amount";
                end;
                TxtTampon := TxtTampon + ';' +
                          DELCHR(FORMAT(DecGMntD, 19, 1), '=') + ';' +
                          DELCHR(FORMAT(DecGMntC, 19, 1), '=');

                TextFileBuilder.AppendLine(TxtTampon);
                OutStr.WriteText(TextFileBuilder.ToText());
                clear(TxtTampon);
                Clear(TextFileBuilder);
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
                        Caption = 'Starting Date', Comment = 'FRA="Date début"';
                        Visible = false;
                    }
                    field(DatGDateF_; DatGDateF)
                    {
                        Caption = 'Ending Date', Comment = 'FRA="Date fin"';
                    }
                }
            }
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
        if not CONFIRM(CstGLaunch) then
            ERROR(CstGCancelledOp);
    end;

    trigger OnPostReport()
    begin
        TxtGToFile := CstGDefault + '.txt';
        TempBlob.CreateInStream(InStr);
        if not DownloadFromStream(InStr, CstGExport, '', CstGXML, TxtGFileName) then
            exit;
        MESSAGE(CstGFileCreated);
    end;

    trigger OnPreReport()
    var
        CduLRBMgt: codeunit "File Management";
    begin
        TxtGFileName := CduLRBMgt.GetFileName(TxtGFichier);
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
    end;

    var
        TempBlob: codeunit "Temp Blob";
        BooGUseConvert: Boolean;
        DatGDateD: Date;
        DatGDateF: Date;
        DecGMntC: Decimal;
        DecGMntD: Decimal;
        Win: Dialog;
        InStr: InStream;
        CstGCancelledOp: label 'Cancelled Operation !', Comment = 'FRA="Opération annulée !"';
        CstGDefault: label 'Default', Comment = 'FRA="Par défaut"';
        CstGExport: label 'Export to Txt File', Comment = 'FRA="Exporter en fichier Txt"';
        CstGFileCreated: label 'Txt File created successfully.', Comment = 'FRA="Fichier Txt correctement créé."';
        CstGLaunch: label 'Do you want to launch the ECF Sage export ?', Comment = 'FRA="Voulez vous lancer l''export vers ECF Sage ?"';
        CstGXML: label 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*', Comment = 'FRA="Fichiers XML (*.xml)|*.xml|Tous les fichiers (*.*)|*.*"';
        OutStr: OutStream;
        TxtGFichier: Text;
        TxtGFileName: Text;
        TxtGToFile: Text;
        TextFileBuilder: TextBuilder;
}

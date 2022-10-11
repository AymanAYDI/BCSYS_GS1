report 50100 "BC6_Trans. YOOZ Gen. Jnl."
{
    Caption = 'Trans. YOOZ Gen. Jnl.', Comment = 'FRA="Trans. import YOOZ -> Feuille Compta"';
    ProcessingOnly = true;
    UsageCategory = None;
    dataset
    {
        dataitem("YOOZ import Buffer"; "BC6_YOOZ import Buffer")
        {
            DataItemTableView = where("Import Type" = const(YOOZ));

            trigger OnPreDataItem()
            begin
                GenJnlTemplate.GET(GenJnlLine."Journal Template Name");
                GenJnlBatch.GET(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                GenJnlLine.SETRANGE("Journal Template Name", GenJnlBatch."Journal Template Name");
                if GenJnlBatch.Name <> '' then
                    GenJnlLine.SETRANGE("Journal Batch Name", GenJnlBatch.Name)
                else
                    GenJnlLine.SETRANGE("Journal Batch Name", '');

                GenJnlLine.LOCKTABLE();
                if GenJnlLine.COUNT <> 0 then
                    if not CONFIRM(CstTxtG001, false, GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name") then
                        ERROR(CstTxtG002);

                if GenJnlLine.FINDLAST() then;

                Window.OPEN(CstTxtG003 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@');
                TotalRecNo := COUNT;

                YOOZManagement.InitGenLineData(GenJnlTemplate, GenJnlBatch, GenJnlLine."Line No.");

                "YOOZ import Buffer".SETRANGE(Status, "YOOZ import Buffer".Status::Check);
            end;

            trigger OnAfterGetRecord()
            begin
                RecNo += 1;
                Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

                // Create Line
                YOOZManagement.InitNewGLLine("YOOZ import Buffer");
            end;

            trigger OnPostDataItem()
            begin
                YOOZManagement.UpdateAllStatus();
                Window.CLOSE();

                GenJnlManagement.TemplateSelectionFromBatch(GenJnlBatch);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field("Journal Template Name"; GenJnlLine."Journal Template Name")
                    {
                        Caption = 'Gen. Journal Template', Comment = 'FRA="Modèle feuille comptabilité"';
                        TableRelation = "Gen. Journal Template" where(Name = const('NDF'));
                        NotBlank = true;
                        ApplicationArea = All;
                    }
                    field("Journal Batch Name"; GenJnlLine."Journal Batch Name")
                    {
                        Caption = 'Gen. Journal Batch', Comment = 'FRA="Nom feuille comptabilité"';
                        ApplicationArea = Basic, Suite;
                        NotBlank = true;
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        //YOOZManagement.CheckAllData;
        YOOZManagement.CheckStatus();
    end;

    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        YOOZManagement: codeunit "BC6_YOOZ Management";
        GenJnlManagement: codeunit GenJnlManagement;
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        CstTxtG001: label 'Journal %1 %2 has some line. Do you want to continue?', Comment = 'FRA="Il existe des lignes dans la feuille %1 %2. Voulez-vous continuer?"';
        CstTxtG002: label 'The update has been interrupted to respect the warning', Comment = 'FRA="La mise à jour a été interrompue pour respecter l''alerte."';
        CstTxtG003: label 'Processing Data...\\', Comment = 'FRA="Traitement des données...\\"';
}

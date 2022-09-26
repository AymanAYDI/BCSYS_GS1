report 50100 "BC6_Trans. YOOZ Gen. Jnl."
{
    Caption = 'Trans. YOOZ Gen. Jnl.', Comment = 'FRA="Trans. import YOOZ -> Feuille Compta"';
    ProcessingOnly = true;
    dataset
    {
        dataitem("YOOZ import Buffer"; "BC6_YOOZ import Buffer")
        {
            DataItemTableView = WHERE("Import Type" = CONST(YOOZ));

            trigger OnPreDataItem()
            begin
                GenJnlTemplate.GET(GenJnlLine."Journal Template Name");
                GenJnlBatch.GET(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                GenJnlLine.SETRANGE("Journal Template Name", GenJnlBatch."Journal Template Name");
                IF GenJnlBatch.Name <> '' THEN
                    GenJnlLine.SETRANGE("Journal Batch Name", GenJnlBatch.Name)
                ELSE
                    GenJnlLine.SETRANGE("Journal Batch Name", '');

                GenJnlLine.LOCKTABLE();
                IF GenJnlLine.COUNT <> 0 THEN
                    IF NOT CONFIRM(CstTxtG001, FALSE, GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name") THEN
                        ERROR(CstTxtG002);

                IF GenJnlLine.FINDLAST() THEN;

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
                        TableRelation = "Gen. Journal Template" WHERE(Name = CONST('NDF'));
                    }
                    field("Journal Batch Name"; GenJnlLine."Journal Batch Name")
                    {
                        ApplicationArea = Basic, Suite;
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
        YOOZManagement: Codeunit "BC6_YOOZ Management";
        GenJnlManagement: Codeunit GenJnlManagement;
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        CstTxtG001: Label 'Journal %1 %2 has some line. Do you want to continue?', Comment = 'FRA="Il existe des lignes dans la feuille %1 %2. Voulez-vous continuer?"';
        CstTxtG002: Label 'The update has been interrupted to respect the warning', Comment = 'FRA="La mise à jour a été interrompue pour respecter l''alerte."';
        CstTxtG003: Label 'Processing Data...\\', Comment = 'FRA="Traitement des données...\\"';
}

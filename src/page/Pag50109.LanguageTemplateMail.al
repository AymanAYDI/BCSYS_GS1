page 50109 "BC6_Language Template Mail"
{
    Caption = 'Language Template Mail', comment = 'FRA="Code Langue Modèle Mail"';
    PageType = List;
    SourceTable = "BC6_Language Template Mail";
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Parameter String"; Rec."Parameter String")
                {
                }
                field("Language Code"; Rec."Language Code")
                {
                }
                field(Object; Rec.Object)
                {
                }
            }
        }
        area(factboxes)
        {
            // part(MessageDetail; 8073322) TODO: "Language Template Mail Detail" page
            // {
            //     SubPageLink = "Parameter String"=FIELD("Parameter String"),
            //                   "Language Code"=FIELD("Language Code");
            // }
        }
    }

    actions
    {
        area(creation)
        {
            action("<Action1100267017>")
            {
                Caption = 'Import template', comment = 'FRA="Importer modèle"';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Fct_SetHtmlTemplate();
                end;
            }
            action("<Action1100267018>")
            {
                Caption = 'Export template', comment = 'FRA="Exporter modèle"';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Fct_ExportHtmlTemplate();
                end;
            }
            action("<Action1100267019>")
            {
                Caption = 'Delete template', comment = 'FRA="Supprimer modèle"';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Fct_DeleteHtmlTemplate();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        InsLInStream: InStream;
    begin
        CLEAR(InsLInStream);
        Rec.CALCFIELDS("Template mail");
        Rec."Template mail".CREATEINSTREAM(InsLInStream);
        //CurrPage.MessageDetail.PAGE.FctInitAddin(InsLInStream, Rec."Parameter String" + ' ' + Rec."Language Code"); TODO: => TDOD ligne 26
    end;
}

page 50073 "BC6_Language Template Mail"
{
    Caption = 'Language Template Mail';
    PageType = List;
    SourceTable = "BC6_Language Template Mail";

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
                Caption = 'Import template';
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
                Caption = 'Export template';
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
                Caption = 'Delete template';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Fct_DeleteHtmlTemplate();
                end;
            }
            action(UpdateModel)
            {
                Caption = 'Modifier modèle';
                Description = 'EMA1.00';
                Image = EditReminder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
                begin
                    GS1DMSManagment.OpenWordDocument(Rec);
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


page 50050 "BC6_Email Models"
{
    Caption = 'Email models', Comment = 'FRA="Modèles email"';
    PageType = List;
    SourceTable = "BC6_Email Model";
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                }
                field(Description; Rec.Description)
                {
                    Visible = false;
                }
                field(Inactive; Rec.Inactive)
                {
                }
                field("Document Title"; Rec."Document Title")
                {
                }
                field("No. Translations"; Rec."No. Translations")
                {
                }
                field("No. Attachments"; Rec."No. Attachments")
                {
                }
                field("No. Recipients"; Rec."No. Recipients")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ViewLog)
            {
                Caption = 'View Log', Comment = 'FRA="Voir le journal"';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "BC6_Email Log";
                RunPageLink = "Email Model Code" = field("Code");
                RunPageMode = View;
            }

            action(Translations)
            {
                Caption = 'Translations', Comment = 'FRA="Traductions"';
                Image = Translations;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    LanguageTemplateMail: Record "BC6_Language Template Mail";
                    Language: codeunit Language;
                begin
                    LanguageTemplateMail.SETRANGE("Parameter String", Rec.Code);
                    if LanguageTemplateMail.ISEMPTY then begin
                        LanguageTemplateMail.INIT();
                        LanguageTemplateMail."Parameter String" := Rec.Code;
                        LanguageTemplateMail."Language Code" := Language.GetUserLanguageCode();
                        LanguageTemplateMail.INSERT();
                        COMMIT();
                    end;
                    PAGE.RUNMODAL(PAGE::"BC6_Language Template Mail", LanguageTemplateMail);
                end;
            }
            action(Recipients)
            {
                Caption = 'Recipients', Comment = 'FRA="Destinataires"';
                Image = ContactPerson;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "BC6_Email Recipients";
                RunPageLink = "Email Setup Code" = field(Code);
            }
            action(Attachments)
            {
                Caption = 'Attachments', Comment = 'FRA="Pièces jointes"';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "BC6_Email Attachments";
                RunPageLink = "Email Setup Code" = field(Code);
            }
        }
    }

    trigger OnOpenPage()
    begin
        if CurrPage.LOOKUPMODE then
            CurrPage.CAPTION(ConstLookupModeCaption);
    end;

    var
        ConstLookupModeCaption: label 'Selecting an email template', comment = 'FRA="Sélection d''un modèle email"';
}



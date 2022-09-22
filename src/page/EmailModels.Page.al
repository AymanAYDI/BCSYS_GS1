page 50050 "BC6_Email Models"
{
    Caption = 'Email models';
    PageType = List;
    SourceTable = "BC6_Email Model";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                    Visible = false;
                }
                field(Inactive; Inactive)
                {
                }
                field("Document Title"; "Document Title")
                {
                }
                field("No. Translations"; "No. Translations")
                {
                }
                field("No. Attachments"; "No. Attachments")
                {
                }
                field("No. Recipients"; "No. Recipients")
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
                Caption = 'View Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "BC6_Email Log";
                RunPageLink = "Email Model Code" = field("Code");
                RunPageMode = View;
            }
            /*
            action(Translations)
            {
                Caption = 'Translations';
                Image = Translations;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    // TODO: Table DSM LanguageTemplateMail: Record "8073297";
                    Language: Record Language;
                begin
                    LanguageTemplateMail.SETRANGE("Parameter String", Code);
                    IF LanguageTemplateMail.ISEMPTY THEN BEGIN
                        LanguageTemplateMail.INIT;
                        LanguageTemplateMail."Parameter String" := Code;
                        LanguageTemplateMail."Language Code" := Language.GetUserLanguage();
                        LanguageTemplateMail.INSERT;
                        COMMIT;
                    END;
                    PAGE.RUNMODAL(PAGE::"Language Template Mail", LanguageTemplateMail);
                end;
            }*/
            action(Recipients)
            {
                Caption = 'Recipients';
                Image = ContactPerson;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page 50079;
                RunPageLink = "Email Setup Code" = FIELD(Code);
            }
            action(Attachments)
            {
                Caption = 'Pièces jointes';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "BC6_Email Recipients";
                RunPageLink = "Email Setup Code" = FIELD(Code);
            }
        }
    }

    trigger OnOpenPage()
    var
        SelectMode: Boolean;
    begin
        IF CurrPage.LOOKUPMODE THEN
            CurrPage.CAPTION(ConstLookupModeCaption);
    end;

    var
        ConstLookupModeCaption: Label 'Selecting an email template';
}


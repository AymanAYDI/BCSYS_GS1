page 50053 "BC6_mail Attachments Type"
{

    Caption = 'Type pièces jointes email';
    PageType = List;
    SourceTable = "BC6_Email Attachment Type";

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
                }
                field("Output Format"; Rec."Output Format")
                {
                }
                field("File Naming"; Rec."File Naming")
                {
                }
                field("WebApi Type"; Rec."WebApi Type")
                {
                }
                field("WebApi Sub Type"; Rec."WebApi Sub Type")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Traductions)
            {
                Image = Translations;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "BC6_Email Attach Type Transl.";
                RunPageLink = "Attachment Type Code" = FIELD(Code);
            }
        }
    }
}



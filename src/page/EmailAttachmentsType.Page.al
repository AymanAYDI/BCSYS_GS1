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
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                }
                field("Output Format"; "Output Format")
                {
                }
                field("File Naming"; "File Naming")
                {
                }
                field("WebApi Type"; "WebApi Type")
                {
                }
                field("WebApi Sub Type"; "WebApi Sub Type")
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


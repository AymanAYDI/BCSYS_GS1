page 50052 "BC6_Email Attachments"
{

    Caption = 'Pièces jointes email';
    PageType = List;
    SourceTable = "BC6_Email Attachment";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Email Setup Code"; "Email Setup Code")
                {
                    Visible = false;
                }
                field("Attachment Type Code"; "Attachment Type Code")
                {
                }
                field("Attachment Description"; "Attachment Description")
                {
                }
            }
        }
    }

    actions
    {
    }
}


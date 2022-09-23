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
                field("Email Setup Code"; Rec."Email Setup Code")
                {
                    Visible = false;
                }
                field("Attachment Type Code"; Rec."Attachment Type Code")
                {
                }
                field("Attachment Description"; Rec."Attachment Description")
                {
                }
            }
        }
    }

    actions
    {
    }
}


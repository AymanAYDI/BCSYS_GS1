page 50079 "BC6_Email Recipients"
{
    Caption = 'Destinataires email';
    PageType = List;
    SourceTable = "BC6_Email Recipient";

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
                field("Email Type"; "Email Type")
                {
                }
                field("Recipient Type"; "Recipient Type")
                {
                }
                field("Recipient Type Code"; "Recipient Type Code")
                {
                    Enabled = "Recipient Type" = "Recipient Type"::Contact;
                }
                field(Email; Email)
                {
                    Enabled = "Recipient Type" = "Recipient Type"::Email;
                }
            }
        }
    }

    actions
    {
    }
}


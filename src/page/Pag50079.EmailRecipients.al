page 50079 "BC6_Email Recipients"
{
    Caption = 'Email Recipients', comment = 'FRA="Destinataires email"';
    PageType = List;
    SourceTable = "BC6_Email Recipient";
    ApplicationArea = all;
    UsageCategory = Lists;


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
                field("Email Type"; Rec."Email Type")
                {
                }
                field("Recipient Type"; Rec."Recipient Type")
                {
                }
                field("Recipient Type Code"; Rec."Recipient Type Code")
                {
                    Enabled = Rec."Recipient Type" = Rec."Recipient Type"::Contact;
                }
                field(Email; Rec.Email)
                {
                    Enabled = Rec."Recipient Type" = Rec."Recipient Type"::Email;
                }
            }
        }
    }

}


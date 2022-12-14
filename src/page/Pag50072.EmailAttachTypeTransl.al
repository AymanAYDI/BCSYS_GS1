page 50072 "BC6_Email Attach Type Transl."
{
    Caption = 'Email Translation Attachment Type', comment = 'FRA="Traductions type pièces jointes email"';
    PageType = List;
    SourceTable = "BC6_Email Attach. Type Trans.";
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attachment Type Code"; Rec."Attachment Type Code")
                {
                }
                field("Language Code"; Rec."Language Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Report ID"; Rec."Report ID")
                {
                }
                field("Report Name"; Rec."Report Name")
                {
                }
                field("Custom Report Layout Code"; Rec."Custom Report Layout Code")
                {
                }
                field("Custom Report Layout Name"; Rec."Custom Report Layout Name")
                {
                }
            }
        }
    }
}

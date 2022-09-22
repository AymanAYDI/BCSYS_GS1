page 50072 "BC6_Email Attach Type Transl."
{
    Caption = 'Email Translation Attachment Type';
    PageType = List;
    SourceTable = "BC6_Email Attach. Type Trans.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attachment Type Code"; "Attachment Type Code")
                {
                }
                field("Language Code"; "Language Code")
                {
                }
                field(Description; Description)
                {
                }
                field("Report ID"; "Report ID")
                {
                }
                field("Report Name"; "Report Name")
                {
                }
                field("Custom Report Layout Code"; "Custom Report Layout Code")
                {
                }
                field("Custom Report Layout Name"; "Custom Report Layout Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}


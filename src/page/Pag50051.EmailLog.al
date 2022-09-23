page 50051 "BC6_Email Log"
{

    Caption = 'Email log';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "BC6_Email Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Email Model Code"; Rec."Email Model Code")
                {
                }
                field("Record Identifier"; Rec."Record Identifier")
                {
                }
                field("Search Record ID"; Rec."Search Record ID")
                {
                }
                field("Message Status"; Rec."Message Status")
                {
                }
                field("Message"; Rec.Message)
                {
                }
                // field("Created Date-Time"; "Created Date-Time") TODO: The name 'Created Date-Time' does not exist in the current context
                // {
                // }
                field("Created by User ID"; Rec."Created by User ID")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ClearLog)
            {
                Caption = 'Clear Log';
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    RecID: RecordID;
                begin
                    IF Rec.ISEMPTY THEN
                        EXIT;

                    IF Rec.GETFILTER("Email Model Code") <> '' THEN
                        IF Rec.GETFILTER("Record Identifier") <> '' THEN
                            RecID := Rec."Record Identifier";

                    Rec.DELETEALL(TRUE);

                    //                     // GS1DMSManagment.InsertLog(EmailSetupCode, RecID, "Message Status"::Information, ConstErasureLog); TODO: The application object or method 'InsertLog' has scope 'Internal' and cannot be used for 'Extension' development.
                end;
            }
        }
    }
}



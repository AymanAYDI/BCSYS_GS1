page 50051 "BC6_Email Log"
{
    Caption = 'Email log', comment = 'FRA="Journal email"';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "BC6_Email Log";
    ApplicationArea = all;
    UsageCategory = Lists;

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
                field("Created Date-Time"; Rec."Create Date-Time")
                {
                }
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
                Caption = 'Clear Log', Comment = 'FRA="Effacer le journal"';
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
                    RecID: RecordID;
                    EmailSetupCode: Code[20];
                    ConstErasureLog: label 'Erasure Log', Comment = 'FRA="Effacement du journal"';
                begin
                    if Rec.ISEMPTY() then
                        exit;

                    if Rec.GETFILTER("Email Model Code") <> '' then
                        EmailSetupCode := Rec."Email Model Code";

                    if Rec.GETFILTER("Record Identifier") <> '' then
                        RecID := Rec."Record Identifier";

                    Rec.DELETEALL(true);

                    GS1DMSManagment.InsertLog(EmailSetupCode, RecID, Rec."Message Status"::Information, ConstErasureLog);
                end;
            }
        }
    }
}

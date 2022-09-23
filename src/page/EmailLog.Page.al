// page 50051 "BC6_Email Log"
// {

//     Caption = 'Email log';
//     DeleteAllowed = false;
//     InsertAllowed = false;
//     ModifyAllowed = false;
//     PageType = List;
//     SourceTable = "BC6_Email Log";

//     layout
//     {
//         area(content)
//         {
//             repeater(Group)
//             {
//                 field("Entry No."; "Entry No.")
//                 {
//                 }
//                 field("Email Model Code"; "Email Model Code")
//                 {
//                 }
//                 field("Record Identifier"; "Record Identifier")
//                 {
//                 }
//                 field("Search Record ID"; "Search Record ID")
//                 {
//                 }
//                 field("Message Status"; "Message Status")
//                 {
//                 }
//                 field(Message; Message)
//                 {
//                 }
//                 // field("Created Date-Time"; "Created Date-Time") TODO: The name 'Created Date-Time' does not exist in the current context
//                 // {
//                 // }
//                 field("Created by User ID"; "Created by User ID")
//                 {
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(processing)
//         {
//             action(ClearLog)
//             {
//                 Caption = 'Clear Log';
//                 Image = ClearLog;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 PromotedIsBig = true;
//                 PromotedOnly = true;

//                 trigger OnAction()
//                 var
//                     ConstErasureLog: Label 'Erasure Log';
//                     GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
//                     RecID: RecordID;
//                     EmailSetupCode: Code[50];
//                 begin
//                     IF ISEMPTY THEN
//                         EXIT;

//                     IF GETFILTER("Email Model Code") <> '' THEN
//                         EmailSetupCode := "Email Model Code";

//                     IF GETFILTER("Record Identifier") <> '' THEN
//                         RecID := "Record Identifier";

//                     DELETEALL(TRUE);

//                     // GS1DMSManagment.InsertLog(EmailSetupCode, RecID, "Message Status"::Information, ConstErasureLog); TODO: The application object or method 'InsertLog' has scope 'Internal' and cannot be used for 'Extension' development.
//                 end;
//             }
//         }
//     }
// }


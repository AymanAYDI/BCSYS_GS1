page 50115 "BC6_Import/Export GS1"
{
    ApplicationArea = All;
    Caption = 'Import/Export GS1', Comment = 'FRA="Import/Export GS1"';
    PageType = NavigatePage;
    UsageCategory = Administration;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            grid(General)
            {
                ShowCaption = false;
                fixed(FixedPart)
                {
                    group("Group Caption")
                    {
                        ShowCaption = false;
                        field("Expense Import"; XmlPort1Lbl)
                        {
                            Caption = 'Expense Import', Comment = 'FRA="Import note de frais"';
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;
                            trigger OnDrillDown()
                            var
                                ExpenseImport: xmlport "BC6_Expense Import";
                            begin
                                ExpenseImport.TextEncoding := TextEncoding::Windows;
                                ExpenseImport.Run();
                            end;
                        }
                        field("Payroll Import"; XmlPort2Lbl)
                        {
                            Caption = 'Payroll Import', Comment = 'FRA="Import paie"';
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;
                            trigger OnDrillDown()
                            var
                                PayrollImport: xmlport "BC6_Payroll Import";
                            begin
                                PayrollImport.TextEncoding := TextEncoding::Windows;
                                PayrollImport.Run();
                            end;
                        }
                        field("ECF Sage Export"; ReportLbl)
                        {
                            Caption = 'ECF Sage Export', Comment = 'FRA="Export vers ECF Sage"';
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;
                            trigger OnDrillDown()
                            begin
                                Report.Run(Report::"BC6_Financial Statement Export");
                            end;
                        }
                    }
                }
            }
        }
    }

    var

        ReportLbl: label 'ECF Sage Export...', Comment = 'FRA="Export vers ECF Sage"';
        XmlPort1Lbl: label 'Expense Import...', Comment = 'FRA="Import note de frais"';
        XmlPort2Lbl: label 'Payroll Import...', Comment = 'FRA="Import paie"';
}

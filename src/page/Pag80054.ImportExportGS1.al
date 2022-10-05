page 80054 "BC6_Import/Export GS1"
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
                        field("Interface YOOZ"; PageLbl)
                        {
                            Caption = 'Interface YOOZ', Comment = 'FRA="Interface YOOZ"';
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;
                            trigger OnDrillDown()
                            begin
                                Page.Run(50111);
                            end;
                        }
                        field("Expense Import"; XmlPort1Lbl)
                        {
                            Caption = 'Expense Import', Comment = 'FRA="Import note de frais"';
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;
                            trigger OnDrillDown()
                            begin
                                Xmlport.Run(50000, true, True);
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
                            begin
                                Xmlport.Run(50001, false, true);
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

    VAR

        PageLbl: Label 'Interface YOOZ...', Comment = 'FRA="Interface YOOZ"';
        XmlPort1Lbl: Label 'Expense Import...', Comment = 'FRA="Import note de frais"';
        XmlPort2Lbl: Label 'Payroll Import...', Comment = 'FRA="Import paie"';
        ReportLbl: Label 'ECF Sage Export...', Comment = 'FRA="Export vers ECF Sage"';
}

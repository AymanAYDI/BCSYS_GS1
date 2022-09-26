page 50005 "BC6_GS1 Setup"
{
    Caption = 'GS1 Setup', Comment = 'FRA="Paramètres GS1"';
    PageType = Card;
    SourceTable = "BC6_GS1 Setup";
    ApplicationArea = all;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            group("Interface YOOZ")
            {
                field("YOOZ File Archive"; Rec."YOOZ File Archive")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the YOOZ File Archive field.';
                }
                field("YOOZ File Import"; Rec."YOOZ File Import")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the YOOZ File Import field.';
                }
                field("YOOZ Journ. Batch Name"; Rec."YOOZ Journ. Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the YOOZ Journ. Batch Name field.';
                }
                field("YOOZ Journ. Temp. Name"; Rec."YOOZ Journ. Temp. Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the YOOZ Journ. Temp. Name field.';
                }
                field("YOOZ Source Code"; Rec."YOOZ Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the YOOZ Source Code field.';
                }

            }
            group("General Ledger")
            {
                Caption = 'General Ledger', Comment = 'FRA="Comptabilité"';
                group(Payroll)
                {
                    Caption = 'Payroll', Comment = 'FRA="Paie"';
                    field("Payroll Journal Template Name"; Rec."Payroll Journal Template Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payroll Journal Template Name field.', Comment = 'FRA="Nom modèle feuille paie"';
                    }
                    field("Payroll Journal Batch Name"; Rec."Payroll Journal Batch Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payroll Journal Template Name field.', Comment = 'FRA="Nom feuille paie"';
                    }
                    field("Payroll Shortcut Dim. 1 Code"; Rec."Payroll Shortcut Dim. 1 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payroll Journal Template Name field.', Comment = 'FRA="Code raccourci axe 1 paie"';
                    }

                    field("Payroll Shortcut Dim. 2 Code"; Rec."Payroll Shortcut Dim. 2 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payroll Journal Template Name field.', Comment = 'FRA="Code raccourci axe 2 paie"';
                    }
                    field("Payroll Shortcut Dim. 3 Code"; Rec."Payroll Shortcut Dim. 3 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payroll Journal Template Name field.', Comment = 'FRA="Code raccourci axe 3 paie"';
                    }
                    field("Payroll Shortcut Dim. 4 Code"; Rec."Payroll Shortcut Dim. 4 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payroll Journal Template Name field.', Comment = 'FRA="Code raccourci axe 4 paie"';
                    }

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("F&unctions")
            {
                // action("Test Azure Endpoint connection")
                // {
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     ApplicationArea = All;
                //     Caption = 'Test Azure Endpoint connection';
                //     Image = ValidateEmailLoggingSetup;
                //     trigger OnAction()
                //     begin
                //         // Token := CduLAzure.GetOAuthToken(Rec);
                //         // IF Token <> '' THEN
                //         //     MESSAGE(STRSUBSTNO(CstLSuccess, Token))
                //         // ELSE
                //         //     MESSAGE(STRSUBSTNO(CstLError, GETLASTERRORTEXT));

                //         //     end;
                //         // }
                // }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.RESET();
        IF NOT Rec.GET() THEN BEGIN
            Rec.INIT();
            Rec.INSERT();
        END;
    end;
}

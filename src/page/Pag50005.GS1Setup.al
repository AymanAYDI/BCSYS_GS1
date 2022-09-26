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

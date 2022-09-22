page 50112 "BC6_YOOZ Import Archive"
{
    Caption = 'YOOZ Import Archive';
    PageType = List;
    SourceTable = "BC6_YOOZ import Buffer";
    SourceTableView = WHERE("Import Type" = CONST(YOOZ), Status = CONST(Post));
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field.';
                }
                field("Import File Name"; Rec."Import File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import File Name field.';
                }
                field("Import DateTime"; Rec."Import DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import DateTime field.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Import Type"; Rec."Import Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Type field.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("YOOZ No."; Rec."YOOZ No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the YOOZ No. field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("YOOZ Posting Date"; Rec."YOOZ Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the YOOZ Posting Date field.';
                }
                field("Import Document Date"; Rec."Import Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Document Date field.';
                }
                field("Import Document Type"; Rec."Import Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Document Type field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Import Account Type"; Rec."Import Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Account Type field.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Debit Amount field.';
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Amount field.';
                }
                field("Dimension Value 1"; Rec."Dimension Value 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Value 1 field.';
                }
                field("Dimension Value 2"; Rec."Dimension Value 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Value 2 field.';
                }
                field("Dimension Value 3"; Rec."Dimension Value 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Value 3 field.';
                }
                field("Dimension Value 4"; Rec."Dimension Value 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Value 4 field.';
                }
                field("Import Journ. Template Name"; Rec."Import Journ. Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Journ. Template Name field.';
                }
                field("Import Journ Batch Name"; Rec."Import Journ Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Journ Batch Name field.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Code field.';
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
                action("Annuler archivage")
                {
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Caption = 'Cancel';
                    Image = ChangeStatus;
                    trigger OnAction()
                    begin
                        YOOZMgt.RemoveStatus(Rec);
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        UserSetup.GET(USERID);
        UserSetup.TESTFIELD("BC6_Allow Yooz Import");
    end;

    var
        UserSetup: Record "User Setup";
        YOOZMgt: Codeunit "BC6_YOOZ Management";
}

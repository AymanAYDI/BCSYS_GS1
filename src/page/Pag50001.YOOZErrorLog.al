page 50001 "BC6_YOOZ Error Log"
{
    Caption = 'YOOZ Error Log';
    PageType = ListPart;
    SourceTable = "BC6_YOOZ Error Log";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Error Description"; Rec."Error Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Description field.';
                }
                field("Value"; Rec."Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field.';
                }
            }
        }
    }
}

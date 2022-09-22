page 50110 "YOOZ Error Log"
{
    Caption = 'YOOZ Error Log';
    PageType = ListPart;
    SourceTable = "BC6_YOOZ Error Log";
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Error Description"; Rec."Error Description")
                {

                }
                field(Value; Rec.Value) { }
            }
        }
    }
}

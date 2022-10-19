page 50001 "BC6_Test"
{
    Caption = 'Test';
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            group(General)
            {
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(NasEmail)
            {
                RunObject = codeunit "BC6_NAS Email";
                // trigger OnAction()

                // var
                //     "NAS Email": codeunit "BC6_NAS Email";
                // begin
                //     "NAS Email".Run;
                // end;

            }

        }
    }
}

pageextension 50002 "BC6_PostedSalesCreditMemo" extends "Posted Sales Credit Memo"
{
    actions
    {
        addlast(navigation)
        {
            action(BC6_SendManually)
            {
                Caption = 'Send manually';
                Ellipsis = true;
                Image = SendElectronicDocument;

                trigger OnAction()
                var
                    GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
                begin
                    GS1DMSManagment.SelectModelAndSendlEmail(Rec.RECORDID);
                end;
            }

        }
    }
}

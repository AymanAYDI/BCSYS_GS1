pageextension 50001 "BC6_PostedSalesInvoice" extends "Posted Sales Invoice"
{
    actions
    {
        addlast(navigation)
        {
            action(BC6_SendManually)
            {
                Caption = 'Send manually', comment = 'FRA="Envoyer manuellement"';
                Ellipsis = true;
                Image = SendElectronicDocument;

                trigger OnAction()
                var
                    GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
                begin
                    GS1DMSManagment.SelectModelAndSendlEmail(Rec.RECORDID);
                end;
            }

        }
    }
}

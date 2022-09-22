pageextension 50000 "Customer Card.PageExt" extends "Customer Card"
{

    actions
    {
        addlast(navigation)
        {
            action(SendManually)
            {
                Caption = 'Send manually';
                Ellipsis = true;
                Image = SendElectronicDocument;

                trigger OnAction()
                var
                    GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
                begin
                    GS1DMSManagment.SelectModelAndSendlEmail(RECORDID);
                end;
            }

        }
    }


}

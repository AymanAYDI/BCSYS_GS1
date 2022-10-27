pageextension 50011 "BC6_PostedSalesCreditMemo" extends "Posted Sales Credit Memo"
{
    actions
    {
        addlast(navigation)
        {
            action(BC6_SendManually)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Send Manually', comment = 'FRA="Envoyer manuellement"';
                Ellipsis = true;
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
                begin
                    GS1DMSManagment.Send(Rec.RECORDID, '');
                end;
            }
        }
    }
}

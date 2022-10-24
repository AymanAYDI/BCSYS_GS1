codeunit 50002 "BC6_Functions"
{
    procedure ApplyID(RecPDtldCustLedgEntry: Record 379; IntPTransactionNo: Integer);
    begin
        //  IF CduGPDWConfigMgt.AccountingBasicPerm(FALSE) THEN BEGIN
        RecPDtldCustLedgEntry.SETCURRENTKEY("Transaction No.");
        RecPDtldCustLedgEntry.SETRANGE("Transaction No.", IntPTransactionNo);
        if RecPDtldCustLedgEntry.FINDFIRST() then
            CduGApplyIDMgt.FctApplyIDCust(IntPTransactionNo, RecPDtldCustLedgEntry."Customer No.");
    end;


    var
        CduGApplyIDMgt: codeunit "BC6_Apply ID Code Management";

}

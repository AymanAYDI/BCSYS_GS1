codeunit 50001 "BC6_Events"
{
    //CDU12

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure CDU12_OnBeforeCustLedgEntryModify(var CustLedgerEntry: Record "Cust. Ledger Entry"; DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry");

    begin
        // IF CduGPDWConfigMgt.AccountingBasicPerm(FALSE) THEN BEGIN
        CustLedgerEntry.CALCFIELDS("Remaining Amt. (LCY)", CustLedgerEntry."Amount (LCY)");
        if (CustLedgerEntry."Remaining Amt. (LCY)" = CustLedgerEntry."Amount (LCY)") then begin
            CduGApplyIDMgt.FctUpdateApplyIdDetCustLedger(CustLedgerEntry."Entry No.", '');
            CustLedgerEntry."BC6_Applies-to ID Code" := '';
        end else begin
            CduGApplyIDMgt.FctUnApplyIDCust(CustLedgerEntry."Customer No.", CustLedgerEntry."BC6_Applies-to ID Code");
            CustLedgerEntry."BC6_Applies-to ID Code" := LOWERCASE(CustLedgerEntry."BC6_Applies-to ID Code");
        end;
        // END;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure CDU12_OnBeforeVendLedgEntryModify(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry");
    begin
        // IF CduGPDWConfigMgt.AccountingBasicPerm(FALSE) THEN BEGIN
        VendorLedgerEntry.CALCFIELDS("Remaining Amt. (LCY)", VendorLedgerEntry."Amount (LCY)");
        if VendorLedgerEntry."Remaining Amt. (LCY)" = VendorLedgerEntry."Amount (LCY)" then begin
            CduGApplyIDMgt.FctUpdateApplyIdDetVendLedger(VendorLedgerEntry."Entry No.", '');
            VendorLedgerEntry."BC6_Applies-to ID Code" := ''
        end else begin
            CduGApplyIDMgt.FctUnApplyIDVend(VendorLedgerEntry."Vendor No.", VendorLedgerEntry."BC6_Applies-to ID Code");
            VendorLedgerEntry."BC6_Applies-to ID Code" := LOWERCASE(VendorLedgerEntry."BC6_Applies-to ID Code");
        end;
        // END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertDtldVendLedgEntry', '', false, false)]
    local procedure CDU12_OnAfterInsertDtldVendLedgEntry(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; GenJournalLine: Record "Gen. Journal Line"; Offset: Integer);
    begin
        //IF CduGPDWConfigMgt.AccountingBasicPerm(FALSE) THEN BEGIN
        if not (//TODOIsTempGLEntryBufEmpty() and 
        not DtldCVLedgEntryBuffer.ISEMPTY) then begin
            CduGApplyIDMgt.FctSetCVLedgEntryBuff(DtldCVLedgEntryBuffer, Offset);
            CduGApplyIDMgt.FctApplyIDCust(DtldVendLedgEntry."Transaction No.", DtldCVLedgEntryBuffer."CV No.");
        end;
        //  END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDtldCustLedgEntriesOnAfterCreateGLEntriesForTotalAmounts', '', false, false)]
    local procedure CDU12_OnPostDtldCustLedgEntriesOnAfterCreateGLEntriesForTotalAmounts(var TempGLEntryBuf: Record "G/L Entry" temporary; var GlobalGLEntry: Record "G/L Entry"; NextTransactionNo: Integer);
    var
        DtldCVLedgEntryBuf: Record 383;
        DtldCustLedgEntryNoOffset: Integer;

    begin
        //IF CduGPDWConfigMgt.AccountingBasicPerm(FALSE) THEN BEGIN
        if not (TempGLEntryBuf.IsEmpty() and not DtldCVLedgEntryBuf.ISEMPTY) then begin
            CduGApplyIDMgt.FctSetCVLedgEntryBuff(DtldCVLedgEntryBuf, DtldCustLedgEntryNoOffset);
            CduGApplyIDMgt.FctApplyIDCust(NextTransactionNo, DtldCVLedgEntryBuf."CV No.");
        end;
        //  END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed Vendor Ledg. Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure CDU12_OnAfterModifyVend(var Rec: Record "Detailed Vendor Ledg. Entry"; var xRec: Record "Detailed Vendor Ledg. Entry"; RunTrigger: Boolean);

    begin
        If (Rec."Transaction No." <> xRec."Transaction No.") And (xRec."Transaction No." <> 0) then
            IF NOT Rec.Unapplied THEN
                CduGApplyIDMgt.FctApplyIDVendApplication(Rec."Application No.", Rec."Vendor No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed Cust. Ledg. Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure CDU12_OnAfterModifyCust(var Rec: Record "Detailed Cust. Ledg. Entry"; var xRec: Record "Detailed Cust. Ledg. Entry"; RunTrigger: Boolean);

    begin
        If (Rec."Transaction No." <> xRec."Transaction No.") And (xRec."Transaction No." <> 0) then
            IF NOT Rec.Unapplied THEN
                CduGApplyIDMgt.FctApplyIDVendApplication(Rec."Application No.", Rec."Customer No.");
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCreateGLEntriesForTotalAmountsUnapplyV19', '', false, false)]
    // local procedure CDU12_OnBeforeFinishPosting(DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var CustomerPostingGroup: Record "Customer Posting Group"; GenJournalLine: Record "Gen. Journal Line"; var TempIDimPostingBuffer: Record "Dimension Posting Buffer" temporary; var IsHandled: Boolean);

    // begin
    //     IF GenJournalLine.BC6_Check THEN
    //         BC6_Function.ApplyID(DetailedCustLedgEntry, NextTransactionNo);

    // end;



    var
        CduGApplyIDMgt: codeunit "BC6_Apply ID Code Management";
        BC6_Function: Codeunit "BC6_Functions";


}

codeunit 50047 "BC6_Events Applies-to ID Mgt"
{
    //CDU12
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure CDU12_OnBeforeCustLedgEntryModify(var CustLedgerEntry: Record "Cust. Ledger Entry"; DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry");
    var
        ApplyIDMgt: codeunit "BC6_Applies-to ID Mgt";
    begin
        CustLedgerEntry.CALCFIELDS("Remaining Amt. (LCY)", CustLedgerEntry."Amount (LCY)");
        if (CustLedgerEntry."Remaining Amt. (LCY)" = CustLedgerEntry."Amount (LCY)") then begin
            ApplyIDMgt.FctUpdateApplyIdDetCustLedger(CustLedgerEntry."Entry No.", '');
            CustLedgerEntry."BC6_Applies-to ID Code" := '';
        end else begin
            ApplyIDMgt.FctUnApplyIDCust(CustLedgerEntry."Customer No.", CustLedgerEntry."BC6_Applies-to ID Code");
            CustLedgerEntry."BC6_Applies-to ID Code" := LOWERCASE(CustLedgerEntry."BC6_Applies-to ID Code");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure CDU12_OnBeforeVendLedgEntryModify(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry");
    var
        ApplyIDMgt: codeunit "BC6_Applies-to ID Mgt";
    begin
        VendorLedgerEntry.CALCFIELDS("Remaining Amt. (LCY)", VendorLedgerEntry."Amount (LCY)");
        if VendorLedgerEntry."Remaining Amt. (LCY)" = VendorLedgerEntry."Amount (LCY)" then begin
            ApplyIDMgt.FctUpdateApplyIdDetVendLedger(VendorLedgerEntry."Entry No.", '');
            VendorLedgerEntry."BC6_Applies-to ID Code" := ''
        end else begin
            ApplyIDMgt.FctUnApplyIDVend(VendorLedgerEntry."Vendor No.", VendorLedgerEntry."BC6_Applies-to ID Code");
            VendorLedgerEntry."BC6_Applies-to ID Code" := LOWERCASE(VendorLedgerEntry."BC6_Applies-to ID Code");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertDtldVendLedgEntry', '', false, false)]
    local procedure CDU12_OnAfterInsertDtldVendLedgEntry(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; GenJournalLine: Record "Gen. Journal Line"; Offset: Integer);
    var
        ApplyIDMgt: codeunit "BC6_Applies-to ID Mgt";
    begin
        if not (GenJournalLine.BC6_Check and not DtldCVLedgEntryBuffer.ISEMPTY()) then
            ApplyIDMgt.FctApplyIDVend(DtldVendLedgEntry."Transaction No.", DtldCVLedgEntryBuffer."CV No.", Offset + DtldCVLedgEntryBuffer."Entry No.", (DtldCVLedgEntryBuffer."Entry Type" <> DtldCVLedgEntryBuffer."Entry Type"::Application));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertDtldCustLedgEntry', '', false, false)]
    local procedure CDU12_OnAfterInsertDtldCustLedgEntry(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; Offset: Integer);
    var
        ApplyIDMgt: codeunit "BC6_Applies-to ID Mgt";
    begin
        case true of
            not (GenJournalLine.BC6_Check and not DtldCVLedgEntryBuffer.ISEMPTY()):
                ApplyIDMgt.FctApplyIDCust(DtldCustLedgEntry."Transaction No.", DtldCVLedgEntryBuffer."CV No.", Offset + DtldCVLedgEntryBuffer."Entry No.", (DtldCVLedgEntryBuffer."Entry Type" <> DtldCVLedgEntryBuffer."Entry Type"::Application));
            not DtldCVLedgEntryBuffer.IsEmpty and GenJournalLine.BC6_Check:
                ApplyIDMgt.ApplyID(DtldCustLedgEntry, DtldCustLedgEntry."Transaction No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostGLAcc', '', false, false)]
    local procedure CDU12_OnAfterPostGLAcc(var GenJnlLine: Record "Gen. Journal Line"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer; Balancing: Boolean);
    begin
        GenJnlLine.BC6_Check := TempGLEntryBuf.IsEmpty;
    end;

    //Tab380
    [EventSubscriber(ObjectType::Table, Database::"Detailed Vendor Ledg. Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure CDU12_OnAfterModifyVend(var Rec: Record "Detailed Vendor Ledg. Entry"; var xRec: Record "Detailed Vendor Ledg. Entry"; RunTrigger: Boolean);
    var
        ApplyIDMgt: codeunit "BC6_Applies-to ID Mgt";
    begin
        if (Rec."Transaction No." <> xRec."Transaction No.") and (xRec."Transaction No." <> 0) then
            if not Rec.Unapplied then
                ApplyIDMgt.FctApplyIDVendApplication(Rec."Application No.", Rec."Vendor No.");
    end;

    //Tab379
    [EventSubscriber(ObjectType::Table, Database::"Detailed Cust. Ledg. Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure CDU12_OnAfterModifyCust(var Rec: Record "Detailed Cust. Ledg. Entry"; var xRec: Record "Detailed Cust. Ledg. Entry"; RunTrigger: Boolean);
    var
        ApplyIDMgt: codeunit "BC6_Applies-to ID Mgt";
    begin
        if (Rec."Transaction No." <> xRec."Transaction No.") and (xRec."Transaction No." <> 0) then
            if not Rec.Unapplied then
                ApplyIDMgt.FctApplyIDVendApplication(Rec."Application No.", Rec."Customer No.");
    end;
}

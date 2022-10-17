report 50101 "BC6_AutomaticApplication"
{
    Caption = 'Automatic Application', Comment = 'FRA="Application automatique"';
    Permissions = tabledata 21 = rimd;
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";
            trigger OnAfterGetRecord()
            var
                CustLedgEntry1: Record "Cust. Ledger Entry";
                CustPostingGroup: Record "Customer Posting Group";

            begin
                GLSetup.GET();
                CLEAR(IntTierCum);
                CLEAR(IntTierNb);
                if GUIALLOWED and not HideValidationDialog then begin
                    Windiag.OPEN(CstAutoAppl +
                                 CstCustNo + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\' + '\ \' +
                                 CstEntryNo + '@2@@@@@@@@@@@@@@@@@@@@@@@@@\' +
                                 CstCustNo + '#3#########################\');
                    Windiag.UPDATE(1, 0);
                end;
                IntTierNb := Customer.COUNT;

                // Remove all living applications
                F9CustCancel(Customer."No.");

                CustLedgEntry.RESET();
                CustLedgEntry.SETCURRENTKEY("Customer No.", Open, "Customer Posting Group", "Currency Code", "Posting Date");
                CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
                CustLedgEntry.SETRANGE(Open, true);

                // 1rst level: Group by posting group
                if CustPostingGroup.FINDSET() then
                    repeat
                        CustLedgEntry.SETRANGE("Customer Posting Group", CustPostingGroup.Code);
                        CodGCurrencyCode := '@#@#@';
                        if not CustLedgEntry.ISEMPTY then begin
                            CustLedgEntry.FindFirst();
                            repeat
                                F9CustCancel(Customer."No.");

                                // 2nd level: Process per currency
                                if CodGCurrencyCode <> CustLedgEntry."Currency Code" then begin
                                    CodGCurrencyCode := CustLedgEntry."Currency Code";

                                    CustLedgEntry1.COPY(CustLedgEntry);

                                    CustLedgEntry1.FINDSET();
                                    repeat
                                        // Mark entry for application
                                        F9Cust(CustLedgEntry1."Entry No.");
                                    until CustLedgEntry1.NEXT() = 0;

                                    // Post application
                                    LettrageCustomer(Customer."No.");
                                end;
                            until CustLedgEntry.NEXT() = 0;
                        end;
                    until CustPostingGroup.NEXT() = 0;

                IntTierCum += 1;

                if GUIALLOWED and not HideValidationDialog then begin
                    Windiag.UPDATE(1, ROUND(IntTierCum / IntTierNb * 10000, 1));
                    Windiag.UPDATE(3, Customer."No.");
                end;
                if GUIALLOWED and not HideValidationDialog then
                    MESSAGE(CstOpFinished);
                Windiag.CLOSE();
            end;
        }
    }
    procedure F9Cust(PEntryNo: Integer) amt2apply: Decimal
    var
        CustLedg: Record "Cust. Ledger Entry";
    begin
        if CustLedg.GET(PEntryNo) then begin
            CustLedg.CALCFIELDS(CustLedg."Remaining Amount");
            CustLedg.VALIDATE("Amount to Apply", CustLedg."Remaining Amount");
            CustLedg.MODIFY();
        end;

        amt2apply := CustLedg."Remaining Amount";
    end;

    procedure F9CustCancel(CodPCustomerNo: Code[20]) amt2apply: Decimal
    var
        CustLedg: Record "Cust. Ledger Entry";
    begin
        CustLedg.SETCURRENTKEY("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CustLedg.SETRANGE("Customer No.", CodPCustomerNo);
        CustLedg.SETRANGE(Open, true);

        if CustLedg.ISEMPTY then
            exit;
        CustLedg.FINDSET(true, false);
        repeat
            CustLedg."Applies-to ID" := '';
            CustLedg.VALIDATE("Amount to Apply", 0);
            CustLedg.MODIFY();
        until CustLedg.NEXT() = 0;

        COMMIT();
    end;

    local procedure LettrageCustomer(CodPCustomerNo: Code[20])
    var
        NewApplyUnapplyParameters: Record "Apply Unapply Parameters";
        CustLedgEntry1: Record "Cust. Ledger Entry";
        CustLedgEntry2: Record "Cust. Ledger Entry";
        CustEntryApplyPostedEntries: codeunit "CustEntry-Apply Posted Entries";
        DecAmountToApply: Decimal;
        IntLi: Integer;
        IntLnb: Integer;
        TxtLApplicationCode: Text[20];

    begin
        CustLedgEntry1.SETCURRENTKEY("Customer No.", Open, "Posting Date");
        CustLedgEntry1.SETRANGE("Customer No.", CodPCustomerNo);
        CustLedgEntry1.SETRANGE(Open, true);
        CustLedgEntry1.SetRange("Document Type", CustLedgEntry1."Document Type"::Payment);
        CustLedgEntry1.CALCFIELDS("Remaining Amt. (LCY)");
        if CustLedgEntry1.FINDSET(true, false) then begin
            CLEAR(TxtLApplicationCode);

            IntLnb := CustLedgEntry1.COUNT;
            IntLi := 0;

            if GUIALLOWED and not HideValidationDialog then
                Windiag.UPDATE(2, 0);
            repeat
                CustLedgEntry1.CALCFIELDS("Remaining Amt. (LCY)");

                IntLi := IntLi + 1;

                if GUIALLOWED and not HideValidationDialog then
                    Windiag.UPDATE(2, ROUND(IntLi / IntLnb * 10000, 1));

                Clear(CustLedgEntry2);
                CustLedgEntry2.Copy(CustLedgEntry1);
                CustLedgEntry2.SetFilter("Document Type", '<>%1', CustLedgEntry1."Document Type"::Payment);
                CustLedgEntry2.CALCFIELDS("Remaining Amt. (LCY)");

                CustLedgEntry2.SetCurrentKey("Remaining Amt. (LCY)");
                CustLedgEntry2.SetFilter("Remaining Amt. (LCY)", '..%1', abs(CustLedgEntry1."Remaining Amt. (LCY)"));
                CustLedgEntry2.Ascending(false);
                CLEAR(DecAmountToApply);
                if CustLedgEntry2.FindSET() then begin
                    repeat
                        CustLedgEntry2.CALCFIELDS("Remaining Amt. (LCY)");
                        DecAmountToApply := DecAmountToApply + CustLedgEntry2."Remaining Amt. (LCY)";
                        CustLedgEntry2."Applies-to ID" := UserId();
                        CustLedgEntry2.Modify();
                    until (CustLedgEntry2.Next() = 0) or (DecAmountToApply >= CustLedgEntry2."Remaining Amt. (LCY)");
                    CustLedgEntry1."Applies-to ID" := UserId();
                    CustLedgEntry1.Modify();
                    NewApplyUnapplyParameters."Posting Date" := WorkDate();
                    CustEntryApplyPostedEntries.Apply(CustLedgEntry1, NewApplyUnapplyParameters);
                end;
            until CustLedgEntry1.NEXT() = 0;
        end;
    end;

    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        HideValidationDialog: Boolean;
        CodGCurrencyCode: Code[10];
        Windiag: Dialog;
        IntTierCum: Integer;
        IntTierNb: Integer;
        CstAutoAppl: label 'Automatic Application - Processing ...\  \', Comment = 'FRA="Application Automatique - En cours ...\  \"';
        CstCustNo: label 'Customer no.        :', Comment = 'FRA="N° client        "';
        CstEntryNo: label 'Entry No.          :', Comment = 'FRA="N° Ecriture          "';
        CstOpFinished: label 'Operation finished.', Comment = 'FRA="Opération terminée"';
}

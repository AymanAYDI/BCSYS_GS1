codeunit 50046 "BC6_Applies-to ID Mgt"
{
    Permissions = tabledata "Cust. Ledger Entry" = m,
                  tabledata "Vendor Ledger Entry" = m,
                  tabledata "Detailed Cust. Ledg. Entry" = rm,
                  tabledata "Detailed Vendor Ledg. Entry" = rm;

    trigger OnRun()
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Vendor: Record Vendor;
        VendLedgerEntry: Record "Vendor Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DialWindows: Dialog;
        Inti: Integer;
        IntTransactionID: Integer;
    begin
        if CONFIRM(CstUpdate, false, Customer.TABLECAPTION) then begin
            DialWindows.OPEN('#####1#####/#####2#####');
            DialWindows.UPDATE(2, Customer.COUNT);
            Inti := 0;
            if Customer.FINDSET() then
                repeat
                    Inti += 1;
                    DialWindows.UPDATE(1, Inti);

                    CustLedgerEntry.RESET();
                    CustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
                    CustLedgerEntry.SETRANGE("Customer No.", Customer."No.");
                    if not CustLedgerEntry.ISEMPTY then
                        CustLedgerEntry.FINDSET(true, false);
                    CustLedgerEntry.MODIFYALL("BC6_Applies-to ID Code", '');

                    IntTransactionID := 0;

                    DetailedCustLedgEntry.RESET();
                    DetailedCustLedgEntry.SETCURRENTKEY("Transaction No.", "Customer No.", "Entry Type");
                    DetailedCustLedgEntry.SETFILTER("Transaction No.", '<>%1', 0);
                    DetailedCustLedgEntry.SETRANGE("Customer No.", Customer."No.");
                    DetailedCustLedgEntry.SETRANGE("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
                    DetailedCustLedgEntry.SETRANGE(Unapplied, false);
                    if not DetailedCustLedgEntry.ISEMPTY then begin
                        DetailedCustLedgEntry.FINDSET(true, false);
                        repeat
                            if IntTransactionID <> DetailedCustLedgEntry."Transaction No." then
                                FctApplyIDCust(DetailedCustLedgEntry."Transaction No.", DetailedCustLedgEntry."Customer No.", DetailedCustLedgEntry."Entry No.", false);

                            IntTransactionID := DetailedCustLedgEntry."Transaction No.";
                        until DetailedCustLedgEntry.NEXT() = 0;
                    end;

                    IntTransactionID := 0;

                    DetailedCustLedgEntry.RESET();
                    DetailedCustLedgEntry.SETCURRENTKEY("Application No.", "Customer No.", "Entry Type");
                    DetailedCustLedgEntry.SETFILTER("Application No.", '<>%1', 0);
                    DetailedCustLedgEntry.SETRANGE("Customer No.", Customer."No.");
                    DetailedCustLedgEntry.SETRANGE("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
                    DetailedCustLedgEntry.SETRANGE(Unapplied, false);
                    if not DetailedCustLedgEntry.ISEMPTY then begin
                        DetailedCustLedgEntry.FINDSET(true, false);
                        repeat
                            if IntTransactionID <> DetailedCustLedgEntry."Application No." then
                                FctApplyIDCustApplication(DetailedCustLedgEntry."Application No.", DetailedCustLedgEntry."Customer No.");

                            IntTransactionID := DetailedCustLedgEntry."Application No.";
                        until DetailedCustLedgEntry.NEXT() = 0;
                    end;
                until Customer.NEXT() = 0;
            DialWindows.CLOSE();
            MESSAGE(CstProcessFinished);
        end;

        if CONFIRM(CstUpdate, false, Vendor.TABLECAPTION) then begin
            DialWindows.OPEN('#####1#####/#####2#####');
            DialWindows.UPDATE(2, Vendor.COUNT);
            Inti := 0;
            Vendor.FINDSET();
            repeat
                Inti += 1;
                DialWindows.UPDATE(1, Inti);

                VendLedgerEntry.RESET();
                VendLedgerEntry.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
                VendLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
                if not VendLedgerEntry.ISEMPTY then
                    VendLedgerEntry.FINDSET(true, false);
                VendLedgerEntry.MODIFYALL("BC6_Applies-to ID Code", '');

                IntTransactionID := 0;

                DetailedVendLedgEntry.RESET();
                DetailedVendLedgEntry.SETCURRENTKEY("Transaction No.", "Vendor No.", "Entry Type");
                DetailedVendLedgEntry.SETFILTER("Transaction No.", '<>%1', 0);
                DetailedVendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
                DetailedVendLedgEntry.SETRANGE("Entry Type", DetailedVendLedgEntry."Entry Type"::Application);
                DetailedVendLedgEntry.SETRANGE(Unapplied, false);
                if not DetailedVendLedgEntry.ISEMPTY then begin
                    DetailedVendLedgEntry.FINDSET(true, false);
                    repeat
                        if IntTransactionID <> DetailedVendLedgEntry."Transaction No." then
                            FctApplyIDVend(DetailedVendLedgEntry."Transaction No.", DetailedVendLedgEntry."Vendor No.", DetailedVendLedgEntry."Entry No.", false);

                        IntTransactionID := DetailedVendLedgEntry."Transaction No.";
                    until DetailedVendLedgEntry.NEXT() = 0;
                end;

                IntTransactionID := 0;

                DetailedVendLedgEntry.RESET();
                DetailedVendLedgEntry.SETCURRENTKEY("Application No.", "Vendor No.", "Entry Type");
                DetailedVendLedgEntry.SETFILTER("Application No.", '<>%1', 0);
                DetailedVendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
                DetailedVendLedgEntry.SETRANGE("Entry Type", DetailedVendLedgEntry."Entry Type"::Application);
                DetailedVendLedgEntry.SETRANGE(Unapplied, false);
                if not DetailedVendLedgEntry.ISEMPTY then begin
                    DetailedVendLedgEntry.FINDSET(true, false);
                    repeat
                        if IntTransactionID <> DetailedVendLedgEntry."Application No." then
                            FctApplyIDVendApplication(DetailedVendLedgEntry."Application No.", DetailedVendLedgEntry."Vendor No.");

                        IntTransactionID := DetailedVendLedgEntry."Application No.";
                    until DetailedVendLedgEntry.NEXT() = 0;
                end;
            until Vendor.NEXT() = 0;
            DialWindows.CLOSE();
            MESSAGE(CstProcessFinished);
        end;
    end;

    var
        TempDetCVLedgerEntryBuff: Record "Detailed CV Ledg. Entry Buffer" temporary;
        CstLimitReached: label 'Limit reached', Comment = 'FRA="Limite atteinte"';
        CstProcessFinished: label 'Process Finished.', Comment = 'FRA="Traitement terminé."';
        CstUpdate: label 'Update %1 ?', Comment = 'FRA="Mise à jour %1 ?"';

    procedure FctApplyIDCust(IntIDTransaction: Integer; CodCustomer: Code[20]; Entry_No: Integer; IsEmpty: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        CustLedgerEntry3: Record "Cust. Ledger Entry";
        CustLedgerEntry4: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        BoolOpen: Boolean;
        TxtCodApply: Text[10];
    begin
        TxtCodApply := '';
        CustLedgerEntry4.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        CustLedgerEntry4.SETRANGE("Customer No.", CodCustomer);
        CustLedgerEntry4.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if CustLedgerEntry4.ISEMPTY then
            TxtCodApply := FctGetNextApplyCode('')
        else begin
            CustLedgerEntry4.FINDLAST();
            TxtCodApply := FctGetNextApplyCode(LOWERCASE(CustLedgerEntry4."BC6_Applies-to ID Code"))
        end;
        BoolOpen := false;

        CustLedgerEntry2.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        DetailedCustLedgEntry2.SETCURRENTKEY("Cust. Ledger Entry No.", "Posting Date");
        if not IsEmpty then begin
            DetailedCustLedgEntry.GET(Entry_No);
            CustLedgerEntry.GET(DetailedCustLedgEntry."Cust. Ledger Entry No.");
            if CustLedgerEntry.Open then
                BoolOpen := true;
            if CustLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                if BoolOpen then begin
                    DetailedCustLedgEntry."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(DetailedCustLedgEntry."BC6_Applies-to ID Code"));
                    CustLedgerEntry."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(CustLedgerEntry."BC6_Applies-to ID Code"));
                end
                else begin
                    DetailedCustLedgEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(DetailedCustLedgEntry."BC6_Applies-to ID Code"));
                    CustLedgerEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(CustLedgerEntry."BC6_Applies-to ID Code"));
                end;
                CustLedgerEntry.MODIFY();
                DetailedCustLedgEntry.MODIFY();
            end
            else begin
                CustLedgerEntry2.SETRANGE("Customer No.", CodCustomer);
                CustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", CustLedgerEntry."BC6_Applies-to ID Code");
                if not CustLedgerEntry2.ISEMPTY then begin
                    CustLedgerEntry2.FINDSET();
                    repeat
                        CustLedgerEntry3.GET(CustLedgerEntry2."Entry No.");
                        if BoolOpen then
                            CustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtCodApply)
                        else
                            CustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                        CustLedgerEntry3.MODIFY();

                        DetailedCustLedgEntry2.SETRANGE("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
                        if BoolOpen then
                            DetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply)
                        else
                            DetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                    until CustLedgerEntry2.NEXT() = 0;
                end;
            end;
        end
        else begin
            DetailedCustLedgEntry.SETCURRENTKEY("Transaction No.", "Customer No.", "Entry Type");
            DetailedCustLedgEntry.SETRANGE("Transaction No.", IntIDTransaction);
            DetailedCustLedgEntry.SETRANGE("Customer No.", CodCustomer);
            DetailedCustLedgEntry.SETRANGE("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
            if not DetailedCustLedgEntry.ISEMPTY then begin
                DetailedCustLedgEntry.FINDSET();
                repeat
                    CustLedgerEntry.GET(DetailedCustLedgEntry."Cust. Ledger Entry No.");
                    if CustLedgerEntry.Open then
                        BoolOpen := true;

                    if CustLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                        if BoolOpen then
                            CustLedgerEntry."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(CustLedgerEntry."BC6_Applies-to ID Code"))
                        else
                            CustLedgerEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(CustLedgerEntry."BC6_Applies-to ID Code"));
                        CustLedgerEntry.MODIFY();

                        DetailedCustLedgEntry2.SETRANGE("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
                        if BoolOpen then
                            DetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply)
                        else
                            DetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                    end
                    else begin
                        CustLedgerEntry2.SETRANGE("Customer No.", CodCustomer);
                        CustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", CustLedgerEntry."BC6_Applies-to ID Code");
                        if not CustLedgerEntry2.ISEMPTY then begin
                            CustLedgerEntry2.FINDSET();
                            repeat
                                CustLedgerEntry3.GET(CustLedgerEntry2."Entry No.");
                                if BoolOpen then
                                    CustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtCodApply)
                                else
                                    CustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                                CustLedgerEntry3.MODIFY();

                                DetailedCustLedgEntry2.SETRANGE("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
                                if BoolOpen then
                                    DetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply)
                                else
                                    DetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                            until CustLedgerEntry2.NEXT() = 0;
                        end;
                    end;
                until DetailedCustLedgEntry.NEXT() = 0;
            end;
        end;

        if BoolOpen then begin
            CustLedgerEntry2.SETRANGE("Customer No.", CodCustomer);
            CustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
            if not CustLedgerEntry2.ISEMPTY then begin
                CustLedgerEntry2.FINDSET();
                repeat
                    CustLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", TxtCodApply);
                    CustLedgerEntry2.MODIFY();

                    FctUpdateApplyIdDetCustLedger(CustLedgerEntry2."Entry No.", TxtCodApply)
                until CustLedgerEntry2.NEXT() = 0;
            end;

            CustLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply);
        end;
    end;

    procedure FctApplyIDCustApplication(IntPIDApplication: Integer; CodPCustomer: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        BoolOpen: Boolean;
        TxtCodApply: Text[10];
    begin
        TxtCodApply := '';
        CustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        CustLedgerEntry.SETRANGE("Customer No.", CodPCustomer);
        CustLedgerEntry.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if CustLedgerEntry.ISEMPTY then
            TxtCodApply := FctGetNextApplyCode('')
        else begin
            CustLedgerEntry.FINDLAST();
            TxtCodApply := FctGetNextApplyCode(LOWERCASE(CustLedgerEntry."BC6_Applies-to ID Code"))
        end;
        CustLedgerEntry.RESET();

        BoolOpen := false;

        DetailedCustLedgEntry.SETCURRENTKEY("Application No.", "Customer No.", "Entry Type");
        DetailedCustLedgEntry.SETRANGE("Application No.", IntPIDApplication);
        DetailedCustLedgEntry.SETRANGE("Customer No.", CodPCustomer);
        DetailedCustLedgEntry.SETRANGE("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
        if not DetailedCustLedgEntry.ISEMPTY then begin
            DetailedCustLedgEntry.FINDSET();
            repeat
                CustLedgerEntry.GET(DetailedCustLedgEntry."Cust. Ledger Entry No.");
                if CustLedgerEntry.Open then
                    BoolOpen := true;

                if CustLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                    CustLedgerEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(CustLedgerEntry."BC6_Applies-to ID Code"));
                    CustLedgerEntry.MODIFY();
                    FctUpdateApplyIdDetCustLedger(CustLedgerEntry."Entry No.", UPPERCASE(TxtCodApply))
                end
                else begin
                    CustLedgerEntry2.SETRANGE("Customer No.", CodPCustomer);
                    CustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", CustLedgerEntry."BC6_Applies-to ID Code");
                    if not CustLedgerEntry2.ISEMPTY then begin
                        CustLedgerEntry2.FINDSET();
                        repeat
                            CustLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                            CustLedgerEntry2.MODIFY();

                            FctUpdateApplyIdDetCustLedger(CustLedgerEntry2."Entry No.", UPPERCASE(TxtCodApply))
                        until CustLedgerEntry2.NEXT() = 0;
                    end;
                end;
            until DetailedCustLedgEntry.NEXT() = 0;

            if BoolOpen then begin
                CustLedgerEntry2.SETRANGE("Customer No.", CodPCustomer);
                CustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                if not CustLedgerEntry2.ISEMPTY then begin
                    CustLedgerEntry2.FINDSET();
                    repeat
                        CustLedgerEntry2."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(CustLedgerEntry2."BC6_Applies-to ID Code"));
                        CustLedgerEntry2.MODIFY();

                        FctUpdateApplyIdDetCustLedger(CustLedgerEntry2."Entry No.", TxtCodApply)
                    until CustLedgerEntry2.NEXT() = 0;
                end;

                CustLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply);
            end;
        end;
    end;

    local procedure FctGetNextApplyCode(TxtApplyCode: Text[10]) TxtRApplyCode: Text[10]
    var
        ChrAlphaLetters: array[26] of Char;
        Inti: Integer;
        IntLetterInNumber: Integer;
    begin
        ChrAlphaLetters[1] := 'a';
        ChrAlphaLetters[2] := 'b';
        ChrAlphaLetters[3] := 'c';
        ChrAlphaLetters[4] := 'd';
        ChrAlphaLetters[5] := 'e';
        ChrAlphaLetters[6] := 'f';
        ChrAlphaLetters[7] := 'g';
        ChrAlphaLetters[8] := 'h';
        ChrAlphaLetters[9] := 'i';
        ChrAlphaLetters[10] := 'j';
        ChrAlphaLetters[11] := 'k';
        ChrAlphaLetters[12] := 'l';
        ChrAlphaLetters[13] := 'm';
        ChrAlphaLetters[14] := 'n';
        ChrAlphaLetters[15] := 'o';
        ChrAlphaLetters[16] := 'p';
        ChrAlphaLetters[17] := 'q';
        ChrAlphaLetters[18] := 'r';
        ChrAlphaLetters[19] := 's';
        ChrAlphaLetters[20] := 't';
        ChrAlphaLetters[21] := 'u';
        ChrAlphaLetters[22] := 'v';
        ChrAlphaLetters[23] := 'w';
        ChrAlphaLetters[24] := 'x';
        ChrAlphaLetters[25] := 'y';
        ChrAlphaLetters[26] := 'z';

        TxtRApplyCode := '';
        if TxtApplyCode <> '' then begin
            TxtRApplyCode := TxtApplyCode;
            for Inti := 1 to 5 do begin
                IntLetterInNumber := FctFindPosiLetter(TxtApplyCode[6 - Inti], ChrAlphaLetters);
                if IntLetterInNumber < 26 then begin
                    TxtRApplyCode[6 - Inti] := ChrAlphaLetters[IntLetterInNumber + 1];
                    exit(TxtRApplyCode);
                end
                else
                    TxtRApplyCode[6 - Inti] := 'a';
            end;
        end
        else
            TxtRApplyCode := FORMAT(ChrAlphaLetters[1]) + FORMAT(ChrAlphaLetters[1]) + FORMAT(ChrAlphaLetters[1])
                              + FORMAT(ChrAlphaLetters[1]) + FORMAT(ChrAlphaLetters[1]);

        if TxtRApplyCode = '' then
            ERROR(CstLimitReached);
    end;

    local procedure FctFindPosiLetter(ChrLetter: Char; ChrAlphaLetters: array[26] of Char): Integer
    begin
        case ChrLetter of
            ChrAlphaLetters[1]:
                exit(1);
            ChrAlphaLetters[2]:
                exit(2);
            ChrAlphaLetters[3]:
                exit(3);
            ChrAlphaLetters[4]:
                exit(4);
            ChrAlphaLetters[5]:
                exit(5);
            ChrAlphaLetters[6]:
                exit(6);
            ChrAlphaLetters[7]:
                exit(7);
            ChrAlphaLetters[8]:
                exit(8);
            ChrAlphaLetters[9]:
                exit(9);
            ChrAlphaLetters[10]:
                exit(10);
            ChrAlphaLetters[11]:
                exit(11);
            ChrAlphaLetters[12]:
                exit(12);
            ChrAlphaLetters[13]:
                exit(13);
            ChrAlphaLetters[14]:
                exit(14);
            ChrAlphaLetters[15]:
                exit(15);
            ChrAlphaLetters[16]:
                exit(16);
            ChrAlphaLetters[17]:
                exit(17);
            ChrAlphaLetters[18]:
                exit(18);
            ChrAlphaLetters[19]:
                exit(19);
            ChrAlphaLetters[20]:
                exit(20);
            ChrAlphaLetters[21]:
                exit(21);
            ChrAlphaLetters[22]:
                exit(22);
            ChrAlphaLetters[23]:
                exit(23);
            ChrAlphaLetters[24]:
                exit(24);
            ChrAlphaLetters[25]:
                exit(25);
            ChrAlphaLetters[26]:
                exit(26);
        end;
    end;

    procedure FctUnApplyIDCust(CodCustomer: Code[20]; TxtApplyID: Text[10])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if TxtApplyID = UPPERCASE(TxtApplyID) then begin
            CustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
            CustLedgerEntry.SETRANGE("Customer No.", CodCustomer);
            CustLedgerEntry.SETRANGE("BC6_Applies-to ID Code", TxtApplyID);
            if not CustLedgerEntry.ISEMPTY then begin
                CustLedgerEntry.FINDSET();
                repeat
                    CustLedgerEntry.VALIDATE("BC6_Applies-to ID Code", LOWERCASE(TxtApplyID));
                    CustLedgerEntry.MODIFY();

                    FctUpdateApplyIdDetCustLedger(CustLedgerEntry."Entry No.", LOWERCASE(TxtApplyID))
                until CustLedgerEntry.NEXT() = 0;
            end;
        end;
    end;

    procedure FctUpdateApplyIdDetCustLedger(IntCustLedgerEntry: Integer; TxtApplyID: Text[10])
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Posting Date");
        DetailedCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", IntCustLedgerEntry);
        DetailedCustLedgEntry.MODIFYALL("BC6_Applies-to ID Code", TxtApplyID);
    end;

    procedure FctApplyIDVend(IntIDTransaction: Integer; CodVendor: Code[20]; Entry_No: Integer; IsEmpty: Boolean)
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendLedgerEntry2: Record "Vendor Ledger Entry";
        VendLedgerEntry3: Record "Vendor Ledger Entry";
        VendLedgerEntry4: Record "Vendor Ledger Entry";
        DetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DetailedVendLedgEntry2: Record "Detailed Vendor Ledg. Entry";
        BoolOpen: Boolean;
        TxtCodApply: Text[10];
    begin
        TxtCodApply := '';
        VendLedgerEntry4.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
        VendLedgerEntry4.SETRANGE("Vendor No.", CodVendor);
        VendLedgerEntry4.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if VendLedgerEntry4.ISEMPTY then
            TxtCodApply := FctGetNextApplyCode('')
        else begin
            VendLedgerEntry4.FINDLAST();
            TxtCodApply := FctGetNextApplyCode(LOWERCASE(VendLedgerEntry4."BC6_Applies-to ID Code"))
        end;
        BoolOpen := false;

        VendLedgerEntry2.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
        DetailedVendLedgEntry2.SETCURRENTKEY("Vendor Ledger Entry No.", "Posting Date");
        if not IsEmpty then begin
            DetailedVendLedgEntry.GET(Entry_No);
            VendLedgerEntry.GET(DetailedVendLedgEntry."Vendor Ledger Entry No.");
            if VendLedgerEntry.Open then
                BoolOpen := true;
            if VendLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                if BoolOpen then begin
                    DetailedVendLedgEntry."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(DetailedVendLedgEntry."BC6_Applies-to ID Code"));
                    VendLedgerEntry."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(VendLedgerEntry."BC6_Applies-to ID Code"));
                end
                else begin
                    DetailedVendLedgEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(DetailedVendLedgEntry."BC6_Applies-to ID Code"));
                    VendLedgerEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(VendLedgerEntry."BC6_Applies-to ID Code"));
                end;
                VendLedgerEntry.MODIFY();
                DetailedVendLedgEntry.MODIFY();
            end
            else begin
                VendLedgerEntry2.SETRANGE("Vendor No.", CodVendor);
                VendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", VendLedgerEntry."BC6_Applies-to ID Code");
                if not VendLedgerEntry2.ISEMPTY then begin
                    VendLedgerEntry2.FINDSET();
                    repeat
                        VendLedgerEntry3.GET(VendLedgerEntry2."Entry No.");
                        if BoolOpen then
                            VendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtCodApply)
                        else
                            VendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                        VendLedgerEntry3.MODIFY();

                        DetailedVendLedgEntry2.SETRANGE("Vendor Ledger Entry No.", VendLedgerEntry."Entry No.");
                        if BoolOpen then
                            DetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply)
                        else
                            DetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                    until VendLedgerEntry2.NEXT() = 0;
                end;
            end;
        end
        else begin
            DetailedVendLedgEntry.SETCURRENTKEY("Transaction No.", "Vendor No.", "Entry Type");
            DetailedVendLedgEntry.SETRANGE("Transaction No.", IntIDTransaction);
            DetailedVendLedgEntry.SETRANGE("Vendor No.", CodVendor);
            DetailedVendLedgEntry.SETRANGE("Entry Type", DetailedVendLedgEntry."Entry Type"::Application);
            if not DetailedVendLedgEntry.ISEMPTY then begin
                DetailedVendLedgEntry.FINDSET();
                repeat
                    VendLedgerEntry.GET(DetailedVendLedgEntry."Vendor Ledger Entry No.");
                    if VendLedgerEntry.Open then
                        BoolOpen := true;

                    if VendLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                        if BoolOpen then
                            VendLedgerEntry."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(VendLedgerEntry."BC6_Applies-to ID Code"))
                        else
                            VendLedgerEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(VendLedgerEntry."BC6_Applies-to ID Code"));
                        VendLedgerEntry.MODIFY();

                        DetailedVendLedgEntry2.SETRANGE("Vendor Ledger Entry No.", VendLedgerEntry."Entry No.");
                        if BoolOpen then
                            DetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply)
                        else
                            DetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                    end
                    else begin
                        VendLedgerEntry2.SETRANGE("Vendor No.", CodVendor);
                        VendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", VendLedgerEntry."BC6_Applies-to ID Code");
                        if not VendLedgerEntry2.ISEMPTY then begin
                            VendLedgerEntry2.FINDSET();
                            repeat
                                VendLedgerEntry3.GET(VendLedgerEntry2."Entry No.");
                                if BoolOpen then
                                    VendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtCodApply)
                                else
                                    VendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                                VendLedgerEntry3.MODIFY();

                                DetailedVendLedgEntry2.SETRANGE("Vendor Ledger Entry No.", VendLedgerEntry."Entry No.");
                                if BoolOpen then
                                    DetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply)
                                else
                                    DetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                            until VendLedgerEntry2.NEXT() = 0;
                        end;
                    end;
                until DetailedVendLedgEntry.NEXT() = 0;
            end;
        end;

        if BoolOpen then begin
            VendLedgerEntry2.SETRANGE("Vendor No.", CodVendor);
            VendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
            if not VendLedgerEntry2.ISEMPTY then begin
                VendLedgerEntry2.FINDSET();
                repeat
                    VendLedgerEntry2."BC6_Applies-to ID Code" := CopyStr(TxtCodApply, 1, MaxStrLen(VendLedgerEntry2."BC6_Applies-to ID Code"));
                    VendLedgerEntry2.MODIFY();

                    FctUpdateApplyIdDetVendLedger(VendLedgerEntry2."Entry No.", TxtCodApply)
                until VendLedgerEntry2.NEXT() = 0;
            end;

            VendLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply);
        end;
    end;

    procedure FctApplyIDVendApplication(IntIDApplication: Integer; CodVendor: Code[20])
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendLedgerEntry2: Record "Vendor Ledger Entry";
        DetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        BoolOpen: Boolean;
        TxtCodApply: Text[10];
    begin
        TxtCodApply := '';
        VendLedgerEntry.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
        VendLedgerEntry.SETRANGE("Vendor No.", CodVendor);
        VendLedgerEntry.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if VendLedgerEntry.ISEMPTY then
            TxtCodApply := FctGetNextApplyCode('')
        else begin
            VendLedgerEntry.FINDLAST();
            TxtCodApply := FctGetNextApplyCode(LOWERCASE(VendLedgerEntry."BC6_Applies-to ID Code"))
        end;
        VendLedgerEntry.RESET();

        BoolOpen := false;

        DetailedVendLedgEntry.SETCURRENTKEY("Application No.", "Vendor No.", "Entry Type");
        DetailedVendLedgEntry.SETRANGE("Application No.", IntIDApplication);
        DetailedVendLedgEntry.SETRANGE("Vendor No.", CodVendor);
        DetailedVendLedgEntry.SETRANGE("Entry Type", DetailedVendLedgEntry."Entry Type"::Application);
        if not DetailedVendLedgEntry.ISEMPTY then begin
            DetailedVendLedgEntry.FINDSET();
            repeat
                VendLedgerEntry.GET(DetailedVendLedgEntry."Vendor Ledger Entry No.");
                if VendLedgerEntry.Open then
                    BoolOpen := true;

                if VendLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                    VendLedgerEntry."BC6_Applies-to ID Code" := CopyStr(UPPERCASE(TxtCodApply), 1, MaxStrLen(VendLedgerEntry."BC6_Applies-to ID Code"));
                    VendLedgerEntry.MODIFY();
                    FctUpdateApplyIdDetVendLedger(VendLedgerEntry."Entry No.", UPPERCASE(TxtCodApply));
                end
                else begin
                    VendLedgerEntry2.SETRANGE("Vendor No.", CodVendor);
                    VendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", VendLedgerEntry."BC6_Applies-to ID Code");
                    if not VendLedgerEntry2.ISEMPTY then begin
                        VendLedgerEntry2.FINDSET();
                        repeat
                            VendLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                            VendLedgerEntry2.MODIFY();

                            FctUpdateApplyIdDetVendLedger(VendLedgerEntry2."Entry No.", UPPERCASE(TxtCodApply))
                        until VendLedgerEntry2.NEXT() = 0;
                    end;
                end;
            until DetailedVendLedgEntry.NEXT() = 0;

            if BoolOpen then begin
                VendLedgerEntry2.SETRANGE("Vendor No.", CodVendor);
                VendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtCodApply));
                if not VendLedgerEntry2.ISEMPTY then begin
                    VendLedgerEntry2.FINDSET();
                    repeat
                        VendLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", TxtCodApply);
                        VendLedgerEntry2.MODIFY();

                        FctUpdateApplyIdDetVendLedger(VendLedgerEntry2."Entry No.", TxtCodApply)
                    until VendLedgerEntry2.NEXT() = 0;
                end;

                VendLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtCodApply);
            end;
        end;
    end;

    procedure FctUnApplyIDVend(CodVendor: Code[20]; TxtApplyID: Text[10])
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if TxtApplyID = UPPERCASE(TxtApplyID) then begin
            VendLedgerEntry.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
            VendLedgerEntry.SETRANGE("Vendor No.", CodVendor);
            VendLedgerEntry.SETRANGE("BC6_Applies-to ID Code", TxtApplyID);
            if not VendLedgerEntry.ISEMPTY then begin
                VendLedgerEntry.FINDSET();
                repeat
                    VendLedgerEntry.VALIDATE("BC6_Applies-to ID Code", LOWERCASE(TxtApplyID));
                    VendLedgerEntry.MODIFY();

                    FctUpdateApplyIdDetVendLedger(VendLedgerEntry."Entry No.", LOWERCASE(TxtApplyID))
                until VendLedgerEntry.NEXT() = 0;
            end;
        end;
    end;

    procedure FctUpdateApplyIdDetVendLedger(IntVendLedgerEntry: Integer; TxtApplyID: Text[10])
    var
        DetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        DetailedVendLedgEntry.SETCURRENTKEY("Vendor Ledger Entry No.", "Posting Date");
        DetailedVendLedgEntry.SETRANGE("Vendor Ledger Entry No.", IntVendLedgerEntry);
        DetailedVendLedgEntry.MODIFYALL("BC6_Applies-to ID Code", TxtApplyID);
    end;

    procedure FctUnApplyIDCustFinal(CodCustomer: Code[20]; TxtApplyID: Text[10])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        CustLedgerEntry.SETRANGE("Customer No.", CodCustomer);
        CustLedgerEntry.SETRANGE("BC6_Applies-to ID Code", TxtApplyID);
        if not CustLedgerEntry.ISEMPTY then begin
            CustLedgerEntry.FINDSET();
            repeat
                FctUpdateApplyIdDetCustLedger(CustLedgerEntry."Entry No.", '')
            until CustLedgerEntry.NEXT() = 0;
        end;
    end;

    procedure FctUpdApplyIdDetCustLdgFinal(IntCustLedgerEntry: Integer; TxtApplyID: Text[10])
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Posting Date");
        DetailedCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", IntCustLedgerEntry);
        DetailedCustLedgEntry.MODIFYALL("BC6_Applies-to ID Code", TxtApplyID);
    end;

    procedure FctSetCVLedgEntryBuff(var DetCVLedgerEntryBuff: Record "Detailed CV Ledg. Entry Buffer"; IntPOffset: Integer)
    begin
        TempDetCVLedgerEntryBuff.DELETEALL();
        if not DetCVLedgerEntryBuff.ISEMPTY then begin
            DetCVLedgerEntryBuff.FINDSET();
            repeat
                if DetCVLedgerEntryBuff."Entry Type" = DetCVLedgerEntryBuff."Entry Type"::Application then begin
                    TempDetCVLedgerEntryBuff.INIT();
                    TempDetCVLedgerEntryBuff.TRANSFERFIELDS(DetCVLedgerEntryBuff);
                    TempDetCVLedgerEntryBuff."Entry No." := DetCVLedgerEntryBuff."Entry No." + IntPOffset;
                    TempDetCVLedgerEntryBuff.INSERT();
                end;
            until DetCVLedgerEntryBuff.NEXT() = 0;
        end;
    end;

    procedure ApplyID(_DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; IntPTransactionNo: Integer)
    begin
        _DtldCustLedgEntry.SETCURRENTKEY("Transaction No.");
        _DtldCustLedgEntry.SETRANGE("Transaction No.", IntPTransactionNo);
        if _DtldCustLedgEntry.FINDFIRST() then
            FctApplyIDCust(IntPTransactionNo, _DtldCustLedgEntry."Customer No.", _DtldCustLedgEntry."Entry No.", (_DtldCustLedgEntry."Entry Type" <> _DtldCustLedgEntry."Entry Type"::Application));
    end;
}

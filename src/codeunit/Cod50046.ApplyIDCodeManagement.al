codeunit 50046 "BC6_Apply ID Code Management"
{
    Permissions = tabledata "Cust. Ledger Entry" = m,
                  tabledata "Vendor Ledger Entry" = m,
                  tabledata "Detailed Cust. Ledg. Entry" = rm,
                  tabledata "Detailed Vendor Ledg. Entry" = rm;

    trigger OnRun()
    var
        RecLCustomer: Record Customer;
        RecLCustLedgerEntry: Record "Cust. Ledger Entry";
        RecLVendor: Record Vendor;
        RecLVendLedgerEntry: Record "Vendor Ledger Entry";
        RecLDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        RecLDetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DialWindows: Dialog;
        IntLi: Integer;
        IntLTransactionID: Integer;
    begin
        if CONFIRM(CstGUpdate, false, RecLCustomer.TABLECAPTION) then begin
            DialWindows.OPEN('#####1#####/#####2#####');
            DialWindows.UPDATE(2, RecLCustomer.COUNT);
            IntLi := 0;
            if RecLCustomer.FINDSET() then
                repeat
                    IntLi += 1;
                    DialWindows.UPDATE(1, IntLi);

                    RecLCustLedgerEntry.RESET();
                    RecLCustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
                    RecLCustLedgerEntry.SETRANGE("Customer No.", RecLCustomer."No.");
                    if not RecLCustLedgerEntry.ISEMPTY then
                        RecLCustLedgerEntry.FINDSET(true, false);
                    RecLCustLedgerEntry.MODIFYALL("BC6_Applies-to ID Code", '');

                    IntLTransactionID := 0;

                    RecLDetailedCustLedgEntry.RESET();
                    RecLDetailedCustLedgEntry.SETCURRENTKEY("Transaction No.", "Customer No.", "Entry Type");
                    RecLDetailedCustLedgEntry.SETFILTER("Transaction No.", '<>%1', 0);
                    RecLDetailedCustLedgEntry.SETRANGE("Customer No.", RecLCustomer."No.");
                    RecLDetailedCustLedgEntry.SETRANGE("Entry Type", RecLDetailedCustLedgEntry."Entry Type"::Application);
                    RecLDetailedCustLedgEntry.SETRANGE(Unapplied, false);
                    if not RecLDetailedCustLedgEntry.ISEMPTY then begin
                        RecLDetailedCustLedgEntry.FINDSET(true, false);
                        repeat
                            if IntLTransactionID <> RecLDetailedCustLedgEntry."Transaction No." then
                                FctApplyIDCust(RecLDetailedCustLedgEntry."Transaction No.", RecLDetailedCustLedgEntry."Customer No.");

                            IntLTransactionID := RecLDetailedCustLedgEntry."Transaction No.";
                        until RecLDetailedCustLedgEntry.NEXT() = 0;
                    end;

                    IntLTransactionID := 0;

                    RecLDetailedCustLedgEntry.RESET();
                    RecLDetailedCustLedgEntry.SETCURRENTKEY("Application No.", "Customer No.", "Entry Type");
                    RecLDetailedCustLedgEntry.SETFILTER("Application No.", '<>%1', 0);
                    RecLDetailedCustLedgEntry.SETRANGE("Customer No.", RecLCustomer."No.");
                    RecLDetailedCustLedgEntry.SETRANGE("Entry Type", RecLDetailedCustLedgEntry."Entry Type"::Application);
                    RecLDetailedCustLedgEntry.SETRANGE(Unapplied, false);
                    if not RecLDetailedCustLedgEntry.ISEMPTY then begin
                        RecLDetailedCustLedgEntry.FINDSET(true, false);
                        repeat
                            if IntLTransactionID <> RecLDetailedCustLedgEntry."Application No." then
                                FctApplyIDCustApplication(RecLDetailedCustLedgEntry."Application No.", RecLDetailedCustLedgEntry."Customer No.");

                            IntLTransactionID := RecLDetailedCustLedgEntry."Application No.";
                        until RecLDetailedCustLedgEntry.NEXT() = 0;
                    end;

                until RecLCustomer.NEXT() = 0;
            DialWindows.CLOSE();
            MESSAGE(CstGProcessFinished);
        end;

        if CONFIRM(CstGUpdate, false, RecLVendor.TABLECAPTION) then begin
            DialWindows.OPEN('#####1#####/#####2#####');
            DialWindows.UPDATE(2, RecLVendor.COUNT);
            IntLi := 0;
            RecLVendor.FINDSET();
            repeat
                IntLi += 1;
                DialWindows.UPDATE(1, IntLi);

                RecLVendLedgerEntry.RESET();
                RecLVendLedgerEntry.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
                RecLVendLedgerEntry.SETRANGE("Vendor No.", RecLVendor."No.");
                if not RecLVendLedgerEntry.ISEMPTY then
                    RecLVendLedgerEntry.FINDSET(true, false);
                RecLVendLedgerEntry.MODIFYALL("BC6_Applies-to ID Code", '');

                IntLTransactionID := 0;

                RecLDetailedVendLedgEntry.RESET();
                RecLDetailedVendLedgEntry.SETCURRENTKEY("Transaction No.", "Vendor No.", "Entry Type");
                RecLDetailedVendLedgEntry.SETFILTER("Transaction No.", '<>%1', 0);
                RecLDetailedVendLedgEntry.SETRANGE("Vendor No.", RecLVendor."No.");
                RecLDetailedVendLedgEntry.SETRANGE("Entry Type", RecLDetailedVendLedgEntry."Entry Type"::Application);
                RecLDetailedVendLedgEntry.SETRANGE(Unapplied, false);
                if not RecLDetailedVendLedgEntry.ISEMPTY then begin
                    RecLDetailedVendLedgEntry.FINDSET(true, false);
                    repeat
                        if IntLTransactionID <> RecLDetailedVendLedgEntry."Transaction No." then
                            FctApplyIDVend(RecLDetailedVendLedgEntry."Transaction No.", RecLDetailedVendLedgEntry."Vendor No.");

                        IntLTransactionID := RecLDetailedVendLedgEntry."Transaction No.";
                    until RecLDetailedVendLedgEntry.NEXT() = 0;
                end;

                IntLTransactionID := 0;

                RecLDetailedVendLedgEntry.RESET();
                RecLDetailedVendLedgEntry.SETCURRENTKEY("Application No.", "Vendor No.", "Entry Type");
                RecLDetailedVendLedgEntry.SETFILTER("Application No.", '<>%1', 0);
                RecLDetailedVendLedgEntry.SETRANGE("Vendor No.", RecLVendor."No.");
                RecLDetailedVendLedgEntry.SETRANGE("Entry Type", RecLDetailedVendLedgEntry."Entry Type"::Application);
                RecLDetailedVendLedgEntry.SETRANGE(Unapplied, false);
                if not RecLDetailedVendLedgEntry.ISEMPTY then begin
                    RecLDetailedVendLedgEntry.FINDSET(true, false);
                    repeat
                        if IntLTransactionID <> RecLDetailedVendLedgEntry."Application No." then
                            FctApplyIDVendApplication(RecLDetailedVendLedgEntry."Application No.", RecLDetailedVendLedgEntry."Vendor No.");

                        IntLTransactionID := RecLDetailedVendLedgEntry."Application No.";
                    until RecLDetailedVendLedgEntry.NEXT() = 0;
                end;

            until RecLVendor.NEXT() = 0;
            DialWindows.CLOSE();
            MESSAGE(CstGProcessFinished);
        end;
    end;

    var
        RecGDetCVLedgerEntryBuffTMP: Record "Detailed CV Ledg. Entry Buffer" temporary;
        CstGLimitReached: label 'Limit reached';
        CstGProcessFinished: label 'Process Finished.';
        CstGUpdate: label 'Update %1 ?';


    procedure FctApplyIDCust(IntPIDTransaction: Integer; CodPCustomer: Code[20])
    var
        RecLCustLedgerEntry: Record "Cust. Ledger Entry";
        RecLCustLedgerEntry2: Record "Cust. Ledger Entry";
        RecLCustLedgerEntry3: Record "Cust. Ledger Entry";
        RecLCustLedgerEntry4: Record "Cust. Ledger Entry";
        RecLDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        RecLDetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        BooLOpen: Boolean;
        TxtLCodApply: Text[20];
    begin
        TxtLCodApply := '';
        RecLCustLedgerEntry4.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        RecLCustLedgerEntry4.SETRANGE("Customer No.", CodPCustomer);
        RecLCustLedgerEntry4.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if RecLCustLedgerEntry4.ISEMPTY then
            TxtLCodApply := FctGetNextApplyCode('')
        else begin
            RecLCustLedgerEntry4.FINDLAST();
            TxtLCodApply := FctGetNextApplyCode(LOWERCASE(RecLCustLedgerEntry4."BC6_Applies-to ID Code"))
        end;
        BooLOpen := false;

        RecLCustLedgerEntry2.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        RecLDetailedCustLedgEntry2.SETCURRENTKEY("Cust. Ledger Entry No.", "Posting Date");

        if not RecGDetCVLedgerEntryBuffTMP.ISEMPTY then begin
            RecGDetCVLedgerEntryBuffTMP.FINDSET();
            repeat
                RecLDetailedCustLedgEntry.GET(RecGDetCVLedgerEntryBuffTMP."Entry No.");
                RecLCustLedgerEntry.GET(RecLDetailedCustLedgEntry."Cust. Ledger Entry No.");
                if RecLCustLedgerEntry.Open then
                    BooLOpen := true;
                if RecLCustLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                    if BooLOpen then begin
                        RecLDetailedCustLedgEntry."BC6_Applies-to ID Code" := TxtLCodApply;
                        RecLCustLedgerEntry."BC6_Applies-to ID Code" := TxtLCodApply;
                    end
                    else begin
                        RecLDetailedCustLedgEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                        RecLCustLedgerEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                    end;
                    RecLCustLedgerEntry.MODIFY();
                    RecLDetailedCustLedgEntry.MODIFY();
                end
                else begin
                    RecLCustLedgerEntry2.SETRANGE("Customer No.", CodPCustomer);
                    RecLCustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", RecLCustLedgerEntry."BC6_Applies-to ID Code");
                    if not RecLCustLedgerEntry2.ISEMPTY then begin
                        RecLCustLedgerEntry2.FINDSET();
                        repeat
                            RecLCustLedgerEntry3.GET(RecLCustLedgerEntry2."Entry No.");
                            if BooLOpen then
                                RecLCustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtLCodApply)
                            else
                                RecLCustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                            RecLCustLedgerEntry3.MODIFY();

                            RecLDetailedCustLedgEntry2.SETRANGE("Cust. Ledger Entry No.", RecLCustLedgerEntry."Entry No.");
                            if BooLOpen then
                                RecLDetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply)
                            else
                                RecLDetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                        until RecLCustLedgerEntry2.NEXT() = 0;
                    end;
                end;
            until RecGDetCVLedgerEntryBuffTMP.NEXT() = 0;
        end
        else begin
            RecLDetailedCustLedgEntry.SETCURRENTKEY("Transaction No.", "Customer No.", "Entry Type");
            RecLDetailedCustLedgEntry.SETRANGE("Transaction No.", IntPIDTransaction);
            RecLDetailedCustLedgEntry.SETRANGE("Customer No.", CodPCustomer);
            RecLDetailedCustLedgEntry.SETRANGE("Entry Type", RecLDetailedCustLedgEntry."Entry Type"::Application);
            if not RecLDetailedCustLedgEntry.ISEMPTY then begin
                RecLDetailedCustLedgEntry.FINDSET();
                repeat
                    RecLCustLedgerEntry.GET(RecLDetailedCustLedgEntry."Cust. Ledger Entry No.");
                    if RecLCustLedgerEntry.Open then
                        BooLOpen := true;

                    if RecLCustLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                        if BooLOpen then
                            RecLCustLedgerEntry."BC6_Applies-to ID Code" := TxtLCodApply
                        else
                            RecLCustLedgerEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                        RecLCustLedgerEntry.MODIFY();

                        RecLDetailedCustLedgEntry2.SETRANGE("Cust. Ledger Entry No.", RecLCustLedgerEntry."Entry No.");
                        if BooLOpen then
                            RecLDetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply)
                        else
                            RecLDetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                    end
                    else begin
                        RecLCustLedgerEntry2.SETRANGE("Customer No.", CodPCustomer);
                        RecLCustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", RecLCustLedgerEntry."BC6_Applies-to ID Code");
                        if not RecLCustLedgerEntry2.ISEMPTY then begin
                            RecLCustLedgerEntry2.FINDSET();
                            repeat
                                RecLCustLedgerEntry3.GET(RecLCustLedgerEntry2."Entry No.");
                                if BooLOpen then
                                    RecLCustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtLCodApply)
                                else
                                    RecLCustLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                                RecLCustLedgerEntry3.MODIFY();

                                RecLDetailedCustLedgEntry2.SETRANGE("Cust. Ledger Entry No.", RecLCustLedgerEntry."Entry No.");
                                if BooLOpen then
                                    RecLDetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply)
                                else
                                    RecLDetailedCustLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                            until RecLCustLedgerEntry2.NEXT() = 0;
                        end;
                    end;
                until RecLDetailedCustLedgEntry.NEXT() = 0;
            end;
        end;

        if BooLOpen then begin
            RecLCustLedgerEntry2.SETRANGE("Customer No.", CodPCustomer);
            RecLCustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
            if not RecLCustLedgerEntry2.ISEMPTY then begin
                RecLCustLedgerEntry2.FINDSET();
                repeat
                    RecLCustLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", TxtLCodApply);
                    RecLCustLedgerEntry2.MODIFY();

                    FctUpdateApplyIdDetCustLedger(RecLCustLedgerEntry2."Entry No.", TxtLCodApply)
                until RecLCustLedgerEntry2.NEXT() = 0;
            end;

            RecLCustLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply);
        end;
    end;

    procedure FctApplyIDCustApplication(IntPIDApplication: Integer; CodPCustomer: Code[20])
    var
        RecLCustLedgerEntry: Record "Cust. Ledger Entry";
        RecLCustLedgerEntry2: Record "Cust. Ledger Entry";
        RecLDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        BooLOpen: Boolean;
        TxtLCodApply: Text[20];
    begin
        TxtLCodApply := '';
        RecLCustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        RecLCustLedgerEntry.SETRANGE("Customer No.", CodPCustomer);
        RecLCustLedgerEntry.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if RecLCustLedgerEntry.ISEMPTY then
            TxtLCodApply := FctGetNextApplyCode('')
        else begin
            RecLCustLedgerEntry.FINDLAST();
            TxtLCodApply := FctGetNextApplyCode(LOWERCASE(RecLCustLedgerEntry."BC6_Applies-to ID Code"))
        end;
        RecLCustLedgerEntry.RESET();

        BooLOpen := false;

        RecLDetailedCustLedgEntry.SETCURRENTKEY("Application No.", "Customer No.", "Entry Type");
        RecLDetailedCustLedgEntry.SETRANGE("Application No.", IntPIDApplication);
        RecLDetailedCustLedgEntry.SETRANGE("Customer No.", CodPCustomer);
        RecLDetailedCustLedgEntry.SETRANGE("Entry Type", RecLDetailedCustLedgEntry."Entry Type"::Application);
        if not RecLDetailedCustLedgEntry.ISEMPTY then begin
            RecLDetailedCustLedgEntry.FINDSET();
            repeat
                RecLCustLedgerEntry.GET(RecLDetailedCustLedgEntry."Cust. Ledger Entry No.");
                if RecLCustLedgerEntry.Open then
                    BooLOpen := true;

                if RecLCustLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                    RecLCustLedgerEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                    RecLCustLedgerEntry.MODIFY();
                    FctUpdateApplyIdDetCustLedger(RecLCustLedgerEntry."Entry No.", UPPERCASE(TxtLCodApply))
                end
                else begin
                    RecLCustLedgerEntry2.SETRANGE("Customer No.", CodPCustomer);
                    RecLCustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", RecLCustLedgerEntry."BC6_Applies-to ID Code");
                    if not RecLCustLedgerEntry2.ISEMPTY then begin
                        RecLCustLedgerEntry2.FINDSET();
                        repeat
                            RecLCustLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                            RecLCustLedgerEntry2.MODIFY();

                            FctUpdateApplyIdDetCustLedger(RecLCustLedgerEntry2."Entry No.", UPPERCASE(TxtLCodApply))
                        until RecLCustLedgerEntry2.NEXT() = 0;
                    end;
                end;
            until RecLDetailedCustLedgEntry.NEXT() = 0;

            if BooLOpen then begin
                RecLCustLedgerEntry2.SETRANGE("Customer No.", CodPCustomer);
                RecLCustLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                if not RecLCustLedgerEntry2.ISEMPTY then begin
                    RecLCustLedgerEntry2.FINDSET();
                    repeat
                        RecLCustLedgerEntry2."BC6_Applies-to ID Code" := TxtLCodApply;
                        RecLCustLedgerEntry2.MODIFY();

                        FctUpdateApplyIdDetCustLedger(RecLCustLedgerEntry2."Entry No.", TxtLCodApply)
                    until RecLCustLedgerEntry2.NEXT() = 0;
                end;

                RecLCustLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply);
            end;
        end;
    end;

    local procedure FctGetNextApplyCode(TxtPApplyCode: Text[10]) TxtRApplyCode: Text[10]
    var
        ChrLAlphaLetters: array[26] of Char;
        IntLi: Integer;
        IntLLetterInNumber: Integer;
        IntLy: Integer;
    begin
        ChrLAlphaLetters[1] := 'a';
        ChrLAlphaLetters[2] := 'b';
        ChrLAlphaLetters[3] := 'c';
        ChrLAlphaLetters[4] := 'd';
        ChrLAlphaLetters[5] := 'e';
        ChrLAlphaLetters[6] := 'f';
        ChrLAlphaLetters[7] := 'g';
        ChrLAlphaLetters[8] := 'h';
        ChrLAlphaLetters[9] := 'i';
        ChrLAlphaLetters[10] := 'j';
        ChrLAlphaLetters[11] := 'k';
        ChrLAlphaLetters[12] := 'l';
        ChrLAlphaLetters[13] := 'm';
        ChrLAlphaLetters[14] := 'n';
        ChrLAlphaLetters[15] := 'o';
        ChrLAlphaLetters[16] := 'p';
        ChrLAlphaLetters[17] := 'q';
        ChrLAlphaLetters[18] := 'r';
        ChrLAlphaLetters[19] := 's';
        ChrLAlphaLetters[20] := 't';
        ChrLAlphaLetters[21] := 'u';
        ChrLAlphaLetters[22] := 'v';
        ChrLAlphaLetters[23] := 'w';
        ChrLAlphaLetters[24] := 'x';
        ChrLAlphaLetters[25] := 'y';
        ChrLAlphaLetters[26] := 'z';


        TxtRApplyCode := '';
        if TxtPApplyCode <> '' then begin
            TxtRApplyCode := TxtPApplyCode;
            for IntLi := 1 to 5 do begin
                IntLLetterInNumber := FctFindPosiLetter(TxtPApplyCode[6 - IntLi], ChrLAlphaLetters);
                if IntLLetterInNumber < 26 then begin
                    TxtRApplyCode[6 - IntLi] := ChrLAlphaLetters[IntLLetterInNumber + 1];
                    exit(TxtRApplyCode);
                end
                else
                    TxtRApplyCode[6 - IntLi] := 'a';
            end;
        end
        else
            TxtRApplyCode := FORMAT(ChrLAlphaLetters[1]) + FORMAT(ChrLAlphaLetters[1]) + FORMAT(ChrLAlphaLetters[1])
                              + FORMAT(ChrLAlphaLetters[1]) + FORMAT(ChrLAlphaLetters[1]);

        if TxtRApplyCode = '' then
            ERROR(CstGLimitReached);
    end;

    local procedure FctFindPosiLetter(ChrPLetter: Char; ChrPAlphaLetters: array[26] of Char): Integer
    begin
        case ChrPLetter of
            ChrPAlphaLetters[1]:
                exit(1);
            ChrPAlphaLetters[2]:
                exit(2);
            ChrPAlphaLetters[3]:
                exit(3);
            ChrPAlphaLetters[4]:
                exit(4);
            ChrPAlphaLetters[5]:
                exit(5);
            ChrPAlphaLetters[6]:
                exit(6);
            ChrPAlphaLetters[7]:
                exit(7);
            ChrPAlphaLetters[8]:
                exit(8);
            ChrPAlphaLetters[9]:
                exit(9);
            ChrPAlphaLetters[10]:
                exit(10);
            ChrPAlphaLetters[11]:
                exit(11);
            ChrPAlphaLetters[12]:
                exit(12);
            ChrPAlphaLetters[13]:
                exit(13);
            ChrPAlphaLetters[14]:
                exit(14);
            ChrPAlphaLetters[15]:
                exit(15);
            ChrPAlphaLetters[16]:
                exit(16);
            ChrPAlphaLetters[17]:
                exit(17);
            ChrPAlphaLetters[18]:
                exit(18);
            ChrPAlphaLetters[19]:
                exit(19);
            ChrPAlphaLetters[20]:
                exit(20);
            ChrPAlphaLetters[21]:
                exit(21);
            ChrPAlphaLetters[22]:
                exit(22);
            ChrPAlphaLetters[23]:
                exit(23);
            ChrPAlphaLetters[24]:
                exit(24);
            ChrPAlphaLetters[25]:
                exit(25);
            ChrPAlphaLetters[26]:
                exit(26);
        end;
    end;


    procedure FctUnApplyIDCust(CodPCustomer: Code[20]; TxtPTxtApplyID: Text[10])
    var
        RecLCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if TxtPTxtApplyID = UPPERCASE(TxtPTxtApplyID) then begin
            RecLCustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
            RecLCustLedgerEntry.SETRANGE("Customer No.", CodPCustomer);
            RecLCustLedgerEntry.SETRANGE("BC6_Applies-to ID Code", TxtPTxtApplyID);
            if not RecLCustLedgerEntry.ISEMPTY then begin
                RecLCustLedgerEntry.FINDSET();
                repeat
                    RecLCustLedgerEntry.VALIDATE("BC6_Applies-to ID Code", LOWERCASE(TxtPTxtApplyID));
                    RecLCustLedgerEntry.MODIFY();

                    FctUpdateApplyIdDetCustLedger(RecLCustLedgerEntry."Entry No.", LOWERCASE(TxtPTxtApplyID))
                until RecLCustLedgerEntry.NEXT() = 0;
            end;
        end;
    end;


    procedure FctUpdateApplyIdDetCustLedger(IntPCustLedgerEntry: Integer; TxtPTxtApplyID: Text[10])
    var
        RecLDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        RecLDetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Posting Date");
        RecLDetailedCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", IntPCustLedgerEntry);
        RecLDetailedCustLedgEntry.MODIFYALL("BC6_Applies-to ID Code", TxtPTxtApplyID);
    end;


    procedure FctApplyIDVend(IntPIDTransaction: Integer; CodPVendor: Code[20])
    var
        RecLVendLedgerEntry: Record "Vendor Ledger Entry";
        RecLVendLedgerEntry2: Record "Vendor Ledger Entry";
        RecLVendLedgerEntry3: Record "Vendor Ledger Entry";
        RecLVendLedgerEntry4: Record "Vendor Ledger Entry";
        RecLDetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        RecLDetailedVendLedgEntry2: Record "Detailed Vendor Ledg. Entry";
        BooLOpen: Boolean;
        TxtLCodApply: Text[20];
    begin
        TxtLCodApply := '';
        RecLVendLedgerEntry4.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
        RecLVendLedgerEntry4.SETRANGE("Vendor No.", CodPVendor);
        RecLVendLedgerEntry4.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if RecLVendLedgerEntry4.ISEMPTY then
            TxtLCodApply := FctGetNextApplyCode('')
        else begin
            RecLVendLedgerEntry4.FINDLAST();
            TxtLCodApply := FctGetNextApplyCode(LOWERCASE(RecLVendLedgerEntry4."BC6_Applies-to ID Code"))
        end;
        BooLOpen := false;

        RecLVendLedgerEntry2.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
        RecLDetailedVendLedgEntry2.SETCURRENTKEY("Vendor Ledger Entry No.", "Posting Date");

        if not RecGDetCVLedgerEntryBuffTMP.ISEMPTY then begin
            RecGDetCVLedgerEntryBuffTMP.FINDSET();
            repeat
                RecLDetailedVendLedgEntry.GET(RecGDetCVLedgerEntryBuffTMP."Entry No.");
                RecLVendLedgerEntry.GET(RecLDetailedVendLedgEntry."Vendor Ledger Entry No.");
                if RecLVendLedgerEntry.Open then
                    BooLOpen := true;
                if RecLVendLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                    if BooLOpen then begin
                        RecLDetailedVendLedgEntry."BC6_Applies-to ID Code" := TxtLCodApply;
                        RecLVendLedgerEntry."BC6_Applies-to ID Code" := TxtLCodApply;
                    end
                    else begin
                        RecLDetailedVendLedgEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                        RecLVendLedgerEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                    end;
                    RecLVendLedgerEntry.MODIFY();
                    RecLDetailedVendLedgEntry.MODIFY();
                end
                else begin
                    RecLVendLedgerEntry2.SETRANGE("Vendor No.", CodPVendor);
                    RecLVendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", RecLVendLedgerEntry."BC6_Applies-to ID Code");
                    if not RecLVendLedgerEntry2.ISEMPTY then begin
                        RecLVendLedgerEntry2.FINDSET();
                        repeat
                            RecLVendLedgerEntry3.GET(RecLVendLedgerEntry2."Entry No.");
                            if BooLOpen then
                                RecLVendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtLCodApply)
                            else
                                RecLVendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                            RecLVendLedgerEntry3.MODIFY();

                            RecLDetailedVendLedgEntry2.SETRANGE("Vendor Ledger Entry No.", RecLVendLedgerEntry."Entry No.");
                            if BooLOpen then
                                RecLDetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply)
                            else
                                RecLDetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                        until RecLVendLedgerEntry2.NEXT() = 0;
                    end;
                end;
            until RecGDetCVLedgerEntryBuffTMP.NEXT() = 0;
        end
        else begin
            RecLDetailedVendLedgEntry.SETCURRENTKEY("Transaction No.", "Vendor No.", "Entry Type");
            RecLDetailedVendLedgEntry.SETRANGE("Transaction No.", IntPIDTransaction);
            RecLDetailedVendLedgEntry.SETRANGE("Vendor No.", CodPVendor);
            RecLDetailedVendLedgEntry.SETRANGE("Entry Type", RecLDetailedVendLedgEntry."Entry Type"::Application);
            if not RecLDetailedVendLedgEntry.ISEMPTY then begin
                RecLDetailedVendLedgEntry.FINDSET();
                repeat
                    RecLVendLedgerEntry.GET(RecLDetailedVendLedgEntry."Vendor Ledger Entry No.");
                    if RecLVendLedgerEntry.Open then
                        BooLOpen := true;

                    if RecLVendLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                        if BooLOpen then
                            RecLVendLedgerEntry."BC6_Applies-to ID Code" := TxtLCodApply
                        else
                            RecLVendLedgerEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                        RecLVendLedgerEntry.MODIFY();

                        RecLDetailedVendLedgEntry2.SETRANGE("Vendor Ledger Entry No.", RecLVendLedgerEntry."Entry No.");
                        if BooLOpen then
                            RecLDetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply)
                        else
                            RecLDetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                    end
                    else begin
                        RecLVendLedgerEntry2.SETRANGE("Vendor No.", CodPVendor);
                        RecLVendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", RecLVendLedgerEntry."BC6_Applies-to ID Code");
                        if not RecLVendLedgerEntry2.ISEMPTY then begin
                            RecLVendLedgerEntry2.FINDSET();
                            repeat
                                RecLVendLedgerEntry3.GET(RecLVendLedgerEntry2."Entry No.");
                                if BooLOpen then
                                    RecLVendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", TxtLCodApply)
                                else
                                    RecLVendLedgerEntry3.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                                RecLVendLedgerEntry3.MODIFY();

                                RecLDetailedVendLedgEntry2.SETRANGE("Vendor Ledger Entry No.", RecLVendLedgerEntry."Entry No.");
                                if BooLOpen then
                                    RecLDetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply)
                                else
                                    RecLDetailedVendLedgEntry2.MODIFYALL("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                            until RecLVendLedgerEntry2.NEXT() = 0;
                        end;
                    end;
                until RecLDetailedVendLedgEntry.NEXT() = 0;
            end;
        end;

        if BooLOpen then begin
            RecLVendLedgerEntry2.SETRANGE("Vendor No.", CodPVendor);
            RecLVendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
            if not RecLVendLedgerEntry2.ISEMPTY then begin
                RecLVendLedgerEntry2.FINDSET();
                repeat
                    RecLVendLedgerEntry2."BC6_Applies-to ID Code" := TxtLCodApply;
                    RecLVendLedgerEntry2.MODIFY();

                    FctUpdateApplyIdDetVendLedger(RecLVendLedgerEntry2."Entry No.", TxtLCodApply)
                until RecLVendLedgerEntry2.NEXT() = 0;
            end;

            RecLVendLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply);
        end;
    end;


    procedure FctApplyIDVendApplication(IntPIDApplication: Integer; CodPVendor: Code[20])
    var
        RecLVendLedgerEntry: Record "Vendor Ledger Entry";
        RecLVendLedgerEntry2: Record "Vendor Ledger Entry";
        RecLDetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        BooLOpen: Boolean;
        TxtLCodApply: Text[20];
    begin
        TxtLCodApply := '';
        RecLVendLedgerEntry.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
        RecLVendLedgerEntry.SETRANGE("Vendor No.", CodPVendor);
        RecLVendLedgerEntry.SETFILTER("BC6_Applies-to ID Code", '<>%1', '');
        if RecLVendLedgerEntry.ISEMPTY then
            TxtLCodApply := FctGetNextApplyCode('')
        else begin
            RecLVendLedgerEntry.FINDLAST();
            TxtLCodApply := FctGetNextApplyCode(LOWERCASE(RecLVendLedgerEntry."BC6_Applies-to ID Code"))
        end;
        RecLVendLedgerEntry.RESET();

        BooLOpen := false;

        RecLDetailedVendLedgEntry.SETCURRENTKEY("Application No.", "Vendor No.", "Entry Type");
        RecLDetailedVendLedgEntry.SETRANGE("Application No.", IntPIDApplication);
        RecLDetailedVendLedgEntry.SETRANGE("Vendor No.", CodPVendor);
        RecLDetailedVendLedgEntry.SETRANGE("Entry Type", RecLDetailedVendLedgEntry."Entry Type"::Application);
        if not RecLDetailedVendLedgEntry.ISEMPTY then begin
            RecLDetailedVendLedgEntry.FINDSET();
            repeat
                RecLVendLedgerEntry.GET(RecLDetailedVendLedgEntry."Vendor Ledger Entry No.");
                if RecLVendLedgerEntry.Open then
                    BooLOpen := true;

                if RecLVendLedgerEntry."BC6_Applies-to ID Code" = '' then begin
                    RecLVendLedgerEntry."BC6_Applies-to ID Code" := UPPERCASE(TxtLCodApply);
                    RecLVendLedgerEntry.MODIFY();
                    FctUpdateApplyIdDetVendLedger(RecLVendLedgerEntry."Entry No.", UPPERCASE(TxtLCodApply))
                end
                else begin
                    RecLVendLedgerEntry2.SETRANGE("Vendor No.", CodPVendor);
                    RecLVendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", RecLVendLedgerEntry."BC6_Applies-to ID Code");
                    if not RecLVendLedgerEntry2.ISEMPTY then begin
                        RecLVendLedgerEntry2.FINDSET();
                        repeat
                            RecLVendLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                            RecLVendLedgerEntry2.MODIFY();

                            FctUpdateApplyIdDetVendLedger(RecLVendLedgerEntry2."Entry No.", UPPERCASE(TxtLCodApply))
                        until RecLVendLedgerEntry2.NEXT() = 0;
                    end;
                end;
            until RecLDetailedVendLedgEntry.NEXT() = 0;

            if BooLOpen then begin
                RecLVendLedgerEntry2.SETRANGE("Vendor No.", CodPVendor);
                RecLVendLedgerEntry2.SETRANGE("BC6_Applies-to ID Code", UPPERCASE(TxtLCodApply));
                if not RecLVendLedgerEntry2.ISEMPTY then begin
                    RecLVendLedgerEntry2.FINDSET();
                    repeat
                        RecLVendLedgerEntry2.VALIDATE("BC6_Applies-to ID Code", TxtLCodApply);
                        RecLVendLedgerEntry2.MODIFY();

                        FctUpdateApplyIdDetVendLedger(RecLVendLedgerEntry2."Entry No.", TxtLCodApply)
                    until RecLVendLedgerEntry2.NEXT() = 0;
                end;

                RecLVendLedgerEntry2.MODIFYALL("BC6_Applies-to ID Code", TxtLCodApply);
            end;
        end;
    end;


    procedure FctUnApplyIDVend(CodPVendor: Code[20]; TxtPTxtApplyID: Text[10])
    var
        RecLVendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if TxtPTxtApplyID = UPPERCASE(TxtPTxtApplyID) then begin
            RecLVendLedgerEntry.SETCURRENTKEY("Vendor No.", "BC6_Applies-to ID Code");
            RecLVendLedgerEntry.SETRANGE("Vendor No.", CodPVendor);
            RecLVendLedgerEntry.SETRANGE("BC6_Applies-to ID Code", TxtPTxtApplyID);
            if not RecLVendLedgerEntry.ISEMPTY then begin
                RecLVendLedgerEntry.FINDSET();
                repeat
                    RecLVendLedgerEntry.VALIDATE("BC6_Applies-to ID Code", LOWERCASE(TxtPTxtApplyID));
                    RecLVendLedgerEntry.MODIFY();

                    FctUpdateApplyIdDetVendLedger(RecLVendLedgerEntry."Entry No.", LOWERCASE(TxtPTxtApplyID))
                until RecLVendLedgerEntry.NEXT() = 0;
            end;
        end;
    end;


    procedure FctUpdateApplyIdDetVendLedger(IntPVendLedgerEntry: Integer; TxtPTxtApplyID: Text[10])
    var
        RecLDetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        RecLDetailedVendLedgEntry.SETCURRENTKEY("Vendor Ledger Entry No.", "Posting Date");
        RecLDetailedVendLedgEntry.SETRANGE("Vendor Ledger Entry No.", IntPVendLedgerEntry);
        RecLDetailedVendLedgEntry.MODIFYALL("BC6_Applies-to ID Code", TxtPTxtApplyID);
    end;


    procedure FctUnApplyIDCustFinal(CodPCustomer: Code[20]; TxtPTxtApplyID: Text[10])
    var
        RecLCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        RecLCustLedgerEntry.SETCURRENTKEY("Customer No.", "BC6_Applies-to ID Code");
        RecLCustLedgerEntry.SETRANGE("Customer No.", CodPCustomer);
        RecLCustLedgerEntry.SETRANGE("BC6_Applies-to ID Code", TxtPTxtApplyID);
        if not RecLCustLedgerEntry.ISEMPTY then begin
            RecLCustLedgerEntry.FINDSET();
            repeat
                FctUpdateApplyIdDetCustLedger(RecLCustLedgerEntry."Entry No.", '')
            until RecLCustLedgerEntry.NEXT() = 0;
        end;
    end;


    procedure FctUpdApplyIdDetCustLdgFinal(IntPCustLedgerEntry: Integer; TxtPTxtApplyID: Text[10])
    var
        RecLDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        RecLDetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Posting Date");
        RecLDetailedCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", IntPCustLedgerEntry);
        RecLDetailedCustLedgEntry.MODIFYALL("BC6_Applies-to ID Code", TxtPTxtApplyID);
    end;


    procedure FctSetCVLedgEntryBuff(var RecPDetCVLedgerEntryBuff: Record "Detailed CV Ledg. Entry Buffer"; IntPOffset: Integer)
    begin
        RecGDetCVLedgerEntryBuffTMP.DELETEALL();
        if not RecPDetCVLedgerEntryBuff.ISEMPTY then begin
            RecPDetCVLedgerEntryBuff.FINDSET();
            repeat
                if RecPDetCVLedgerEntryBuff."Entry Type" = RecPDetCVLedgerEntryBuff."Entry Type"::Application then begin
                    RecGDetCVLedgerEntryBuffTMP.INIT();
                    RecGDetCVLedgerEntryBuffTMP.TRANSFERFIELDS(RecPDetCVLedgerEntryBuff);
                    RecGDetCVLedgerEntryBuffTMP."Entry No." := RecPDetCVLedgerEntryBuff."Entry No." + IntPOffset;
                    RecGDetCVLedgerEntryBuffTMP.INSERT();
                end;
            until RecPDetCVLedgerEntryBuff.NEXT() = 0;
        end;
    end;
}


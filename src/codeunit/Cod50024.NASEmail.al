codeunit 50024 "BC6_NAS Email"
{

    Permissions = TableData 112 = rm,
                  TableData 114 = rm;
    TableNo = 472;

    trigger OnRun()
    var
        ParameterArray: array[5] of Text;
    begin
        ParameterStringToArray(Rec."Parameter String", ParameterArray);
        //>>INC-04533-N2L0S9
        CASE UPPERCASE(ParameterArray[1]) OF
            'INVOICE':
                OnAfterPostSalesDoc(ParameterArray[2]);
            'CREDITMEMO':
                OnAfterPostCreditMemo(ParameterArray[2]);
            //>>REQ-02761-L6P2W4
            'PURGE':
                PurgeLog();
        //<<REQ-02761-L6P2W4
        END;
        //<<INC-04533-N2L0S9
    end;


    procedure OnAfterPostSalesDoc(StatusFilter: Text)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
    begin
        //>>INC-04533-N2L0S9
        SalesInvoiceHeader.SETRANGE("BC6_Send Status", GetStatus(CopyStr(StatusFilter, 1, 10)));
        //<<INC-04533-N2L0S9
        //>>CAS-250650-K8W3K8 ONLY for UAT
        //SETFILTER("Sell-to Customer No.",'%1|%2','CLT-0021310','CLT-0021299');
        //<<CAS-250650-K8W3K8
        //>>REQ-02588-N1D4R9 Only for UAT environment
        SalesInvoiceHeader.SETFILTER("Sell-to Customer No.", '%1|%2', 'CLT-0021862', 'CLT-0021861');
        //<<REQ-02588-N1D4R9
        IF NOT SalesInvoiceHeader.ISEMPTY THEN BEGIN
            SalesInvoiceHeader.FINDSET();
            REPEAT
                COMMIT();
                GS1DMSManagment.Send(SalesInvoiceHeader.RECORDID, '');
            UNTIL SalesInvoiceHeader.NEXT() = 0;
        END;
    end;


    procedure OnAfterPostCreditMemo(StatusFilter: Text)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GS1DMSManagment: Codeunit "BC6_GS1 : DMS Managment";
    begin
        //>>INC-04533-N2L0S9
        SalesCrMemoHeader.SETRANGE("BC6_Send Status", GetStatus(CopyStr(StatusFilter, 1, 10)));
        //<<INC-04533-N2L0S9
        //>>CAS-250650-K8W3K8
        //SETFILTER("Sell-to Customer No.",'%1|%2','CLT-0021310','CLT-0021299');
        //<<CAS-250650-K8W3K8
        //>>REQ-02588-N1D4R9 Only for UAT environment
        SalesCrMemoHeader.SETFILTER("Sell-to Customer No.", '%1|%2', 'CLT-0021862', 'CLT-0021861');
        //<<REQ-02588-N1D4R9
        IF NOT SalesCrMemoHeader.ISEMPTY THEN BEGIN
            SalesCrMemoHeader.FINDSET();
            REPEAT
                COMMIT();
                GS1DMSManagment.Send(SalesCrMemoHeader.RECORDID, '');
            UNTIL SalesCrMemoHeader.NEXT() = 0;
        END;
    end;

    local procedure ParameterStringToArray(ParameterString: Text; var ParameterArray: array[5] of Text)
    var
        I: Integer;
    begin
        CLEAR(ParameterArray);
        FOR I := 1 TO STRLEN(ParameterString) - STRLEN(DELCHR(ParameterString, '=', ',')) + 1 DO
            ParameterArray[I] := SELECTSTR(I, ParameterString);
    end;

    local procedure GetStatus(StatusFilter: Code[10]): Integer
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        //>>REQ-02761-L6P2W4
        IF StatusFilter = 'NOTSENT' THEN
            EXIT(SalesInvoiceHeader."BC6_Send Status"::"Not Sent".AsInteger());

        EXIT(SalesInvoiceHeader."BC6_Send Status"::" ".AsInteger());
        //<<REQ-02761-L6P2W4
    end;


    procedure PurgeLog()
    var
        RecLEmailLog: Record "BC6_Email Log";
        NewDate: Date;
        NewDateTime: DateTime;
    begin
        //>>REQ-02761-L6P2W4
        NewDate := CALCDATE('<-7D>', TODAY);
        NewDateTime := CREATEDATETIME(NewDate, 0T);
        RecLEmailLog.SETFILTER(RecLEmailLog."Create Date-Time", '<%1', NewDateTime);
        RecLEmailLog.DELETEALL();
        //<<REQ-02761-L6P2W4
    end;
}


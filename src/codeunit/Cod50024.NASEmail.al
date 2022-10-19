codeunit 50024 "BC6_NAS Email"
{
    Permissions = tabledata 112 = rm,
                  tabledata 114 = rm;
    TableNo = 472;


    trigger OnRun()
    var
        ParameterArray: array[5] of Text;
    begin
        ParameterStringToArray(Rec."Parameter String", ParameterArray);
        //>>INC-04533-N2L0S9
        case UPPERCASE(ParameterArray[1]) of
            'INVOICE':
                OnAfterPostSalesDoc(ParameterArray[2]);
            'CREDITMEMO':
                OnAfterPostCreditMemo(ParameterArray[2]);
            //>>REQ-02761-L6P2W4
            'PURGE':
                PurgeLog();
        //<<REQ-02761-L6P2W4
        end;
        //<<INC-04533-N2L0S9
    end;


    procedure OnAfterPostSalesDoc(StatusFilter: Text)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
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
        if not SalesInvoiceHeader.ISEMPTY then begin
            SalesInvoiceHeader.FINDSET();
            repeat
                COMMIT();
                GS1DMSManagment.Send(SalesInvoiceHeader.RECORDID, '');
            until SalesInvoiceHeader.NEXT() = 0;
        end;
    end;


    procedure OnAfterPostCreditMemo(StatusFilter: Text)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
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
        if not SalesCrMemoHeader.ISEMPTY then begin
            SalesCrMemoHeader.FINDSET();
            repeat
                COMMIT();
                GS1DMSManagment.Send(SalesCrMemoHeader.RECORDID, '');
            until SalesCrMemoHeader.NEXT() = 0;
        end;
    end;

    local procedure ParameterStringToArray(ParameterString: Text; var ParameterArray: array[5] of Text)

    var

        I: Integer;

    begin

        CLEAR(ParameterArray);

        for I := 1 to STRLEN(ParameterString) - STRLEN(DELCHR(ParameterString, '=', ',')) + 1 do

            ParameterArray[I] := SELECTSTR(I, ParameterString);

    end;


    local procedure GetStatus(StatusFilter: Code[10]): Integer
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        //>>REQ-02761-L6P2W4
        if StatusFilter = 'NOTSENT' then
            exit(SalesInvoiceHeader."BC6_Send Status"::"Not Sent".AsInteger());

        exit(SalesInvoiceHeader."BC6_Send Status"::" ".AsInteger());
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


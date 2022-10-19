codeunit 50024 "BC6_NAS Email"
{
    Permissions = tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Cr.Memo Header" = rm;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ParameterArray: array[5] of Text;
    begin
        ParameterStringToArray(Rec."Parameter String", ParameterArray);
        case UPPERCASE(ParameterArray[1]) of
            'INVOICE':
                OnAfterPostSalesDoc(ParameterArray[2]);
            'CREDITMEMO':
                OnAfterPostCreditMemo(ParameterArray[2]);
            'PURGE':
                PurgeLog();
        end;
    end;

    procedure OnAfterPostSalesDoc(StatusFilter: Text)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GS1DMSManagment: codeunit "BC6_GS1 : DMS Managment";
    begin
        SalesInvoiceHeader.SETRANGE("BC6_Send Status", GetStatus(CopyStr(StatusFilter, 1, 10)));
        SalesInvoiceHeader.SETFILTER("Sell-to Customer No.", '%1|%2', 'CLT-0021862', 'CLT-0021861');
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
        SalesCrMemoHeader.SETRANGE("BC6_Send Status", GetStatus(CopyStr(StatusFilter, 1, 10)));
        SalesCrMemoHeader.SETFILTER("Sell-to Customer No.", '%1|%2', 'CLT-0021862', 'CLT-0021861');
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
        if StatusFilter = 'NOTSENT' then
            exit(SalesInvoiceHeader."BC6_Send Status"::"Not Sent".AsInteger());

        exit(SalesInvoiceHeader."BC6_Send Status"::" ".AsInteger());
    end;

    procedure PurgeLog()
    var
        RecLEmailLog: Record "BC6_Email Log";
        NewDate: Date;
        NewDateTime: DateTime;
    begin
        NewDate := CALCDATE('<-7D>', TODAY);
        NewDateTime := CREATEDATETIME(NewDate, 0T);
        RecLEmailLog.SETFILTER(RecLEmailLog."Create Date-Time", '<%1', NewDateTime);
        RecLEmailLog.DELETEALL();
    end;
}

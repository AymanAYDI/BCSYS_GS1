tableextension 50004 "BC6_Customer" extends Customer
{
    fields
    {
        field(50017; "BC6_Company ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'GS110.00';
        }
        field(8034656; "BC6_SIREN/SIRET"; Text[50])
        {
            Caption = 'SIREN/SIRET';
            DataClassification = ToBeClassified;
        }

    }
    procedure GetContact(): Code[20]
    var
        RecLContBusRel: Record "Contact Business Relation";
    begin
        //>>DSM-Distribution.TFS2543
        if "No." <> '' then begin
            RecLContBusRel.SETCURRENTKEY("Link to Table", "No.");
            RecLContBusRel.SETRANGE("Link to Table", RecLContBusRel."Link to Table"::Customer);
            RecLContBusRel.SETRANGE("No.", "No.");
            if not RecLContBusRel.ISEMPTY then begin
                RecLContBusRel.FINDFIRST();
                exit(RecLContBusRel."Contact No.");
            end;
        end;

        exit('');
        //<<DSM-Distribution.TFS2543
    end;

    procedure FctGetContact(CodPCustomerNo: Code[20]) RetContactNo: Code[20]
    var
        RecLContBusRel: Record "Contact Business Relation";
    begin
        if CodPCustomerNo <> '' then begin
            RecLContBusRel.SETCURRENTKEY("Link to Table", "No.");
            RecLContBusRel.SETRANGE("Link to Table", RecLContBusRel."Link to Table"::Customer);
            RecLContBusRel.SETRANGE("No.", CodPCustomerNo);
            if not RecLContBusRel.ISEMPTY then begin
                if RecLContBusRel.FINDFIRST() then
                    RetContactNo := RecLContBusRel."Contact No.";
                exit(RecLContBusRel."Contact No.");
            end;
        end;
        exit('');
    end;

}

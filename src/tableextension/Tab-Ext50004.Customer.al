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
        IF "No." <> '' THEN BEGIN
            RecLContBusRel.SETCURRENTKEY("Link to Table", "No.");
            RecLContBusRel.SETRANGE("Link to Table", RecLContBusRel."Link to Table"::Customer);
            RecLContBusRel.SETRANGE("No.", "No.");
            IF NOT RecLContBusRel.ISEMPTY THEN BEGIN
                RecLContBusRel.FINDFIRST();
                EXIT(RecLContBusRel."Contact No.");
            END;
        END;

        EXIT('');
        //<<DSM-Distribution.TFS2543
    end;

    procedure FctGetContact(CodPCustomerNo: Code[20]) RetContactNo: Code[20]
    var
        RecLContBusRel: Record "Contact Business Relation";
    begin
        IF CodPCustomerNo <> '' THEN BEGIN
            RecLContBusRel.SETCURRENTKEY("Link to Table", "No.");
            RecLContBusRel.SETRANGE("Link to Table", RecLContBusRel."Link to Table"::Customer);
            RecLContBusRel.SETRANGE("No.", CodPCustomerNo);
            IF NOT RecLContBusRel.ISEMPTY THEN BEGIN
                IF RecLContBusRel.FINDFIRST() THEN
                    RetContactNo := RecLContBusRel."Contact No.";
                EXIT(RecLContBusRel."Contact No.");
            END;
        END;
        EXIT('');
    end;

}

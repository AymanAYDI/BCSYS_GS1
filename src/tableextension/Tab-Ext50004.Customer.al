tableextension 50004 "BC6_Customer" extends Customer
{
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
}

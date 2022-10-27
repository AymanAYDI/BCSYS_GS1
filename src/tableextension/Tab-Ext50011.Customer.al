tableextension 50011 "BC6_Customer" extends Customer
{
    fields
    {
        field(50017; "BC6_Company ID"; Code[20])
        {
            Caption = 'Company ID', Comment = 'FRA="ID entreprise"';
            DataClassification = CustomerContent;
        }
        field(50004; "BC6_SIREN/SIRET"; Text[50])
        {
            Caption = 'SIREN/SIRET', comment = 'FRA="SIREN/SIRET"';
            DataClassification = CustomerContent;
        }
    }
    procedure GetContact(): Code[20]
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        if "No." <> '' then begin
            ContBusRel.SETCURRENTKEY("Link to Table", "No.");
            ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
            ContBusRel.SETRANGE("No.", "No.");
            if not ContBusRel.ISEMPTY then begin
                ContBusRel.FINDFIRST();
                exit(ContBusRel."Contact No.");
            end;
        end;
        exit('');
    end;
}

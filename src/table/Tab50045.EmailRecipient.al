table 50045 "BC6_Email Recipient"
{
    Caption = 'Email Recipient';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Email Setup Code"; Code[20])
        {
            Caption = 'Email Setup Code', Comment = 'FRA="Code paramètre email"';
            DataClassification = CustomerContent;
            TableRelation = "BC6_Email Model";
        }
        field(2; "Email Type"; Enum "Email Type")
        {
            Caption = 'Email Type';
            DataClassification = CustomerContent;
        }
        field(3; "Recipient Type"; Enum "Recipient Type")
        {
            Caption = 'Recipient Type';
            DataClassification = CustomerContent;
        }
        field(4; Email; Text[80])
        {
            Caption = 'Email', Comment = 'FRA="Mél"';
            DataClassification = CustomerContent;
        }
        field(5; "Recipient Type Code"; Code[10])
        {
            Caption = 'Recipient Type Code', Comment = 'FRA="Code type destinataire"';
            DataClassification = CustomerContent;
            TableRelation = IF ("Recipient Type" = CONST(Contact)) "Organizational Level".Code;
        }
    }
    keys
    {
        key(PK; "Email Setup Code", "Email Type", "Recipient Type", Email, "Recipient Type Code")
        {
            Clustered = true;
        }
    }
}

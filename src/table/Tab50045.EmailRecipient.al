table 50045 "BC6_Email Recipient"
{
    Caption = 'Email Recipient', Comment = 'FRA="Destinataire du courriel"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Email Setup Code"; Code[20])
        {
            Caption = 'Email Setup Code', Comment = 'FRA="Code paramètre email"';
            DataClassification = CustomerContent;
            TableRelation = "BC6_Email Model";
        }
        field(2; "Email Type"; enum "BC6_Email Type")
        {
            Caption = 'Email Type', Comment = 'FRA="Type email"';
            DataClassification = CustomerContent;
        }
        field(3; "Recipient Type"; enum "BC6_Recipient Type")
        {
            Caption = 'Recipient Type', Comment = 'FRA="Type destinataire"';
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
            TableRelation = if ("Recipient Type" = const(Contact)) "Organizational Level".Code;
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

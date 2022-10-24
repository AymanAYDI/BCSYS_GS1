table 50031 "BC6_Email Attachment"
{
    Caption = 'Email Attachment', Comment = 'FRA="Pièce jointe email"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Email Setup Code"; Code[20])
        {
            Caption = 'Email Setup Code', Comment = 'FRA="Code paramètre email"';
            DataClassification = CustomerContent;
            TableRelation = "BC6_Email Model";
        }
        field(2; "Attachment Type Code"; Code[20])
        {
            Caption = 'Attachment Type Code', Comment = 'FRA="Code type pièce jointe"';
            DataClassification = CustomerContent;
            TableRelation = "BC6_Email Attachment Type";
        }
        field(3; "Attachment Description"; Text[50])
        {
            CalcFormula = lookup("BC6_Email Attachment Type".Description where(Code = field("Attachment Type Code")));
            Caption = 'Attachment Description', Comment = 'FRA="Désignation pièce jointe"';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; "Email Setup Code", "Attachment Type Code")
        {
            Clustered = true;
        }
    }
}

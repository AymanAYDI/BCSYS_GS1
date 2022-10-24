table 50032 "BC6_Email Attachment Type"
{
    Caption = 'Email Attachment Type', Comment = 'FRA="Type pièce jointe email"';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code', Comment = 'FRA="Code"';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description', Comment = 'FRA="Désignation"';
            DataClassification = CustomerContent;
        }
        field(3; "WebApi Type"; Text[50])
        {
            Caption = 'WebApi Type', Comment = 'FRA="Type WebApi"';
            DataClassification = CustomerContent;
        }
        field(4; "WebApi Sub Type"; Text[50])
        {
            Caption = 'WebApi Sub Type', Comment = 'FRA="Sous Type WebApi"';
            DataClassification = CustomerContent;
        }
        field(5; "Output Format"; enum "BC6_Output Format.Enum")
        {
            Caption = 'Output Format', Comment = 'FRA="Format de sortie"';
            DataClassification = CustomerContent;
        }
        field(6; "File Path"; Text[250])
        {
            Caption = 'File Path', Comment = 'FRA="Chemin du fichier"';
            DataClassification = CustomerContent;
        }
        field(7; "File Naming"; enum "BC6_File Naming")
        {
            Caption = 'File Naming', Comment = 'FRA="Nommage du fichier"';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}

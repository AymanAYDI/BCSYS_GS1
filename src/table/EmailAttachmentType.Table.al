table 50032 "BC6_Email Attachment Type"
{
    Caption = 'Email Attachment Type';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "WebApi Type"; Text[50])
        {
            Caption = 'WebApi Type';
            DataClassification = CustomerContent;
        }
        field(4; "WebApi Sub Type"; Text[50])
        {
            Caption = 'WebApi Sub Type';
            DataClassification = CustomerContent;
        }
        field(5; "Output Format"; Enum "Output Format.Enum")
        {
            Caption = 'Output Format';
            DataClassification = CustomerContent;
        }
        field(6; "File Path"; Text[250])
        {
            Caption = 'File Path';
            DataClassification = CustomerContent;
        }
        field(7; "File Naming"; Enum "File Naming")
        {
            Caption = 'File Naming';
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

table 50030 "BC6_Email Log"
{
    Caption = 'Email Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Email Model Code"; Code[20])
        {
            Caption = 'Email Model Code';
            DataClassification = CustomerContent;
            TableRelation = "BC6_Email Model";
        }
        field(3; "Record Identifier"; RecordId)
        {
            Caption = 'Record Identifier';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Search Record ID"; Code[100])
        {
            Caption = 'Search Record ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Message Status"; Enum "Message Status.Enum")
        {
            Caption = 'Message Status';
            DataClassification = CustomerContent;
        }
        field(6; Message; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(7; "Create Date-Time"; DateTime)
        {
            Caption = 'Create Date-Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Created by User ID"; Code[50])
        {
            Caption = 'Created by User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

table 50100 "BC6_GS1 Setup"
{
    Caption = 'GS1 Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;

        }
        field(50520; "YOOZ Journ. Temp. Name"; Code[10])
        {
            Caption = 'YOOZ Journ. Temp. Name';
            DataClassification = ToBeClassified;
        }
        field(50521; "YOOZ Journ. Batch Name"; Code[10])
        {
            Caption = 'YOOZ Journ. Batch Name';
            DataClassification = ToBeClassified;

        }
        field(50522; "YOOZ Source Code"; Code[10])
        {
            Caption = 'YOOZ Source Code';
            DataClassification = ToBeClassified;


        }
        field(50523; "YOOZ File Import"; Text[250])
        {
            Caption = 'YOOZ File Import';
            DataClassification = ToBeClassified;


        }
        field(50524; "YOOZ File Archive"; Text[250])
        {
            Caption = 'YOOZ File Archive';
            DataClassification = ToBeClassified;
            Editable = true;

        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}

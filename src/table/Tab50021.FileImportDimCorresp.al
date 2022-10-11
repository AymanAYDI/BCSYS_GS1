table 50021 "BC6_File Import Dim. Corresp."
{
    Caption = 'File Import Dimension Corresp.', Comment = 'FRA="Corresp. analytique import fichier"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code', Comment = 'FRA="Code axe"';
            NotBlank = true;
            TableRelation = Dimension;
            DataClassification = CustomerContent;
        }
        field(2; "NAV Value Code"; Code[20])
        {
            Caption = 'NAV Value Code', Comment = 'FRA="Code section NAV"';
            NotBlank = true;
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("Dimension Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(3; "File Value Code"; Code[20])
        {
            Caption = 'File Value Code', Comment = 'FRA="Code section fichier"';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(4; "Import Type"; enum "BC6_ImportTypeNDF/Paie")
        {
            Caption = 'Import Type', Comment = 'FRA="Type d''import"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Dimension Code", "NAV Value Code", "File Value Code", "Import Type")
        {
            Clustered = true;
        }
        key(Key2; "Import Type", "Dimension Code", "File Value Code")
        {
        }
    }
}
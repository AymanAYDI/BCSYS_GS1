//TODO: used in XMLport 50000
table 50021 "File Import Dimension Corresp."
{
    Caption = 'File Import Dimension Corresp.';

    fields
    {
        field(1; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            NotBlank = true;
            TableRelation = Dimension;
        }
        field(2; "NAV Value Code"; Code[20])
        {
            Caption = 'NAV Value Code';
            NotBlank = true;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Dimension Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(3; "File Value Code"; Code[20])
        {
            Caption = 'File Value Code';
            NotBlank = true;
        }
        field(4; "Import Type"; Option)
        {
            Caption = 'Type d''import';
            OptionCaption = 'Expense,Payroll';
            OptionMembers = Expense,Payroll;
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

    fieldgroups
    {
    }
}


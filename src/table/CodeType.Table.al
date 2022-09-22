table 50014 "BC6_Code Type"
{
    Caption = 'Code Type';
    // LookupPageID = 50023; TODO

    fields
    {
        field(1; "Code Type ID"; Integer)
        {
            Caption = 'Code Type ID';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "Product Count"; Option)
        {
            Caption = 'Product Count';
            OptionCaption = ' ,1,10,100,1 000,10 000,100 000,1 000 000';
            OptionMembers = "  ","1","10","100","1 000","10 000","100 000","1 000 000";
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5; "Is Editable"; Boolean)
        {
            Caption = 'Editable';
        }
        field(6; "Quantity Factor"; Decimal)
        {
            Caption = 'Quantity Factor';
            DecimalPlaces = 0 : 2;
        }
        field(7; "To Invoice"; Boolean)
        {
            Caption = 'To Invoice';
        }
        field(8; "Quantity Alert On Existing"; Decimal)
        {
            Caption = 'Quantity Alert';
            DecimalPlaces = 0 : 2;
        }
        field(9; "Quantity Alert On Line"; Decimal)
        {
            Caption = 'Quantity Alert On Line';
            DecimalPlaces = 0 : 2;
        }
        field(10; "Invoicing Proportion"; Boolean)
        {
            Caption = 'Invoicing Proportion';
        }
        field(11; "UPC Code Required"; Boolean)
        {
            Caption = 'UPC Code Required';
        }
        field(12; "Prefix Required"; Boolean)
        {
            Caption = 'Prefix Required';
        }
        field(13; "Invoice Title"; Code[20])
        {
            Caption = 'Invoice Title';
            TableRelation = "Standard Text".Code;
        }
        field(14; "Invoice On Renewal"; Boolean)
        {
            Caption = 'Facturation au renouvellement';
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Bloqué';
        }
    }

    keys
    {
        key(Key1; "Code Type ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code Type ID", Description, "Product Count")
        {
        }
    }
}


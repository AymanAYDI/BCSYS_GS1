table 50014 "BC6_Code Type"
{
    Caption = 'Code Type', Comment = 'FRA="Type de code"';
    DataClassification = CustomerContent;
    // LookupPageID = 50023; TODO:

    fields
    {
        field(1; "Code Type ID"; Integer)
        {
            Caption = 'Code Type ID', Comment = 'FRA="ID type code"';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description', Comment = 'FRA="Désignation"';
            DataClassification = CustomerContent;
        }
        field(3; "Product Count"; Option)
        {
            Caption = 'Product Count', Comment = 'FRA="Nombre de produits"';
            OptionCaption = ' ,1,10,100,1 000,10 000,100 000,1 000 000';
            OptionMembers = "  ","1","10","100","1 000","10 000","100 000","1 000 000";
            DataClassification = CustomerContent;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.', Comment = 'FRA="N° article"';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(5; "Is Editable"; Boolean)
        {
            Caption = 'Editable', Comment = 'FRA="Editable"';
            DataClassification = CustomerContent;
        }
        field(6; "Quantity Factor"; Decimal)
        {
            Caption = 'Quantity Factor', Comment = 'FRA="Multiple quantité"';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
        field(7; "To Invoice"; Boolean)
        {
            Caption = 'To Invoice', Comment = 'FRA="Payant"';
            DataClassification = CustomerContent;
        }
        field(8; "Quantity Alert On Existing"; Decimal)
        {
            Caption = 'Quantity Alert', Comment = 'FRA="Alerte quantité sur existant"';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
        field(9; "Quantity Alert On Line"; Decimal)
        {
            Caption = 'Quantity Alert On Line', Comment = 'FRA="Alerte quantité sur attribution"';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
        field(10; "Invoicing Proportion"; Boolean)
        {
            Caption = 'Invoicing Proportion', Comment = 'FRA="Prorata facturation"';
            DataClassification = CustomerContent;
        }
        field(11; "UPC Code Required"; Boolean)
        {
            Caption = 'UPC Code Required', Comment = 'FRA="Code UPC requis"';
            DataClassification = CustomerContent;
        }
        field(12; "Prefix Required"; Boolean)
        {
            Caption = 'Prefix Required', Comment = 'FRA="Préfixe requis"';
            DataClassification = CustomerContent;
        }
        field(13; "Invoice Title"; Code[20])
        {
            Caption = 'Invoice Title', Comment = 'FRA="Titre facture"';
            TableRelation = "Standard Text".Code;
            DataClassification = CustomerContent;
        }
        field(14; "Invoice On Renewal"; Boolean)
        {
            Caption = 'Facturation au renouvellement', Comment = 'FRA="Facturation au renouvellement"';
            DataClassification = CustomerContent;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Bloqué', Comment = 'FRA="Bloqué"';
            DataClassification = CustomerContent;
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


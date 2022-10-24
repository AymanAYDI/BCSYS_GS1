table 50008 "BC6_GS1 Bar Code"
{
    Caption = 'GS1 Bar Code', Comment = 'FRA="Code barres GS1"';
    DataClassification = CustomerContent;
    // DrillDownPageID = 50008; TODO:
    // LookupPageID = 50008;TODO:

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.', Comment = 'FRA="N° séquence"';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.', Comment = 'FRA="N° client"';
            TableRelation = Customer;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateGLN();
            end;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.', Comment = 'FRA="N° article"';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(4; IDCodes; BigInteger)
        {
            Caption = 'ID Code', Comment = 'FRA="ID code"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TESTFIELD("Customer No.");
                TESTFIELD("Item No.");
            end;
        }
        field(5; IDEntreprise; Integer)
        {
            Caption = 'ID Entreprise', Comment = 'FRA="ID entreprise"';
            DataClassification = CustomerContent;
        }
        field(6; IDTypeCodes; Integer)
        {
            Caption = 'ID Type Codes', Comment = 'FRA="ID type code"';
            TableRelation = "BC6_Code Type"."Code Type ID";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                RecLCodeType: Record "Bc6_Code Type";
            begin
                if RecLCodeType.GET(IDTypeCodes) then
                    "Is Editable" := RecLCodeType."Is Editable"
                else
                    "Is Editable" := false;
            end;
        }
        field(10; LIB_Description; Text[50])
        {
            Caption = 'Description', Comment = 'FRA="Description"';
            DataClassification = CustomerContent;
        }
        field(11; DAT_CODES; Date)
        {
            Caption = 'Last Date Modified', Comment = 'FRA="Date dern. modification"';
            DataClassification = CustomerContent;
        }
        field(12; B_Payant; Boolean)
        {
            Caption = 'Buyer', Comment = 'FRA="Payant"';
            DataClassification = CustomerContent;
        }
        field(13; Date_Payant; Date)
        {
            CalcFormula = max("Item Ledger Entry"."Posting Date" where("Entry Type" = const("Sale"),
                                                                        "Document Type" = const("Sales Invoice"),
                                                                        "Item No." = field("Item No."),
                                                                        "Source No." = field("Customer No.")));
            Caption = 'Last Invoice Date', Comment = 'FRA="Dernière date de facturation"';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; DAT_Inactif; Date)
        {
            Caption = 'Inactive Date', Comment = 'FRA="Date inactif"';
            DataClassification = CustomerContent;
        }
        field(15; NUM_NBCodes; Integer)
        {
            Caption = 'Quantity', Comment = 'FRA="Quantité"';
            DataClassification = CustomerContent;
        }
        field(16; Num_Code; Text[250])
        {
            Caption = 'Start Code', Comment = 'FRA="Code début"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                MESSAGE('%1', Rec.Num_Code);
            end;
        }
        field(17; "Num_Code F"; Text[250])
        {
            Caption = 'End Code', Comment = 'FRA="Code de fin"';
            DataClassification = CustomerContent;
        }
        field(18; B_CnufPrincipal; Boolean)
        {
            Caption = 'Main Code', Comment = 'FRA="Code principal"';
            DataClassification = CustomerContent;
        }
        field(19; IDDocument; Integer)
        {
            Caption = 'ID Document', Comment = 'FRA="ID Document"';
            DataClassification = CustomerContent;
        }
        field(20; "BFlagSanté"; Boolean)
        {
            Caption = 'Blocked', Comment = 'FRA="Code santé"';
            DataClassification = CustomerContent;
        }
        field(21; "Is Editable"; Boolean)
        {
            Caption = 'Editable', Comment = 'FRA="Editable"';
            DataClassification = CustomerContent;
        }
        field(22; "Subscription No."; Code[20])
        {
            Caption = 'N° abonnement', Comment = 'FRA="N° abonnement"';
            DataClassification = CustomerContent;
            //TableRelation = "BC6_Subscription Header"; TODO
        }
        field(23; "Subscription Line No."; Integer)
        {
            Caption = 'N° ligne abonnement', Comment = 'FRA="N° ligne abonnement"';
            DataClassification = CustomerContent;
            //TableRelation = "Subscription Line"."Line No." WHERE("Subscription No." = FIELD("Subscription No.")); TODO
        }
        field(24; B_Inactive; Boolean)
        {
            Caption = 'Inactive', Comment = 'FRA="Inactif"';
            DataClassification = CustomerContent;
        }
        field(25; "Request Code Entry No."; Integer)
        {
            Caption = 'Request Code Entry No.', Comment = 'FRA="N° séquence demande de code"';
            DataClassification = CustomerContent;
        }
        field(26; "Transfer-To Entry No."; BigInteger)
        {
            Caption = 'Transfer-To Entry No.', Comment = 'FRA="N° séquence transféré"';
            DataClassification = CustomerContent;
        }
        field(27; "Transfer-From Entry No."; BigInteger)
        {
            Caption = 'Transfer-From Entry No.', Comment = 'FRA="N° séquence origine transfert"';
            DataClassification = CustomerContent;
        }
        field(28; Selected; Boolean)
        {
            Caption = 'Sélectionné', Comment = 'FRA="Sélectionné"';
            DataClassification = CustomerContent;
        }
        field(53; Comment; Boolean)
        {
            //CalcFormula = Exist("GS1 Comment Line" WHERE("Table Name" = CONST("GS1 Code"),"No." = FIELD("Entry No."))); TODO
            Caption = 'Comment', Comment = 'FRA="Commentaires"';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; GLN; Code[13])
        {
            Caption = 'GLN', Comment = 'FRA="GLN"';
            Numeric = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Customer No.", "Item No.")
        {
            SumIndexFields = NUM_NBCodes;
        }
        key(Key3; IDCodes, IDEntreprise, IDTypeCodes)
        {
        }
        key(Key4; "Request Code Entry No.")
        {
        }
        key(Key5; DAT_Inactif, B_Inactive)
        {
        }
        key(Key6; "Subscription No.", "Subscription Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
    end;

    local procedure GetNextEntryNo(): BigInteger
    var
        GS1BarCode: Record "BC6_GS1 Bar Code";
    begin
        GS1BarCode.LOCKTABLE();
        if GS1BarCode.FINDLAST() then
            exit(GS1BarCode."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure UpdateGLN()
    var
        Customer: Record Customer;
    begin
        if ("Customer No." <> '') then begin
            Customer.GET("Customer No.");
            if Customer.GLN <> '' then
                GLN := Customer.GLN;
        end;
    end;
}


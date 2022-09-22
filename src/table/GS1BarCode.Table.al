table 50008 "BC6_GS1 Bar Code"
{
    Caption = 'GS1 Bar Code';
    // DrillDownPageID = 50008; TODO:
    // LookupPageID = 50008;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                UpdateGLN;
            end;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(4; IDCodes; BigInteger)
        {
            Caption = 'ID Code';

            trigger OnValidate()
            begin
                TESTFIELD("Customer No.");
                TESTFIELD("Item No.");
            end;
        }
        field(5; IDEntreprise; Integer)
        {
            Caption = 'ID Entreprise';
        }
        field(6; IDTypeCodes; Integer)
        {
            Caption = 'ID Type Codes';
            TableRelation = "BC6_Code Type"."Code Type ID";

            trigger OnValidate()
            var
                RecLCodeType: Record "Bc6_Code Type";
            begin
                IF RecLCodeType.GET(IDTypeCodes) THEN BEGIN
                    "Is Editable" := RecLCodeType."Is Editable";
                END ELSE BEGIN
                    "Is Editable" := FALSE;
                END;
            end;
        }
        field(10; LIB_Description; Text[50])
        {
            Caption = 'Description';
        }
        field(11; DAT_CODES; Date)
        {
            Caption = 'Last Date Modified';
        }
        field(12; B_Payant; Boolean)
        {
            Caption = 'Buyer';
        }
        field(13; Date_Payant; Date)
        {
            CalcFormula = Max("Item Ledger Entry"."Posting Date" WHERE("Entry Type" = CONST("Sale"),
                                                                        "Document Type" = CONST("Sales Invoice"),
                                                                        "Item No." = FIELD("Item No."),
                                                                        "Source No." = FIELD("Customer No.")));
            Caption = 'Last Invoice Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; DAT_Inactif; Date)
        {
            Caption = 'Inactive Date';
        }
        field(15; NUM_NBCodes; Integer)
        {
            Caption = 'Quantity';
        }
        field(16; Num_Code; Text[250])
        {
            Caption = 'Start Code';

            trigger OnValidate()
            begin
                MESSAGE('%1', Rec.Num_Code);
            end;
        }
        field(17; "Num_Code F"; Text[250])
        {
            Caption = 'End Code';
        }
        field(18; B_CnufPrincipal; Boolean)
        {
            Caption = 'Main Code';
        }
        field(19; IDDocument; Integer)
        {
            Caption = 'ID Document';
        }
        field(20; "BFlagSanté"; Boolean)
        {
            Caption = 'Blocked';
        }
        field(21; "Is Editable"; Boolean)
        {
            Caption = 'Editable';
        }
        field(22; "Subscription No."; Code[20])
        {
            Caption = 'N° abonnement';
            //TableRelation = "BC6_Subscription Header"; TODO
        }
        field(23; "Subscription Line No."; Integer)
        {
            Caption = 'N° ligne abonnement';
            //TableRelation = "Subscription Line"."Line No." WHERE("Subscription No." = FIELD("Subscription No.")); TODO
        }
        field(24; B_Inactive; Boolean)
        {
            Caption = 'Inactive';
        }
        field(25; "Request Code Entry No."; Integer)
        {
            Caption = 'Request Code Entry No.';
        }
        field(26; "Transfer-To Entry No."; BigInteger)
        {
            Caption = 'Transfer-To Entry No.';
        }
        field(27; "Transfer-From Entry No."; BigInteger)
        {
            Caption = 'Transfer-From Entry No.';
        }
        field(28; Selected; Boolean)
        {
            Caption = 'Sélectionné';
        }
        field(53; Comment; Boolean)
        {
            //CalcFormula = Exist("GS1 Comment Line" WHERE("Table Name" = CONST("GS1 Code"),"No." = FIELD("Entry No."))); TODO
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; GLN; Code[13])
        {
            Caption = 'GLN';
            Numeric = true;
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
        IF "Entry No." = 0 THEN
            "Entry No." := GetNextEntryNo;
    end;

    local procedure GetNextEntryNo(): BigInteger
    var
        RecLGS1BarCode: Record "BC6_GS1 Bar Code";
    begin
        RecLGS1BarCode.LOCKTABLE;
        IF RecLGS1BarCode.FINDLAST THEN
            EXIT(RecLGS1BarCode."Entry No." + 1)
        ELSE
            EXIT(1);
    end;

    local procedure UpdateGLN()
    var
        RecLCustomer: Record Customer;
    begin
        IF ("Customer No." <> '') THEN BEGIN
            RecLCustomer.GET("Customer No.");
            IF RecLCustomer.GLN <> '' THEN
                GLN := RecLCustomer.GLN;
        END;
    end;
}


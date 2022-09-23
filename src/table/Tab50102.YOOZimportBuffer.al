table 50102 "BC6_YOOZ import Buffer"
{
    Caption = 'YOOZ import Buffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = ToBeClassified;
        }
        field(3; Status; Enum BC6_Status)
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
        }
        field(4; "Import Type"; Enum "BC6_Import Type")
        {
            Caption = 'Import Type';
            DataClassification = ToBeClassified;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(10; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = ToBeClassified;
        }
        field(11; "YOOZ Posting Date"; Date)
        {
            Caption = 'YOOZ Posting Date';
            DataClassification = ToBeClassified;
        }
        field(12; "Document Type"; enum "BC6_Document Type")
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
        }
        field(13; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(20; "Import Source Code"; Text[10])
        {
            Caption = 'Import Source Code';
            DataClassification = ToBeClassified;
        }
        field(21; "Import Document Date"; Text[10])
        {
            Caption = 'Import Document Date';
            DataClassification = ToBeClassified;
        }
        field(22; "Import Document Type"; Text[20])
        {
            Caption = 'Import Document Type';
            DataClassification = ToBeClassified;
        }
        field(24; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = ToBeClassified;
        }
        field(25; "Import Account Type"; Text[20])
        {
            Caption = 'Import Account Type';
            DataClassification = ToBeClassified;
        }
        field(26; "Employe Identifier"; Code[20])
        {
            Caption = 'Employe Identifier';
            DataClassification = ToBeClassified;
        }
        field(27; "YOOZ No."; Code[35])
        {
            Caption = 'YOOZ No.';
            DataClassification = ToBeClassified;
        }
        field(28; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(29; "Import Payment Method"; Text[20])
        {
            Caption = 'Import Payment Method';
            DataClassification = ToBeClassified;
        }
        field(30; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = ToBeClassified;
        }
        field(31; "Import Due Date"; Text[10])
        {
            Caption = 'Import Due Date';
            DataClassification = ToBeClassified;
        }
        field(32; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = ToBeClassified;
        }
        field(33; "Sense of Amount"; Text[10])
        {
            Caption = 'Sense of Amount';
            DataClassification = ToBeClassified;
        }
        field(34; "Import Amount"; Text[20])
        {
            Caption = 'Import Amount';
            DataClassification = ToBeClassified;
        }
        field(35; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = ToBeClassified;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = ToBeClassified;
        }
        field(37; "Import Amount (LCY)"; Text[20])
        {
            Caption = 'Import Amount (LCY)';
            DataClassification = ToBeClassified;
        }
        field(38; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = ToBeClassified;
        }
        field(39; "Company Currency Code"; Code[10])
        {
            Caption = 'Company Currency Code';
            DataClassification = ToBeClassified;
        }
        field(40; "Position Dimension"; Code[10])
        {
            Caption = 'Position Dimension';
            DataClassification = ToBeClassified;
        }
        field(41; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            DataClassification = ToBeClassified;
        }
        field(42; "Dimension Value 1"; Code[25])
        {
            Caption = 'Dimension Value 1';
            DataClassification = ToBeClassified;
        }
        field(43; "Part Number"; Code[10])
        {
            Caption = 'Part Number';
            DataClassification = ToBeClassified;
        }
        field(44; "Account Type"; Enum "BC6_Account Type")
        {
            Caption = 'Account Type';
            DataClassification = ToBeClassified;
        }
        field(45; "Dimension Value 2"; Code[20])
        {
            Caption = 'Dimension Value 2';
            DataClassification = ToBeClassified;
        }
        field(46; "Dimension Value 3"; Code[20])
        {
            Caption = 'Dimension Value 3';
            DataClassification = ToBeClassified;
        }
        field(47; "Dimension Value 4"; Code[20])
        {
            Caption = 'Dimension Value 4';
            DataClassification = ToBeClassified;
        }
        field(50; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            DataClassification = ToBeClassified;
        }
        field(51; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = ToBeClassified;
        }
        field(52; "Import Journ. Template Name"; Text[10])
        {
            Caption = 'Import Journ. Template Name';
            DataClassification = ToBeClassified;
        }
        field(53; "Import Journ Batch Name"; Text[10])
        {
            Caption = 'Import Journ Batch Name';
            DataClassification = ToBeClassified;
        }
        field(54; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier';
            DataClassification = ToBeClassified;
        }
        field(100; "Comment Zone 1"; Text[50])
        {
            Caption = 'Comment Zone 1';
            DataClassification = ToBeClassified;
        }
        field(200; "Import File Name"; Text[250])
        {
            Caption = 'Import File Name';
            DataClassification = ToBeClassified;
        }
        field(201; "Import DateTime"; DateTime)
        {
            Caption = 'Import DateTime';
            DataClassification = ToBeClassified;
        }
        field(202; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        DeleteErrorLine();
    end;

    procedure DeleteErrorLine()
    var
        ErrorLine: Record "BC6_YOOZ Error Log";
    begin
        ErrorLine.SETRANGE("Entry No.", "Entry No.");
        ErrorLine.DELETEALL();
    end;
}

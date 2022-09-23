table 50066 "BC6_YOOZ Error Log"
{
    Caption = 'YOOZ Error Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(9; "Error Description"; Text[250])
        {
            Caption = 'Error Description';
            DataClassification = ToBeClassified;
        }
        field(10; "Import File Name"; Text[250])
        {
            Caption = 'Import File Name';
            DataClassification = ToBeClassified;
        }
        field(11; "Field"; Text[250])
        {
            Caption = 'Field';
            DataClassification = ToBeClassified;
        }
        field(12; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = ToBeClassified;
        }
        field(20; User; Code[50])
        {
            Caption = 'User';
            DataClassification = ToBeClassified;
        }
        field(21; "Import Date"; Date)
        {
            Caption = 'Import Date';
            DataClassification = ToBeClassified;
        }
        field(22; "Import Time"; Time)
        {
            Caption = 'Import Time';
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

    Procedure InsertLogEntry(IntPEntryNo: Integer; TxtPErrorDescription: Text[250]; TxtPFileName: Text[250]; TxtPField: Text[250]; TxtPValue: Text[250])
    var
        IntLineNumber: Integer;
    Begin
        Rec.RESET();
        SETRANGE("Entry No.", IntPEntryNo);
        IF Rec.FINDLAST() THEN
            IntLineNumber := Rec."Line No." + 10000
        ELSE
            IntLineNumber := 10000;

        Rec.INIT();
        Rec."Entry No." := IntPEntryNo;
        Rec."Line No." := IntLineNumber;

        Rec.User := CopyStr(USERID, 1, MaxStrLen(Rec.User));
        Rec."Import Date" := WORKDATE();
        Rec."Import Time" := TIME;

        Rec."Error Description" := TxtPErrorDescription;
        Rec."Import File Name" := TxtPFileName;
        Rec.Field := TxtPField;
        Rec.Value := TxtPValue;
        Rec.INSERT();
    End;
}

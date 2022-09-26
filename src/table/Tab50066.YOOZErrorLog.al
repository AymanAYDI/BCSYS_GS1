table 50066 "BC6_YOOZ Error Log"
{
    Caption = 'YOOZ Error Log', Comment = 'FRA="Journal d''erreur YOOZ"';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', Comment = 'FRA="N° séquence"';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'FRA="N° ligne"';
            DataClassification = ToBeClassified;
        }
        field(9; "Error Description"; Text[250])
        {
            Caption = 'Error Description', Comment = 'FRA="Désignation erreur"';
            DataClassification = ToBeClassified;
        }
        field(10; "Import File Name"; Text[250])
        {
            Caption = 'Import File Name', Comment = 'FRA="Nom fichier d''import"';
            DataClassification = ToBeClassified;
        }
        field(11; "Field"; Text[250])
        {
            Caption = 'Field', Comment = 'FRA="Champ"';
            DataClassification = ToBeClassified;
        }
        field(12; Value; Text[250])
        {
            Caption = 'Value', Comment = 'FRA="Valeur"';
            DataClassification = ToBeClassified;
        }
        field(20; User; Code[50])
        {
            Caption = 'User', Comment = 'FRA="User"';
            DataClassification = ToBeClassified;
        }
        field(21; "Import Date"; Date)
        {
            Caption = 'Import Date', Comment = 'FRA="Date import"';
            DataClassification = ToBeClassified;
        }
        field(22; "Import Time"; Time)
        {
            Caption = 'Import Time', Comment = 'FRA="Heure import"';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry No.", "Line No.")
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

        Rec.User := USERID;
        Rec."Import Date" := WORKDATE();
        Rec."Import Time" := TIME;

        Rec."Error Description" := TxtPErrorDescription;
        Rec."Import File Name" := TxtPFileName;
        Rec.Field := TxtPField;
        Rec.Value := TxtPValue;
        Rec.INSERT();
    End;
}

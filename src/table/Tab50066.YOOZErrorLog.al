table 50066 "BC6_YOOZ Error Log"
{
    Caption = 'YOOZ Error Log', Comment = 'FRA="Journal d''erreur YOOZ"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', Comment = 'FRA="N° séquence"';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'FRA="N° ligne"';
            DataClassification = CustomerContent;
        }
        field(9; "Error Description"; Text[250])
        {
            Caption = 'Error Description', Comment = 'FRA="Désignation erreur"';
            DataClassification = CustomerContent;
        }
        field(10; "Import File Name"; Text[250])
        {
            Caption = 'Import File Name', Comment = 'FRA="Nom fichier d''import"';
            DataClassification = CustomerContent;
        }
        field(11; "Field"; Text[250])
        {
            Caption = 'Field', Comment = 'FRA="Champ"';
            DataClassification = CustomerContent;
        }
        field(12; Value; Text[250])
        {
            Caption = 'Value', Comment = 'FRA="Valeur"';
            DataClassification = CustomerContent;
        }
        field(20; User; Code[50])
        {
            Caption = 'User', Comment = 'FRA="User"';
            DataClassification = CustomerContent;
        }
        field(21; "Import Date"; Date)
        {
            Caption = 'Import Date', Comment = 'FRA="Date import"';
            DataClassification = CustomerContent;
        }
        field(22; "Import Time"; Time)
        {
            Caption = 'Import Time', Comment = 'FRA="Heure import"';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure InsertLogEntry(IntPEntryNo: Integer; TxtPErrorDescription: Text[250]; TxtPFileName: Text[250]; TxtPField: Text; TxtPValue: Text)
    var
        IntLineNumber: Integer;
    begin
        Rec.RESET();
        SETRANGE("Entry No.", IntPEntryNo);
        if Rec.FINDLAST() then
            IntLineNumber := Rec."Line No." + 10000

        else
            IntLineNumber := 10000;

        Rec.INIT();
        Rec."Entry No." := IntPEntryNo;
        Rec."Line No." := IntLineNumber;

        Rec.User := CopyStr(USERID, 1, MaxStrLen(Rec.User));
        Rec."Import Date" := WORKDATE();
        Rec."Import Time" := TIME;

        Rec."Error Description" := TxtPErrorDescription;
        Rec."Import File Name" := TxtPFileName;
        Rec.Field := CopyStr(TxtPField, 1, MaxStrLen(Rec.Field));
        Rec.Value := CopyStr(TxtPValue, 1, MaxStrLen(Rec.Value));
        Rec.INSERT();
    end;
}

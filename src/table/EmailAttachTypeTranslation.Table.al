table 50047 "BC6_Email Attach. Type Trans."
{
    Caption = 'Email Attach. Type Translation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Attachment Type Code"; Code[20])
        {
            Caption = 'Attachment Type Code';
            DataClassification = CustomerContent;
            TableRelation = "BC6_Email Attachment Type";
        }
        field(2; "Language Code"; Code[20])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(5; "Report Name"; Text[50])
        {
            Caption = 'Report Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Name" WHERE("Object Type" = CONST(Report), "Object ID" = FIELD("Report ID")));
            Editable = false;
        }
        field(6; "Custom Report Layout Code"; Code[20])
        {
            Caption = 'Custom Report Layout Code';
            DataClassification = CustomerContent;
            TableRelation = "Custom Report Layout".Code WHERE("Report ID" = FIELD("Report ID"), Code = FIELD("Custom Report Layout Code"));
        }
        field(7; "Custom Report Layout Name"; Text[50])
        {
            Caption = 'Custom Report Layout Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("Custom Report Layout".Description WHERE("Report ID" = FIELD("Report ID"), Code = FIELD("Custom Report Layout Code")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Attachment Type Code", "Language Code")
        {
            Clustered = true;
        }
    }
}

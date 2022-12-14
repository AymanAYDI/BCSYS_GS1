table 50047 "BC6_Email Attach. Type Trans."
{
    Caption = 'Email Attach. Type Translation', Comment = 'FRA="Traduction type pièce jointe email"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Attachment Type Code"; Code[20])
        {
            Caption = 'Attachment Type Code', Comment = 'FRA="Code type pièce jointe"';
            DataClassification = CustomerContent;
            TableRelation = "BC6_Email Attachment Type";
        }
        field(2; "Language Code"; Code[20])
        {
            Caption = 'Language Code', Comment = 'FRA="Code langue"';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description', Comment = 'FRA="Désignation"';
            DataClassification = CustomerContent;
        }
        field(4; "Report ID"; Integer)
        {
            Caption = 'Report ID', Comment = 'FRA="ID état"';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
        }
        field(5; "Report Name"; Text[50])
        {
            Caption = 'Report Name', Comment = 'FRA="Nom de l''état"';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Report), "Object ID" = field("Report ID")));
            Editable = false;
        }
        field(6; "Custom Report Layout Code"; Code[20])
        {
            Caption = 'Custom Report Layout Code', Comment = 'FRA="Code présentation état personnalisé"';
            DataClassification = CustomerContent;
            TableRelation = "Custom Report Layout".Code where("Report ID" = field("Report ID"), Code = field("Custom Report Layout Code"));
        }
        field(7; "Custom Report Layout Name"; Text[250])
        {
            Caption = 'Custom Report Layout Name', Comment = 'FRA="Nom présentation état personnalisé"';
            FieldClass = FlowField;
            CalcFormula = lookup("Custom Report Layout".Description where("Report ID" = field("Report ID"), Code = field("Custom Report Layout Code")));
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

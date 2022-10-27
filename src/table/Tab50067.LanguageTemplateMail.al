table 50067 "BC6_Language Template Mail"
{
    Caption = 'Language Template Mail', Comment = 'FRA="Code Langue Modèle Mail"';
    LookupPageID = "BC6_Language Template Mail";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Parameter String"; Text[50])
        {
            Caption = 'Template Mail Code', Comment = 'FRA="Code Modèle de Mail"';
            DataClassification = CustomerContent;
        }
        field(2; "Language Code"; Code[10])
        {
            Caption = 'Language Code', Comment = 'FRA="Code langue"';
            TableRelation = Language;
            DataClassification = CustomerContent;
        }
        field(10; "Template mail"; BLOB)
        {
            Caption = 'Template mail', Comment = 'FRA="Modèle Email"';
            DataClassification = CustomerContent;
        }
        field(50000; Object; Text[250])
        {
            Caption = 'Object', Comment = 'FRA="Objet"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Parameter String", "Language Code")
        {
            Clustered = true;
        }
    }

    var
        CstG009: label 'Do you want to replace the existing template %1 ?', Comment = 'FRA="Voulez-vous remplacer le modèle existant %1 ?"';
        CstG010: label 'Do you want to delete the template %1?', Comment = 'FRA="Voulez vous supprimer le modèle %1 ?"';

    procedure Fct_SetHtmlTemplate() TxtRRecupients: Text[1024]
    var
        RBAutoMgt: codeunit "File Management";
        BLOBRef: codeunit "Temp Blob";
        RecRef: RecordRef;
        BooLTemplateExists: Boolean;

    begin
        CALCFIELDS("Template mail");
        if "Template mail".HASVALUE then
            BooLTemplateExists := true;
        if RBAutoMgt.BLOBImport(BLOBRef, '*.html') = '' then
            exit;
        RecRef.GetTable(Rec);
        BLOBRef.ToRecordRef(RecRef, FieldNo("Template mail"));
        RecRef.SetTable(Rec);

        if BooLTemplateExists then
            if not CONFIRM(CstG009, false, FIELDCAPTION("Template mail")) then
                exit;
        MODIFY();
    end;

    procedure Fct_DeleteHtmlTemplate() TxtRRecupients: Text[1024]
    begin
        CALCFIELDS("Template mail");
        if "Template mail".HASVALUE then
            if CONFIRM(CstG010, false, FIELDCAPTION("Template mail")) then begin
                CLEAR("Template mail");
                MODIFY();
            end;
    end;

    procedure Fct_ExportHtmlTemplate() TxtRRecupients: Text[1024]
    var
        RBAutoMgt: codeunit "File Management";
        BLOBRef: codeunit "Temp Blob";
    begin
        CALCFIELDS("Template mail");
        if "Template mail".HASVALUE then begin
            BLOBRef.FromRecord(Rec, FieldNo("Template mail"));
            RBAutoMgt.BLOBExport(BLOBRef, '*.html', true);
        end;
    end;
}

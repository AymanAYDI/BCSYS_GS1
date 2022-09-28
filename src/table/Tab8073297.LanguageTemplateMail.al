table 8073297 "BC6_Language Template Mail"
{
    Caption = 'Language Template Mail';
    LookupPageID = 8073321;

    fields
    {
        field(1; "Parameter String"; Text[50])
        {
            Caption = 'Template Mail Code', Comment = 'FRA="Code Modèle de Mail"';
        }
        field(2; "Language Code"; Code[10])
        {
            Caption = 'Language Code', Comment = 'FRA="Code langue"';
            TableRelation = Language;
        }
        field(10; "Template mail"; BLOB)
        {
            Caption = 'Template mail', Comment = 'FRA="Modèle Email"';
        }
        field(50000; Object; Text[250])
        {
            Caption = 'Object', Comment = 'FRA="Objet"';
        }
    }

    keys
    {
        key(Key1; "Parameter String", "Language Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        CstG009: Label 'Do you want to replace the existing template %1 %2?';
        CstG010: Label 'Do you want to delete the template %1?';


    procedure Fct_SetHtmlTemplate() TxtRRecupients: Text[1024]
    var
        RBAutoMgt: Codeunit "File Management";
        BLOBRef: Codeunit "Temp Blob";
        RecRef: RecordRef;
        BooLTemplateExists: Boolean;

    begin
        CALCFIELDS("Template mail");
        IF "Template mail".HASVALUE THEN
            BooLTemplateExists := TRUE;
        IF RBAutoMgt.BLOBImport(BLOBRef, '*.html') = '' THEN
            EXIT;
        RecRef.GetTable(Rec);
        BLOBRef.ToRecordRef(RecRef, FieldNo("Template mail"));
        RecRef.SetTable(Rec);

        IF BooLTemplateExists THEN
            IF NOT CONFIRM(CstG009, FALSE, FIELDCAPTION("Template mail")) THEN
                EXIT;
        MODIFY();
    end;


    procedure Fct_DeleteHtmlTemplate() TxtRRecupients: Text[1024]
    begin
        CALCFIELDS("Template mail");
        IF "Template mail".HASVALUE THEN
            IF CONFIRM(CstG010, FALSE, FIELDCAPTION("Template mail")) THEN begin
                CLEAR("Template mail");
                MODIFY();
            end;
    end;


    procedure Fct_ExportHtmlTemplate() TxtRRecupients: Text[1024]
    var
        RBAutoMgt: Codeunit "File Management";
        BLOBRef: Codeunit "Temp Blob";
    begin
        CALCFIELDS("Template mail");
        IF "Template mail".HASVALUE THEN BEGIN
            BLOBRef.FromRecord(Rec, FieldNo("Template mail"));
            RBAutoMgt.BLOBExport(BLOBRef, '*.html', TRUE);
        END;
    end;
}


table 8073297 "BC6_Language Template Mail"
{
    Caption = 'Language Template Mail';
    LookupPageID = 8073321;

    fields
    {
        field(1; "Parameter String"; Text[50])
        {
            Caption = 'Template Mail Code';
            Description = 'GS110.00-FED-14';
        }
        field(2; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(10; "Template mail"; BLOB)
        {
            Caption = 'Template mail';
        }
        field(50000; "Object"; Text[250])
        {
            Caption = 'Object';
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

    [Scope('Internal')]
    procedure Fct_SetHtmlTemplate() TxtRRecupients: Text[1024]
    var
        RecLSalesReceivablesSetup: Record "Sales & Receivables Setup";
        RBAutoMgt: Codeunit "File Management";
        // BLOBRef: Record "99008535"; //TODO: table tempBlob removed
        BLOBRef: Codeunit "Temp Blob";
        BooLTemplateExists: Boolean;
    begin
        CALCFIELDS("Template mail");
        IF "Template mail".HASVALUE THEN
            BooLTemplateExists := TRUE;
        IF RBAutoMgt.BLOBImport(BLOBRef, '*.html') = '' THEN
            EXIT;
        "Template mail" := BLOBRef.Blob;
        IF BooLTemplateExists THEN
            IF NOT CONFIRM(CstG009, FALSE, FIELDCAPTION("Template mail")) THEN
                EXIT;
        MODIFY;
    end;

    [Scope('Internal')]
    procedure Fct_DeleteHtmlTemplate() TxtRRecupients: Text[1024]
    var
        RecLSalesReceivablesSetup: Record "Sales & Receivables Setup";
        RBAutoMgt: Codeunit "File Management";
    // BLOBRef: Record "99008535"; TODO: table tempBlob removed
    begin
        CALCFIELDS("Template mail");
        IF "Template mail".HASVALUE THEN BEGIN
            IF CONFIRM(CstG010, FALSE, FIELDCAPTION("Template mail")) THEN BEGIN
                CLEAR("Template mail");
                MODIFY;
            END;
        END;
    end;

    [Scope('Internal')]
    procedure Fct_ExportHtmlTemplate() TxtRRecupients: Text[1024]
    var
        RecLSalesReceivablesSetup: Record "Sales & Receivables Setup";
        RBAutoMgt: Codeunit "File Management";
        // BLOBRef: Record "99008535";TODO: table tempBlob removed
        BooLTemplateExists: Boolean;
    begin
        CALCFIELDS("Template mail");
        IF "Template mail".HASVALUE THEN BEGIN
            BLOBRef.Blob := "Template mail";
            RBAutoMgt.BLOBExport(BLOBRef, '*.html', TRUE);
        END;
    end;
}


tableextension 50001 "BC6_Language" extends Language
{




    procedure GetUserLanguage(): Code[10]
    begin
        CLEAR(Rec);
        SETRANGE("Windows Language ID", GLOBALLANGUAGE);
        IF FINDFIRST() THEN;
        SETRANGE("Windows Language ID");
        EXIT(Code);
    end;

    procedure GetLanguageID(LanguageCode: Code[10]): Integer
    begin
        CLEAR(Rec);
        IF LanguageCode <> '' THEN
            IF GET(LanguageCode) THEN
                EXIT("Windows Language ID");
        "Windows Language ID" := GLOBALLANGUAGE;
        EXIT("Windows Language ID");
    end;
}

tableextension 50001 "BC6_Language" extends Language
{




    procedure GetUserLanguage(): Code[10]
    begin
        CLEAR(Rec);
        SETRANGE("Windows Language ID", GLOBALLANGUAGE);
        if FINDFIRST() then;
        SETRANGE("Windows Language ID");
        exit(Code);
    end;

    procedure GetLanguageID(LanguageCode: Code[10]): Integer
    begin
        CLEAR(Rec);
        if LanguageCode <> '' then
            if GET(LanguageCode) then
                exit("Windows Language ID");
        "Windows Language ID" := GLOBALLANGUAGE;
        exit("Windows Language ID");
    end;
}

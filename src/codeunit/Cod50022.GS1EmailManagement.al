codeunit 50022 "BC6_GS1 : Email Management"
{
    var
        Mail: codeunit Email;
        EmailMessage: codeunit "Email Message";
        TxtGHtmlTable: Text;
        TxtGHtmlTableOutVeh: Text;
        TxtGPeriod: Text;
        TxtGCreditorName: Text[50];


    procedure SendMail(BooPHideSmtpError: Boolean)
    begin
        Mail.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;


    procedure FctGetTemplateWithLanguage(TxtPParameterString: Text[250]; _Language: Code[10]; var _BLOBRef: codeunit "Temp Blob")
    var
        LanguageTemplateMail: Record "BC6_Language Template Mail";
    begin
        if not LanguageTemplateMail.GET(TxtPParameterString, _Language) then
            LanguageTemplateMail.GET(TxtPParameterString, 'FRA');
        LanguageTemplateMail.CALCFIELDS("Template mail");
        _BLOBRef.FromRecord(LanguageTemplateMail, LanguageTemplateMail.FieldNo("Template mail"));
    end;


    procedure FctLoadMailBody(var RefPRecordRef: RecordRef; var RecPBLOBRef: codeunit "Temp Blob"; TxtPSpecialText1: Text; TxtPSpecialText2: Text; var TxtPEmailBodyText: Text) Error: Text[1024]
    var
        Skip: Boolean;
        Stop: Boolean;
        WrongEnd: Boolean;
        InStreamTemplate: InStream;
        I: Integer;
        y: Integer;
        z: Integer;
        Body: Text;
        InSReadChar: Text[1];
        CharNo: Text[30];
        RepeatLine: Text[1024];
    begin
        if not RefPRecordRef.ISEMPTY then begin
            RecPBLOBRef.CREATEINSTREAM(InStreamTemplate, TEXTENCODING::Windows);
            TxtPEmailBodyText := '';

            while InStreamTemplate.READ(InSReadChar, 1) <> 0 do
                if InSReadChar = '%' then begin
                    TxtPEmailBodyText += Body;
                    Body := InSReadChar;

                    if InStreamTemplate.READ(InSReadChar, 1) <> 0 then;

                    if InSReadChar = 'n' then begin
                        RepeatLine := '';
                        Stop := false;
                        y := 1;

                        while (not Stop) do begin
                            if InStreamTemplate.READ(InSReadChar, 1) <> 0 then;
                            RepeatLine += InSReadChar;

                            if y > 1 then
                                if (FORMAT(RepeatLine[y - 1]) + FORMAT(RepeatLine[y])) = '%n' then begin
                                    RepeatLine := DELSTR(RepeatLine, STRPOS(RepeatLine, '%n'), 2);
                                    Stop := true;
                                end;
                            y += 1;
                        end;

                        while (not Skip) do begin
                            Body := '';
                            for y := 1 to STRLEN(RepeatLine) do
                                if RepeatLine[y] = '%' then begin
                                    Body += '%';

                                    y += 1;
                                    if (RepeatLine[y] >= '0') and (RepeatLine[y] <= '9') then begin
                                        Body := Body + '1';
                                        CharNo := FORMAT(RepeatLine[y]);
                                        y += 1;
                                        while ((RepeatLine[y] >= '0') and (RepeatLine[y] <= '9')) or (RepeatLine[y] = '/') do begin
                                            CharNo := CharNo + FORMAT(RepeatLine[y]);
                                            y += 1;
                                        end;
                                        Body += FORMAT(RepeatLine[y]);
                                        FctFillTemplate(Body, CharNo, RefPRecordRef, TxtPSpecialText1, TxtPSpecialText2);
                                        TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                                        Body := '';

                                    end else
                                        Body += FORMAT(RepeatLine[y]);
                                end else
                                    Body += FORMAT(RepeatLine[y]);


                            TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                            Body := '';
                            Skip := RefPRecordRef.NEXT() = 0;
                        end;
                    end else begin
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                            Body := Body + '1';
                            CharNo := InSReadChar;
                            while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                                if InStreamTemplate.READ(InSReadChar, 1) <> 0 then;
                                if (InSReadChar >= '0') and (InSReadChar <= '9') then
                                    CharNo := CopyStr(CharNo + InSReadChar, 1, MaxStrLen(CharNo));
                            end;
                        end else
                            Body := Body + InSReadChar;

                        FctFillTemplate(Body, CharNo, RefPRecordRef, TxtPSpecialText1, TxtPSpecialText2);
                        TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                        Body := InSReadChar;
                    end;

                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                        Body := '';
                        I := 0;
                    end;
                end;


            if (STRLEN(Body) > 0) then begin
                WrongEnd := true;
                for z := 0 to 5 do
                    if Body[STRLEN(Body) - z] = '>' then
                        WrongEnd := false;

                if WrongEnd then
                    Body := Body + '>';
            end;

            TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
        end;
    end;

    procedure FctFillTemplate(var Body: Text[1024]; TextNo: Text[30]; var Header: RecordRef; TxtPSpecialText1: Text; TxtPSpecialText2: Text)
    var
        RecLActiveSession: Record "Active Session";
        FldLRef: FieldRef;
        FldLRef2: FieldRef;
        DecLValue1: Decimal;
        DecLValue2: Decimal;
        IntLFieldNumber: Integer;
        IntLFieldNumber2: Integer;
    begin
        if TextNo = '' then
            exit;
        if STRPOS(TextNo, '/') = 0 then begin
            EVALUATE(IntLFieldNumber, TextNo);
            case IntLFieldNumber of
                10000:
                    Body := STRSUBSTNO(Body, TxtPSpecialText1);
                10001:
                    Body := STRSUBSTNO(Body, TxtPSpecialText2);
                10002:
                    Body := STRSUBSTNO(Body, TxtGHtmlTable);
                10003:
                    Body := STRSUBSTNO(Body, TxtGHtmlTableOutVeh);
                10009:
                    Body := STRSUBSTNO(Body, FORMAT(WORKDATE()));
                10010:
                    Body := STRSUBSTNO(Body, FORMAT(TxtGPeriod));
                10011:
                    Body := STRSUBSTNO(Body, FORMAT(TxtGCreditorName));
                200000001:
                    begin
                        RecLActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());
                        RecLActiveSession.SETRANGE("Session ID", SESSIONID());
                        RecLActiveSession.FINDFIRST();
                        Body := STRSUBSTNO(Body, FctConvertStr(RecLActiveSession."Server Computer Name"));
                    end;
                200000002:
                    begin
                        RecLActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());
                        RecLActiveSession.SETRANGE("Session ID", SESSIONID());
                        RecLActiveSession.FINDFIRST;
                        Body := STRSUBSTNO(Body, FctConvertStr(RecLActiveSession."Database Name"));
                    end;
                200000003:
                    Body := STRSUBSTNO(Body, FctConvertStr(CopyStr(COMPANYNAME, 1, 1024)));

                else begin
                    FldLRef := Header.FIELD(IntLFieldNumber);
                    if FORMAT(FldLRef.CLASS) = 'FlowField' then
                        FldLRef.CALCFIELD();
                    case FORMAT(FldLRef.TYPE) of
                        /*
                        'Option':BEGIN
                          EVALUATE(IntLOptionValue, FORMAT(FldLRef.VALUE));
                          TxtLOptionString := FldLRef.OPTIONCAPTION;
                          FOR i:=0 TO IntLOptionValue DO
                          BEGIN
                            TxtLMySelectedOptionString := COPYSTR(TxtLOptionString, 1, STRPOS(TxtLOptionString, ',')-1);
                            TxtLOptionString := COPYSTR(TxtLOptionString, STRPOS(TxtLOptionString, ',')+1, STRLEN(TxtLOptionString));
                          END;
                          Body := STRSUBSTNO(Body, TxtLMySelectedOptionString);
                        END;
                        */
                        'Decimal':
                            begin
                                EVALUATE(DecLValue1, FORMAT(FldLRef.VALUE));
                                Body := STRSUBSTNO(Body, FORMAT(ROUND(DecLValue1, 0.01)));
                            end else
                                    Body := STRSUBSTNO(Body, FldLRef.VALUE);
                    end;
                end;
            end;
        end else begin
            EVALUATE(IntLFieldNumber, COPYSTR(TextNo, 1, STRPOS(TextNo, '/') - 1));
            EVALUATE(IntLFieldNumber2, COPYSTR(TextNo, STRPOS(TextNo, '/') + 1, STRLEN(TextNo)));
            FldLRef := Header.FIELD(IntLFieldNumber);
            if FORMAT(FldLRef.CLASS) = 'FlowField' then
                FldLRef.CALCFIELD();

            FldLRef2 := Header.FIELD(IntLFieldNumber2);
            if FORMAT(FldLRef2.CLASS) = 'FlowField' then
                FldLRef2.CALCFIELD();

            EVALUATE(DecLValue1, FORMAT(FldLRef.VALUE));
            EVALUATE(DecLValue2, FORMAT(FldLRef2.VALUE));
            if DecLValue2 <> 0 then
                Body := STRSUBSTNO(Body, FORMAT(ROUND((DecLValue1 / DecLValue2), 0.01)))
            else
                Body := STRSUBSTNO(Body, FORMAT(ROUND(DecLValue1, 0.01)))

        end;

    end;

    procedure FctConvertStr(TxtPStringToConvert: Text[1024]) TxtRStringToConvert: Text[1024]
    var
        BooLFirst: Boolean;
    begin
        BooLFirst := true;
        TxtRStringToConvert := '';
        if STRPOS(TxtPStringToConvert, ' ') <> 0 then begin
            while (STRPOS(TxtPStringToConvert, ' ') <> 0) do begin
                if BooLFirst then
                    TxtRStringToConvert += COPYSTR(TxtPStringToConvert, 1, STRPOS(TxtPStringToConvert, ' ') - 1)
                else
                    TxtRStringToConvert += '%20' + COPYSTR(TxtPStringToConvert, 1, STRPOS(TxtPStringToConvert, ' ') - 1);
                BooLFirst := false;

                TxtPStringToConvert := COPYSTR(TxtPStringToConvert, STRPOS(TxtPStringToConvert, ' ') + 1, STRLEN(TxtPStringToConvert));
            end;
            TxtRStringToConvert += '%20' + TxtPStringToConvert;
        end else
            TxtRStringToConvert := TxtPStringToConvert;
    end;

    procedure CreateMailMessage(_SendTo: Text[250]; _CC: Text[250]; _BCC: Text[250]; _Subject: Text[250]; _BodyText: Text)
    var
        BCCList: List of [Text];
        CCList: List of [Text];
        SendToList: List of [Text];
    begin
        SendToList := AddMailList(_SendTo);
        CCList := AddMailList(_CC);
        BCCList := AddMailList(_BCC);
        EmailMessage.Create(SendToList, _Subject, _BodyText, true, CCList, BCCList);
    end;

    procedure AddMailAttachment(var TempBlob: codeunit "Temp Blob"; AttachmentFileName: Text[250])
    var
        InStream: InStream;
    begin
        if not TempBlob.HasValue() then
            exit;

        TempBlob.CreateInStream(InStream);
        EmailMessage.AddAttachment(AttachmentFileName, 'SendMail', InStream);
    end;

    local procedure AddMailList(_Mail: Text) _MailList: List of [Text]
    begin
        if _Mail.Contains(';') then
            _MailList := _Mail.Split(';')
        else
            if _Mail <> '' then
                _MailList.Add(_Mail);
    end;
}


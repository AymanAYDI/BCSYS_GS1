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


    procedure FctLoadMailBody(var RefPRecordRef: RecordRef; var RecPBLOBRef: codeunit "Temp Blob"; TxtSpecialText1: Text; TxtSpecialText2: Text; var TxtEmailBodyText: Text) Error: Text[1024]
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
            TxtEmailBodyText := '';

            while InStreamTemplate.READ(InSReadChar, 1) <> 0 do
                if InSReadChar = '%' then begin
                    TxtEmailBodyText += Body;
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
                                        FctFillTemplate(Body, CharNo, RefPRecordRef, TxtSpecialText1, TxtSpecialText2);
                                        TxtEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                                        Body := '';

                                    end else
                                        Body += FORMAT(RepeatLine[y]);
                                end else
                                    Body += FORMAT(RepeatLine[y]);


                            TxtEmailBodyText += (CONVERTSTR(Body, '|', '%'));
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

                        FctFillTemplate(Body, CharNo, RefPRecordRef, TxtSpecialText1, TxtSpecialText2);
                        TxtEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                        Body := InSReadChar;
                    end;

                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        TxtEmailBodyText += (CONVERTSTR(Body, '|', '%'));
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

            TxtEmailBodyText += (CONVERTSTR(Body, '|', '%'));
        end;
    end;

    procedure FctFillTemplate(var Body: Text[1024]; TextNo: Text[30]; var Header: RecordRef; TxtSpecialText1: Text; TxtSpecialText2: Text)
    var
        ActiveSession: Record "Active Session";
        FldRef: FieldRef;
        FldRef2: FieldRef;
        DecValue1: Decimal;
        DecValue2: Decimal;
        IntFieldNumber: Integer;
        IntFieldNumber2: Integer;
    begin
        if TextNo = '' then
            exit;
        if STRPOS(TextNo, '/') = 0 then begin
            EVALUATE(IntFieldNumber, TextNo);
            case IntFieldNumber of
                10000:
                    Body := STRSUBSTNO(Body, TxtSpecialText1);
                10001:
                    Body := STRSUBSTNO(Body, TxtSpecialText2);
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
                        ActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());
                        ActiveSession.SETRANGE("Session ID", SESSIONID());
                        ActiveSession.FINDFIRST();
                        Body := STRSUBSTNO(Body, FctConvertStr(ActiveSession."Server Computer Name"));
                    end;
                200000002:
                    begin
                        ActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());
                        ActiveSession.SETRANGE("Session ID", SESSIONID());
                        ActiveSession.FINDFIRST();
                        Body := STRSUBSTNO(Body, FctConvertStr(ActiveSession."Database Name"));
                    end;
                200000003:
                    Body := STRSUBSTNO(Body, FctConvertStr(CopyStr(COMPANYNAME, 1, 1024)));

                else begin
                    FldRef := Header.FIELD(IntFieldNumber);
                    if FORMAT(FldRef.CLASS) = 'FlowField' then
                        FldRef.CALCFIELD();
                    case FORMAT(FldRef.TYPE) of
                        'Decimal':
                            begin
                                EVALUATE(DecValue1, FORMAT(FldRef.VALUE));
                                Body := STRSUBSTNO(Body, FORMAT(ROUND(DecValue1, 0.01)));
                            end else
                                    Body := STRSUBSTNO(Body, FldRef.VALUE);
                    end;
                end;
            end;
        end else begin
            EVALUATE(IntFieldNumber, COPYSTR(TextNo, 1, STRPOS(TextNo, '/') - 1));
            EVALUATE(IntFieldNumber2, COPYSTR(TextNo, STRPOS(TextNo, '/') + 1, STRLEN(TextNo)));
            FldRef := Header.FIELD(IntFieldNumber);
            if FORMAT(FldRef.CLASS) = 'FlowField' then
                FldRef.CALCFIELD();

            FldRef2 := Header.FIELD(IntFieldNumber2);
            if FORMAT(FldRef2.CLASS) = 'FlowField' then
                FldRef2.CALCFIELD();

            EVALUATE(DecValue1, FORMAT(FldRef.VALUE));
            EVALUATE(DecValue2, FORMAT(FldRef2.VALUE));
            if DecValue2 <> 0 then
                Body := STRSUBSTNO(Body, FORMAT(ROUND((DecValue1 / DecValue2), 0.01)))
            else
                Body := STRSUBSTNO(Body, FORMAT(ROUND(DecValue1, 0.01)))

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


codeunit 50022 "BC6_GS1 : Email Management"
{
    Permissions = tabledata 99008535 = rimd;


    var
        // CstGText001: Label 'Automatic batch doesn''t exist.';
        // CstGText002: Label 'Order Tracking - %1 - %2';
        // IntGLanguage: Integer;
        Mail: codeunit Email;
        BooGAutoSend: Boolean;
        // CumuledAdresse: Text;
        // CstGText003: Label 'No Reply';
        // CstGText004: Label 'There is no attachment for this task.';
        // CstGText005: Label 'All documents are received.';
        // CstGHtmlTableBegin: Label '<table style="border: 1px solid #ddd;border-collapse: collapse;width: auto"><tr style="background-color: #528094;color: white;padding: 8px;"><th style="text-align: left;padding: 8px;">%1</th><th style="background-color: #528094;color: white;text-align: left;padding: 8px;">%2</th></tr>';
        // CstGHtmlTableAddLine: Label '<tr style="text-align: left;padding: 8px;"><td>%1</td><td>%2</td></tr>';
        // CstGHtmlTableEnd: Label '</table>';
        TxtGHtmlTable: Text;
        // CstGText0006: Label 'Document';
        // CstGHtmlTableHeader: Label '<table style="border: 1px solid #ddd;border-collapse: collapse;width: auto" border="1"><tr style="background-color: #528094;color: white;padding: 8px;"><th style="text-align: left;padding: 8px;">%1</th><th style="background-color: #528094;color: white;text-align: left;padding: 8px;">%2</th><th style="background-color: #528094;color: white;text-align: left;padding: 8px;">%3</th><th style="background-color: #528094;color: white;text-align: left;padding: 8px;">%4</th><th style="background-color: #528094;color: white;text-align: left;padding: 8px;">%5</th><th style="background-color: #528094;color: white;text-align: left;padding: 8px;">%6</th><th style="background-color: #528094;color: white;text-align: left;padding: 8px;">%7</th></tr>';
        // CstGHtmlTableLine: Label '<tr style="text-align: left;padding: 8px;"><td>%1</td><td>%2</td><td>%3</td><td>%4</td><td>%5</td><td>%6</td><td style="text-align: right;">%7</td></tr>';
        // CstGHtmlTableTotLine: Label '<tr style="text-align: left;padding: 8px;"><td colspan="6">Total société %1 %2</td><td style="text-align: right;">%3</td></tr>';
        // CstGText006: Label 'Order No.';
        // CstGText007: Label 'Place';
        // CstGText008: Label 'Make';
        // CstGText009: Label 'Registration';
        // CstGText010: Label 'Entry Date';
        // CstGText011: Label 'Recorded Value';
        TxtGHtmlTableOutVeh: Text;
        // CstGText012: Label 'Serial No.';
        // CstGText013: Label 'Véhicules à sortir de plus de %1 jours de %2';
        // CstGText014: Label 'First Release Date';
        // CstGText015: Label 'Age';
        // CstGText016: Label 'Véhicules périmés de plus de %1 ans de %2';
        // CstGHtmlTableABSVehHeader: Label '<table style="border: 1px solid #ddd;border-collapse: collapse;width: auto" border="1"><tr style="background-color: #F78181;color: white;padding: 8px;"><th style="text-align: left;padding: 8px;">%1</th><th style="background-color: #F78181;color: white;text-align: left;padding: 8px;">%2</th><th style="background-color: #F78181;color: white;text-align: left;padding: 8px;">%3</th><th style="background-color: #F78181;color: white;text-align: left;padding: 8px;">%4</th><th style="background-color: #F78181;color: white;text-align: left;padding: 8px;">%5</th><th style="background-color: #F78181;color: white;text-align: left;padding: 8px;">%6</th><th style="background-color: #F78181;color: white;text-align: left;padding: 8px;">%7</th><th style="background-color: #F78181;color: white;text-align: left;padding: 8px;">%8</th></tr>';
        // CstGHtmlTableABSVehLine: Label '<tr style="text-align: left;padding: 8px;"><td>%1</td><td>%2</td><td>%3</td><td>%4</td><td>%5</td><td>%6</td><td style="text-align: right;">%7</td><td>%8</td></tr>';
        // CstGHtmlTableABSVehTotLine: Label '<tr style="text-align: left;padding: 8px;"><td colspan="7">Total société %1 %2</td><td style="text-align: right;">%3</td></tr>';
        TxtGPeriod: Text;
        // MyFilterPageBuilder: FilterPageBuilder;
        // CstGText017: Label 'Discount Type';
        TxtGCreditorName: Text[50];
        CduGSMTPMail: codeunit "Email Message";


    procedure FctSendMail(BooPHideSmtpError: Boolean)
    var
        MailSent: Boolean;
    begin
        if BooGAutoSend then
            // CduGSMTPMail.Send TODO
            // ELSE
            MailSent := Mail.Send(CduGSMTPMail, Enum::"Email Scenario"::Default);
    end;


    procedure FctGetTemplateWithLanguage(TxtPParameterString: Text[250]; CodPLanguage: Code[10]; var RecPBLOBRef: codeunit "Temp Blob")
    var
        RecLLanguageTemplateMail: Record "BC6_Language Template Mail";
    begin
        if not RecLLanguageTemplateMail.GET(TxtPParameterString, CodPLanguage) then
            RecLLanguageTemplateMail.GET(TxtPParameterString, 'FRA');
        RecLLanguageTemplateMail.CALCFIELDS("Template mail");
        RecPBLOBRef.FromRecord(RecLLanguageTemplateMail, RecLLanguageTemplateMail.FieldNo("Template mail"));
    end;


    procedure FctLoadMailBody(var RefPRecordRef: RecordRef; var RecPBLOBRef: codeunit "Temp Blob"; TxtPSpecialText1: Text; TxtPSpecialText2: Text; var TxtPEmailBodyText: Text) Error: Text[1024]
    var
        BooLSkip: Boolean;
        BooLStop: Boolean;
        BooWrongEnd: Boolean;
        InStreamTemplate: InStream;
        I: Integer;
        y: Integer;
        z: Integer;
        Body: Text;
        InSReadChar: Text[1];
        CharNo: Text[30];
        TxtLRepeatLine: Text[1024];
    begin
        if not RefPRecordRef.ISEMPTY then begin
            // TxtLTempPath := TEMPORARYPATH + 'TempTemplate.HTM';
            RecPBLOBRef.CREATEINSTREAM(InStreamTemplate, TEXTENCODING::Windows);
            TxtPEmailBodyText := '';

            while InStreamTemplate.READ(InSReadChar, 1) <> 0 do
                if InSReadChar = '%' then begin
                    TxtPEmailBodyText += Body;
                    Body := InSReadChar;

                    if InStreamTemplate.READ(InSReadChar, 1) <> 0 then;

                    if InSReadChar = 'n' then begin
                        TxtLRepeatLine := '';
                        BooLStop := false;
                        y := 1;

                        while (not BooLStop) do begin
                            if InStreamTemplate.READ(InSReadChar, 1) <> 0 then;
                            TxtLRepeatLine += InSReadChar;

                            if y > 1 then
                                if (FORMAT(TxtLRepeatLine[y - 1]) + FORMAT(TxtLRepeatLine[y])) = '%n' then begin
                                    TxtLRepeatLine := DELSTR(TxtLRepeatLine, STRPOS(TxtLRepeatLine, '%n'), 2);
                                    BooLStop := true;
                                end;
                            y += 1;
                        end;

                        while (not BooLSkip) do begin
                            Body := '';
                            for y := 1 to STRLEN(TxtLRepeatLine) do
                                if TxtLRepeatLine[y] = '%' then begin
                                    Body += '%';

                                    y += 1;
                                    if (TxtLRepeatLine[y] >= '0') and (TxtLRepeatLine[y] <= '9') then begin
                                        Body := Body + '1';
                                        CharNo := FORMAT(TxtLRepeatLine[y]);
                                        y += 1;
                                        while ((TxtLRepeatLine[y] >= '0') and (TxtLRepeatLine[y] <= '9')) or (TxtLRepeatLine[y] = '/') do begin
                                            CharNo := CharNo + FORMAT(TxtLRepeatLine[y]);
                                            y += 1;
                                        end;
                                        Body += FORMAT(TxtLRepeatLine[y]);
                                        FctFillTemplate(Body, CharNo, RefPRecordRef, TxtPSpecialText1, TxtPSpecialText2);
                                        TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                                        Body := '';

                                    end else
                                        Body += FORMAT(TxtLRepeatLine[y]);
                                end else
                                    Body += FORMAT(TxtLRepeatLine[y]);


                            TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                            Body := '';
                            BooLSkip := RefPRecordRef.NEXT() = 0;
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
                BooWrongEnd := true;
                for z := 0 to 5 do
                    if Body[STRLEN(Body) - z] = '>' then
                        BooWrongEnd := false;

                if BooWrongEnd then
                    Body := Body + '>';
            end;

            TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
        end;
    end;


    procedure FctFillTemplate(var Body: Text[1024]; TextNo: Text[30]; var Header: RecordRef; TxtPSpecialText1: Text; TxtPSpecialText2: Text)
    var
        FldLRef: FieldRef;
        FldLRef2: FieldRef;
        DecLValue1: Decimal;
        DecLValue2: Decimal;
        IntLFieldNumber: Integer;
        IntLFieldNumber2: Integer;
        RecLActiveSession: Record "Active Session";
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


    procedure FctCreateMailMessage(TxtPFromName: Text[100]; TxtPFromAddress: Text[250]; TxtPSendTo: Text[250]; TxtPCC: Text[250]; TxtPBCC: Text[250]; TxtPSubject: Text[250]; TxtPBodyText: Text; BooPAutoSend: Boolean)
    var
        TxtPSendToList: List of [Text];
        TxtPCCList: List of [Text];
        TxtPBCCList: List of [Text];
    begin
        if BooPAutoSend then begin
            TxtPSendToList := AddMailList(TxtPSendTo);
            TxtPCCList := AddMailList(TxtPCC);
            TxtPBCCList := AddMailList(TxtPBCC);
            CduGSMTPMail.Create(TxtPSendToList, TxtPSubject, TxtPBodyText, true, TxtPCCList, TxtPBCCList);
        end;
        BooGAutoSend := BooPAutoSend;
    end;


    procedure FctAddMailAttachment(AttachmentFilePath: Text; AttachmentFileName: Text)
    var
        tempBlob: codeunit "Temp Blob";
        InStr: InStream;
    begin
        if AttachmentFilePath = '' then
            exit;
        if BooGAutoSend then begin
            tempBlob.CreateInStream(InStr);
            CduGSMTPMail.AddAttachment(AttachmentFileName, 'SendMail', InStr);
        end
        // ELSE
        // Mail.AttachFile(AttachmentFilePath); TODO

    end;

    procedure AddMailList(mail: Text) RecipientsList: List of [Text]
    var
        textList: List of [Text];
    begin
        mail += ';';
        while STRPOS(mail, ';') > 1 do begin
            textList.Add(COPYSTR(mail, 1, STRPOS(mail, ';') - 1));
            mail := COPYSTR(mail, STRPOS(mail, ';') + 1);
        end;
        RecipientsList := textList;

    end;
}


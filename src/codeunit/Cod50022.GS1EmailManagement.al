codeunit 50022 "BC6_GS1 : Email Management"
{
    Permissions = TableData 99008535 = rimd;


    var
        CduGSMTPMail: Codeunit "400";
        // CstGText001: Label 'Automatic batch doesn''t exist.';
        // CstGText002: Label 'Order Tracking - %1 - %2';
        // IntGLanguage: Integer;
        Mail: Codeunit Mail;
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


    procedure FctSendMail(BooPHideSmtpError: Boolean)
    var
        MailSent: Boolean;
    begin
        IF BooGAutoSend THEN
            CduGSMTPMail.Send
        ELSE
            MailSent := Mail.Send;
    end;


    procedure FctGetTemplateWithLanguage(TxtPParameterString: Text[250]; CodPLanguage: Code[10]; var RecPBLOBRef: Codeunit "Temp Blob")
    var
        RecLLanguageTemplateMail: Record "BC6_Language Template Mail";
    begin
        IF NOT RecLLanguageTemplateMail.GET(TxtPParameterString, CodPLanguage) THEN
            RecLLanguageTemplateMail.GET(TxtPParameterString, 'FRA');
        RecLLanguageTemplateMail.CALCFIELDS("Template mail");
        RecPBLOBRef.FromRecord(RecLLanguageTemplateMail, RecLLanguageTemplateMail.FieldNo("Template mail"));
    end;


    procedure FctLoadMailBody(var RefPRecordRef: RecordRef; var RecPBLOBRef: Codeunit "Temp Blob"; TxtPSpecialText1: Text; TxtPSpecialText2: Text; var TxtPEmailBodyText: Text) Error: Text[1024]
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
        IF NOT RefPRecordRef.ISEMPTY THEN BEGIN
            // TxtLTempPath := TEMPORARYPATH + 'TempTemplate.HTM';
            RecPBLOBRef.CREATEINSTREAM(InStreamTemplate, TEXTENCODING::Windows);
            TxtPEmailBodyText := '';

            WHILE InStreamTemplate.READ(InSReadChar, 1) <> 0 DO
                IF InSReadChar = '%' THEN BEGIN
                    TxtPEmailBodyText += Body;
                    Body := InSReadChar;

                    IF InStreamTemplate.READ(InSReadChar, 1) <> 0 THEN;

                    IF InSReadChar = 'n' THEN BEGIN
                        TxtLRepeatLine := '';
                        BooLStop := FALSE;
                        y := 1;

                        WHILE (NOT BooLStop) DO BEGIN
                            IF InStreamTemplate.READ(InSReadChar, 1) <> 0 THEN;
                            TxtLRepeatLine += InSReadChar;

                            IF y > 1 THEN
                                IF (FORMAT(TxtLRepeatLine[y - 1]) + FORMAT(TxtLRepeatLine[y])) = '%n' THEN BEGIN
                                    TxtLRepeatLine := DELSTR(TxtLRepeatLine, STRPOS(TxtLRepeatLine, '%n'), 2);
                                    BooLStop := TRUE;
                                END;
                            y += 1;
                        END;

                        WHILE (NOT BooLSkip) DO BEGIN
                            Body := '';
                            FOR y := 1 TO STRLEN(TxtLRepeatLine) DO
                                IF TxtLRepeatLine[y] = '%' THEN BEGIN
                                    Body += '%';

                                    y += 1;
                                    IF (TxtLRepeatLine[y] >= '0') AND (TxtLRepeatLine[y] <= '9') THEN BEGIN
                                        Body := Body + '1';
                                        CharNo := FORMAT(TxtLRepeatLine[y]);
                                        y += 1;
                                        WHILE ((TxtLRepeatLine[y] >= '0') AND (TxtLRepeatLine[y] <= '9')) OR (TxtLRepeatLine[y] = '/') DO BEGIN
                                            CharNo := CharNo + FORMAT(TxtLRepeatLine[y]);
                                            y += 1;
                                        END;
                                        Body += FORMAT(TxtLRepeatLine[y]);
                                        FctFillTemplate(Body, CharNo, RefPRecordRef, TxtPSpecialText1, TxtPSpecialText2);
                                        TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                                        Body := '';

                                    END ELSE
                                        Body += FORMAT(TxtLRepeatLine[y]);
                                END ELSE
                                    Body += FORMAT(TxtLRepeatLine[y]);


                            TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                            Body := '';
                            BooLSkip := RefPRecordRef.NEXT() = 0;
                        END;
                    END ELSE BEGIN
                        IF (InSReadChar >= '0') AND (InSReadChar <= '9') THEN BEGIN
                            Body := Body + '1';
                            CharNo := InSReadChar;
                            WHILE (InSReadChar >= '0') AND (InSReadChar <= '9') DO BEGIN
                                IF InStreamTemplate.READ(InSReadChar, 1) <> 0 THEN;
                                IF (InSReadChar >= '0') AND (InSReadChar <= '9') THEN
                                    CharNo := CopyStr(CharNo + InSReadChar, 1, MaxStrLen(CharNo));
                            END;
                        END ELSE
                            Body := Body + InSReadChar;

                        FctFillTemplate(Body, CharNo, RefPRecordRef, TxtPSpecialText1, TxtPSpecialText2);
                        TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                        Body := InSReadChar;
                    END;

                END ELSE BEGIN
                    Body := Body + InSReadChar;
                    I := I + 1;
                    IF I = 500 THEN BEGIN
                        TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
                        Body := '';
                        I := 0;
                    END;
                END;


            IF (STRLEN(Body) > 0) THEN BEGIN
                BooWrongEnd := TRUE;
                FOR z := 0 TO 5 DO
                    IF Body[STRLEN(Body) - z] = '>' THEN
                        BooWrongEnd := FALSE;

                IF BooWrongEnd THEN
                    Body := Body + '>';
            END;

            TxtPEmailBodyText += (CONVERTSTR(Body, '|', '%'));
        END;
    end;


    procedure FctFillTemplate(var Body: Text[1024]; TextNo: Text[30]; var Header: RecordRef; TxtPSpecialText1: Text; TxtPSpecialText2: Text)
    var
        FldLRef: FieldRef;
        FldLRef2: FieldRef;
        DecLValue1: Decimal;
        DecLValue2: Decimal;
        IntLFieldNumber: Integer;
        IntLFieldNumber2: Integer;
    // RecLActiveSession: Record "Active Session"; TODO: unused
    begin
        IF TextNo = '' THEN
            EXIT;
        IF STRPOS(TextNo, '/') = 0 THEN BEGIN
            EVALUATE(IntLFieldNumber, TextNo);
            CASE IntLFieldNumber OF
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
                    BEGIN
                        RecLActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());
                        RecLActiveSession.SETRANGE("Session ID", SESSIONID());
                        RecLActiveSession.FINDFIRST();
                        Body := STRSUBSTNO(Body, FctConvertStr(RecLActiveSession."Server Computer Name"));
                    END;
                200000002:
                    BEGIN
                        RecLActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());
                        RecLActiveSession.SETRANGE("Session ID", SESSIONID());
                        RecLActiveSession.FINDFIRST;
                        Body := STRSUBSTNO(Body, FctConvertStr(RecLActiveSession."Database Name"));
                    END;
                200000003:
                    Body := STRSUBSTNO(Body, FctConvertStr(CopyStr(COMPANYNAME, 1, 1024)));

                ELSE BEGIN
                    FldLRef := Header.FIELD(IntLFieldNumber);
                    IF FORMAT(FldLRef.CLASS) = 'FlowField' THEN
                        FldLRef.CALCFIELD();
                    CASE FORMAT(FldLRef.TYPE) OF
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
                            BEGIN
                                EVALUATE(DecLValue1, FORMAT(FldLRef.VALUE));
                                Body := STRSUBSTNO(Body, FORMAT(ROUND(DecLValue1, 0.01)));
                            END ELSE
                                    Body := STRSUBSTNO(Body, FldLRef.VALUE);
                    END;
                END;
            END;
        END ELSE BEGIN
            EVALUATE(IntLFieldNumber, COPYSTR(TextNo, 1, STRPOS(TextNo, '/') - 1));
            EVALUATE(IntLFieldNumber2, COPYSTR(TextNo, STRPOS(TextNo, '/') + 1, STRLEN(TextNo)));
            FldLRef := Header.FIELD(IntLFieldNumber);
            IF FORMAT(FldLRef.CLASS) = 'FlowField' THEN
                FldLRef.CALCFIELD();

            FldLRef2 := Header.FIELD(IntLFieldNumber2);
            IF FORMAT(FldLRef2.CLASS) = 'FlowField' THEN
                FldLRef2.CALCFIELD();

            EVALUATE(DecLValue1, FORMAT(FldLRef.VALUE));
            EVALUATE(DecLValue2, FORMAT(FldLRef2.VALUE));
            IF DecLValue2 <> 0 THEN
                Body := STRSUBSTNO(Body, FORMAT(ROUND((DecLValue1 / DecLValue2), 0.01)))
            ELSE
                Body := STRSUBSTNO(Body, FORMAT(ROUND(DecLValue1, 0.01)))

        END;

    end;


    procedure FctConvertStr(TxtPStringToConvert: Text[1024]) TxtRStringToConvert: Text[1024]
    var
        BooLFirst: Boolean;
    begin
        BooLFirst := TRUE;
        TxtRStringToConvert := '';
        IF STRPOS(TxtPStringToConvert, ' ') <> 0 THEN BEGIN
            WHILE (STRPOS(TxtPStringToConvert, ' ') <> 0) DO BEGIN
                IF BooLFirst THEN
                    TxtRStringToConvert += COPYSTR(TxtPStringToConvert, 1, STRPOS(TxtPStringToConvert, ' ') - 1)
                ELSE
                    TxtRStringToConvert += '%20' + COPYSTR(TxtPStringToConvert, 1, STRPOS(TxtPStringToConvert, ' ') - 1);
                BooLFirst := FALSE;

                TxtPStringToConvert := COPYSTR(TxtPStringToConvert, STRPOS(TxtPStringToConvert, ' ') + 1, STRLEN(TxtPStringToConvert));
            END;
            TxtRStringToConvert += '%20' + TxtPStringToConvert;
        END ELSE
            TxtRStringToConvert := TxtPStringToConvert;
    end;


    procedure FctCreateMailMessage(TxtPFromName: Text[100]; TxtPFromAddress: Text[250]; TxtPSendTo: Text[250]; TxtPCC: Text[250]; TxtPBCC: Text[250]; TxtPSubject: Text[250]; TxtPBodyText: Text; BooPAutoSend: Boolean)
    var
        TxtLFromAddress: Text;
        TxtLFromName: Text;
    begin
        IF BooPAutoSend THEN BEGIN
            TxtLFromName := TxtPFromName;
            TxtLFromAddress := TxtPFromAddress;

            CduGSMTPMail.CreateMessage(TxtLFromName, TxtLFromAddress, '', TxtPSubject, TxtPBodyText, TRUE);
            //TO
            IF TxtPSendTo <> '' THEN
                IF STRPOS(TxtPSendTo, ';') > 1 THEN
                    CduGSMTPMail.FctAddTo(TxtPSendTo)
                ELSE
                    CduGSMTPMail.AddRecipients(TxtPSendTo);

            //CC
            IF TxtPCC <> '' THEN
                IF STRPOS(TxtPCC, ';') > 1 THEN
                    CduGSMTPMail.FctAddCC(TxtPCC)
                ELSE
                    CduGSMTPMail.AddCC(TxtPCC);

            //BCC
            IF TxtPBCC <> '' THEN
                IF STRPOS(TxtPBCC, ';') > 1 THEN
                    CduGSMTPMail.FctAddBCC(TxtPBCC)
                ELSE
                    CduGSMTPMail.AddBCC(TxtPBCC);

        END ELSE
            IF Mail.TryInitializeOutlook THEN
                Mail.CreateMessage(TxtPSendTo, TxtPCC, TxtPBCC, TxtPSubject, TxtPBodyText, TRUE, FALSE);

        BooGAutoSend := BooPAutoSend;
    end;


    procedure FctAddMailAttachment(AttachmentFilePath: Text; AttachmentFileName: Text)
    var
    begin
        IF AttachmentFilePath = '' THEN
            EXIT;
        IF BooGAutoSend THEN
            CduGSMTPMail.AddAttachment(AttachmentFilePath, AttachmentFileName)
        ELSE
            Mail.AttachFile(AttachmentFilePath);
    end;
}


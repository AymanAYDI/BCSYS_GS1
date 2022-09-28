codeunit 50046 "BC6_Convert Ansi-Ascii Manag"
{
    trigger OnRun()
    begin
    end;

    var
        CstGJournal: Label 'The folder name must end with a slash character, i.e. %1.';


    procedure Ansi2Ascii(TxtLString: Text[250]) _Output: Text[250]
    begin
        // Converts from ANSI to ASCII
        EXIT(CONVERTSTR(TxtLString, 'Ã³ÚÔõÓÕþÛÙÞ´¯ý’µã¶÷ž¹¨ Íœ°úÏÎâßÝ¾·±Ð¬‡Š«Œ‹“”‘–—¤•ËÈÊš›™',
                                'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáíóúñÑªº¿®ÁÂÀÊËÈÍÎÏÌÓßÔÒÚÛÙ'));
    end;


    procedure Ascii2Ansi(TxtLString: Text[1024]): Text[1024]
    begin
        // Converts from ASCII to ANSI
        EXIT(CONVERTSTR(TxtLString, 'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáíóúñÑªº¿®ÁÂÀÊËÈÍÎÏÌÓßÔÒÚÛÙ',
                                'Ã³ÚÔõÓÕþÛÙÞ´¯ý’µã¶÷ž¹¨ Íœ°úÏÎâßÝ¾·±Ð¬‡Š«Œ‹“”‘–—¤•ËÈÊš›™'));
    end;
}


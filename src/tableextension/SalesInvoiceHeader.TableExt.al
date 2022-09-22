tableextension 50000 "BC6_Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(50000; "BC6_Invoice Title"; Code[20])
        {
            TableRelation = "Standard Text".Code;
        }
        field(50001; "BC6_Send Status"; Enum "Send Status")
        {
            Caption = 'Send Status';
        }
    }
}

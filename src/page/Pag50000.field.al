page 50000 "BC6_field"
{
    ApplicationArea = All;
    Caption = 'field';
    PageType = List;
    SourceTable = "Field";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(TableNo; Rec.TableNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the table number.';
                }
                field(TableName; Rec.TableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table.';
                }

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID number of the field in the table.';
                }
                field(FieldName; Rec.FieldName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the field in the table.';
                }
            }
        }
    }
}

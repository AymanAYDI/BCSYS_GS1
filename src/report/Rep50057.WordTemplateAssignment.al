report 50057 "BC6_Word Template - Assignment"
{
    RDLCLayout = './src/Layout//WordTemplateAssignment.rdl';

    Caption = 'Modèle Word - Attribution de code';
    DefaultLayout = Word;
    WordMergeDataItem = "Sales Invoice Header";

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            column(Today_Date; FORMAT(TODAY))
            {
            }
            column(SalesInvoiceHeader_ExternalDocumentNo; "Sales Invoice Header"."External Document No.")
            {
            }
            column(SalesInvoiceHeader_InvoiceNo; "Sales Invoice Header"."No.")
            {
            }
            column(SalesInvoiceHeader_DocumentDate; FORMAT("Sales Invoice Header"."Document Date"))
            {
            }
            column(SalesInvoiceHeader_BillToName; "Sales Invoice Header"."Bill-to Name")
            {
            }
            column(SalesInvoiceHeader_BillToAddress; "Sales Invoice Header"."Bill-to Address")
            {
            }
            column(SalesInvoiceHeader_BillToAddress2; "Sales Invoice Header"."Bill-to Address 2")
            {
            }
            column(SalesInvoiceHeader_BillToPostCode; "Sales Invoice Header"."Bill-to Post Code")
            {
            }
            column(SalesInvoiceHeader_BillToCity; "Sales Invoice Header"."Bill-to City")
            {
            }
            column(SalesInvoiceHeader_BillToCountry; SalesInvoiceHeader_Country)
            {
            }
            dataitem(Contact; Contact)
            {
                DataItemLink = "No." = FIELD("Sell-to Contact No.");
                DataItemTableView = SORTING("No.")
                                    WHERE("Organizational Level Code" = CONST('PRINCIPAL'));
                column(Contact_Name; Contact.Name)
                {
                }
                column(Contact_Address; Contact.Address)
                {
                }
                column(Contact_Address2; Contact."Address 2")
                {
                }
                column(Contact_PostCode; Contact."Post Code")
                {
                }
                column(Contact_City; Contact.City)
                {
                }
                column(Contact_Country; Contact_Country)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    IF CountryRegion.GET(Contact."Country/Region Code") THEN
                        Contact_Country := CountryRegion.Name
                    ELSE
                        Contact_Country := '';
                end;
            }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = FIELD("Sell-to Customer No.");
                column(Customer_SIREN_SIRET; Customer."BC6_SIREN/SIRET")
                {
                }
                column(Customer_GTIN; COPYSTR(Customer.GLN, 1, 9))
                {
                }
                column(Customer_GLN; Customer.GLN)
                {
                }
                column(Customer_VATRegistrationNo; Customer."VAT Registration No.")
                {
                }
                column(Customer_Name; Customer.Name)
                {
                }
                column(Customer_Address; Customer.Address)
                {
                }
                column(Customer_Address2; Customer."Address 2")
                {
                }
                column(Customer_PostCode; Customer."Post Code")
                {
                }
                column(Customer_City; Customer.City)
                {
                }
                column(Customer_Country; Customer_Country)
                {
                }
                // column(Customer_ProductCountToCodify; Customer."Product Count To Codify") //TODO: champe DSM
                // {
                // }

                trigger OnAfterGetRecord()
                begin
                    IF CountryRegion.GET(Customer."Country/Region Code") THEN
                        Customer_Country := CountryRegion.Name
                    ELSE
                        Customer_Country := ''
                end;
            }
            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.");
                dataitem(GS1BarCode; "BC6_GS1 Bar Code")
                {
                    // DataItemLink = "Subscription No." = FIELD("Subscription No."), "Subscription Line No." = FIELD("Subscription Source Line No."); TODO:
                    DataItemTableView = SORTING("Entry No.");
                    column(GS1BarCode_Item_Code; GS1BarCode_Item_Code)
                    {
                    }
                    column(GS1BarCode_Prefix_Price; GS1BarCode_Prefix_Price)
                    {
                    }
                    column(GS1BarCode_Prefix_Wight; GS1BarCode_Prefix_Wight)
                    {
                    }
                    column(GS1BarCode_Prefix_StartCode; GS1BarCode.Num_Code)
                    {
                    }
                    column(GS1BarCode_Prefix_EndCode; GS1BarCode."Num_Code F")
                    {
                    }
                    column(GS1BarCode_Prefix_Description; GS1BarCode.LIB_Description)
                    {
                    }
                    column(GS1BarCode_Prefix_StartCode_pvar; GS1BarCode_Prefix_StartCode_pvar)
                    {
                    }
                    column(GS1BarCode_Prefix_EndCode_pvar; GS1BarCode_Prefix_EndCode_pvar)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        IF (STRLEN(GS1BarCode."Num_Code F") > 2) AND (STRLEN(GS1BarCode.Num_Code) > 2) THEN BEGIN
                            GS1BarCode_Item_Code := STRSUBSTNO('%1 %2', COPYSTR(GS1BarCode.Num_Code, 3, STRLEN(GS1BarCode.Num_Code) - 2), COPYSTR(GS1BarCode."Num_Code F", 3, STRLEN(GS1BarCode."Num_Code F") - 2));
                            GS1BarCode_Prefix_StartCode_pvar := COPYSTR(GS1BarCode.Num_Code, 3, STRLEN(GS1BarCode.Num_Code) - 2);
                            GS1BarCode_Prefix_EndCode_pvar := COPYSTR(GS1BarCode."Num_Code F", 3, STRLEN(GS1BarCode."Num_Code F") - 2);
                        END ELSE BEGIN
                            GS1BarCode_Item_Code := '';
                            GS1BarCode_Prefix_StartCode_pvar := '';
                            GS1BarCode_Prefix_EndCode_pvar := '';
                        END;

                        GS1BarCode_Prefix_Price := COPYSTR(GS1BarCode.Num_Code, 1, 2);

                        CASE GS1BarCode_Prefix_Price OF
                            '02':
                                GS1BarCode_Prefix_Wight := '29';
                            '24':
                                GS1BarCode_Prefix_Wight := '23';
                            '28':
                                GS1BarCode_Prefix_Wight := '25';
                            '26':
                                GS1BarCode_Prefix_Wight := '27';
                            '22':
                                GS1BarCode_Prefix_Wight := '21';
                            ELSE
                                GS1BarCode_Prefix_Wight := '';
                        END;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    //>>INC-09435-Y8J9N4
                    "Sales Invoice Line".SETRANGE(Type, "Sales Invoice Line".Type::Item);
                    "Sales Invoice Line".SETFILTER("Line No.", '>=10000');
                    "Sales Invoice Line".FINDFIRST();
                    //<<INC-09435-Y8J9N4
                end;
            }
            dataitem(CompanyInformation; "Company Information")
            {
                column(CompanyInformation_Name; CompanyInformation.Name)
                {
                }
                column(CompanyInformation_Address; CompanyInformation.Address)
                {
                }
                column(CompanyInformation_Address2; CompanyInformation."Address 2")
                {
                }
                column(CompanyInformation_PostCode; CompanyInformation."Post Code")
                {
                }
                column(CompanyInformation_City; CompanyInformation.City)
                {
                }
                column(CompanyInformation_Country; CompanyInformation_Country)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    IF CountryRegion.GET(CompanyInformation."Country/Region Code") THEN
                        CompanyInformation_Country := CountryRegion.Name
                    ELSE
                        CompanyInformation_Country := '';
                end;
            }

            trigger OnAfterGetRecord()
            begin
                IF CountryRegion.GET("Sales Invoice Header"."Bill-to Country/Region Code") THEN
                    SalesInvoiceHeader_Country := CountryRegion.Name
                ELSE
                    SalesInvoiceHeader_Country := '';
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        CountryRegion: Record "Country/Region";
        CompanyInformation_Country: Text;
        Contact_Country: Text;
        Customer_Country: Text;
        GS1BarCode_Item_Code: Text;
        GS1BarCode_Prefix_EndCode_pvar: Text;
        GS1BarCode_Prefix_Price: Text;
        GS1BarCode_Prefix_StartCode_pvar: Text;
        GS1BarCode_Prefix_Wight: Text;
        SalesInvoiceHeader_Country: Text;
}


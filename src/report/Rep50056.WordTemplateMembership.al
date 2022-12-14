report 50056 "BC6_Word Template - Membership"
{
    RDLCLayout = './src/Layout/WordTemplateMembership.rdl';
    Caption = 'Modèle Word - Adhésion', comment = 'FRA="Word Template - Membership"';
    DefaultLayout = Word;
    WordMergeDataItem = Customer;

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(Today_Date; FORMAT(TODAY))
            {
            }
            column(Customer_SIREN_SIRET; Customer."BC6_SIREN/SIRET")
            {
            }
            column(Customer_GTIN; COPYSTR(Customer.GLN, 1, 9))
            {
            }
            column(Customer_GLN; Customer.GLN)
            {
            }
            column(Customer_Name; Customer.Name)
            {
            }
            column(Customer_VATRegistrationNo; Customer."VAT Registration No.")
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
            dataitem(Contact; Contact)
            {
                DataItemTableView = sorting("No.")
                                    where("Organizational Level Code" = const('PRINCIPAL'));
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
                    if CountryRegion.GET(Contact."Country/Region Code") then
                        Contact_Country := CountryRegion.Name
                    else
                        Contact_Country := '';
                end;

                trigger OnPreDataItem()
                begin
                    Contact.SETRANGE("Company No.", Customer.GetContact());
                end;
            }
            dataitem(GS1BarCode; "BC6_GS1 Bar Code")
            {
                DataItemLink = "Customer No." = field("No.");
                DataItemTableView = sorting("Entry No.")
                                        where(B_CnufPrincipal = const(true));
                column(GS1BarCode_Prefix_StartCode; GS1BarCode.Num_Code)
                {
                }
                column(GS1BarCode_Prefix_EndCode; GS1BarCode."Num_Code F")
                {
                }
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
                    if CountryRegion.GET(CompanyInformation."Country/Region Code") then
                        CompanyInformation_Country := CountryRegion.Name
                    else
                        CompanyInformation_Country := '';
                end;
            }
        }
    }
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation_Country: Text;
        Contact_Country: Text;
}

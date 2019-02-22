/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetAddressLocation
Description:  This class contain method that handles get asset address location call - story #4316381 
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/29/2018     1.0     Rodrigo Carpio      Initial Release
08/21/2018     1.1     Harsha Reddy        DEFECT 5503837
-------------------------------------------------------------------------------------------------------------------------- */
public class AssetAddressLocation {

    @TestVisible public static List < AssetLocationResponse__x > mockedAssetLocationRespnse = new List < AssetLocationResponse__x > ();

    public class AssetAddressWrapper {
        @InvocableVariable(label = 'Street Address')
        public String streetAddress;
        @InvocableVariable(label = 'City')
        public String cityAddress;
        @InvocableVariable(label = 'State')
        public String stateAddress;
        @InvocableVariable(label = 'Postal Code')
        public String postalCodeAddress;
        @InvocableVariable(label = 'Country')
        public String countryAddress;
        @InvocableVariable(label = 'Party Location Id')
        public String partyLocationId;
        @InvocableVariable(label = 'Asset Party Location Id')
        public String assetPartyLocationId;
        @InvocableVariable(label = 'Billing Street Address')
        public String streetAddressBilling;
        @InvocableVariable(label = 'Billing Street Address 2')
        public String streetAddressBilling2;
        @InvocableVariable(label = 'Billing City')
        public String cityAddressBilling;
        @InvocableVariable(label = 'Billing State')
        public String stateAddressBilling;
        @InvocableVariable(label = 'Billing Postal Code')
        public String postalCodeAddressBilling;
        @InvocableVariable(label = 'Billing Country')
        public String countryAddressBilling;
        @InvocableVariable(label = 'Brazil Address Line1')
        public String BrazilAddressLine1;
        @InvocableVariable(label = 'Brazil Address Line2')
        public String BrazilAddressLine2;
        @InvocableVariable(label = 'Brazil Address Line3')
        public String BrazilAddressLine3;
        @InvocableVariable(label = 'Brazil Address Line4')
        public String BrazilAddressLine4;

        public AssetAddressWrapper() {
            this.streetAddress = streetAddress;
            this.cityAddress = cityAddress;
            this.stateAddress = stateAddress;
            this.postalCodeAddress = postalCodeAddress;
            this.countryAddress = countryAddress;
            this.partyLocationId = partyLocationId;
            this.assetPartyLocationId = assetPartyLocationId;
            this.streetAddressBilling = streetAddressBilling;
            this.streetAddressBilling2 = streetAddressBilling2;
            this.cityAddressBilling = cityAddressBilling;
            this.stateAddressBilling = stateAddressBilling;
            this.postalCodeAddressBilling = postalCodeAddressBilling;
            this.countryAddressBilling = countryAddressBilling;
            this.BrazilAddressLine1 = BrazilAddressLine1;
            this.BrazilAddressLine2 = BrazilAddressLine2;
            this.BrazilAddressLine3 = BrazilAddressLine3;
            this.BrazilAddressLine4 = BrazilAddressLine4;
        }
    }

    // Method to Invoke To Get Asset Address
    @InvocableMethod(label = 'Asset Address Location'
        description = 'Call Bill to get asset address location')
    public static List < AssetAddressWrapper > getAssetAddressLocation(list < string > serviceTagList)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getAssetAddressLocation
    Description:  this functions makes a call to BIL to pull the asset address information 
    Input: servicetag - 
    Output: Address information wrapper
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/29/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            List < AssetAddressWrapper > addrWrapList = new List < AssetAddressWrapper > ();
            AssetAddressWrapper addrWrap = new AssetAddressWrapper();

            list < AssetLocationResponse__x > assetAddress = new list < AssetLocationResponse__x > ();

            assetAddress = (!mockedAssetLocationRespnse.isEmpty()) ? mockedAssetLocationRespnse : [select ServiceTagId__c, AddressLine1__c,
                AddressLine2__c, AddressLine3__c, AddressLine4__c,
                City__c, Country__c, PostalCode__c, State__c, ResponseCode__c, ResponseMessage__c,
                AssetPartyLocationId__c, PartyLocationId__c,
                BillingAddressLine1__c,
                BillingAddressLine2__c, BillingAddressLine3__c, BillingAddressLine4__c,
                BillingCity__c, BillingCountry__c, BillingPostalCode__c, BillingState__c
                from AssetLocationResponse__x where ServiceTagId__c =: serviceTagList[0] limit 1
            ];
            //Akhil testing:
            /*AssetLocationResponse__x obj = new AssetLocationResponse__x();
            assetAddress.add(obj);
            assetAddress[0].Country__c='BR';
            assetAddress[0].AddressLine1__c='Street1';
            assetAddress[0].AddressLine2__c='Street2';
            //assetAddress[0].AddressLine3__c='Street3';
            //assetAddress[0].AddressLine4__c='Street4';
            //assetAddress[0].City__c='ARCity';
            assetAddress[0].PostalCode__c='2323';
            assetAddress[0].State__c='AM';
            assetAddress[0].ResponseCode__c='100';
            //assetAddress.add(obj);*/
            System.debug('Akhil++++ Value in ASset Address'+assetAddress[0]);
            if (!assetAddress.isEmpty() && assetAddress.size() > 0) {
                if (assetAddress[0].ResponseCode__c.equals('100')) {
                    string lineAddress = '';
                    if (string.isNotBlank(assetAddress[0].AddressLine1__c)) {
                        lineAddress = lineAddress + assetAddress[0].AddressLine1__c;
                    }
                    
                    // conditions added for 6051876 to avoid concatenation of all street line address for LATAM countries                   
                    if (String.isNotBlank(assetAddress[0].Country__c) )
                    {
                        string countryCode = assetAddress[0].Country__c;
                        if (Label.LatamCountries.lastIndexOfIgnoreCase(countryCode) < 0)
                        {
                            if (string.isNotBlank(assetAddress[0].AddressLine2__c)) {
                            lineAddress = lineAddress + ' ' + assetAddress[0].AddressLine2__c;
                            }
                            if (string.isNotBlank(assetAddress[0].AddressLine3__c)) {
                                lineAddress = lineAddress + ' ' + assetAddress[0].AddressLine3__c;
                            }
                            if (string.isNotBlank(assetAddress[0].AddressLine4__c)) {
                                lineAddress = lineAddress + ' ' + assetAddress[0].AddressLine4__c;
                            }
							
							if(lineAddress.length()>255)
                            {
                                lineAddress = lineAddress.substring(0, 254);
                            }
                        }
                    }
                    if (String.isNotBlank(assetAddress[0].City__c)) {
                        addrWrap.cityAddress = assetAddress[0].City__c;
                    }
                    if (String.isNotBlank(assetAddress[0].PostalCode__c)) {
                        addrWrap.postalCodeAddress = assetAddress[0].PostalCode__c;
                    }
                    if (String.isNotBlank(assetAddress[0].State__c)) {
                        System.debug('Akhil++ Inside State'+assetAddress[0].State__c);
                        addrWrap.stateAddress = assetAddress[0].State__c;
                    }
                    if (String.isNotBlank(assetAddress[0].Country__c)) {
                        System.debug('Akhil++ Inside Country'+assetAddress[0].Country__c);
                        addrWrap.countryAddress = assetAddress[0].Country__c;
                    }
                    if (String.isNotBlank(assetAddress[0].AssetPartyLocationId__c)) {
                        addrWrap.assetPartyLocationId = assetAddress[0].AssetPartyLocationId__c;
                    }
                    if (String.isNotBlank(assetAddress[0].PartyLocationId__c)) {
                        addrWrap.partyLocationId = assetAddress[0].PartyLocationId__c;
                    }
                    addrWrap.streetAddress = lineAddress;

                    /*
                    if (assetAddress[0].BillingAddressLine1__c != null)
                        lineAddress = lineAddress + assetAddress[0].BillingAddressLine1__c + '\n\r';
                    if (assetAddress[0].BillingAddressLine2__c != null)
                        lineAddress = lineAddress + assetAddress[0].BillingAddressLine2__c + '\n\r';
                    if (assetAddress[0].BillingAddressLine3__c != null)
                        lineAddress = lineAddress + assetAddress[0].BillingAddressLine3__c + '\n\r';
                    if (assetAddress[0].BillingAddressLine4__c != null)
                        lineAddress = lineAddress + assetAddress[0].BillingAddressLine4__c + '\n\r';
                    */
                    if (String.isNotBlank(assetAddress[0].BillingAddressLine1__c)) {
                        addrWrap.streetAddressBilling = assetAddress[0].BillingAddressLine1__c;
                    }
                    if (String.isNotBlank(assetAddress[0].BillingAddressLine2__c)) {
                        addrWrap.streetAddressBilling2 = assetAddress[0].BillingAddressLine2__c;
                    }
                    if (String.isNotBlank(assetAddress[0].BillingCity__c)) {
                        addrWrap.cityAddressBilling = assetAddress[0].BillingCity__c;
                    }
                    if (String.isNotBlank(assetAddress[0].BillingPostalCode__c)) {
                        addrWrap.postalCodeAddressBilling = assetAddress[0].BillingPostalCode__c;
                    }
                    if (String.isNotBlank(assetAddress[0].BillingState__c)) {
                        addrWrap.stateAddressBilling = assetAddress[0].BillingState__c;
                    }
                    if (String.isNotBlank(assetAddress[0].BillingCountry__c)) {
                        addrWrap.countryAddressBilling = assetAddress[0].BillingCountry__c;
                    }
                    System.debug('Akhil++ custom label value:' +System.Label.LatamCountries);
                    if (System.Label.LatamCountries.contains(assetAddress[0].Country__c)){
                        System.debug('Akhil++ Inside Latam Country street update'+assetAddress[0].Country__c);
                        if (string.isNotBlank(assetAddress[0].AddressLine1__c)) {
                        addrWrap.BrazilAddressLine1 = assetAddress[0].AddressLine1__c;
                        }
                        if (string.isNotBlank(assetAddress[0].AddressLine2__c)) {
                        addrWrap.BrazilAddressLine2 = assetAddress[0].AddressLine2__c;
                        }
                        if (string.isNotBlank(assetAddress[0].AddressLine3__c)) {
                        addrWrap.BrazilAddressLine3 = assetAddress[0].AddressLine3__c;
                        }
                        if (string.isNotBlank(assetAddress[0].AddressLine4__c)) {
                        addrWrap.BrazilAddressLine4 = assetAddress[0].AddressLine4__c;
                        }
                    }
                    addrWrapList.add(addrWrap);
                }
            }
            return addrWrapList;
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'CreateDispatchHandler', 'AssetAddressLocation', 'Dispatch Management');
            return null;
        }
    }
}
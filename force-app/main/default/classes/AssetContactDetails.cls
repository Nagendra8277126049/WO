/*
Name:       AssetContactDetails
Description:  This class contain method to get and update asset contacts details - story #4150193
Date         Version     Author                   Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio             Initial Release
30/04/2018     1.1     Srikanth Parvathareddy     Story #4918471 - Contact Field Addition Due to BIL PCF Changes
06/07/2018     1.2     Brundha rajkumar           Defect #5174955
07/10/2018     1.3     Brundha Rajkumar           Updated condition for task #5287275
-------------------------------------------------------------------------------------------------------------------------- */
global class AssetContactDetails {
    public class AssetContactDetailsWrapper{
        @AuraEnabled public String serviceTag; 
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        //   @AuraEnabled public String areaCode;
        @AuraEnabled public String countryCode;
        @AuraEnabled public String extension;
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String addressType;
        @AuraEnabled public String secondaryFirstName;
        @AuraEnabled public String secondaryLastName;
        @AuraEnabled public String secondaryEmail;
        //     @AuraEnabled public String secondaryAreaCode;
        @AuraEnabled public String secondaryCountryCode;
        @AuraEnabled public String secondaryExtension;
        @AuraEnabled public String secondaryPhoneNumber;
        @AuraEnabled public String secondaryAddressType;
        @AuraEnabled public String tertiaryFirstName;
        @AuraEnabled public String tertiaryLastName;
        @AuraEnabled public String tertiaryEmail;
        //   @AuraEnabled public String tertiaryAreaCode;
        @AuraEnabled public String tertiaryCountryCode;
        @AuraEnabled public String tertiaryExtension;
        @AuraEnabled public String tertiaryPhoneNumber;
        @AuraEnabled public String tertiaryAddressType;
        @AuraEnabled public String fullName;
        @AuraEnabled public String secondaryFullName;
        @AuraEnabled public String tertiaryFullName;
        @AuraEnabled public String fullPhone;
        @AuraEnabled public String secondaryFullPhone;
        @AuraEnabled public String tertiaryFullPhone;
        @AuraEnabled public String message;
        @AuraEnabled public integer code;
        @AuraEnabled public boolean isReadOnly;
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
Name:       formatRequest
Description:  this functions is used to format the JSON request string - story #4150193
Date         Version  Author                    Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio           Initial Release
30/04/2018     1.1     Srikanth Parvathareddy   Story #4918471 - Contact Field Addition Due to BIL PCF Changes
-------------------------------------------------------------------------------------------------------------------------- */    
    @TestVisible private static string formatRequest(String ContactCode, String sServiceTag, string sFirstName, string sLastName, 
                                                     /* string sPhoneAreaCode ,*/ string sPhoneNumber, string sAddressType, string sEmailAddress, 
                                                     string sCountryCode,string AssetPartyLocationId,string PartyLocationId,string PartyId,string MiddleName,
                                                     String Title,String Department,String OrganizationName,String Language,String AlternateContactName,
                                                     String AlternateGivenName,String AlternateMiddleName,String AlternateLastName,String PartyContactMethodIdEmail,
                                                     String PartyContactMethodIdPhone
                                                    ) 
    {
        try {
            // format request body
            JSONGenerator gen = JSON.createGenerator(true);  
            
            // Write data to the JSON string.
            gen.writeStartObject();
            
            // will construct standard request header details
            CommonRequestHeader MessageHeader = new CommonRequestHeader();
            MessageHeader.SetDefaultValues();
            gen.writeFieldName('MessageHeader');
            gen.writeObject(MessageHeader);
            
            // format contact details  
            gen.writeFieldName('AssetContactUpdate');
            gen.writeStartObject();
            gen.writeStringField('ServiceTag', sServiceTag);
            gen.writeStringField(ContactCode+'FirstName', sFirstName);
            gen.writeStringField(ContactCode+'LastName', sLastName);
            
            /*     if ((sPhoneAreaCode != null) && (sPhoneAreaCode != ''))
gen.writeStringField(ContactCode+'PhoneAreaCode', sPhoneAreaCode);
else
gen.writeStringField(ContactCode+'PhoneAreaCode', '');*/
            
            gen.writeStringField(ContactCode+'PhoneNumber', sPhoneNumber);
            
            if (sAddressType != null)
                gen.writeStringField(ContactCode+'AddressType', sAddressType);
            else    
                gen.writeStringField(ContactCode+'AddressType','CP');
            if (sEmailAddress!=null)
                gen.writeStringField(ContactCode+'EmailAddress', sEmailAddress);
            else
                gen.writeStringField(ContactCode+'EmailAddress', '');
            if ( (sCountryCode != null) && (sCountryCode != ''))
                gen.writeStringField(ContactCode+'CountryCode', sCountryCode);
            else
                gen.writeStringField(ContactCode+'CountryCode', '');
            
            gen.writeEndObject();
            
            gen.writeEndObject();
            
            String requestStr = gen.getAsString();
           // system.debug('request'+requestStr);
            return requestStr;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssetContactDetails','formatRequest','AssetManagement');
            return null;
        }
    }    
    @AuraEnabled
    public static integer updateAssetContact(String ContactCode, String sServiceTag, string sFirstName, string sLastName, 
                                             /* string sPhoneAreaCode,*/ string sPhoneNumber, string sAddressType, string sEmailAddress, string sCountryCode,
                                             String AssetPartyLocationId,String PartyLocationId,String PartyId,String MiddleName,
                                             String Title,String Department,String OrganizationName,String Language,String AlternateContactName,
                                             String AlternateGivenName,String AlternateMiddleName,String AlternateLastName,String PartyContactMethodIdEmail,
                                             String PartyContactMethodIdPhone
                                            ) 
        /* -----------------------------------------------------------------------------------------------------------------------
Name:       updateAssetContact
Description:  this functions calls REST API operation, to perform update on asset contact - story #4150193
Date         Version  Author                    Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio           Initial Release
03/08/2018     2.0     Rodrigo Carpio           Mode the JSON request string formatting into a function formatRequest
30/04/2018     1.1     Srikanth Parvathareddy   Story #4918471 - Contact Field Addition Due to BIL PCF Changes
-------------------------------------------------------------------------------------------------------------------------- */
    {
        try {            
            string requestStr = formatRequest(ContactCode, sServiceTag, sFirstName, sLastName, 
                                              /*  sPhoneAreaCode, */ sPhoneNumber, sAddressType, sEmailAddress, sCountryCode,
                                              AssetPartyLocationId,PartyLocationId,PartyId,MiddleName,
                                              Title,Department,OrganizationName,Language,AlternateContactName,
                                              AlternateGivenName,AlternateMiddleName,AlternateLastName,PartyContactMethodIdEmail,
                                              PartyContactMethodIdPhone
                                             ); 
            // perform the REST API call
            // 
            // // perform the REST API call
            Http httpProtocol = new Http();
            
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            
            // set end point
            request.setEndPoint('callout:AssetContactUpdate');
            
            //set header
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            
            //set timeout
            request.setTimeout(5000);
            
            // set request body
            // Added condition for the task #5317972
            if(!string.isEmpty(requestStr)){
                request.setBody(requestStr);
            }
            
            // Set the HTTP verb to POST.
            request.setMethod('POST');
            
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            response = httpProtocol.send(request);
            integer intCode;
            
            if (response!=null && response.getStatusCode() == 200) {
                assetContactDetailsJSON dezresponse = (assetContactDetailsJSON)JSON.deserialize(response.getBody(), assetContactDetailsJSON.class); 
                CommonMessageHeader respHeaderMsg = dezresponse.MessageHeader;
                
                CommonReturnMessaging respMsg = respHeaderMsg.ReturnMessaging;
                if (respMsg.Code == '100'){
                    intCode = response.getStatusCode();
                }else{
                    intCode = 500;                    
                }                    
            }
            else{
                ExceptionHandler.logCalloutErrors(response,'AssetContactDetails','', 'AssetManagement');
            }
            
            return intCode;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssetContactDetails','updateAssetContact','AssetManagement');
            return null;
        }
    }
    
    
    @AuraEnabled
    public static AssetContactDetailsWrapper getAssetContactDetails(Id recordId) 
        /* -----------------------------------------------------------------------------------------------------------------------
Name:       getAssetContactDetails
Description:  this functions calls REST API operation, to perform get asset contact - story #4150193
Date         Version  Author                    Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio           Initial Release
03/08/2018     2.0     Rodrigo Carpio           Mode the line of codes to format the contact details response formatContactDetails
30/04/2018     1.1     Srikanth Parvathareddy   Story #4918471 - Contact Field Addition Due to BIL PCF Changes
-------------------------------------------------------------------------------------------------------------------------- */
    {
        try 
        {            
            string AssetName = [SELECT Name FROM Asset WHERE Id = :recordID LIMIT 1].Name;
            // format request body
            JSONGenerator gen = JSON.createGenerator(true);  
            
            // Write data to the JSON string.
            gen.writeStartObject();
            gen.writeStringField('ServiceTag', AssetName);
            CommonRequestHeader MessageHeader = new CommonRequestHeader();
            MessageHeader.SetDefaultValues();
            gen.writeFieldName('MessageHeader');
            gen.writeObject(MessageHeader);            
            gen.writeEndObject();
            
            String pretty = gen.getAsString();
            //system.debug(pretty);
            
            // perform the REST API call
            Http httpProtocol = new Http();
            
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            
            // set end point
            request.setEndPoint('callout:AssetContactDetails');
            
            //set header
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            
            //set timeout
            request.setTimeout(5000);
            
            // set request body
            // Added condition for the task #5317972
            if(!string.isEmpty(pretty)){
                request.setBody(pretty);
            }
            
            // Set the HTTP verb to POST.
            request.setMethod('POST');
            
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            response = httpProtocol.send(request);
            AssetContactDetailsWrapper assetContactWrapper = new AssetContactDetailsWrapper();
            // get JSONparser object
            JSONParser parser = JSON.createParser(response.getBody());
            //Object obj;
            //system.debug('body'+response.getBody());
            
            
            if(response!=null && response.getStatusCode()==200)
            {
                assetContactDetailsJSON dezresponse = (assetContactDetailsJSON)JSON.deserialize(response.getBody(), assetContactDetailsJSON.class); 
                
                system.debug('dezresponse'+dezresponse);
                /*
assetContactDetailsJSON parser = (assetContactDetailsJSON) commUtil.ResponseObject;  
*/
                if(dezresponse!=null && dezresponse.assetContactDetails!=null){ //  Added If condition for task #5287275
                    assetContactWrapper = formatContactDetails(dezresponse.assetContactDetails);
                }
                
                String profileName = [Select Name from Profile where Id =: userinfo.getProfileid() limit 1].name;
                
                if (profileName.equalsIgnoreCase(Label.System_Read_Only)||profileName.equalsIgnoreCase(Label.Service_Agent_Read_Only))
                    assetContactWrapper.isReadOnly = true;
                else
                    assetContactWrapper.isReadOnly = false;            
            }
            else{
                ExceptionHandler.logCalloutErrors(response,'AssetContactDetails',recordID, 'AssetManagement');
            }
            
            assetContactWrapper.Message = response.getStatus();
            assetContactWrapper.Code = response.getStatusCode();
            
            return assetContactWrapper;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssetContactDetails','getAssetContactDetails','AssetManagement');
            return null;
        }
    }
    /* -----------------------------------------------------------------------------------------------------------------------
Name:       formatContactDetails
Description:  this functions is used to format the contact details response - story #4150193
Date         Version   Author                   Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/08/2018     1.0     Rodrigo Carpio           Initial Release
30/04/2018     1.1     Srikanth Parvathareddy   Story #4918471 - Contact Field Addition Due to BIL PCF Changes
-------------------------------------------------------------------------------------------------------------------------- */
    @TestVisible private static AssetContactDetailsWrapper formatContactDetails(assetContactDetailsJSON.AssetContactDetailsResponse parser)
    {
        try {
            AssetContactDetailsWrapper assetContactWrapper = new AssetContactDetailsWrapper();
            assetContactDetailsJSON.AssetContactDetailsResponse con = new assetContactDetailsJSON.AssetContactDetailsResponse();
            
            con = parser;
            assetContactWrapper.ServiceTag = con.ServiceTag; 
            assetContactWrapper.FirstName = con.PrimaryFirstName;
            assetContactWrapper.LastName = con.PrimaryLastName;
            assetContactWrapper.Email = con.PrimaryEmail;
            //  assetContactWrapper.AreaCode = con.PrimaryAreaCode;
            assetContactWrapper.CountryCode = con.PrimaryCountryCode;
            assetContactWrapper.Extension = con.PrimaryExtension;  
            assetContactWrapper.PhoneNumber = con.PrimaryPhoneNumber; 
            assetContactWrapper.AddressType = con.PrimaryAddressType; 
            assetContactWrapper.SecondaryFirstName = con.SecondaryFirstName;
            assetContactWrapper.SecondaryLastName = con.SecondaryLastName;
            assetContactWrapper.SecondaryEmail = con.SecondaryEmail;
            //   assetContactWrapper.SecondaryAreaCode = con.SecondaryAreaCode;
            assetContactWrapper.SecondaryCountryCode = con.SecondaryCountryCode;
            assetContactWrapper.SecondaryExtension = con.SecondaryExtension; 
            assetContactWrapper.SecondaryPhoneNumber = con.SecondaryPhoneNumber;
            assetContactWrapper.SecondaryAddressType = con.SecondaryAddressType; 
            assetContactWrapper.TertiaryFirstName = con.TertiaryFirstName;
            assetContactWrapper.TertiaryLastName = con.TertiaryLastName;
            assetContactWrapper.TertiaryEmail = con.TertiaryEmail;
            //   assetContactWrapper.TertiaryAreaCode = con.TertiaryAreaCode;
            assetContactWrapper.TertiaryCountryCode = con.TertiaryCountryCode;
            assetContactWrapper.TertiaryExtension = con.TertiaryExtension;
            assetContactWrapper.TertiaryPhoneNumber = con.TertiaryPhoneNumber;
            assetContactWrapper.TertiaryAddressType = con.TertiaryAddressType;
            
            if (con.PrimaryFirstName != null)
                assetContactWrapper.FullName = con.PrimaryFirstName + ' ' + con.PrimaryLastName;
            if (con.SecondaryFirstName != null)
                assetContactWrapper.SecondaryFullName = con.SecondaryFirstName + ' ' + con.SecondaryLastName;
            if (con.TertiaryFirstName != null)
                assetContactWrapper.TertiaryFullName = con.TertiaryFirstName + ' ' + con.TertiaryLastName;
            
            assetContactWrapper.fullPhone = formatPhoneNumber(con.PrimaryCountryCode,/* con.PrimaryAreaCode,*/ con.PrimaryPhoneNumber);
            assetContactWrapper.SecondaryFullPhone = formatPhoneNumber(con.SecondaryCountryCode,/* con.SecondaryAreaCode,*/ con.SecondaryPhoneNumber);
            assetContactWrapper.TertiaryFullPhone = formatPhoneNumber(con.TertiaryCountryCode,/* con.TertiaryAreaCode,*/ con.TertiaryPhoneNumber);
            
            return assetContactWrapper;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssetContactDetails','formatContactDetails','AssetManagement');
            return null;
        }
    }
    
    @TestVisible private static string formatPhoneNumber (string countryCode,/* string areadCode,*/ string phoneNumber)
        /* -----------------------------------------------------------------------------------------------------------------------
Name:       formatPhoneNumber
Description:  this functions is used to format the phone number for display - story #4150193
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
12/05/2017     1.0     Rodrigo Carpio      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
    {
        string fullPhoneStr = '';        
        
        if (countryCode != null ) {
            //  fullPhoneStr = fullPhoneStr + '+';
            fullPhoneStr ='+'+countryCode;
        }
        // fullPhoneStr = fullPhoneStr + '-';
        /*   if (areadCode != null )
fullPhoneStr = fullPhoneStr + areadCode;
else 
fullPhoneStr = fullPhoneStr + ' '; */
        //   fullPhoneStr = fullPhoneStr + '-';
        if (phoneNumber != null )
            fullPhoneStr = fullPhoneStr +'-'+ phoneNumber;
        // else 
        //  fullPhoneStr = fullPhoneStr + ' ';
        
        return fullPhoneStr;
    }
}
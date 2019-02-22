/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssociateServiceTagHandler
Description:  This class contains the asset association logic #4640778
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/07/2018     1.0     Rodrigo Carpio      Initial Release
03/12/2018     1.1     Roselin Hephzibah   Added a method for story #4718475
05/14/2018     1.2     Surya               Added a method - assetUpdatePB
05/19/2018     1.3     Pavan Samanthapudi  Createad the method MapAssetToCase and moved the existing code from method: AssociateServiceTag
                                           to MapAssetToCase so that the same code can be excuted from Lightning Component(Chat) and through Process builder(for SRO)
05/19/2018     1.0     Pavan Samanthapudi   Created this function to make an API call in async mode   
07/10/2018     1.4     Brundha Rajkumar    updated the conditions for the task # 5287278
                                     
-------------------------------------------------------------------------------------------------------------------------- */

public class AssociateServiceTagHandler {
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       associateServiceTag
    Description:  this functions makes a call to BIL to pull the asset information for the record to be created in SFDC
    Input: recordId - holds the record identifier to pull the needed information i.e case id, transcript id
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/07/2018     1.0     Rodrigo Carpio      Initial Release
    03/27/2018     1.1     Roselin Hephzibah   Updated to Handle existing asset in Salesforce.
    05/19/2018     1.2     Pavan Samanthapudi  Moved the existing code from this method to MapAssetToCase
    -------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static string associateServiceTag(Id recordId){

        String assetId=MapAssetToCase(recordId);
        return assetId;
    }    

    /* -----------------------------------------------------------------------------------------------------------------------
    Name        :  assetUpdatePB
    Description :  this functions is created to be called from Process Builder when an Asset id is not found in SFDC for SRO Case Creation.
    Input: caseObject - holds the case record that is passed from a process builder.
    Output: None
    Date         Version       Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    05/08/2018     1.0         Surya           Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @InvocableMethod
    public static void assetUpdatePB(List<Case> caseObject)
            {
        for(Case c:caseObject)
        {
           MakeAPICallAsync(c.id);
        }    
        
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name        :  MakeAPICallAsync
    Description :  this functions makes an API call in Async when the asset is not found in SFDC for SRO case creation.
    Input: caseId - holds the record identifier to pull the asset number of the case.
    Output: None
    Date         Version       Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    05/19/2018     1.0         Pavan           Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @Future(callout=true)
    public static void MakeAPICallAsync(Id i)
    
    {
         MapAssetToCase(i);         
    }
    
    
    @TestVisible private static string MapAssetToCase(Id recordId)
    {
        string assetName='';
        string assetId= null;  
        string accountId=''; 
        string replyCode='100';        
        Case caseObj;
        
        try
        {
            caseObj = [SELECT Id,Service_Tag__c, AssetId, AccountId, ContactId, NonAgentContactEmail__c, NonAgentContactFirstName__c, NonAgentContactLastName__c, NonAgentContactPhone__c, TranscriptId__c FROM Case WHERE Id = :recordId LIMIT 1];
            
            if (caseObj.Service_Tag__c != '' && caseObj.Service_Tag__c != null) 
            {
                List<Asset> assetList = [Select Id,Name from Asset WHERE Name =: caseObj.Service_Tag__c limit 1]; //Check if Asset exists in salesforce.
                if (assetList.isEmpty())
                { 
                    BILAssetInformation bilAssetInfo;// = (BILAssetInformation) JSON.deserialize(strResponse, BILAssetInformation.class);   
                    bilAssetInfo = performAPICall(caseObj.Service_Tag__c);
                    
                    if (bilAssetInfo != null)
                    {   
                        assetId = performAssetAssociation(caseObj, bilAssetInfo);                   
                    }
                } 
                else {
                    //updateAssetinCase(assetList[0].Name,caseObj.Id); //If the asset exist in Salesforce, Update the asset in case.
                    caseObj.AssetId = assetList[0].Id;
                    assetId = assetList[0].Id;
                    update caseObj;
                    if (caseObj.TranscriptId__c != null && caseObj.TranscriptId__c != '')
                    {
                        LiveChatTranscript liveChatObj = new LiveChatTranscript();
                        liveChatObj = [SELECT Id, Asset__c FROM LiveChatTranscript WHERE Id = :caseObj.TranscriptId__c limit 1]; //Changed Asset field from AssetId__c to Asset__c(lookup)
                        if(liveChatObj.Asset__c == null || (caseObj.Case_Age__c!=null && caseObj.Case_Age__c.Contains('Hour(s)'))) { // Added if conditions for the task # 5287278
                            liveChatObj.Asset__c = assetId;
                            update liveChatObj;
                        }
                    }
                }
            }            
            return assetId;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssociateServiceTagHandler','performAssociation','Case Management');  
            return null;
        }
    
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       performAssetAssociation
    Description:  this functions perform asset association 
    Input: objectCase - case objects that holds information needed to create a new contact record
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/08/2018     1.0     Rodrigo Carpio      Initial Release
    03/14/2018     1.1     Roselin Hephzibah   Updated method to handle Asset that exist in Salesforce
    03/28/2018     1.2     Roselin Hephzibah   Updated method to handle Account that does not exist in salesforce
    -------------------------------------------------------------------------------------------------------------------------- */
    @TestVisible public static string performAssetAssociation(case caseObj, BILAssetInformation bilAssetInfo)
     
    {
        string assetId;
        string contactId;
        Case objectCase = caseObj;
        string customerNumber = bilAssetInfo.asset.customerNumber;
        string customerBUID = bilAssetInfo.asset.customerBuid;
        try { 
            
            List<Account> accountList = [SELECT Id FROM Account WHERE (AccountNumber = :bilAssetInfo.asset.customerNumber and BUID__c = :bilAssetInfo.asset.customerBuid) or (AccountNumber LIKE: '%'+bilAssetInfo.asset.customerNumber and BUID__c = :bilAssetInfo.asset.customerBuid) LIMIT 1];                     
            
            If(!accountList.isEmpty()){
                objectCase.AccountId = accountList[0].Id;            
                contactId = createContact(objectCase);  
                
                if (contactId != '' && contactId != null)
                    objectCase.ContactId = contactId;   
                
                assetId = createAsset(bilAssetInfo, accountList[0].Id);  
                
                if (assetId != '' && assetId != null)
                    objectCase.AssetId = assetId;                
                
                update objectCase;
                
                if (objectCase.TranscriptId__c != null && objectCase.TranscriptId__c != '')
                {
                    LiveChatTranscript liveChatObj = new LiveChatTranscript();
                    liveChatObj = [SELECT Id, Asset__c, ContactId, AccountId, CustomerNumber__c, CustomerBUID__c , caseId   FROM LiveChatTranscript WHERE Id = :objectCase.TranscriptId__c limit 1]; //Changed Asset field from AssetId__c to Asset__c(lookup)
                    if(liveChatObj.Asset__c == null || (objectCase.Case_Age__c!=null && objectCase.Case_Age__c.Contains('Hour(s)'))) {  // Added if conditions for the task # 5287278
                        liveChatObj.Asset__c = assetId;
                        if(liveChatObj.ContactId == null) {
                            liveChatObj.ContactId = contactId;
                        }
                        if(liveChatObj.AccountId == null) {
                            liveChatObj.AccountId = accountList[0].Id;
                        }
                        if(liveChatObj.CustomerNumber__c == null) {
                            liveChatObj.CustomerNumber__c = bilAssetInfo.asset.customerNumber;
                        }
                        if(liveChatObj.CustomerBUID__c == null){
                            liveChatObj.CustomerBUID__c = bilAssetInfo.asset.customerBuid;
                        }                        
                        update liveChatObj;
                    }
                }
            } 
            else 
            {
                assetId = 'AccountNA';
            }
            return assetId;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssociateServiceTagHandler','performAssetAssociation','Case Management');  
            return null;
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       performAPICall
    Description:  this functions perform interface call 
    Input: serviceTag - information of the service tag to be used for the interface call
    Output: Asset Information
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/15/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @TestVisible private static BILAssetInformation performAPICall(string serviceTag)

    {
        try 
        {
            BILAssetInformation assetInfo;
            if (serviceTag != '') 
            {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                string requestURL = Label.BILGetAssetDetailsURL + serviceTag + '/identifiers/?' + Label.BILGetAssetDetailsAPIKey;
                request.setEndpoint(requestURL);
                request.setHeader('Content-Type','Plain/text');
                request.setMethod('GET');
                request.setTimeout(10000); 
                HttpResponse response = http.send(request);
                string strResponse = response.getBody(); 
                
                if (response.getStatusCode() == 200 && !strResponse.contains('NOT_FOUND'))
                {
                    assetInfo = (BILAssetInformation) JSON.deserialize(strResponse, BILAssetInformation.class);  
                    
                }
                
            }
            return assetInfo;
        }
        catch(exception e) {
            ExceptionHandler.logHandledExceptions(e,'AssociateServiceTagHandler','createAsset','Case Management');  
            return null;
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       createAsset
    Description:  this functions perform asset creation 
    Input: objectCase - case objects that holds information needed to create a new contact record
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/08/2018     1.0     Rodrigo Carpio      Initial Release
    03/28/2018     1.1     Roselin Hephzibah   Updated method to handle productcode conversion
    03/28/2018     1.2     Roselin Hephzibah   Updated method to handle product that does not exist in Salesforce
    -------------------------------------------------------------------------------------------------------------------------- */
    @TestVisible private static string createAsset(BILAssetInformation bilAssetInfo, Id accountId)    
    {
        try {
            string assetId;
            string strDate = bilAssetInfo.asset.shipDate;
            Date dateObj = date.valueOf(strDate.substring(0,strDate.indexOf('T')));
            string strPSNT = '';
            BILAssetInformation.AssetDetails assetDetails = bilAssetInfo.asset;
            BILAssetInformation.AssetIdentifiers assetIdList = bilAssetInfo.identifiers;
            
            for (BILAssetInformation.Identifiers itemId : assetIdList.content)
            {
                if (itemId.identifierTypeId == '92') {
                    strPSNT = itemId.identifierValue;
                    break;
                }                    
            }
            //Replace '\' with 'sfdc' and '/' with 'gsd'
            String replacedString;
            String regex = '\\\\';
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(bilAssetInfo.asset.productCode);
            If(regexMatcher.find())
                replacedString = (bilAssetInfo.asset.productCode).replaceAll(regex,'sfdc');
            else
                replacedString = bilAssetInfo.asset.productCode;
            String sfdcExtId = replacedString.replace('/', 'gsd');
            List<Product2> productList = [SELECT Id FROM Product2 WHERE External_Id__c = :sfdcExtId LIMIT 1];
            
            if(!productList.isEmpty()){            
                // create asset if product is found
                Asset assetToInsert = new Asset(AccountId = accountId,External_id__c = bilAssetInfo.asset.id, Asset_Number__c = bilAssetInfo.asset.id,
                                                Name = bilAssetInfo.asset.serviceTag,Express_Svc_Code__c = bilAssetInfo.asset.expressServiceCode,                                                
                                                SerialNumber = bilAssetInfo.asset.serialNumber,Invoice_Date__c = dateObj, 
                                                Manufacturer_No__c = decimal.valueOf(bilAssetInfo.asset.manufacturerId),
                                                Order_BUID__c = bilAssetInfo.asset.orderBuid,Order_Number__c = bilAssetInfo.asset.orderNumber,
                                                OCN__c = bilAssetInfo.asset.orderCompanyNumber,Local_Channel__c = bilAssetInfo.asset.localChannel,
                                                PSNT__c = strPSNT, Status = 'Active');
                
                assetToInsert.Product2Id = productList[0].Id;
                insert assetToInsert;  
                assetId = (string) assetToInsert.Id;
            } else {
                assetId = 'ProductNA';
            }
            return assetId;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssociateServiceTagHandler','createAsset','Case Management');  
            return null;
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       createContact
    Description:  this functions perform contact creation 
    Input: objectCase - case objects that holds information needed to create a new contact record
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/08/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @TestVisible private static string createContact(Object objectCase)

    {
        try{
            string contactId = '';
            Case objCase = (Case) objectCase;
            // Call the Flow
            Map<String, Object> params = new Map<String, Object>();
            if (objCase.NonAgentContactLastName__c != null && objCase.NonAgentContactLastName__c != '') {  
                
                //params.put('inCaseId', objectCase.Id);
                params.put('inAccountId', objCase.AccountId);
                params.put('inFirstName', objCase.NonAgentContactFirstName__c);
                params.put('inLastName', objCase.NonAgentContactLastName__c);
                params.put('inEmailAddress', objCase.NonAgentContactEmail__c);
                params.put('inPhone', objCase.NonAgentContactPhone__c);
                
                Flow.Interview.Contact_Search_and_Create contactFlow = new Flow.Interview.Contact_Search_and_Create(params);
                contactFlow.start();
                
                // Obtain the results
                contactId = (string)contactFlow.getVariableValue('outContactId');    
            }
            
            return contactId; 
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssociateServiceTagHandler','createContact','Case Management');  
            return null;
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       updateAssetinCase
    Description:  this functions makes a updates the asset number entered by user in the Service_Tag__c field in respective case.
    Input: caseId - holds the record identifier to pull the case record ; ase - holds the asset number.
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/12/2018     1.0     Roselin Hephzibah      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static void updateAssetinCase(String ast, Id caseId) {
        
        try{   
            List<Database.SaveResult> listSR = new List<Database.SaveResult>();
            if(ast != null && caseId != null){
                //Update case
                List<Case> caseList = [Select Id, Service_Tag__c from Case WHERE Id =: caseId];
                for(Case c : caseList){
                    c.Service_Tag__c = ast;
                }
                List<Database.SaveResult> results = Database.update(caseList, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        listSR.add(result);
                    } 
                }
                if(!listSR.isEmpty()) {
                    ExceptionHandler.logHandledExceptions(listSR,'GetAssetDetails','updateAssetinCase','AssetSearch');
                } 
            }
        }catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssociateServiceTagHandler','createContact','Case Management');  
        }
        
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       populateAssetNumber
    Description:  this functions returns the asset number stored in temporary field when the asset is not found.
    Input: caseId - holds the record identifier to pull the asset number of the case.
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/12/2018     1.0     Roselin Hephzibah      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static string populateAssetNumber(Id caseId) {
        
        try{    
            String assetNo = null;
            if(caseId != null){
                //Update case
                List<Case> caseList = [Select Id, Service_Tag__c, assetID from Case WHERE Id =: caseId];
                for(Case c : caseList){
                    If(c.AssetId == null){
                        assetNo = c.Service_Tag__c;
                    } else {
                        assetNo = 'Populated';
                    }
                }
            }
            return assetNo;
        }catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssociateServiceTagHandler','createContact','Case Management');
            return null;  
        }
    }
}
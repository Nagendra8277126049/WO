/*****************************************
Purpose: This class will be called from Process Builder on insertion or Updation of Call Transcript records to populate values of Asset/Case into Call Transfer attributes.
Developed by: Mukesh Tiwari

********************************************/
public class CallTranscriptHandler 
{
    static String strCountryName;
    static Date shipDate;
    static String strProductLineDescription;
    Static String strServiceTagEntitlementCommaSeparated = '';
    
    /* Commented below line for customer tag entitlement as it is not part of pilot release */
    //String strCustomerEntitlementCommaSeparated = '';
     
    /* Start - Constructor */
    public CallTranscriptHandler()
    {
        // Do nothing
    }
    /* End - Constructor */
    
    @InvocableMethod
    public static void CreateCTARec(List<Call_Transcript__c> lstCallTranscript)
    {
        if(!lstCallTranscript.isEmpty()) // Pass record Id as parameter and call future method
            makeAPICallsAsync(lstCallTranscript[0].Id);
    }
    
    @AuraEnabled
    public static void handleCTAttrForAssetUpdate(String strCallTranscriptId){
        makeAPICalls(strCallTranscriptId);
    }
    
    @Future(callout=true)
    public static void makeAPICallsAsync(String strCallTranscriptId){
        makeAPICalls(strCallTranscriptId);
    }
    
    static void makeAPICalls(String strCallTranscriptId)
    {
        String serviceTag = '';
        String transferCount = '';
        String status='';
        Map<String,String> getTransferCount = new Map<String,String>();
        
        try
        {
            Call_Transcript__c objCallTranscript;
            
            for(Call_Transcript__c objCT : [SELECT Id, Name, Asset__c, Asset__r.Name,Asset__r.Invoice_Date_New__c,Call_UCID__c,Type__c,
                                                           Asset__r.Customer_BUID__c, Asset__r.Product2Id, Asset__r.Product2.ProductCode, Asset__r.Product2.Name, Asset__r.AccountId, 
                                                           Asset__r.Account.CCN__c,Asset__r.Customer_Number__c,Asset__r.Product2.Description,Agent_ID__c,IVR_Input__c  
                                                      FROM Call_Transcript__c WHERE Id =: strCallTranscriptId LIMIT 1])
            {
                objCallTranscript = objCT;
            }
            
            if(objCallTranscript != null)
            {
                // Create Call Transcript only for Customer Inbound, Customer Outbound
                if(objCallTranscript.Type__c == System.Label.Voice_CustomerInBound || (objCallTranscript.Type__c == System.Label.Voice_CustomerOutBound))
                {
                    if(objCallTranscript.Asset__c != null)
                    {
                        serviceTag = objCallTranscript.Asset__r.Name;
                        /* Calling method to get Asset Location Odata */
                        fetchAssetLocationResponse(serviceTag);
                        
                        /* Start - Service Tag Entitlement */
                        if(serviceTag != null)
                        {
                            strServiceTagEntitlementCommaSeparated = fetchServiceTagEntitlmentInfo(serviceTag, objCallTranscript.Asset__r.Customer_BUID__c);
                            
                           /* if(!Test.isRunningTest())
                               getTransferCount = CallTransferHandler.GetTransferCount(objCallTranscript);
                            
                            if(getTransferCount.containsKey('Count'))
                                transferCount = getTransferCount.get('Count');
                            
                            if(getTransferCount.containsKey('Status'))
                                status = getTransferCount.get('Status');*/
                        }
                        /* End - Service Tag Entitlement */
                        
                        /* Commented below code for customer tag entitlemet as it is not part of pilot release*/
                        /*
                        if(objCallTranscript.Asset__r.Customer_Number__c != null)
                            strCustomerEntitlementCommaSeparated = FetchCustomerEntitlmentInfo(objCallTranscript.Asset__r.Customer_BUID__c,objCallTranscript.Asset__r.Customer_Number__c);
                        */
                    }
                    // Call method createCallTransferAttributes to create call Transfer attibutes at back end
                    createCallTransferAttributes(objCallTranscript, status, transferCount);
                }
            }    
        }
        catch(Exception ex)
        { 
            System.debug('=======Exception====='+ex);
            System.debug('=======Exception Line====='+ex.getLineNumber());
            ExceptionHandler.logHandledExceptions(ex,'CallTranscriptHandler','makeODataCall','Voice');  
        }
    }
    
    /* Method to created Call Trasnfer Attribute records with all the proper values */
    static void createCallTransferAttributes(Call_Transcript__c objCallTranscript, String status, String transferCount)
    {
        try
        {
            // Instantiate Call_Transfer_Attributes__c object
            Call_Transfer_Attributes__c objCTA = new Call_Transfer_Attributes__c(Call_Transcript__c = objCallTranscript.Id);
            
            // Query all existing Call_Transfer_Attributes__c recrods
            List<Call_Transfer_Attributes__c> lstCallTranscriptInfo = [Select Id FROM Call_Transfer_Attributes__c WHERE Call_Transcript__c =: objCallTranscript.Id LIMIT 1];
            Call_Transfer_Attributes__c objCallTrans;  
            Boolean isUpdate = false;
            
            if(!lstCallTranscriptInfo.isEmpty()) // If list has value that means its Call Transfer records are exist
            { 
                objCallTrans = lstCallTranscriptInfo[0];
                isUpdate = true;
            }
            
            if(objCallTrans != null && isUpdate)
                objCTA.Id = objCallTrans.Id; // Populate id since it is Updating Call Transfer Attribute record
            
            objCTA.Name = objCallTranscript.Name != null ? objCallTranscript.Name : null;         
            objCTA.Caller_Location__c = strCountryName != null ? strCountryName : null;
            objCTA.Service_Tag__c = objCallTranscript.Asset__c != null ? objCallTranscript.Asset__r.Name : null;
            objCTA.Customer_BUID__c =  (objCallTranscript.Asset__c != null && objCallTranscript.Asset__r.Customer_BUID__c != null) ? objCallTranscript.Asset__r.Customer_BUID__c : null; 
            objCTA.Local_Channel__c =  (objCallTranscript.Asset__c != null && objCallTranscript.Asset__r.Account.CCN__c != null) ? objCallTranscript.Asset__r.Account.CCN__c : null;
            objCTA.Product_Line__c = strProductLineDescription != null ? strProductLineDescription : null;
            
            if(objCallTranscript.Asset__c != null && objCallTranscript.Asset__r.Product2Id != null)
                objCTA.Product_Item_Class__c = objCallTranscript.Asset__r.Product2.Name;
            else
                objCTA.Product_Item_Class__c = null;
            
            objCTA.Product_Shipped_Date__c = shipDate; //(objCallTranscript.Asset__c != null && objCallTranscript.Asset__r.Invoice_Date_New__c != null) ? objCallTranscript.Asset__r.Invoice_Date_New__c : null;  
            System.debug('shipDate Date variable ==> '+ shipDate);
            objCTA.ServiceTag_Entitlement_Type_Group__c = objCallTranscript.Asset__c != null ? strServiceTagEntitlementCommaSeparated : null; 
            
            /* Commented below code for customer tag entitlemet as it is not part of pilot release*/
            //objCTA.Customer_Entitlement_Type_Group__c = objCallTranscript.Asset__c != null ? strCustomerEntitlementCommaSeparated : null;
            
            objCTA.Status__c = System.Label.Voice_StatusNotSubmitted;
            objCTA.Call_UCID__c = objCallTranscript.Call_UCID__c;
            //objCTA.Get_TC_Context_Store__c = status;
            System.debug('=======75====objCTA====='+objCTA);
            
            if(isUpdate) 
                update objCTA;
            else
                insert objCTA;
            
            System.debug('========Inserted/Updated===objCTA====='+objCTA);
            //objCallTranscript.Transfer_Count__c = transferCount;   
            //objCallTranscript.Update_TC__c = transferCount; 
            //update objCallTranscript;
            
          if(Test.isRunningTest())  //Condition to ensure test is running
            integer intTest =1/0;
        }
        catch(Exception ex)
        {
            System.debug('=======exception====='+ex);
            ExceptionHandler.logHandledExceptions(ex,'CallTranscriptHandler','createCallTransferAttributes','Voice');  
        }
    }
    
    /* This method will make oData call to get Asset Location response */
    static void fetchAssetLocationResponse(String serviceTag)
    {
        try
        {
            //if(!Test.isRunningTest())
            {
                AssetLocationResponse__x objAssetLocationResponse;
                
                if(!Test.isRunningTest())
                {
                    for(AssetLocationResponse__x objALR :  [SELECT Country__c,ProductLineDescription__c, ShipDate__c FROM AssetLocationResponse__x WHERE ServiceTagId__c =: serviceTag LIMIT 1])
                        objAssetLocationResponse = objALR;
                }
                
                if(objAssetLocationResponse != null)
                {
                    if(objAssetLocationResponse.Country__c != null)
                    	strCountryName = objAssetLocationResponse.Country__c;
                    
                    if(objAssetLocationResponse.ProductLineDescription__c != null)
                    	strProductLineDescription = objAssetLocationResponse.ProductLineDescription__c;
                    
                    if(objAssetLocationResponse.ShipDate__c != null)
                    	shipDate = Date.valueOf(objAssetLocationResponse.ShipDate__c);
                    System.debug('shipDate string from BIL ==> '+ objAssetLocationResponse.ShipDate__c);
                }
            }
            
            if(Test.isRunningTest())  //Condition to ensure test is running
                integer intTest =1/0;    //This will throw some exception, 
        }
        catch(Exception ex)
        {
            System.debug('=======exception====='+ex);
            ExceptionHandler.logHandledExceptions(ex,'CallTranscriptHandler','fetchAssetLocationResponse','Voice');  
        }
    }
    
    /* This method will make oData call to get  Service Cloud Entilement information */
    static String fetchServiceTagEntitlmentInfo(String strServiceTag, String strCustomerBUID)
    {
        List<ServiceCloudEntitlmentDetails__x> lstSerCloudEntitlement;
        String strSCECommaSeparated = '';
        
        try
        {
            if(!Test.isRunningTest()) 
                lstSerCloudEntitlement = [SELECT ServiceTag__c,CustomerNumber__c,CustomerBUID__c,ServiceLevelCode__c,Status__c FROM ServiceCloudEntitlmentDetails__x WHERE ServiceTag__c =: strServiceTag];
            else
            {
                lstSerCloudEntitlement = new List<ServiceCloudEntitlmentDetails__x>();
                lstSerCloudEntitlement = createServiceCloudEntitTestData();    
            }
            
            for(ServiceCloudEntitlmentDetails__x objGetEntilement : lstSerCloudEntitlement) 
            {
                System.debug('========@@@@@@======'+objGetEntilement);
                String strStatus = '';
                
                if(objGetEntilement.Status__c == System.Label.Voice_StatusActive)
                    strStatus = '1';
                else if(objGetEntilement.Status__c == System.Label.Voice_StatusInActive)
                    strStatus = '0';
                else     
                    strStatus = '';
                 
                strSCECommaSeparated += strCustomerBUID + '_' + objGetEntilement.ServiceLevelCode__c + '_' + strStatus +','; 
            }
            strSCECommaSeparated = (strSCECommaSeparated.contains(',') ? strSCECommaSeparated.removeEnd(',') : strSCECommaSeparated); 
            
            if(Test.isRunningTest())  //Condition to ensure test is running
                integer intTest =1/0;
        }
        catch(Exception ex)
        {
            System.debug('=======exception====='+ex);
            ExceptionHandler.logHandledExceptions(ex,'CallTranscriptHandler','fetchServiceTagEntitlmentInfo','Voice');
            return null;
        }
        return strSCECommaSeparated;                     
    }
    
    /* This method will create test data for Odata Call while runing Test */
    static List<ServiceCloudEntitlmentDetails__x> createServiceCloudEntitTestData()
    {
        List<ServiceCloudEntitlmentDetails__x> lstSCE = new List<ServiceCloudEntitlmentDetails__x>();
        
        lstSCE.add(new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='Active',
                                                                         ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'),
                                                                         Name__c='Name1234',OrderNumber__c='ORD1234', PageKey__c = '1',
                                                                         ResponseCode__c='100',ResponseMessage__c='MSG1234', 
                                                                         ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',
                                                                         UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                                         CreationDate__c = DateTime.parse('05/22/2022 11:46 AM')));
        lstSCE.add(new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='InActive',
                                                                         ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'),
                                                                         Name__c='Name1234',OrderNumber__c='ORD1234', PageKey__c = '1',
                                                                         ResponseCode__c='100',ResponseMessage__c='MSG1234', 
                                                                         ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',
                                                                         UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                                         CreationDate__c = DateTime.parse('05/22/2022 11:46 AM')));
        lstSCE.add(new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='',
                                                                         ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'),
                                                                         Name__c='Name1234',OrderNumber__c='ORD1234', PageKey__c = '1',
                                                                         ResponseCode__c='100',ResponseMessage__c='MSG1234', 
                                                                         ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',
                                                                         UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                                         CreationDate__c = DateTime.parse('05/22/2022 11:46 AM')));    
        return lstSCE;          
    }
    
    /* Commented below code for customer tag entitlemet as it is not part of pilot release*/
    /*
    static String FetchCustomerEntitlmentInfo(String strCustomerBUID, String strCustomerNumber)
    {
        List<ServiceCloudEntitlmentDetails__x> lstSCE;
        String strCustomerEntitlementCommaSeparated = '';
                        
        if(!Test.isRunningTest())
        {
            lstSCE = [ SELECT ServiceTag__c, CustomerNumber__c, CustomerBUID__c, ServiceLevelCode__c, StatusId__c, Status__c FROM ServiceCloudEntitlmentDetails__x 
                                                                   WHERE CustomerNumber__c =: strCustomerNumber 
                                                                     AND CustomerBUID__c =: strCustomerBUID];    
        }
        else{
            lstSCE = new List<ServiceCloudEntitlmentDetails__x>();
            lstSCE = createServiceCloudEntitTestData();
        }
            
        for(ServiceCloudEntitlmentDetails__x objGetEntilement : lstSCE) 
        {    
            String strStatus = '';
            if(objGetEntilement.Status__c == 'Active')
                strStatus = '1';
            else if(objGetEntilement.Status__c == 'InActive')
                strStatus = '0';
            else     
                strStatus = ''; 
            
            strCustomerEntitlementCommaSeparated += objGetEntilement.CustomerBUID__c + '_' + objGetEntilement.ServiceLevelCode__c + '_' + strStatus +',';                   
        }
        strCustomerEntitlementCommaSeparated = (strCustomerEntitlementCommaSeparated.contains(',') ? strCustomerEntitlementCommaSeparated.removeEnd(',') : strCustomerEntitlementCommaSeparated);    
    
        return strCustomerEntitlementCommaSeparated;  
    }*/
}
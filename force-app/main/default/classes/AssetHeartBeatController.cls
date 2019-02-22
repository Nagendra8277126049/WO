/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetHeartBeatController
Description:  Makes OData call to external system and fetches the SupportAssit Details - Story #4794544 - Phase2
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
03/14/2018     1.0     Harsha Reddy              Initial Release
05/21/2017     1.1     Srikanth Parvathareddy    Story #5091877-SFDC Phase 3 :SA Changes on Asset Details
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class AssetHeartBeatController {
    
    /* Wrapper Class*/
    public with sharing class HeartBeatWrapper {
        @AuraEnabled public string UTCDate {get;set;}
        @AuraEnabled public String ServiceTag {get;set;}
        @AuraEnabled public String ResponseCode {get;set;}
        @AuraEnabled public String ResponseMessage {get;set;}
        @AuraEnabled public Boolean noRecordsFound{get;set;}
        @AuraEnabled public String URL{get;set;}
        @AuraEnabled public String Status{get;set;}
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
Method Name:       getSupportAssitDetails
Description:  Makes OData call to external system and fetches the SupportAssit Details - Story #4794544 - Phase2
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
03/14/2018     1.0     Harsha Reddy              Initial Release
05/21/2017     1.1     Srikanth Parvathareddy    Story #5091877-SFDC Phase 3 :SA Changes on Asset Details
-------------------------------------------------------------------------------------------------------------------------- */
    
    @AuraEnabled
    public static HeartBeatWrapper getSupportAssitDetails(Id recordId) {
        try{
            string assetName = '';
            assetName = [SELECT Name FROM Asset WHERE Id = :recordId LIMIT 1].Name;
            
            List<HBServicesInfo__x> HBServicesList;
            HeartBeatWrapper HBService = new HeartBeatWrapper();
            
            if (assetName != null) {
                
                if(!Test.isRunningTest()){
                    HBServicesList = [SELECT UTCDate__c,ServiceTagId__c,ResponseCode__c,ResponseMessage__c,URL__c,Status__c FROM HBServicesInfo__x WHERE ServiceTagId__c=:assetName LIMIT 1];
                } 
                else {
                    HBServicesList = new List<HBServicesInfo__x>();
                    HBServicesList.add(new HBServicesInfo__x(UTCDate__c=DateTime.parse('05/22/2012 11:46 AM'),ServiceTagId__c= assetName,ResponseCode__c='100',ResponseMessage__c='Sucess'));
                    HBServicesList.add(new HBServicesInfo__x(UTCDate__c=DateTime.parse('05/22/2012 11:46 AM'),ServiceTagId__c= assetName,ResponseCode__c='100',ResponseMessage__c='Sucess'));
                    HBServicesList.add(new HBServicesInfo__x(UTCDate__c=DateTime.parse('05/22/2012 11:46 AM'),ServiceTagId__c= assetName,ResponseCode__c='100',ResponseMessage__c='Sucess'));
                    HBServicesList.add(new HBServicesInfo__x(UTCDate__c=null,ServiceTagId__c= assetName,ResponseCode__c='-101',ResponseMessage__c='Sucess'));
                }
                
                if (HBServicesList.size()>0 && HBServicesList[0].ResponseCode__c=='100')
                {
                    HBService.ResponseCode = HBServicesList[0].ResponseCode__c;
                    HBService.ResponseMessage = HBServicesList[0].ResponseMessage__c;
                    if (HBServicesList[0].UTCDate__c != null)
                    {
                        
                        HBService.UTCDate = HBServicesList[0].UTCDate__c.format();  
                        HBService.URL = HBServicesList[0].URL__c;
                        HBService.Status = HBServicesList[0].Status__c;
                        HBService.noRecordsFound = false;
                    }
                    else
                    {
                        HBService.noRecordsFound = true; 
                    }    
                    HBService.ServiceTag = HBServicesList[0].ServiceTagId__c;
                } 
                else
                {
                    HBService.noRecordsFound = true;
                }
            }
            return HBService;
        } catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AssetHeartBeatController','getSupportAssitDetails','AssetManagement');
            return null;
        }
    }
}
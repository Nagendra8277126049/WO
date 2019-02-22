/*
******************************************************************************************************
Name:       SupportAssistController.apxc
Description: Controller of Lightning component to display Support data stored in SATC through oData services
Story 4656242:SFDC Phase2: Display if there are any Diagnostics alerts on an Asset and Case Page

*******************************************************************************************************
Date         Version            Author                Summary of Changes 
*******************************************************************************************************
03/2/2018     1.0       	Amitabh Wankhede	         Initial Release
07-Jul-2018   1.1			Srikanth Parvathareddy       Story 5067671 :SA Changes on Asset Details and Diagnostic Tab
*******************************************************************************************************

*/
public with sharing class SupportAssistController {
    
    //wrapper class to parse the LastCollectionDate
    public class SupportAssistException extends Exception{}
    {}
    public with sharing class CollectionAlertsWrapper{
        
        //CollectionAlert
        @AuraEnabled Public String Name {get;set;}
        @AuraEnabled Public String Status {get;set;}
        @AuraEnabled Public String URL {get;set;}
        
        //Service Codes
        @AuraEnabled Public String ResponseCode {get;set;}
        @AuraEnabled Public String ResponseMessage {get;set;}
    }
    
    //wrapper class to parse the CollectionAlerts
    public with sharing class LastCollectionAlertDateWrapper{
        
        //Last collection Date
        @AuraEnabled public String daysSinceLastCollection {get;set;}
        @AuraEnabled Public String lastCollectionDate {get;set;}
        @AuraEnabled Public String CollectionStatusURL {get;set;}
        
        //Service Codes
        @AuraEnabled Public String ResponseCode {get;set;}
        @AuraEnabled Public String ResponseMessage {get;set;}
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
Method Name:       getLastCollectionDate
Description:  Makes OData call to external system and fetches the LastCollectionDate Details
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
07-Jul-2018    1.0     Srikanth Parvathareddy    Story 5067671 :SA Changes on Asset Details and Diagnostic Tab
-------------------------------------------------------------------------------------------------------------------------- */    
    @AuraEnabled
    public static LastCollectionAlertDateWrapper getLastCollectionDate(Id recordId){        
        try{
            
            List<LastCollectionStatus__x> lastCollectionDateList = new List<LastCollectionStatus__x>();
            LastCollectionAlertDateWrapper collectiondateresults = new LastCollectionAlertDateWrapper();
            
            String assetName = '';
            
            //Querying the Asset Name based on the recordId passed
            
            if(recordId == Null){
                throw new SupportAssistException('No Record ID received');
            }
            if(recordId.getsobjecttype().getDescribe().getName().equals('Asset')){
                assetName = [SELECT Name FROM Asset WHERE Id = :recordId LIMIT 1].Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('Case')){
                assetName = [SELECT Asset.Name FROM Case WHERE Id = :recordId LIMIT 1].Asset.Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('LiveChatTranscript')){
                assetName = [SELECT Asset__r.Name FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].Asset__r.Name;
            }
            
            //Null check 
            if (assetName != null) {
                
                if(!Test.isRunningTest()){
                    
                    //Querying the actual alerts
                    lastCollectionDateList = [SELECT Id, ServiceTagId__c, daysSinceLastCollection__c, LastCollectionDate__c,collectionStatusURL__c, ResponseCode__c, ResponseMessage__c FROM LastCollectionStatus__x WHERE ServiceTagId__c =:assetName limit 1];
                    
                } else {
                    
                    // Test Coverage for external object records
                    lastCollectionDateList.add(new LastCollectionStatus__x(ServiceTagId__c='STAG1234', daysSinceLastCollection__c='30',
                                                                           LastCollectionDate__c='05/22/2012 11:46 AM',collectionStatusURL__c='http://dell.com',
                                                                           ResponseCode__c='100',ResponseMessage__c='SUCCESS'
                                                                          ));
                    lastCollectionDateList.add(new LastCollectionStatus__x(ServiceTagId__c='STAG1234', daysSinceLastCollection__c='30',
                                                                           LastCollectionDate__c='05/28/2012 11:26 AM',collectionStatusURL__c='http://dell.com',
                                                                           ResponseCode__c='100',ResponseMessage__c='SUCCESS'
                                                                          ));
                    lastCollectionDateList.add(new LastCollectionStatus__x(ServiceTagId__c='STAG1234', daysSinceLastCollection__c='30',
                                                                           LastCollectionDate__c='05/25/2012 10:46 AM',collectionStatusURL__c='http://dell.com',
                                                                           ResponseCode__c='100',ResponseMessage__c='SUCCESS'
                                                                          ));
                }
                
                //List size verification
                if(lastCollectionDateList.size()>0)
                {
                    //Null check on LastCollectionDate
                    if(lastCollectionDateList[0].LastCollectionDate__c!=null && lastCollectionDateList[0].LastCollectionDate__c!='' && lastCollectionDateList[0].ResponseCode__c=='100')
                    {
                        collectiondateresults.lastCollectionDate=lastCollectionDateList[0].LastCollectionDate__c;
                        
                        collectiondateresults.daysSinceLastCollection=lastCollectionDateList[0].daysSinceLastCollection__c;
                    }
                    
                    //Assigning the external object field values to wrapper fields
                    collectiondateresults.CollectionStatusURL=lastCollectionDateList[0].collectionStatusURL__c;
                    collectiondateresults.ResponseCode=lastCollectionDateList[0].ResponseCode__c;
                    collectiondateresults.ResponseMessage=lastCollectionDateList[0].ResponseMessage__c;
                }
                
            }
            return collectiondateresults;
            
        }
        catch(exception e){
            //Handling exception records
            ExceptionHandler.logHandledExceptions(e,'SupportAssistController','getLastCollectionDate','Case Management');
            return null;
        }
        
    }
    /* -----------------------------------------------------------------------------------------------------------------------
Method Name:       getLastCollectionAlerts
Description:  Makes OData call to external system and fetches the CollectionsAlerts 
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
07-Jul-2018    1.0     Srikanth Parvathareddy    Story 5067671 :SA Changes on Asset Details and Diagnostic Tab
-------------------------------------------------------------------------------------------------------------------------- */  
    @AuraEnabled
    public static List<CollectionAlertsWrapper> getLastCollectionAlerts(Id recordId){        
        try{
            
            List<CollectionAlert__x> lastCollectionAlertList = new List<CollectionAlert__x>();
            List<CollectionAlertsWrapper> collectionalerts = new List<CollectionAlertsWrapper>();
            
            String assetName = '';
            
            //Querying the Asset Name based on the recordId passed
            
            if(recordId == Null){
                throw new SupportAssistException('No Record ID received');
            }
            if(recordId.getsobjecttype().getDescribe().getName().equals('Asset')){
                assetName = [SELECT Name FROM Asset WHERE Id = :recordId LIMIT 1].Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('Case')){
                assetName = [SELECT Asset.Name FROM Case WHERE Id = :recordId LIMIT 1].Asset.Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('LiveChatTranscript')){
                assetName = [SELECT Asset__r.Name FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].Asset__r.Name;
            }
            
            //Null check
            if (assetName != null) {
                
                if(!Test.isRunningTest()){
                    
                    //Querying the actual alerts
                    lastCollectionAlertList = [SELECT Id, ServiceTagId__c,Name__c, URL__c, Status__c, ResponseCode__c, ResponseMessage__c  FROM CollectionAlert__x WHERE ServiceTagId__c =:assetName limit 100];
                    
                } else {
                    
                    // Test Coverage for external object records
                    lastCollectionAlertList.add(new CollectionAlert__x(ServiceTagId__c='STAG1234', Name__c='Name1',
                                                                       URL__c='www.google.co.in',Status__c='Critical',
                                                                       ResponseCode__c='100',ResponseMessage__c='SUCCESS'
                                                                      ));
                    lastCollectionAlertList.add(new CollectionAlert__x(ServiceTagId__c='STAG1234', Name__c='Name2',
                                                                       URL__c='www.google.co.in',Status__c='Critical',
                                                                       ResponseCode__c='100',ResponseMessage__c='SUCCESS'
                                                                      ));
                    lastCollectionAlertList.add(new CollectionAlert__x(ServiceTagId__c='STAG1234', Name__c='Name3',
                                                                       URL__c='www.google.co.in',Status__c='Critical',
                                                                       ResponseCode__c='100',ResponseMessage__c='SUCCESS'
                                                                      ));
                }
                
                //List size verification
                if(lastCollectionAlertList.size()>0)
                {
                    CollectionAlertsWrapper calerts;
                    for(CollectionAlert__x ca : lastCollectionAlertList)
                    {
                        calerts= new CollectionAlertsWrapper();
                        
                        //Null check on collection alert name
                        if(ca.Name__c!=null && ca.Name__c!='')
                        {
                            calerts.Name=ca.Name__c;
                        }    
                        
                        //Assigning the external object field values to wrapper fields
                        calerts.Status=ca.Status__c;
                        calerts.URL=ca.URL__c;
                        calerts.ResponseCode=ca.ResponseCode__c;
                        calerts.ResponseMessage=ca.ResponseMessage__c;
                        collectionalerts.add(calerts);
                    }     
                }
            }
            return collectionalerts;
        }
        catch(exception e){
            //Handling exception records
            ExceptionHandler.logHandledExceptions(e,'SupportAssistController','getLastCollectionAlerts','Case Management');
            return null;
        }
        
    }
    
}
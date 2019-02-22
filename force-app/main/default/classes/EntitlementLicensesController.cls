/* -----------------------------------------------------------------------------------------------------------------------
Name:       EntitlementLicensesController
Description:  Makes OData call to external system and fetches the DEE Entitlements to display 
			  this information in Lightning Component - EntitlementLicenses.cmp - Story #4559894
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
02/19/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class EntitlementLicensesController {
    
    /*Wrapper Class*/
    public with sharing class EntitlementPagerWrapper {
        //@AuraEnabled public Integer page {get;set;}
        //@AuraEnabled public Boolean next {get; set;}
        //@AuraEnabled public Boolean previous {get; set;}
        @AuraEnabled public String serviceResponse {get; set;}
        @AuraEnabled public String serviceCode {get;set;}
        @AuraEnabled public List<EntitlementListWrapper> entDetails {get;set;}
    }
    
    /* Wrapper Class*/
    public with sharing class EntitlementListWrapper {
        @AuraEnabled public string BindingType {get;set;}
        @AuraEnabled public String EntitlementReferenceId {get;set;}
        @AuraEnabled public String LicenseType {get;set;}
        @AuraEnabled public String PartDescription {get;set;}
        @AuraEnabled public String Status {get;set;}
        @AuraEnabled public string UniqueId {get;set;}
    }
        
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  getDeeEntitlements
    Description:  Quieries DEE Entitlements Info from External Object - EntitlementDEEDetails__x (ODATA Service)
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------      
    02/19/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */

    @AuraEnabled
    public static EntitlementPagerWrapper getDeeEntitlements (Id recordId) {
        try{
            string assetName = '';
            string caseRecordId = '';
            string responseCode = '';
            string username = '';           
			
            //get object name using recordId
			/* Asset Object */
            if(recordId.getsobjecttype().getDescribe().getName().equals('Asset')){
                assetName = [SELECT Name FROM Asset WHERE Id = :recordId LIMIT 1].Name;
            } 
            /* Case Object */
            else if(recordId.getsobjecttype().getDescribe().getName().equals('Case')){
                assetName = [SELECT Asset.Name FROM Case WHERE Id = :recordId LIMIT 1].Asset.Name;
            }
            /* Live Chat Transcript */
            else if(recordId.getsobjecttype().getDescribe().getName().equals('LiveChatTranscript')){
            	assetName = [SELECT Asset__r.Name FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].Asset__r.Name;
            }
            
            //query for Dell Badge ID -stored in Federation ID field
            username = [select FederationIdentifier from user where id=:userinfo.getuserid() LIMIT 1].FederationIdentifier;
            
            List<EntitlementListWrapper> entitlements = new List<EntitlementListWrapper>();
            List<EntitlementDEEDetails__x> delList = new List<EntitlementDEEDetails__x>();
            EntitlementPagerWrapper objEnt = new EntitlementPagerWrapper();
            
            if (assetName != null) {
            
                if(!Test.isRunningTest()){
                    delList = [SELECT BindingTypeDesc__c,EntitlementReferenceId__c,LicenseType__c,PartDescription__c,ResponseCode__c,ResponseMessage__c,Status__c, 
                               DeviceUniqueId__c FROM EntitlementDEEDetails__x WHERE ServiceTag__c = :assetName AND UserID__c=:username LIMIT 100];
                } 
                else
                {
                    delList.add(new EntitlementDEEDetails__x(BindingTypeDesc__c='Binding Type Desc Sample1',EntitlementReferenceId__c='ENT1234',
                                                             ResponseCode__c='100',ResponseMessage__c='MSG1234',LicenseType__c='Basic', 
                                                             PartDescription__c='Monitor',Status__c='Open',DeviceUniqueId__c='786579'));
                    delList.add(new EntitlementDEEDetails__x(BindingTypeDesc__c='Binding Type Desc Sample2',EntitlementReferenceId__c='ENT1234',
                                                             ResponseCode__c='100',ResponseMessage__c='MSG1234',LicenseType__c='Basic', 
                                                             PartDescription__c='Monitor',Status__c='Completed',DeviceUniqueId__c='786579'));
                    delList.add(new EntitlementDEEDetails__x(BindingTypeDesc__c='Binding Type Desc Sample3',EntitlementReferenceId__c='ENT1234',
                                                             ResponseCode__c='100',ResponseMessage__c='MSG1234',LicenseType__c='Basic', 
                                                             PartDescription__c='Monitor',Status__c='Open',DeviceUniqueId__c='786579'));
                }
                
                if (delList.size()>0){
                    
                    responseCode = delList[0].ResponseCode__c;
                    objEnt.serviceCode = responseCode;
                    objEnt.serviceResponse = delList[0].ResponseMessage__c;
                                        
                    if (responseCode.equals('100')){
                   
                        EntitlementListWrapper entlmnt;
                        for(EntitlementDEEDetails__x del : delList) {
                            entlmnt = new EntitlementListWrapper();
                             
                            entlmnt.BindingType = del.BindingTypeDesc__c;
                            entlmnt.EntitlementReferenceId = del.EntitlementReferenceId__c;
                            entlmnt.LicenseType = del.LicenseType__c;
                            entlmnt.PartDescription = del.PartDescription__c;
                            entlmnt.Status = del.Status__c;
                            entlmnt.UniqueId = del.DeviceUniqueId__c;
                            entitlements.add(entlmnt);
                        }
                        objEnt.entDetails = entitlements;
                    }
                }
            }
			
            return objEnt;

        } Catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'EntitlementLicensesController','getDeeEntitlements','EntitlementManagement');
        	return null;
        }
    }
}
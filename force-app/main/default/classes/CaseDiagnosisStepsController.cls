/********************************************************************************************************
Name: CaseDiagnosisStepsController.apxc
Apex Controller: 
Description: Lightning component to display eSupport data stored in Case fields and SATC through web services
Story 4560890:SFDC Pilot Phase 2 :: Agent Console :: Need to capture the diagnosis steps

*******************************************************************************************************
Date         Version            Author                Summary of Changes 
*******************************************************************************************************
02/28/2018     1.0       	Amitabh Wankhede	         Initial Release
07/19/2018     1.1			Srikanth Parvathareddy       Story 5067671 :SA Changes on Asset Details and Diagnostic Tab
07/31/2018	   1.2          Sushmitha J					 Defect 5384965: no use case for passed results 
********************************************************************************************************/
public class CaseDiagnosisStepsController {
    
    //wrapper class to parse the values
    public class ExternalDiagnosticResultsWrapper{
        
        @AuraEnabled Public String DiagnosticDate {get;set;}
        @AuraEnabled Public String HardwareType {get;set;}
        @AuraEnabled Public String Result {get;set;}
        @AuraEnabled Public String URL {get;set;}
        @AuraEnabled Public String ResponseCode {get;set;}
        @AuraEnabled Public String ResponseMessage {get;set;}
        @AuraEnabled Public String IsAllHardwareTestPassed {get;set;}
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
Method Name:       searchForCase
Description:  Makes OData call to external system and fetches the eSupportAlert Details
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
07/19/018    1.0       Srikanth Parvathareddy    Story 5067671 :SA Changes on Asset Details and Diagnostic Tab
07/31/2018	 1.1	   Sushmitha J				 Defect 5384965: diagnostic tab - no use case for passed results 
-------------------------------------------------------------------------------------------------------------------------- */    
    @AuraEnabled
    Public Static list<ExternalDiagnosticResultsWrapper> searchForCase(Id recordId) {
        try{
            List<ESupportDiagnosticAlerts__x> extDiagList = new List<ESupportDiagnosticAlerts__x>();
            List<ExternalDiagnosticResultsWrapper> extDiagResults = new List<ExternalDiagnosticResultsWrapper>();
            
            String assetName = '';
            
            //Querying the Asset Name based on the recordId passed
            
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
                    extDiagList = [Select DiagnosticDate__c,ResponseCode__c,ResponseMessage__c,Result__c,HardwareType__c,ServiceTagId__c,URL__c,IsAllHardwareTestPassed__c From ESupportDiagnosticAlerts__x Where ServiceTagId__c = :assetName Limit 100];
                }
                else{
                    
                    // Test Coverage for external object records
                    extDiagList.add(new ESupportDiagnosticAlerts__x(ServiceTagId__c='STAG1234', Result__c='1 critical,2 warning',
                                                                    DiagnosticDate__c='05/22/2012 11:46 AM',HardwareType__c='CPU',URL__c='http://dell.com',
                                                                    ResponseCode__c='100',ResponseMessage__c='SUCCESS', IsAllHardwareTestPassed__c='true'
                                                                   ));
                    extDiagList.add(new ESupportDiagnosticAlerts__x(ServiceTagId__c='STAG1234', Result__c='1 critical,2 warning',
                                                                    DiagnosticDate__c='05/22/2012 11:46 AM',HardwareType__c='CPU',URL__c='http://dell.com',
                                                                    ResponseCode__c='100',ResponseMessage__c='SUCCESS', IsAllHardwareTestPassed__c='true'
                                                                   ));
                    extDiagList.add(new ESupportDiagnosticAlerts__x(ServiceTagId__c='STAG1234', Result__c='1 critical,2 warning',
                                                                    DiagnosticDate__c='05/22/2012 11:46 AM',HardwareType__c='CPU',URL__c='http://dell.com',
                                                                    ResponseCode__c='100',ResponseMessage__c='SUCCESS', IsAllHardwareTestPassed__c='true'
                                                                   ));
                }
                
                //List size verification
                if(extDiagList.size()>0)
                {
                    ExternalDiagnosticResultsWrapper ediagalerts;
                    for(ESupportDiagnosticAlerts__x elist : extDiagList)
                    {
                        ediagalerts= new ExternalDiagnosticResultsWrapper();
                        
                        //Null check on eSupport diagnostic date
                        if(elist.DiagnosticDate__c!=null && elist.DiagnosticDate__c!='')
                        {
                            ediagalerts.DiagnosticDate=elist.DiagnosticDate__c;
                        }   
                        
                        //Assigning the external object field values to wrapper fields
                        ediagalerts.Result=elist.Result__c;
                        ediagalerts.HardwareType=elist.HardwareType__c;
                        ediagalerts.URL=elist.URL__c;
                        ediagalerts.ResponseCode=elist.ResponseCode__c;
                        ediagalerts.ResponseMessage=elist.ResponseMessage__c;
                        ediagalerts.IsAllHardwareTestPassed=elist.IsAllHardwareTestPassed__c;
                        extDiagResults.add(ediagalerts);
                    }     
                    
                } 
            }     
            return extDiagResults;
        } catch(Exception e){
            //Handling exception records
            ExceptionHandler.logHandledExceptions(e,'CaseDiagnosisStepsController','searchForCase','CaseManagement');
            return null;
        }
        
    }
}
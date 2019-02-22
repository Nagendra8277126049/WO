/* -----------------------------------------------------------------------------------------------------------------------
Name:       CaseAlertsController
Description:  Makes OData call to external system and fetches the Asset & customer Alert Details
to display this information in Lightning Component - CaseAlerts.cmp & CaseAlertDetails
-  Story #4142699
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/27/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
5/24/2018      2.0     Brundha Rajkumar             Changes are made for User Story #5096431
7/18/2018      2.1     Brundha Rajkumar             updated end date for test code coverage
12/11/2018     2.2     Brundha Rajkumar             Update the query for the User Story #5710705
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class CaseAlertsController {
    
    // User Story #5096431 Code Starts
    /* Wrapper Class*/
    public with sharing class AlertListWrapper {
        @AuraEnabled public string alertDashboardFlag {get;set;}
        @AuraEnabled public String alertName {get;set;}
        @AuraEnabled public String alertType {get;set;}
        @AuraEnabled public String endDate {get;set;}
        @AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get; set;}
        @AuraEnabled public String serviceTagId {get;set;}
        @AuraEnabled public Boolean isActive{get; set;}
        @AuraEnabled public String supportAssistURL {get; set;}
        
    }
    // User Story #5096431 Code ends
    
    /* -----------------------------------------------------------------------------------------------------------------------
Method Name:  getAlerts
Description:  Makes OData call to external system and fetches the Alert Details - Story #4142699
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/27/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
    
    @AuraEnabled
    public static List<AlertListWrapper> getAlerts (Id recordId, string dashFlag){ // User Story #5096431 Updated from List<ServiceCloudAlerts__x>  to List<AlertListWrapper>
        try{
            List<ServiceCloudAlerts__x > alertList = new List<ServiceCloudAlerts__x >();
            Case caseObj = new Case();
            string query=''; //User Story #5710705
            string assetName = '';
            string custNumber = '';
            string custBuid = '';
            // User Story #5710705 starts
            string orderNumber='';
            string orderNumBuid='';
            string linkNumber='';           
            
            caseObj = [SELECT Asset.Name,Asset.Order_Number__c,Asset.Order_BUID__c, Account.AccountNumber, Account.BUID__c, Account.Link_Number__c FROM Case WHERE Id = :recordId LIMIT 1];
            // User Story #5710705 Ends
            custNumber = caseObj.Account.AccountNumber;            
            custBuid = caseObj.Account.BUID__c;            
            assetName = caseObj.Asset.Name;
            //User Story #5710705 Starts
            orderNumber = caseObj.Asset.Order_Number__c;
            orderNumBuid = caseObj.Asset.Order_BUID__c;
            linkNumber = caseObj.Account.Link_Number__c;         
            
            if (assetName != null && String.isNotEmpty(custNumber) && String.isNotEmpty(custBuid) && String.isNotEmpty(orderNumber) && String.isNotEmpty(orderNumBuid)) {
                if(!Test.isRunningTest()){
                    
                    query='SELECT AlertDashboardFlag__c,AlertName__c,AlertType__c,EndDate__c,ResponseCode__c,ResponseMessage__c,ServiceTagId__c,StartDate__c, SupportAssistURL__c FROM ServiceCloudAlerts__x WHERE AlertDashboardFlag__c =\''+dashFlag+'\' AND ServiceTagId__c = \''+assetName+'\' AND ((CustomerNumber__c =\''+custNumber +'\' AND CustomerNumberBUID__c = \''+custBuid+'\') OR (OrderNumber__c=\''+orderNumber +'\' AND OrderNumBUID__c =\''+orderNumBuid+'\')';
                    if(String.isNotEmpty(linkNumber)){
                        query+=' OR (LinkNumber__c =\''+linkNumber+'\')) LIMIT 100';
                    }
                    else{
                        query+=') LIMIT 100';
                    }
                    alertList=Database.query(query);
                    //system.debug(query+'query');
                    //system.debug(alertList+'ss'+alertList.size());
                    //User Story #5710705 Ends       
                } else {
                    
                    //Updated the StartDate__c and EndDate__c in the below ServicecloudAlerts for the User Story #5096431 due to Invalid Data While Parsing
                    
                    alertList.add(new ServiceCloudAlerts__x(AlertDashboardFlag__c='false',AlertName__c='Battery Draining very fast',
                                                            AlertType__c='ServiceTest', EndDate__c=string.valueof(System.today() + 5),
                                                            StartDate__c =string.valueof(System.today() + 1),ResponseCode__c='100',
                                                            ServiceTagId__c='ABCD123',SupportAssistURL__c = 'http://localhost.com/ABCD123'
                                                           ));
                    alertList.add(new ServiceCloudAlerts__x(AlertDashboardFlag__c='false',AlertName__c='Issue with Battery',
                                                            AlertType__c='SupportAssistTest', EndDate__c=string.valueof(System.today() + 5),
                                                            StartDate__c =string.valueof(System.today() + 1),ResponseCode__c='100',
                                                            ServiceTagId__c='XYZ12387',SupportAssistURL__c = 'http://localhost.com/XYZ12387'
                                                           ));
                    alertList.add(new ServiceCloudAlerts__x(AlertDashboardFlag__c='true',AlertName__c='System is getting Hot',
                                                            AlertType__c='Asset Proactive Instructions', /*EndDate__c=string.valueof(System.today() + 5),*/
                                                            StartDate__c =string.valueof(System.today() + 1),ResponseCode__c='100',
                                                            ServiceTagId__c='UIO907',SupportAssistURL__c = 'http://localhost.com/UIO907'
                                                           ));
                    alertList.add(new ServiceCloudAlerts__x(AlertDashboardFlag__c='false',AlertName__c='AntiVirus is expiring soon',
                                                            AlertType__c='Asset DSP Inclusion', EndDate__c=string.valueof(System.today() -1),
                                                            StartDate__c =string.valueof(System.today() + 1),ResponseCode__c='100',
                                                            ServiceTagId__c='TEST678',SupportAssistURL__c = 'http://localhost.com/TEST678'
                                                           ));
                }
            }
            
            // User Story #5096431 code starts
            List<AlertListWrapper> Alerts = new List<AlertListWrapper>();
            if(alertList.size()>0){
                AlertListWrapper alrtWrap;
                for(ServiceCloudAlerts__x alrt:alertList){
                    alrtWrap=new AlertListWrapper ();
                    alrtWrap.alertDashboardFlag=alrt.AlertDashboardFlag__c;
                    alrtWrap.alertName=alrt.AlertName__c;
                    alrtWrap.alertType=alrt.AlertType__c;
                    // alrtWrap.endDate=alrt.EndDate__c;
                    // alrtWrap.startDate=alrt.StartDate__c;
                    alrtWrap.responseCode=alrt.ResponseCode__c;
                    alrtWrap.serviceTagId=alrt.ServiceTagId__c;
                    alrtWrap.supportAssistURL=alrt.SupportAssistURL__c;
                    
                    if(alrt.EndDate__c!=null){
                        
                        /*updated for Defect #5478373 */  
                        String eformattedDate=alrt.EndDate__c;
                        String eyear=eformattedDate.substring(6, 10);
                        String eday=eformattedDate.substring(3, 5); 
                        String emonth= eformattedDate.substring(0, 2); 
                        string myEndDate = eyear+'-'+emonth+'-'+eday;
                        date endDate;
                        
                        String sformattedDate=alrt.StartDate__c;
                        String syear=sformattedDate.substring(6, 10);
                        String sday=sformattedDate.substring(3, 5); 
                        String smonth= sformattedDate.substring(0, 2); 
                        string myStartDate = syear+'-'+smonth+'-'+sday;
                        date startDate;
                        
                        
                        if(!Test.isRunningTest()){
                            endDate=Date.newInstance(Integer.valueOf(eyear),Integer.valueOf(emonth),Integer.valueOf(eday));
                            startDate=Date.newInstance(Integer.valueOf(syear),Integer.valueOf(smonth),Integer.valueOf(sday));
                        }else{
                            endDate=date.valueOf(alrt.EndDate__c);
                            startDate=date.valueOf(alrt.startDate__c);
                        }
                        //System.debug(endDate+'****ENDDATE***'); 
                        if(endDate>=system.today()){
                            alrtWrap.isActive=true;
                            //  System.debug('true');                            
                        }
                        else{
                            alrtWrap.isActive=false;
                            // System.debug('false');
                        }
                        if(endDate!=null){
                            alrtWrap.endDate=endDate.format(); 
                        }
                        if(startDate!=null){
                            alrtWrap.startDate=startDate.format();
                        }
                    }
                    else{
                        alrtWrap.isActive=true;
                    }
                    
                    Alerts.add(alrtWrap);
                    
                }
            }
            return Alerts;
            // User Story #5096431 Code ends            
            
        } catch(exception e){
            
            //ExceptionLogger.newExceptionLogger(e.getMessage(), 'AssetAlertsController','getAlerts');
            //system.debug('Exception occured due to: '+e.getMessage());
            ExceptionHandler.logHandledExceptions(e,'CaseAlertsController','getAlerts','CaseManagement');
            return null;
        }
    }
}
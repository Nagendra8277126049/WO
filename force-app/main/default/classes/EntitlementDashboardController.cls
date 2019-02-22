/* -----------------------------------------------------------------------------------------------------------------------
Name:       EntitlementDashboardController
Description:  Makes OData call to external system and fetches the Entitlement Dashboard and Entitlement Details
                to display this information in Lightning Component - EntitlementDahboard.cmp - Story #4145473
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/17/2017     1.0     Harsha Reddy              Initial Release
03/05/2017     1.1     Harsha Reddy              Updated Code for Phase 2 release
07/19/2018     1.2     Brundha                   Defect # 5363252
-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class EntitlementDashboardController {
    
    /*Wrapper Class*/
    public with sharing class EntitlementPagerWrapper {
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Boolean next {get; set;}
        @AuraEnabled public Boolean previous {get; set;}
        @AuraEnabled public String serviceResponse {get; set;}
        @AuraEnabled public String serviceCode {get;set;}
		@AuraEnabled public String AssetId {get;set;}
        @AuraEnabled public List<EntitlementListWrapper> entDetails {get;set;}
    }
    
    /* Wrapper Class*/
    public with sharing class EntitlementListWrapper {
        @AuraEnabled public string entName {get;set;}
        @AuraEnabled public String entStartDate {get;set;}
        @AuraEnabled public String entEndDate {get;set;}
        @AuraEnabled public String entStatus {get;set;}
        @AuraEnabled public String entType {get;set;}
        @AuraEnabled public String entRemDays {get; set;}
        @AuraEnabled public String entOrderNumber {get;set;}
        @AuraEnabled public Integer entDetRemDays {get; set;}
        @AuraEnabled public String entDateCreated {get; set;}
        @AuraEnabled public String status {get;set;}
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  getEntitlements
    Description:  Quieries Entitlement Dashboard Info from External Object - GetEntitlementDashboard__x (ODATA Service)
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------      
    11/17/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
   10/30/2018     1.1     Rajesh Guru           Nov Release story-Story 5086637 & 5150078 (added for Live chat transcript( InternalChat RecordType)
    -------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static List<EntitlementListWrapper> getEntitlements (Id recordId) {
        try{
            string assetName = '';
            string caseRecordId = '';
            String eDate = '';
            //get object name using recordId
            if(recordId.getsobjecttype().getDescribe().getName().equals('Asset')){
                assetName = [SELECT Name FROM Asset WHERE Id = :recordId LIMIT 1].Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('Case')){
                assetName = [SELECT Asset.Name FROM Case WHERE Id = :recordId LIMIT 1].Asset.Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('LiveChatTranscript')){
                if([SELECT Id, RecordtypeId, RecordType.name FROM LiveChatTranscript  where Id = :recordId ].RecordType.Name =='InternalChat'){
                   assetName = [SELECT Case.Asset_Name__c FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1 ].Case.Asset_Name__c;
               System.debug( assetName );
                
                }else{
                assetName = [SELECT Asset__r.Name FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].Asset__r.Name;
            }
               
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('Call_Transcript__c')){
               assetName = [SELECT Asset__r.Name FROM Call_Transcript__c WHERE Id = :recordId LIMIT 1].Asset__r.Name;
            }

            List<EntitlementListWrapper> entitlements = new List<EntitlementListWrapper>();
            List<GetEntitlementDashboard__x> entlist = new List<GetEntitlementDashboard__x>();
          
            if (assetName != null) {
                if(!Test.isRunningTest()){
                    entlist = [SELECT ServiceTagId__c, CurrentEntitlement__c, CurrentEntitlementEndDate__c, 
                                      Position__c, RemainingDays__c, Status__c, Type__c, LastEndDate__c
                                      FROM GetEntitlementDashboard__x WHERE ServiceTagId__c = :AssetName LIMIT 100];
                } else {
                    
                    entlist.add(new GetEntitlementDashboard__x(ServiceTagId__c='STAG1234', CurrentEntitlement__c='ENT1234',
                                                               CurrentEntitlementEndDate__c= DateTime.parse('05/22/2012 11:46 AM'),
                                                               Position__c='POS1234',RemainingDays__c='4'
                                                               ,Status__c='Active',Type__c='Type', 
                                                               LastEndDate__c= DateTime.parse('05/22/2012 11:46 AM')
                                                               ));
                    entlist.add(new GetEntitlementDashboard__x(ServiceTagId__c='STAG1234', CurrentEntitlement__c='ENT1234',
                                                               CurrentEntitlementEndDate__c = DateTime.parse('05/22/2012 11:46 AM'),
                                                               Position__c='POS1234',RemainingDays__c='4'
                                                               ,Status__c='Active',Type__c='Type', 
                                                               LastEndDate__c=DateTime.parse('05/22/2012 11:46 AM')
                                                               ));
                    entlist.add(new GetEntitlementDashboard__x(ExternalId='1234',ServiceTagId__c='STAG1234',CurrentEntitlement__c='ENT1234',
                                                               CurrentEntitlementEndDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                               Position__c='POS1234',RemainingDays__c='4'
                                                               ,Status__c='Active',Type__c='Type', 
                                                               LastEndDate__c=DateTime.parse('05/22/2012 11:46 AM')
                                                               ));
                    
                }
                //system.debug(entlist);
                if (entlist.size()>0){
                    
                    EntitlementListWrapper entlmnt;
                    for(GetEntitlementDashboard__x ent : entlist) {
                        system.debug(ent.CurrentEntitlement__c);
                        entlmnt = new EntitlementListWrapper();
                        // Entitlement Type
                        if (ent.CurrentEntitlement__c!=null){
                            entlmnt.entName = ent.CurrentEntitlement__c;
                            // Entitlement EndDate
                            if (ent.LastEndDate__c!=null){
                                entlmnt.entEndDate = (ent.LastEndDate__c.date()).format(); // Defect 5553977
                            }
                            //Entitlement Status
                            entlmnt.entStatus = ent.Status__c;
                            // Entitlement Type
                            entlmnt.entType = ent.Type__c;
                            //Entitlement Remaining Days
                            entlmnt.entRemDays = ent.RemainingDays__c;
                            entitlements.add(entlmnt);
                        }
                    }
                }
            }
            //system.debug(entitlements);
            return entitlements;
        } catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'EntitlementDashboardController','getEntitlements','EntitleManagement');
            return null;
        }
    }

    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  getEntDetails
    Description:  Quieries Entitlement Details Info from External Object - SearchEntitlementByServiceTag__x (ODATA Service)
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------      
    11/17/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */

    @AuraEnabled
    public static EntitlementPagerWrapper getEntDetails (Id recordId, Decimal PageKey, String PageSize) {
        try{
            
            string assetName = '';
            string caseRecordId = '';
            string lastPage='';
            string responseCode = '';
			string assetId ='';
            String edDtStr = '';
            Integer page = (Integer) PageKey;
            String sInteger = String.valueOf(page);
            Boolean isWorkOrder=false; //will be used to Identify the Type WorkOrder.            
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
            
             /* Voice Call Transcript */
            else if(recordId.getsobjecttype().getDescribe().getName().equals('Call_Transcript__c')){
                assetName = [SELECT Asset__r.Name FROM call_Transcript__c WHERE Id = :recordId LIMIT 1].Asset__r.Name;
            }

            /* Work Order */
            else if(recordId.getsobjecttype().getDescribe().getName().equals('WorkOrder')){
				List<WorkOrder> WoList = [SELECT Asset.Name, AssetId FROM WorkOrder WHERE Id = :recordId LIMIT 1];
                assetName = WoList[0].Asset.Name;
				assetId = WoList[0].AssetId;
                IsWorkOrder=true;
            }
            List<EntitlementListWrapper> entitlements = new List<EntitlementListWrapper>();
            List<ServiceCloudEntitlmentDetails__x> delList = new List<ServiceCloudEntitlmentDetails__x>();
            EntitlementPagerWrapper objEnt = new EntitlementPagerWrapper();
            
            if (assetName != null) {
            	
                if(!Test.isRunningTest()){
                    delList = [SELECT BasisType__c,EntitlementId__c,ExpiryDate__c,Name__c,UserId__c, LastPage__c, CreationDate__c,
                                      OrderNumber__c,ResponseCode__c,ResponseMessage__c,ServiceTag__c,StartDate__c, PageKey__c,
                                      PageSize__c,Status__c FROM ServiceCloudEntitlmentDetails__x WHERE ServiceTag__c = :assetName AND 
                                      PageKey__c =:sInteger AND PageSize__c=:PageSize LIMIT 100];
                } else{

                    delList.add(new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='Active',
                                                                     ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'),
                                                                     Name__c='Name1234',OrderNumber__c='ORD1234', PageKey__c = '1',
                                                                     ResponseCode__c='100',ResponseMessage__c='MSG1234', 
                                                                     ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',
                                                                     UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                                     CreationDate__c = DateTime.parse('05/22/2022 11:46 AM')
                                                                    ));
                    delList.add(new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='Active',
                                                                     ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), 
                                                                     Name__c='Name1234',OrderNumber__c='ORD1234', PageSize__c = '10',
                                                                     ResponseCode__c='100',ResponseMessage__c='MSG1234',
                                                                     ServiceTag__c='STAG1234', LastPage__c = 'false', PageKey__c = '1',
                                                                     UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                                     CreationDate__c = DateTime.parse('05/22/2022 11:46 AM')
                                                                    ));
                    delList.add(new ServiceCloudEntitlmentDetails__x(BasisType__c='AType1234',EntitlementId__c='ENT1234',Status__c='Active',
                                                                     ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), 
                                                                     Name__c='Name1234',OrderNumber__c='ORD1234', PageKey__c = '1',
                                                                     ResponseCode__c='100',ResponseMessage__c='MSG1234',
                                                                     ServiceTag__c='STAG1234', LastPage__c = 'true', PageSize__c = '10',
                                                                     UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                                     CreationDate__c = DateTime.parse('05/22/2022 11:46 AM')
                                                                    ));
            
                }
                //system.debug(delList);
                if (delList.size()>0){

                    responseCode = delList[0].ResponseCode__c;
                    objEnt.serviceCode = responseCode;
                    objEnt.serviceResponse = delList[0].ResponseMessage__c;
					objEnt.AssetId = assetId;
                    
                    if (responseCode.equals('100')){
                    
                        lastPage = delList[0].LastPage__c;
                        
                        objEnt.page = integer.valueof(delList[0].PageKey__c);
                      
                        if (lastPage!=null && page!=null){
                         
                            if (lastPage.equalsIgnoreCase('false') && page == 1){
                                // Not Last Page and has Next Page
                                objEnt.next = true;
                                objEnt.previous = false;
                            }
                            else if (lastPage.equalsIgnoreCase('true') && page > 1){
                                // Last Page and has previous page
                                objEnt.next = false;
                                objEnt.previous = true;
                            }
                            else if (lastPage.equalsIgnoreCase('false') && page > 1){
                                //  Not Last Page and has both next page ,previous page
                                objEnt.next = true;
                                objEnt.previous = true;
                            }
                        }
                        
                        EntitlementListWrapper entlmnt;
                        for(ServiceCloudEntitlmentDetails__x del : delList) {
                           
                             
                            string eName = del.Name__c;
                             if (!string.isEmpty(eName)){ //5363252
                                entlmnt = new EntitlementListWrapper(); //5363252
                                entlmnt.entName = del.Name__c;
                                
                                if (del.ExpiryDate__c != null){
                                    
                                    //To determine Remaining Days using End Date
                                    Date dueDate = del.ExpiryDate__c.dateGmt();
                                    DateTime currentDateTime = System.now();
                                    Date startDate = currentDateTime.date();
                                    entlmnt.entDetRemDays = startDate.daysBetween(dueDate);
    
                                    //End Date
                                    entlmnt.entEndDate  =(del.ExpiryDate__c.date()).format(); // Defect 5553977  
                                }
                                                            
                                if (del.StartDate__c != null){      
                                    //Start Date
                                    entlmnt.entStartDate = (del.StartDate__c.date()).format(); // Defect 5553977

                                }
                                
                                if (del.CreationDate__c != null){
                                    //Created Date
                                    entlmnt.entDateCreated = del.CreationDate__c.format();   
                                }
         
                                entlmnt.entType = del.BasisType__c;
                                entlmnt.entOrderNumber = del.OrderNumber__c;
                                entlmnt.status = del.Status__c;
                                entitlements.add(entlmnt); //5363252
                            }
                           
                        }
                        objEnt.entDetails = entitlements;
                    }
                }
                If(IsWorkOrder){
                    DispatchDefaultHelper.addEntitlementDetails(delList,recordId);
                }
            }
            //system.debug(objEnt);
            return objEnt;

        } Catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'EntitlementDashboardController','getEntDetails','EntitlementManagement');
            return null;
        }
    }
}
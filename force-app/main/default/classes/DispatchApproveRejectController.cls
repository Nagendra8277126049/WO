/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchApproveRejectController
Description:  This class contain method that handles Approval And Rejection of Work Order
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
07/31/2018     1.0    Harsha Reddy       Initial Release
07/31/2018     1.0    Rodrigo Carpio     Initial Release
09/26/2018     1.1    harsha Reddy       STORY 5499262
12/03/2018     1.2    Rodrigo Carpio   removed the logic for cut-off 
12/04/2018     1.2    Rodrigo Carpio   STORY 5847508

-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class DispatchApproveRejectController {
    public class customException extends Exception {}
    @TestVisible private static List<Asset_Country__mdt> mockedAssetCountry = new List<Asset_Country__mdt>();
    @TestVisible private static List < CancelSlot__x > mockedCancelSlots = new List < CancelSlot__x > ();
    //@TestVisible private static DateTime mockDateTime;
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:       ApproveDispatch
    Description:  This Method will get triggered when Approver Clicks on Approve Button for Approving WorkOrder 
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    07/31/2018     1.0    Harsha Reddy       Initial Release
    07/31/2018     1.0    Rodrigo Carpio     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static string ApproveDispatch(Id recordId,String approveReason, String approveComment){
        try{
            List<DispatchPendingApproval__c> dpAList = new List<DispatchPendingApproval__c>(); 
            List<WorkOrderHistory> wOHisstoryList = new List<WorkOrderHistory>();
            List<User> userList = new List<User>();
            DispatchInstruction__c dispInst = new DispatchInstruction__c();
            string userApprove;
            DateTime tempDateTime;
            
            dpAList = [SELECT Id,Name,Approval_Comments__c,Approval_Reason__c, RecordTypeId, Reject_Comments__c, Reject_Reason__c,
                        Work_Order__c, Work_Order__r.RecordTypeId, Work_Order__r.Approver_Id__c,Work_Order__r.Approved_Rejected__c, 
                        Work_Order__r.FSD_Approver__c,Work_Order__r.CountryCode,Work_Order__r.Timezone__c,
                        Work_Order__r.Approve_Reject_Reason__c,Work_Order__r.Approve_Reject_DateTime__c,Work_Order__r.Approve_Reject_Comments__c,
                        Work_Order__r.status,Approval_Reject_Date__c,Work_Order__r.WorkOrderNumber,Queue_Approval_Attribute_Map__c,
                        Queue_Approval_Attribute_Map__r.Approved_Count__c, Work_Order__r.DispatchEvent__c, Work_Order__r.IsDeferralAllowed__c,
                        Work_Order__r.ScheduleStartDate__c, Work_Order__r.Schedule_Enable_Flag__c, Work_Order__r.Deferred__c,
                        Work_Order__r.EntitlementStartDate__c,Work_Order__r.schedulingInternalLogic__c,Work_Order__r.ScheduleEndDate__c
                        FROM DispatchPendingApproval__c WHERE Id=:recordId LIMIT 1];
            
            userList = [SELECT Dell_NTUserID__c from User where Id = :UserInfo.getUserId() LIMIT 1];
            
            if(userList!=null && !userList.isEmpty()) {
                if(string.isNotEmpty(userList[0].Dell_NTUserID__c) && string.isNotBlank(userList[0].Dell_NTUserID__c)) {
                    userApprove = userList[0].Dell_NTUserID__c;
                }
            }
            /*
            wOHisstoryList =  [SELECT Id,CreatedDate,OldValue,NewValue,Field,WorkOrderId FROM WOrkOrderHistory 
                               WHERE Field='Status' AND WorkOrderId=:dpAList[0].Work_Order__c ORDER BY CreatedDate DESC NULLS LAST LIMIT 1000];
            
            System.debug('Result ===> '+wOHisstoryList);
            
           if(!Test.isRunningTest()){
                if(!wOHisstoryList.isEmpty() && wOHisstoryList.size()>0){
                    for(WorkOrderHistory wo :wOHisstoryList){
                        if(wo.newvalue == 'Pending Review'){
                            tempDateTime = wo.CreatedDate;
                            break;
                        }
                    }
                }
           } else{
               tempDateTime = mockDateTime;
           }
            
      
            System.debug('tempDateTime ====>  '+tempDateTime);
            */
            
            // added for story STORY 5847508 - starts here
            Boolean proceedApproval = true;
            //Deepa added Null check for Defect 6004309
            if (dpAList[0].Work_Order__r.IsDeferralAllowed__c)
            {
                if(dpAList[0].Work_Order__r.Schedule_Enable_Flag__c != NULL && dpAList[0].Work_Order__r.Schedule_Enable_Flag__c.equalsIgnoreCase('Y') && String.isEmpty(dpAList[0].Work_Order__r.ScheduleStartDate__c))
                    proceedApproval = false;
                else {
                    if (dpAList[0].Work_Order__r.Deferred__c!=NULL && dpAList[0].Work_Order__r.Deferred__c.equalsIgnoreCase('Yes'))
                    {
                        if (!isDeferredDateStillValid(dpAList[0].Work_Order__r.EntitlementStartDate__c, dpAList[0].Work_Order__r.Timezone__c))
                            proceedApproval = false;
                    }                        
                    else {
                        if (dpAList[0].Work_Order__r.Deferred__c!=NULL && dpAList[0].Work_Order__r.Deferred__c.equalsIgnoreCase('No') && String.isEmpty(dpAList[0].Work_Order__r.ScheduleStartDate__c) && String.isEmpty(dpAList[0].Work_Order__r.EntitlementStartDate__c))    
                            proceedApproval = false;
                    }
                }
            }
            
            
            if(String.isNotBlank(dpAList[0].Work_Order__r.schedulingInternalLogic__c)){
                if(dpAList[0].Work_Order__r.schedulingInternalLogic__c.equalsIgnoreCase('Scheduled')){
                    if(schedulingCheck(dpAList[0].Work_Order__r.ScheduleStartDate__c, dpAList[0].Work_Order__r.ScheduleEndDate__c, dpAList[0].Work_Order__r.Timezone__c, dpAList[0].Work_Order__r.CountryCode,dpAList[0].Work_Order__c)){
                        proceedApproval = false;   
                    }
                }
            }
            
            // added for story STORY 5847508 - ends here
            //if(isInCountryCutoff(dpAList[0].Work_Order__r.CountryCode,dpAList[0].Work_Order__r.Timezone__c,tempDateTime))
            if (proceedApproval)
            {
                dpAList[0].Work_Order__r.RecordTypeId = System.Label.Dispatch_Record_Type_Submitted;
                dpAList[0].Work_Order__r.Approver_Id__c = UserInfo.getUserId();
                dpAList[0].Work_Order__r.FSD_Approver__c = userApprove;
                dpAList[0].Work_Order__r.Approved_Rejected__c = 'Approved';
                dpAList[0].Work_Order__r.Approve_Reject_Reason__c = approveReason;
                dpAList[0].Work_Order__r.Approve_Reject_Comments__c = approveComment;
                dpAList[0].Work_Order__r.Approve_Reject_DateTime__c = System.now();
                dpAList[0].Work_Order__r.status = 'Approved';
                dpAList[0].Work_Order__r.DispatchEvent__c = 'DISPATCH_APPROVED';
                dpAList[0].RecordTypeId = System.Label.DispatchApproval_ReordTypeId;
                dpAList[0].Approval_Reason__c = approveReason;
                dpAList[0].Approval_Comments__c = approveComment;
                dpAList[0].Approval_Status__c = 'Approved';
                dpAList[0].Approval_Reject_Date__c = system.now();
                dpAList[0].OwnerId = UserInfo.getUserId();
                dpAList[0].Name = dpAList[0].Work_Order__r.WorkOrderNumber + ' - ' + 'Approved'; 
                
                //dispInst.Type__c = 'Approve Reason';// DEFECT 5674757 - Harsha Reddy
                dispInst.Type__c = 'Comments List'; // DEFECT 5674757 - Harsha Reddy
                dispInst.Receiver__c = 'Internal';
                dispInst.Instruction__c = approveComment;
                dispInst.Work_Order__c = dpAList[0].Work_Order__c;
                
                // Update Work Order Record
                update dpAList[0].Work_Order__r;
                
                if(dpAList[0].Queue_Approval_Attribute_Map__c!=null){
                    decimal Count = 0;
                    if(dpAList[0].Queue_Approval_Attribute_Map__r.Approved_Count__c!=null){
                         Count = dpAList[0].Queue_Approval_Attribute_Map__r.Approved_Count__c;
                    }
                    dpAList[0].Queue_Approval_Attribute_Map__r.Approved_Count__c= Count + 1;
                    
                    // update Queue Approval Attribute Record With Couint
                    update dpAList[0].Queue_Approval_Attribute_Map__r;
                }
                // Update Pending Approval Record
                update dpAList[0];
                
                // Insert Instruction Record
                insert dispInst;
                
                // Submit Work order
                //DispatchSubmissionProcess.submitWorkOrder(dpAList[0].Work_Order__c);
                DispatchSubmissionProcess dsp = new DispatchSubmissionProcess(dpAList[0].Work_Order__c);
                Id jobId = system.enqueueJob(dsp);
                // Submit Work order
                
                // Return Work Order Record Id
                return dpAList[0].Work_Order__c;   
            } else {
                // Navigate to Edit View - on Rework
                dpAList[0].Work_Order__r.RecordTypeId = System.Label.Dispatch_Record_Type_Create;
                dpAList[0].Work_Order__r.Approver_Id__c = UserInfo.getUserId();
                dpAList[0].Work_Order__r.FSD_Approver__c = userApprove;
                //dpAList[0].Work_Order__r.Approved_Rejected__c = 'Rejected';
                //dpAList[0].Work_Order__r.Approve_Reject_Reason__c = 'Country Cut-Off';
                //dpAList[0].Work_Order__r.Approve_Reject_Comments__c = 'Work Order moved to Rework - Since it is approved after the Country CutOff time';
                dpAList[0].Work_Order__r.Approve_Reject_DateTime__c = system.now();
                dpAList[0].Work_Order__r.status = 'Rework';
                dpAList[0].RecordTypeId = System.Label.DispatchApproval_ReordTypeId;
                //dpAList[0].Approval_Reason__c = 'Country Cut-Off';
                //dpAList[0].Approval_Comments__c = 'Work Order moved to Rework - Since it is approved after the Country CutOff time';
                dpAList[0].Approval_Status__c = 'Rejected';
                dpAList[0].Approval_Reject_Date__c = system.now();
                dpAList[0].OwnerId = UserInfo.getUserId();
                dpAList[0].Name = dpAList[0].Work_Order__r.WorkOrderNumber + ' - ' + 'Rejected - Due Service Dates value';   
                dispInst.Type__c = 'Reject Reason'; // Story 5933002(DEFECT 5786093) - Deepa
                //dispInst.Type__c = 'Comments List'; // DEFECT 5674757 - Harsha Reddy
                dispInst.Receiver__c = 'Internal';
                dispInst.Instruction__c = 'Work Order moved to Rework - as the work order does have the relevant fields populated for submission';
                dispInst.Work_Order__c =  dpAList[0].Work_Order__c;
                
                // Update Work Order Record
                update dpAList[0].Work_Order__r;
                
                // Update Pending Approval Record
                update dpAList[0];
                
                // Insert Instruction Record
                insert dispInst;
                
                // Return Work Order Record Id
                return dpAList[0].Work_Order__c;
            }
        } catch (Exception e){
            // Log Exception
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','ApproveDispatch','Dispatch Management');
            return null;
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:       RejectDispatch
    Description:  This Method will get triggered when Approver Clicks on Reject Button for Rejecting WorkOrder 
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    07/31/2018     1.0    Harsha Reddy       Initial Release
    07/31/2018     1.0    Rodrigo Carpio     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static string RejectDispatch(Id recordId,String rejectReason, String rejectComment){
        try{
            List<DispatchPendingApproval__c> dpAList = new List<DispatchPendingApproval__c>(); 
            DispatchInstruction__c dispInst = new DispatchInstruction__c();
            List<User> userList = new List<User>();
            string userApprove;
            
            dpAList = [SELECT Id,Name,Approval_Comments__c,Approval_Reason__c,RecordTypeId, Reject_Comments__c, Reject_Reason__c, 
                        Work_Order__c, Work_Order__r.RecordTypeId, Work_Order__r.Approver_Id__c,Work_Order__r.Approved_Rejected__c, Work_Order__r.FSD_Approver__c,
                        Work_Order__r.Approve_Reject_Reason__c,Work_Order__r.Approve_Reject_DateTime__c,Work_Order__r.Approve_Reject_Comments__c,
                        Work_Order__r.status,Approval_Reject_Date__c,Work_Order__r.WorkOrderNumber,Queue_Approval_Attribute_Map__c,Queue_Approval_Attribute_Map__r.Rejected_Count__c
                        FROM DispatchPendingApproval__c WHERE Id=:recordId LIMIT 1];
            
            userList = [SELECT Dell_NTUserID__c from User where Id = :UserInfo.getUserId() LIMIT 1];
            
            if(userList!=null && !userList.isEmpty()) {
                if(string.isNotEmpty(userList[0].Dell_NTUserID__c) && string.isNotBlank(userList[0].Dell_NTUserID__c)) {
                    userApprove = userList[0].Dell_NTUserID__c;
                }
            }
            
            // Navigate to Edit View - on Rework
            dpAList[0].Work_Order__r.RecordTypeId = System.Label.Dispatch_Record_Type_Create;
            dpAList[0].Work_Order__r.Approver_Id__c = UserInfo.getUserId();
            dpAList[0].Work_Order__r.FSD_Approver__c = userApprove;
            dpAList[0].Work_Order__r.Approved_Rejected__c = 'Rejected';
            dpAList[0].Work_Order__r.Approve_Reject_Reason__c = rejectReason;
            dpAList[0].Work_Order__r.Approve_Reject_Comments__c = rejectComment;
            dpAList[0].Work_Order__r.Approve_Reject_DateTime__c = system.now();
            dpAList[0].Work_Order__r.status = 'Rework';
            dpAList[0].RecordTypeId = System.Label.DispatchApproval_ReordTypeId;
            dpAList[0].Approval_Reason__c = rejectReason;
            dpAList[0].Approval_Comments__c = rejectComment;
            dpAList[0].Approval_Status__c = 'Rejected';
            dpAList[0].Approval_Reject_Date__c = system.now();
            dpAList[0].OwnerId = UserInfo.getUserId();
            dpAList[0].Name = dpAList[0].Work_Order__r.WorkOrderNumber + ' - ' + 'Rejected';

            dispInst.Type__c = 'Reject Reason'; //Story 5933002(DEFECT 5786093) - Deepa
            //dispInst.Type__c = 'Comments List'; // DEFECT 5674757 - Harsha Reddy
            dispInst.Receiver__c = 'Internal';
            dispInst.Instruction__c = rejectReason + '||' +rejectComment;
            dispInst.Work_Order__c =  dpAList[0].Work_Order__c;
            
            // Update Work Order Record
            update dpAList[0].Work_Order__r;
            
            if(dpAList[0].Queue_Approval_Attribute_Map__c!=null) {
                Decimal Count = 0;
                if(dpAList[0].Queue_Approval_Attribute_Map__r.Rejected_Count__c!=null){
                    Count = dpAList[0].Queue_Approval_Attribute_Map__r.Rejected_Count__c;
                }
                dpAList[0].Queue_Approval_Attribute_Map__r.Rejected_Count__c=Count + 1;
                
                // update Queue Approval Attribute Record With Couint
                update dpAList[0].Queue_Approval_Attribute_Map__r;
            }
            
            // Update Pending Approval Record
            update dpAList[0];
            
            // Insert Instruction Record
            insert dispInst;
            
            // Return Work Order Record Id
            return dpAList[0].Work_Order__c;
        } catch (Exception e){
            // Log Exception
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','RejectDispatch','Dispatch Management');
            return null;
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:       isDeferredDateStillValid
    Description:  This Method will validate if the service window defer date is still valid 
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    12/04/2018     1.0    Rodrigo Carpio     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    public static boolean isDeferredDateStillValid(String serviceWindowStart, string timeZone)
    {
        try{
            // 2018-09-26T08:00:00
            //String serviceWindowStart = '2018-10-03T08:00:00';
//string timeZone = 'America/Chicago';
      string serviceWindowStartStr = serviceWindowStart;
            serviceWindowStartStr = serviceWindowStartStr.replace('T', ' ');

            DateTime currentServiceWindowDT = DateTime.ValueofGmt(serviceWindowStartStr);

            Datetime gMTDate;
            gMTDate = system.now();

            Datetime currentWorkOrderDT;
            String workOrderDTStr;
            workOrderDTStr = gMTDate.format('yyyy-MM-dd HH:mm:ss', timeZone);

            currentWorkOrderDT = DateTime.ValueofGmt(workOrderDTStr);

      if (currentWorkOrderDT < currentServiceWindowDT)
                return false;
            
            return true;
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','isDeferredDateStillValid','Dispatch Management');
            return false;
        }
    }
    /*
    public static boolean isInCountryCutoff(String countryCode, String timeZone, DateTime submittedTime){
        try{
            Datetime gMTDate;
            DateTime currentTime;
            DateTime cutoffTime;
            String strConvertedDateTime;
            String strConDate;
            String cutOffValue='';
            string conDT;
            String strConvertedSubDateTime;
            
            if(String.isBlank(countryCode)){
                throw new customException('Input Param countryCode is Blank');
            }
            if(String.isBlank(timeZone)){
                throw new customException('Input Param timeZone is Blank');
            }
            if(submittedTime==null){
                throw new customException('Input Param submittedTime is Blank');
            }
            
            List<Asset_Country__mdt> AssCountList = new List<Asset_Country__mdt>();
            AssCountList = (!mockedAssetCountry.isEmpty())?mockedAssetCountry:[SELECT CutOff__c FROM Asset_Country__mdt 
                             WHERE Active__c = true AND CountryCode__c =:countryCode LIMIT 1];
            if(!AssCountList.isEmpty() && AssCountList.size()>0){
                if(String.isNotBlank(AssCountList[0].CutOff__c)) {
                    cutOffValue = AssCountList[0].CutOff__c;
                }
            }
            
            if(String.isBlank(cutOffValue)){
                throw new customException('No Country CutOff Value found for the WorkOrder CountryCode');
            }

            gMTDate = system.now();
            strConvertedDateTime = GMTDate.format('yyyy-MM-dd HH:mm:ss',timeZone);
            strConDate = GMTDate.format('yyyy-MM-dd',timeZone);
            currentTime = DateTime.ValueofGmt(strConvertedDateTime);
            conDT = strConDate+' '+cutOffValue+':00';
            cutoffTime = DateTime.ValueofGmt(conDT);
            strConvertedSubDateTime = submittedTime.format('yyyy-MM-dd HH:mm:ss',timeZone);
            submittedTime = DateTime.ValueofGmt(strConvertedSubDateTime);
            cutoffTime = cutoffTime.addMinutes(1); //Megha: added this to fix defect 5694619
            // Work Order Should not be Approved - When Current Time is after the Country CutOff Time (or) if it is not SameDay Dispatch.
            if(cutoffTime>currentTime && currentTime.isSameDay(submittedTime)){
                return true;
            } 
            return false;
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','isInCountryCutoff','Dispatch Management');
            return false;
        }
    }
  */
    @TestVisible private static boolean schedulingCheck(String ScheduleStartDate, String ScheduleEndDate, String timeZone, String countryCode,Id recordId){
        try{
            boolean cutOffFlag = countryCutoffLogic(countryCode,timeZone);
            integer noOfDays = schedulingNextBusinessDayCheck(ScheduleStartDate,ScheduleEndDate,timeZone);
            
            //if(countryCutoffLogic(countryCode,timeZone) && schedulingNextBusinessDayCheck(ScheduleStartDate,ScheduleEndDate,timeZone)){
            if((noOfDays==1 && cutOffFlag)|| noOfDays<=0){  
                if(recordId!=null){
                    AsyncCancelSlotsWithPartner aCS = new AsyncCancelSlotsWithPartner(recordId);
                    Id jobId = system.enqueueJob(aCS);
                } else{
                    throw new customException('Input Param recordId is Blank');
                }
                return true;
            } else {
                return false;
            }
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','schedulingCheck','Dispatch Management');
            return false;
        }
    }
    
    //@TestVisible private static boolean schedulingNextBusinessDayCheck(String ScheduleStartDate, String ScheduleEndDate,String timeZone){
    @TestVisible private static integer schedulingNextBusinessDayCheck(String ScheduleStartDate, String ScheduleEndDate,String timeZone){
    	try{
            if(String.isBlank(ScheduleStartDate) || String.isBlank(ScheduleEndDate) || String.isBlank(timeZone)){
                throw new customException('Input Paramters are Blank');
            }
            DateTime dt,currentTime;
            String strConvertedDateTime='';
            String currentDay = '';
            integer numberDaysDue = 0;
            DateTime todayTime = system.now();
            if(String.isNotBlank(ScheduleStartDate)){
                ScheduleStartDate = ScheduleStartDate.replace('T',' ');
                dt = DateTime.ValueofGmt(ScheduleStartDate);
                strConvertedDateTime = todayTime.format('yyyy-MM-dd HH:mm:ss',timeZone);
                currentTime = DateTime.ValueofGmt(strConvertedDateTime);
                //currentDay= todayTime.format('EEE',timeZone);
                numberDaysDue = currentTime.dateGmt().daysBetween(dt.dateGmt());
                /*
                if(numberDaysDue>1){
                    return false;
                } else {
                    return true;
                }
				*/
            }    
            //return false;
            return numberDaysDue;
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','schedulingNextBusinessDayCheck','Dispatch Management');
            //return false;
            return 0;
        }
    }
    
    @TestVisible private static boolean countryCutoffLogic(String countryCode, String timeZone){
        try{
            String strConvertedDateTime = '',strConDate='',cutOffValue = '';
            DateTime currentTime,cutoffTime;
            DateTime todayTime = system.now();
             if(String.isBlank(countryCode) && String.isBlank(timeZone)){
                throw new customException('Input Parameters are Blank');
            }
            
            List<Asset_Country__mdt> AssCountList = new List<Asset_Country__mdt>();
            AssCountList = (!mockedAssetCountry.isEmpty())?mockedAssetCountry:[SELECT CutOff__c FROM Asset_Country__mdt 
                             WHERE Active__c = true AND CountryCode__c =:countryCode LIMIT 1];
            if(!AssCountList.isEmpty() && AssCountList.size()>0){
                if(String.isNotBlank(AssCountList[0].CutOff__c)) {
                    cutOffValue = AssCountList[0].CutOff__c;
                }
            }
            
            if(String.isNotBlank(cutOffValue)){
            	strConvertedDateTime = todayTime.format('yyyy-MM-dd HH:mm:ss',timeZone);
                currentTime = DateTime.ValueofGmt(strConvertedDateTime);
                strConDate = todayTime.format('yyyy-MM-dd',timeZone);
                cutoffTime = DateTime.ValueofGmt(strConDate+' '+cutOffValue+':00');
                if(currentTime>cutoffTime){
                    return true;
                }
             }
            return false;
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','countryCutoffLogic','Dispatch Management');
            return false;
        }
    }
    
    Public class AsyncCancelSlotsWithPartner implements Queueable {
        @TestVisible private Id recordId;
        AsyncCancelSlotsWithPartner(Id recordId){
            this.recordId = recordId;
        }
        public void execute(QueueableContext context) {
            try{
                List<WorkOrder> woList = new List<WorkOrder>();
                String ScheduleStartDate='',ScheduleEndDate='',dsp='',dspName='';
                if(recordId!=null){
                    woList = [SELECT WorkOrderNumber, Status, AccountId, StartDate, EndDate, Account.Name,
                                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c,
                                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City, DSPName__c,
                                State, StateCode, Country, CountryCode, PostalCode, Region__c, schedulingInternalLogic__c,
                                EntitlementStartDate__c, EntitlementEndDate__c, SLAStartDate__c, SLAEndDate__c,
                                Deferred__c, IsScheduled__c, ScheduleStartDate__c, ScheduleEndDate__c, PartnerWorkOrderNumber__c 
                                FROM WorkOrder WHERE id=:recordId LIMIT 1];
                } else {
                    throw new customException('Input Param recordId is Blank');
                }
                
                if(woList!=null && !woList.isEmpty() && woList.size()>0){
                    if(string.isNotBlank(woList[0].ScheduleEndDate__c)){
                        ScheduleEndDate =woList[0].ScheduleEndDate__c;
                    }
                    if(string.isNotBlank(woList[0].ScheduleStartDate__c)){
                        ScheduleStartDate = woList[0].ScheduleStartDate__c;
                    }
                    
                    if(string.isNotBlank(woList[0].DSP__c)){
                        dsp =woList[0].DSP__c;
                    }
                    if(string.isNotBlank(woList[0].DSPName__c)){
                        dspName = woList[0].DSPName__c;
                    }
                    List<CancelSlot__x> csList = new List<CancelSlot__x>();
                    csList = cancelSlot(woList[0]);
                    if(csList!=null && csList.size()>0 && !csList.isEmpty()){
                        woList[0].ScheduleStartDate__c = null;
                        woList[0].ScheduleEndDate__c = null;
                        woList[0].StartDate = null;
                        woList[0].EndDate = null;
                        woList[0].schedulingInternalLogic__c='Neither';
                        
                        if(woList[0]!=null){
                            // Update Work Order Record.
                            update woList[0];   
                        }
                        
                        if(csList[0]!=null){
                             createServiceEvent(csList[0],recordId,ScheduleStartDate,ScheduleEndDate,dsp,DSPName);
                        }
                    } else{
                        throw new customException('Something went wrong while canceling slots with partner');
                    }
                } else{
                    throw new customException('Something went wrong while canceling slots with partner');   
                }
            } catch (Exception e){
                ExceptionHandler.logHandledExceptions(e,'AsyncCancelSlotsWithPartner','execute','Dispatch Management');
            }
        }
    }
    
    @TestVisible private static void createServiceEvent(CancelSlot__x cancelRespCode, Id WorkOrderId,String ScheduleStartDate,String ScheduleEndDate,String dsp,String DSPName){
        try{
            if (cancelRespCode != null) {
                if (String.isNotBlank(cancelRespCode.ReplyCode__c)) {
                    List < DispatchServiceEvent__c > serEventCancelList = new List < DispatchServiceEvent__c > ();
                    serEventCancelList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                        Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c
                        FROM DispatchServiceEvent__c WHERE Work_Order__c =: WorkOrderId AND Event_Code__c = 'XO'
                        AND Reply_Code__c =: cancelRespCode.ReplyCode__c AND DSP_Code__c =:dsp ORDER BY CreatedDate DESC LIMIT 1
                    ];

                    if (!serEventCancelList.isEmpty() && serEventCancelList.size()>0  && serEventCancelList!=null && !cancelRespCode.ReplyCode__c.equals('100000')) {
                        serEventCancelList[0].DSP_Reference__c = cancelRespCode.ISPConfirmationNumber__c;
                        serEventCancelList[0].Event_DateTime__c = ScheduleStartDate + '|' + ScheduleEndDate;
                        serEventCancelList[0].Reply_Code__c = cancelRespCode.ReplyCode__c;
                        serEventCancelList[0].Reply_Code_Description__c = cancelRespCode.ResponseMessage__c;
                        serEventCancelList[0].Service_Event__c = 'COUNTRY_CUTOFF';
                        
                        update serEventCancelList[0];

                    } else {

                        DispatchServiceEvent__c serEventCancel = new DispatchServiceEvent__c();
                        serEventCancel.DSP_Details__c = DSPName;
                        serEventCancel.DSP_Code__c = DSP;
                        serEventCancel.DSP_Reference__c = cancelRespCode.ISPConfirmationNumber__c;
                        serEventCancel.Event_Code__c = 'XO';
                        serEventCancel.Event_DateTime__c = ScheduleStartDate + '|' + ScheduleEndDate;
                        serEventCancel.Event_Source__c = 'SFDC';
                        serEventCancel.Reply_Code__c = cancelRespCode.ReplyCode__c;
                        serEventCancel.Reply_Code_Description__c = cancelRespCode.ResponseMessage__c;
                        serEventCancel.Service_Event__c = 'COUNTRY_CUTOFF';
                        serEventCancel.Work_Order__c = WorkOrderId;
                        
                        insert serEventCancel;
                    }
                }
            }
            return;
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchApproveRejectController','countryCutoffLogic','Dispatch Management');
            return;
        }
    }
        
    @TestVisible private static List<CancelSlot__x> cancelSlot(WorkOrder oWorkOrder) {
        try {
            list < CancelSlot__x > cancelList = new list < CancelSlot__x > ();
            string userName = UserInfo.getFirstName();
            cancelList = (!mockedCancelSlots.isEmpty()) ? mockedCancelSlots : [SELECT Id, CurrencyIsoCode, ExternalId, DisplayUrl, DPSURL__c, DispatchID__c, ISPConfirmationNumber__c,
                ISPEndTime__c, ISPRequestID__c, ISPStartTime__c, ISPTarget__c, LOB__c, Locale__c, LoggedUser__c, ReplyCode__c, ResponseCode__c, ResponseMessage__c
                FROM CancelSlot__x WHERE DispatchID__c =: oWorkOrder.PartnerWorkOrderNumber__c
                AND ISPRequestID__c =: oWorkOrder.WorkOrderNumber AND ISPTarget__c =: oWorkOrder.DSP__c AND LOB__c =: oWorkOrder.LOB__c AND Locale__c = 'en_US'
                AND LoggedUser__c =: userName AND DPSURL__c =: oWorkOrder.Scheduling_URL__c LIMIT 1
            ];
            return cancelList;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchApproveRejectController', 'cancelSlot', 'Dispatch Management');
            return null;
        }
    }
}
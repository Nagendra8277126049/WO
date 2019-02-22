/* -----------------------------------------------------------------------------------------------------------------------
Name:         DispatchCancelSlotsScedule
Description:  Class to Schdeule the DispatchCancelSlotsBatch Batch Class
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
06/13/2018     1.0         Harsha Reddy              Initial Release
01/06/2019     2.0         Harsha & Carpio	         FY190102 - Jan Release        			 
-------------------------------------------------------------------------------------------------------------------------- */
/*
public with sharing class DispatchCancelSlotsScedule implements Schedulable{
    
    public void execute(SchedulableContext ctx){
		DispatchCancelSlotsBatch batchCancelSlots = new DispatchCancelSlotsBatch();
        Database.executeBatch(batchCancelSlots,200);
    }
}
*/
public with sharing class DispatchCancelSlotsScedule implements Schedulable{
    
    public void execute(SchedulableContext ctx){
        //string q = 'SELECT Id,ScheduleEndDate__c,CountryCode,TimeZone__c,ScheduleStartDate__c,DispatchEvent__c,StartDate,EndDate FROM WorkOrder WHERE Status IN (\'Pending Schedule\',\'Pending Review\',\'Awaiting Acknowledgement\',\'Approved\',\'Queued\',\'Problem\',\'ReWork\') AND schedulingInternalLogic__c=\'Scheduled\' AND StartDate=NEXT_N_DAYS:1';
        string q = 'SELECT Id,ScheduleEndDate__c,CountryCode,TimeZone__c,ScheduleStartDate__c,DispatchEvent__c,StartDate,EndDate FROM WorkOrder WHERE Status IN (\'Pending Schedule\',\'Pending Review\',\'Awaiting Acknowledgement\',\'Approved\',\'Queued\',\'Problem\',\'ReWork\') AND schedulingInternalLogic__c=\'Scheduled\' AND (StartDate=TODAY OR StartDate=TOMORROW) ORDER BY Status DESC';
        DispatchCancelSlotsBatch batchCancelSlots = new DispatchCancelSlotsBatch(q);
        Database.executeBatch(batchCancelSlots,1000);
    }
}
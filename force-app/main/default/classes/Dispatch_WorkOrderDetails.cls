/*======================================================================================================================+
|  HISTORY                                                                  
|                                                                           
|  DATE            DEVELOPER         WR/DEFECT        DESCRIPTION                               
|  ====            =========         =========        =========== 
| 25/05/2018       Megha Bhardwaj    4972586          This class is being used as an apex controller for DispatchOverallSubPartLaborStatus lightning component where we are showing work order, sub status, part status and labor status on the top section of workorder submitted UI
|          
+======================================================================================================================*/
/*======================================================================================================================+
|  Test Class Covering this class                                                                  
|      Dispatch_WorkOrderDetailsTest                                                                         
+======================================================================================================================*/
public class Dispatch_WorkOrderDetails {
    
    public with sharing class statusWrapper{
        
        @AuraEnabled workOrder workOrderRecord {get; set;}
        @AuraEnabled public String woStatusLastUpdatedDate {get; set;}
        @AuraEnabled public String subStatusLastUpdatedDate {get; set;}
        @AuraEnabled public String partStatusLastUpdatedDate {get; set;}
        @AuraEnabled public String laborStatusLastUpdatedDate {get; set;}
        @AuraEnabled public List<string> allWorkOrderStatusList {get; set;}
        @AuraEnabled public Boolean disableEditOption {get;set;}
        @AuraEnabled public Boolean GCCUser {get;set;} //adding Logic for GCC
        
        public statusWrapper(){
            
            workOrderRecord = new workOrder();
            woStatusLastUpdatedDate = '';
            subStatusLastUpdatedDate = '';
            partStatusLastUpdatedDate = '';
            laborStatusLastUpdatedDate = '';
            allWorkOrderStatusList = new List<string>();
            disableEditOption = false;
            GCCUser =false; //adding Logic for GCC
        }
    }
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       fetchStatusFieldsData
    Description:  this method fetches the work order status, part, labor and sub status from DB and shows on UI of lightning component
    Input: workOrderId - work order record identifier
    workOrderId - work order record identifier          
    Output: an instance of the wrapper class(statusWrapper)
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    25/05/2018     1.0     Megha Bhardwaj    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    @Auraenabled
    public static statusWrapper fetchStatusFieldsData(String workOrderId){
        
        try{
            List<WorkOrder> workOrderList = [Select Id, RecordType.DeveloperName, Status, Sub_Status__c, Comments__c, Labor_Status__c, Parts_Status__c, 
                                             Labor_Status_Last_Modified__c, Parts_Status_Last_Modified__c,
                                             Sub_Status_Last_Modified__c, LastModifiedDate, ISP_Comments__c, 
                                             Reason_for_repeat_Work_Order__c From workOrder where Id = :workOrderId limit 1];
            
            statusWrapper statusWrapperInstance = new statusWrapper();
            statusWrapperInstance.GCCUser =DispatchGccConfiguration.isGCCuser() ;//adding Logic for GCC
            //String userProfile = '';
            String wostatus = workOrderList[0].Status;
            //List<User> userList = [Select Id, ProfileId from user where Id = :UserInfo.getUserId() limit 1];
           //Profile profileName = [Select Name from Profile where Id = :userList[0].ProfileId limit 1];
            //userProfile = profileName.Name;
            String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
            //Removing the logic for Profile Check--Dattaa1
            /*List<User> userList = [Select Id, ProfileId from user where Id = :UserInfo.getUserId() limit 1];
            
            string profileIdsInCustomLabel = Label.Dispatch_ProfileIdsCommaSeparated;
            
            if(null != userList && userList.size() > 0 && String.isNotBlank(profileIdsInCustomLabel)){
                
                List<String> profileIdsList = new List<String>();
                if(null != profileIdsInCustomLabel && profileIdsInCustomLabel.length() > 0){
                    
                    if(profileIdsInCustomLabel.contains(',')){
                      profileIdsList = profileIdsInCustomLabel.split(',');
                    }
                    else{
                        profileIdsList.add(profileIdsInCustomLabel);
                    }
                    //system.debug('profileIdsList ###'+profileIdsList);
                    
                    for(String IdProfile : profileIdsList){
                        
                        if(IdProfile.startswith('00e')){
                            
                          if(IdProfile == userList[0].ProfileId){
                              statusWrapperInstance.disableEditOption = true;
                          }
                        }
                    }
                }
            }*/
            if(null != workOrderList && workOrderList.size() > 0){
                
                //system.debug('workOrderList[0].RecordType.DeveloperName ###'+workOrderList[0].RecordType.DeveloperName);
                if(workOrderList[0].RecordType.DeveloperName == 'Delta_Dispatch')
                    statusWrapperInstance.disableEditOption = true;
                
                Set<String> statuslist= new Set<String>();
                    /*if(!statusWrapperInstance.GCCUser){ //adding Logic for GCC
                        if(null != System.Label.Dispatch_Status_Not_Allowed)
                        {
                                for(String key : System.Label.Dispatch_Status_Not_Allowed.split(','))
                                statuslist.add(key);
                        }
                    }
                    else{    //adding Logic for GCC
                        if(null != System.Label.Dispatch_Status_Allowed_GCC)
                        {
                                for(String key : System.Label.Dispatch_Status_Allowed_GCC.split(','))
                                statuslist.add(key);
                        }
                    }*/
           
                
                //Schema.DescribeFieldResult fieldResult = workOrder.Status.getDescribe(); 
                //List<Schema.PicklistEntry> pick_list_values = fieldResult.getPicklistValues(); 
               //for(Schema.PicklistEntry pe : pick_list_values){
                    if(!statusWrapperInstance.GCCUser && (usrProfileName.equalsIgnoreCase('Service Agent')||usrProfileName.equalsIgnoreCase('System Administrator') )){//non GCC User
                        if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Awaiting acknowledgement')||workOrderList[0].Status.equalsIgnoreCase('Work in progress') || workOrderList[0].Status.equalsIgnoreCase('Queued') ))
                        {
                          statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
                        }
                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review')|| workOrderList[0].Status.equalsIgnoreCase('Approved') || workOrderList[0].Status.equalsIgnoreCase('Problem') ))
                         {
                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
                         }
                         
                        
                    }
                    else if(usrProfileName.equalsIgnoreCase('Work Order Approver')|| statusWrapperInstance.GCCUser){//Approver Profile
                        
                        if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Awaiting acknowledgement')||workOrderList[0].Status.equalsIgnoreCase('Work in progress')||workOrderList[0].Status.equalsIgnoreCase('Problem')||workOrderList[0].Status.equalsIgnoreCase('Queued')||workOrderList[0].Status.equalsIgnoreCase('Delay/Service Interruption')))
                        {
                        statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
                        }
                        
                        if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review')|| workOrderList[0].Status.equalsIgnoreCase('Approved') || workOrderList[0].Status.equalsIgnoreCase('Problem') || workOrderList[0].Status.equalsIgnoreCase('ReWork') || workOrderList[0].Status.equalsIgnoreCase('Open')))
                        {
                        statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
                        }
                        
                        if(null != workOrderList[0].Status && workOrderList[0].Status.equalsIgnoreCase('cancellation request') && statusWrapperInstance.GCCUser)
                        {
                        statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
                        }
                        
                        if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Work In Progress')|| workOrderList[0].Status.equalsIgnoreCase('Delay/Service Interruption')) && statusWrapperInstance.GCCUser)
                        {
                        statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
                        }
                    
                    }
                //}
                statusWrapperInstance.workOrderRecord = workOrderList[0]; 
                statusWrapperInstance.woStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].LastModifiedDate);
                statusWrapperInstance.subStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].Sub_Status_Last_Modified__c);
                statusWrapperInstance.partStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].Parts_Status_Last_Modified__c);
                statusWrapperInstance.laborStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].Labor_Status_Last_Modified__c);
                return statusWrapperInstance;
            }
            else 
                return null;
         }
         catch(exception e){
          ExceptionHandler.logHandledExceptions(e,'Dispatch_WorkOrderDetails','fetchStatusFieldsData','fetchStatusFieldsData');
          return null;
      }
    }
     /* -----------------------------------------------------------------------------------------------------------------------
    Name:       fetchDateAndHours
    Description:  this method converts the incoming dateTime formatted date to another format ie MM/dd/yy HH:mm
    Input: lastModifiedDate - date in DateTime format
    lastModifiedDate - date in DateTime format          
    Output: a string holding the date in MM/dd/yy HH:mm format
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    25/05/2018     1.0     Megha Bhardwaj    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @Auraenabled
    public static String fetchDateAndHours(DateTime lastModifiedDate){
         
        String  dateTimeString = '';
        if(null != lastModifiedDate)
            dateTimeString = lastModifiedDate.format('MM/dd/yy HH:mm');
        return dateTimeString;
    }
     /* -----------------------------------------------------------------------------------------------------------------------
    Name:       saveWorkOrder
    Description:  this method inserts dispatch instruction record
    Input: workOrderId - work order record identifier
    workOrderId - work order record identifier          
    Output: a string contains either "SUCCESS" or the error message if any
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    25/07/2018     1.0                       Initial Release
    25/09/2018     1.1    Rodrigo            Added code for defect 5646833
    -------------------------------------------------------------------------------------------------------------------------- */
     @Auraenabled
    public static String saveWorkOrder(WorkOrder workOrderRecord){
         
        try{
            workOrderRecord.EventDateTime__c = System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
            update workOrderRecord;
            //insert dispatch instructions only for work orders having status as cancellation request
             if(null != workOrderRecord.status && workOrderRecord.status.equalsIgnoreCase(Label.DispatchCancellationRequest))
             {  
                List<DispatchInstruction__c> DispInst = new List<DispatchInstruction__c>(); 
                /*DispatchInstruction__c dispatchInstruction = new DispatchInstruction__c();
                dispatchInstruction.Work_Order__c = workOrderRecord.Id;
                dispatchInstruction.Instruction__c = workOrderRecord.Comments__c;
                dispatchInstruction.Vendor_Instructions__c = true;
                dispatchInstruction.Type__c = 'Cancellation Comments';

                dispatchInstruction.Receiver__c = 'All Providers';  // change from Internal to All Providers - Rodrigo
                insert dispatchInstruction;*/
                 
                 DispInst.add(new DispatchInstruction__c(
                     Work_Order__c = workOrderRecord.Id,
                     Instruction__c = workOrderRecord.Comments__c,
                     Vendor_Instructions__c = true,
                     Type__c = 'Cancellation Comments',
                     Receiver__c = 'All Providers'
                 ));
                 //Adding for Defect 5817861
                 DispInst.add(new DispatchInstruction__c(
                     Work_Order__c = workOrderRecord.Id,
                     Instruction__c = workOrderRecord.Comments__c,
                     Vendor_Instructions__c = false,
                     Type__c = 'Cancellation Comments',
                     Receiver__c = 'Internal'
                 ));
                 insert DispInst;
            }
            return 'SUCCESS';
        }
        catch(Exception ex){
            //system.debug('exception occured--->'+ex.getMessage());
            String errorMessage = ex.getMessage();
            if(errorMessage.contains('EXCEPTION, ') && errorMessage.contains(':'))
              errorMessage = errorMessage.substringBetween('EXCEPTION, ',':');
            return errorMessage;
        }
    }
}
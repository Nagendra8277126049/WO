/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchApprovalQueueMappingBatch
Description: Batch class to Update Existing Case to Map Case Owner for Work Order Approval Process
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
07/31/2018     1.0    Harsha Reddy       Initial Release
07/31/2018     1.0    Rodrigo Carpio     Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
global with sharing class DispatchApprovalQueueMappingBatch implements Database.Batchable<Sobject>, Database.Stateful{
    global Integer recordsProcessed = 0;
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name: Start
    Description: To collect the case records to pass to the interface method execute
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    07/31/2018     1.0    Harsha Reddy       Initial Release
    07/31/2018     1.0    Rodrigo Carpio     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    global Database.querylocator start(Database.BatchableContext BC) {
        string query = 'SELECT Id,CaseNumber,ApprovalQueueName__c,Owner.Name,OwnerId FROM Case WHERE Status!=\'Closed\'';
        return Database.getQueryLocator(query);
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name: Execute
    Description: This method is called for each batch of records that are passed to it. 
				 It will Update the ApprovalQueueName__c Field  on Case Records. 
				 If the Case Owner is Mapped to Queue - then ApprovalQueueName__c ='Owner Queue Name'. 
				 Else If the Case Owner is  User - then ApprovalQueueName__c= it Will Check if Case Owner Exists any Queue 
					and it will the Take first queue Name in alphabetical Order.
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    07/31/2018     1.0    Harsha Reddy       Initial Release
    07/31/2018     1.0    Rodrigo Carpio     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    global void execute(Database.BatchableContext BC, List<Case> CaseList) {
        // process each batch of records
        List<Case> UpdateCaseList = new List<Case>();
        List<Case> OwnerCaseList = new List<Case>();
        set<Id> OwnerIdSet = new Set<Id> ();
        Set<Id> groupMemberIdSet = new Set < Id > ();
        Map<Id,List<Id>> groupMemberMap = new Map<Id,List<Id>> ();
        Map<Id,List<String>> queueMap = new Map<Id,List<String>> ();
        
		// Check for CaseList is Empty or Not
        if (!CaseList.isEmpty()) {
            for (Case cs: CaseList) {
                // Check if Case Owner is Queue
                if (string.valueOf(cs.OwnerId).startsWith('00G')) {
                    if (string.isNotEmpty(cs.Owner.Name)) {
                        // Map Case Owner Queue to ApprovalQueueName__c Field
                        cs.ApprovalQueueName__c = cs.Owner.Name;
                        // Add Record to UpdateCaseList
                        UpdateCaseList.add(cs);
                    }
                } else if (string.valueOf(cs.OwnerId).startsWith('005')) {
                    // Check if Case Owner is User
                    //Add User Id to OwnerIdSet
                    OwnerIdSet.add(cs.OwnerId);
                    OwnerCaseList.add(cs);
                }
                
                // increment the instance member counter
            	recordsProcessed = recordsProcessed + 1;
            }
			
            // Check for OwnerIdSet is not EMpty
            if (!OwnerIdSet.isEmpty() && OwnerIdSet.size() > 0) {
                for (GroupMember gm: [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:OwnerIdSet AND Group.Type='Regular' ORDER BY Group.DeveloperName ASC NULLS LAST LIMIT 50000]) {
                    groupMemberIdSet.add(gm.GroupId);
                    if (groupMemberMap.containsKey(gm.UserOrGroupId)) {
                        List<Id> groupIds = groupMemberMap.get(gm.UserOrGroupId);
                        groupIds.add(gm.GroupId);
                        groupMemberMap.put(gm.UserOrGroupId, groupIds);
                    } else {
                        groupMemberMap.put(gm.UserOrGroupId, new List<Id> { gm.GroupId });
                    }
                }

                if (!groupMemberIdSet.isEmpty() && groupMemberIdSet.size() > 0) {
                    for (GroupMember ql: [SELECT Group.DeveloperName,UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN: groupMemberIdSet AND Group.type = 'Queue' ORDER BY Group.DeveloperName ASC NULLS LAST LIMIT 50000]) {
                        if (queueMap.containsKey(ql.UserOrGroupId)) {
                            List<String> queueNames = queueMap.get(ql.UserOrGroupId);
                            if (!queueNames.isEmpty()) {
                                queueNames.add(ql.Group.DeveloperName);
                                queueMap.put(ql.UserOrGroupId, queueNames);
                            }
                        } else {
                            queueMap.put(ql.UserOrGroupId, new List<String>{ql.Group.DeveloperName});
                        }
                    }
                }

                if (!queueMap.isEmpty() && queueMap.size() > 0) {
                    for (Case cs: OwnerCaseList) {
                        if (groupMemberMap.containsKey(cs.OwnerId)) {
                            for (Id i: groupMemberMap.get(cs.OwnerId)) {
                                if (queueMap.containsKey(i)) {
                                    List<String> queueList = queueMap.get(i);
                                    if (!queueList.isEmpty()) {
                                        if (queueList[0] != null) {
                                            cs.ApprovalQueueName__c = queueList[0];
                                            UpdateCaseList.add(cs);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
		
        // Check for UpdateCaseList is Empty or Not
        if (!UpdateCaseList.isEmpty() && UpdateCaseList.size() > 0) {
            //Update Case Records
            Database.SaveResult[] srList;
            if (!Schema.sObjectType.Case.fields.ApprovalQueueName__c.isUpdateable()){
        		srList = Database.update(UpdateCaseList, false);
            }
            if(srList!=null && !srList.isEmpty()){
                ExceptionHandler.logHandledExceptions(srList, 'DispatchApprovalQueueMappingBatch', 'execute', 'Dispatch Management');
            }
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name: Finish
    Description: To send confirmation email after post-processing all batch operations.
				 This method is called after all batches are processed.
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    07/31/2018     1.0    Harsha Reddy       Initial Release
    07/31/2018     1.0    Rodrigo Carpio     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    global void finish(Database.BatchableContext BC) {
        //Move Email Address to Custom Labels - Harsha
        EmailUtility.sendPlainTextEmail(new List<String>{'Service_Cloud_DEV_Admins@Dell.com'}, 
                                        'DispatchApprovalQueueMappingBatch Process Completed', 
                                        'DispatchApprovalQueueMappingBatch Completed ===> No.of Records Processed = '+recordsProcessed);
    }
}
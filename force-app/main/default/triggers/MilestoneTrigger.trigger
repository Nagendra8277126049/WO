trigger MilestoneTrigger on pse__Milestone__c (after insert, after update, before delete) {
    
    MilestoneHandler.handleMilestones(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isBefore, Trigger.isAfter);
   
}
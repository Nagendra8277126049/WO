/*
      Purpose:
            Maintain the CE Survey Contact lookup field on Project in relation to CE Survey checkbox
            field on Project Contact, and its Contact__c lookup

      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/3/18
*/

trigger ProjectTrigger on pse__Proj__c (before update, after update, after insert) {
    TriggerOperation triggerOp;
    if (Trigger.isInsert && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_INSERT;
    if (Trigger.isInsert && Trigger.isBefore) triggerOp = TriggerOperation.BEFORE_INSERT;
    if (Trigger.isUpdate && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_UPDATE;
    if (Trigger.isUpdate && Trigger.isBefore) triggerOp = TriggerOperation.BEFORE_UPDATE;
    if (Trigger.isDelete && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_DELETE;
    if (Trigger.isDelete && Trigger.isBefore) triggerOp = TriggerOperation.BEFORE_DELETE;
    if (Trigger.isUndelete && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_UNDELETE;
    
    if (triggerOp == TriggerOperation.BEFORE_UPDATE){
        IdsProjectClosureHandler.handleClosure(Trigger.oldMap, Trigger.newMap);
    }
    
    if (triggerOp == TriggerOperation.AFTER_UPDATE) {
        ProjectContactHandler.maintainProjectContactRecords(Trigger.oldMap, Trigger.newMap, triggerOp);
        
        IdsProjectHandler.HandlePhaseChange(Trigger.old, Trigger.new);
        
        IdsProjectHandler.handleStageChange(Trigger.old, Trigger.new);
        
        IdsProjectClosureHandler.handleMilestones(Trigger.oldMap, Trigger.newMap);
    }
    
    if(triggerOp == TriggerOperation.BEFORE_INSERT){
        for(pse__Proj__c project : Trigger.new){
            project.pse__Is_Active__c = true;
            project.pse__Is_Billable__c = true;
        }
    }
    
    if (triggerOp == TriggerOperation.AFTER_INSERT){
        List<id> projectIds = new List<id>();
        for(pse__Proj__c project : Trigger.new){
            projectIds.add(project.Id);
        }
       ProjectMilestoneCreator.createMilestoneFromProject(projectIds);
    }
    
    //if (triggerOp == TriggerOperation.AFTER_INSERT || triggerOp == TriggerOperation.AFTER_UPDATE)
    //{
    //    /*if (OT_TriggerController.projectTriggerEnabled) {
    //        List<ID> idList = new List<ID>();
    //        
    //        for (pse__Proj__c prj : Trigger.new) {
    //            idList.add(prj.ID);
    //        }
    //        
    //        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Project' });*/
    //    }
    //}
}
/*
      Purpose:
            Your purpose here...
            
      Initiative: ...Initiative...
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/18/18
*/

trigger ProjectTaskTrigger on pse__Project_Task__c (after insert, after update, after delete, before update) {
    ProjectTaskHandler.handleProjectTasks(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
    ProjectTaskHandler.updateProjectSite(Trigger.newMap, Trigger.isUpdate, Trigger.isBefore);
	if (Trigger.isInsert && Trigger.isAfter) {
		IdsProjectTaskHandler projectTaskHandlerJob = new IdsProjectTaskHandler(Trigger.new, false);
		
		ID jobID = System.enqueueJob(projectTaskHandlerJob);
	}
}
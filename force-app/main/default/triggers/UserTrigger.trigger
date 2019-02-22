/*
      Purpose:
            Maintain membership of a group / queue that represents users who should be able to access
            Federal projects, based on the value of the checkbox field User.Federal_Access__c.
            
      Initiative: Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    8/1/18

	==================================================================================	
	Modfications :
	Purpose	: Updating Resources related to the user when the user is deactivated.
	Date	: 1/3/2019
	Author	: Pawan K
	Company	: OAC Services INC.
	===================================================================================

*/

trigger UserTrigger on User (after insert, after update, before update) 
{
    if(trigger.isAfter)
    {
        UserHandler.maintainFederalGroupMembership(Trigger.isInsert,Trigger.isUpdate,Trigger.newMap,Trigger.oldMap);
    }
    
	if(RecursiveTriggerHandler.isFirstTime())
    {    
        if(trigger.isBefore)
    	{
        	//Update Event
        	UserHandler.beforeUpdate(Trigger.isUpdate,Trigger.newMap,Trigger.oldMap);
    	}
    }
    
}
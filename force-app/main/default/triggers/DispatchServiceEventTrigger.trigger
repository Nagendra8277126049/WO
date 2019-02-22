trigger DispatchServiceEventTrigger on DispatchServiceEvent__c (before update, after insert, before insert) {
    if(!(Trigger_Execution_Control__c.getInstance().Skip_WorkOrder_Trigger__c)){
        /*if(Trigger.isAfter && Trigger.isInsert)
        {
            system.debug('Trigger.isAfter && Trigger.isInsert');
            DispatchServiceEventTriggerHandler.performStatusUpdate(Trigger.oldMap, Trigger.newMap); 
        }*/
        if(Trigger.isBefore && Trigger.isInsert)
        {
            map<Id, DispatchServiceEvent__c> mapNew;
            system.debug('Trigger.isBefore && Trigger.isInsert ' + trigger.new);
            mapNew = new map<Id, DispatchServiceEvent__c>();
			for(DispatchServiceEvent__c o : trigger.new)
				mapNew.put(o.Id, o);

            DispatchServiceEventTriggerHandler.performStatusUpdate(Trigger.oldMap, mapNew); 
        }
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            system.debug('Trigger.isBefore && Trigger.isUpdate');
            DispatchServiceEventTriggerHandler.performStatusUpdate(Trigger.oldMap, Trigger.newMap);            
        }
    }
}
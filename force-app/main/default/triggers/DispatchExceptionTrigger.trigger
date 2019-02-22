trigger DispatchExceptionTrigger on DispatchException__c (before update, after insert, before insert) {
	if(!(Trigger_Execution_Control__c.getInstance().Skip_WorkOrder_Trigger__c))
    {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            map<Id, DispatchException__c> mapNew;
            system.debug('Trigger.isBefore && Trigger.isInsert ' + trigger.new);
            mapNew = new map<Id, DispatchException__c>();
			for(DispatchException__c o : trigger.new)
				mapNew.put(o.Id, o);

            DispatchExceptionTriggerHandler.performStatusUpdate(Trigger.oldMap, mapNew); 
        }
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            system.debug('Trigger.isBefore && Trigger.isUpdate');
            DispatchExceptionTriggerHandler.performStatusUpdate(Trigger.oldMap, Trigger.newMap);            
        }        
    }
}
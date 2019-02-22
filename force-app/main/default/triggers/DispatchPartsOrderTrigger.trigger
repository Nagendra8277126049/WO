trigger DispatchPartsOrderTrigger on DispatchPartsOrder__c (before update, before insert) {
    if(!(Trigger_Execution_Control__c.getInstance().Skip_WorkOrder_Trigger__c))
    {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            map<Id, DispatchPartsOrder__c> mapNew;
            system.debug('Trigger.isBefore && Trigger.isInsert ' + trigger.new);
            mapNew = new map<Id, DispatchPartsOrder__c>();
			for(DispatchPartsOrder__c o : trigger.new)
				mapNew.put(o.Id, o);

            DispatchPartsOrderTriggerHandler.performStatusUpdate(Trigger.oldMap, mapNew); 
        }
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            system.debug('Trigger.isBefore && Trigger.isUpdate');
            DispatchPartsOrderTriggerHandler.performStatusUpdate(Trigger.oldMap, Trigger.newMap);            
        }        
    }
}
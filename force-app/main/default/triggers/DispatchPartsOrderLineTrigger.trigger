trigger DispatchPartsOrderLineTrigger on DispatchPartsOrderLine__c (before update, before insert, after insert) {
    if(!(Trigger_Execution_Control__c.getInstance().Skip_WorkOrder_Trigger__c))
    {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            map<Id, DispatchPartsOrderLine__c> mapNew;
            system.debug('Trigger.isBefore && Trigger.isInsert ' + trigger.new);
            mapNew = new map<Id, DispatchPartsOrderLine__c>();
			for(DispatchPartsOrderLine__c o : trigger.new)
				mapNew.put(o.Id, o);
            DispatchPartsOrderLineTriggerHandler.performStatusUpdate(Trigger.oldMap, mapNew); 
        }
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            system.debug('Trigger.isBefore && Trigger.isUpdate');
            DispatchPartsOrderLineTriggerHandler.performStatusUpdate(Trigger.oldMap, Trigger.newMap);            
        }  
        
    }
}
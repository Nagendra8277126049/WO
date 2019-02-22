/**
 * Trigger on the Order table to create/update business workspaces
 */
trigger xecmOrderTrigger on Order (after insert, after update) {
    
    if (TriggerController.orderTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Order ord : Trigger.new) {
            idList.add(ord.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Order' });
    }
}
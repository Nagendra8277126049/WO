/**
 * Trigger on the Product table to create/update business workspaces
 */
trigger xecmProductTrigger on Product2 (after insert, after update) {
    
    if (TriggerController.product2TriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Product2 prod : Trigger.new) {
            idList.add(prod.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Product' });
    }
}
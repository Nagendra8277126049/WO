/**
 * Trigger on the Quote table to create/update business workspaces
 */
trigger xecmQuoteTrigger on Quote (after insert, after update) {
    
    if (TriggerController.quoteTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Quote qt : Trigger.new) {
            idList.add(qt.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Quote' });
    }
}
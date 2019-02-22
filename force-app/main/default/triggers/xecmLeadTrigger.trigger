/**
 * Trigger on the Lead table to create/update business workspaces
 */
trigger xecmLeadTrigger on Lead (after insert, after update) {
    
    if (TriggerController.leadTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Lead ld : Trigger.new) {
            idList.add(ld.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Lead' });
    }
}
/**
 * Trigger on the Case table to create/update business workspaces
 */
trigger xecmCaseTrigger on Case (after insert, after update) {
    
    if (TriggerController.caseTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Case cs : Trigger.new) {
            idList.add(cs.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Case' });
    }
}
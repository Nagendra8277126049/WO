/**
 * Trigger on the Opportunity table to create/update business workspaces
 */
trigger xecmOpportunityTrigger on Opportunity (after insert, after update) {
    
    if (TriggerController.opportunityTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Opportunity op : Trigger.new) {
            idList.add(op.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Opportunity' });
    }
}
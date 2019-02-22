/**
 * Trigger on the Solution table to create/update business workspaces
 */
trigger xecmSolutionTrigger on Solution (after insert, after update) {
    
    if (TriggerController.solutionTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Solution sol : Trigger.new) {
            idList.add(sol.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Solution' });
    }
}
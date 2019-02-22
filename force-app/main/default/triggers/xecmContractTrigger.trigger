/**
 * Trigger on the Contract table to create/update business workspaces
 */
trigger xecmContractTrigger on Contract (after insert, after update) {
    
    if (TriggerController.contractTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Contract con : Trigger.new) {
            idList.add(con.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Contract' });
    }
}
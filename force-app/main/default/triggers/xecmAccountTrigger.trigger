/**
 * Trigger on the Account table to create/update business workspaces
 */
trigger xecmAccountTrigger on Account (after insert, after update) {
    
    if (TriggerController.accountTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Account acnt : Trigger.new) {
            idList.add(acnt.ID);
        }

        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Account' });
    }
}
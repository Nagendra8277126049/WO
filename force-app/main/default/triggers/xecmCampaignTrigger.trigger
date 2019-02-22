/**
 * Trigger on the Campaign table to create/update business workspaces
 */
trigger xecmCampaignTrigger on Campaign (after insert, after update) {
    
    if (TriggerController.campaignTriggerEnabled) {
        
        List<ID> idList = new List<ID>();
        
        for (Campaign camp : Trigger.new) {
            idList.add(camp.ID);
        }
        
        XECMFacade.raiseStandardEvent(idList, new List<String> { 'Campaign' });
    }
}
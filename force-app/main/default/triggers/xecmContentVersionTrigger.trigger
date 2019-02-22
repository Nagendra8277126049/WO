/**
 * Created by cshah on 2/13/2018.
 */

trigger xecmContentVersionTrigger on ContentVersion (after insert, after update) {
    if (TriggerController.contentVersionTriggerEnabled) {
        XECMFacade.processContents(Trigger.new);
    }
}
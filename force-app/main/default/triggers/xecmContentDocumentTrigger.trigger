/**
 * Created by cshah on 2/14/2018.
 */

trigger xecmContentDocumentTrigger on ContentDocument (after insert, after update) {
    if (TriggerController.contentDocumentTriggerEnabled) {
        XECMFacade.processContents(Trigger.new);
    }
}
/**
 * Created by cshah on 2/13/2018.
 */

trigger xecmContentDocumentLinkTrigger on ContentDocumentLink (after insert, after update) {
    if (TriggerController.contentDocumentLinkTriggerEnabled) {
        XECMFacade.processContents(Trigger.new);
    }
}
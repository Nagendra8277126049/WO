/**
 * Created by cshah on 2/14/2018.
 */

trigger xecmAttachmentTrigger on Attachment (after insert, after update) {
    if (TriggerController.attachmentTriggerEnabled) {
        XECMFacade.processContents(Trigger.new);
    }
}
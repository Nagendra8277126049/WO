/**
 * Created by cshah on 2/14/2018.
 */

trigger xecmNoteTrigger on Note (after insert, after update) {
    if (TriggerController.noteTriggerEnabled) {
        XECMFacade.processContents(Trigger.new);
    }
}
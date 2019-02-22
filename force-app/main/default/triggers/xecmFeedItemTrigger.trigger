/**
 * Created by cshah on 2/13/2018.
 */

trigger xecmFeedItemTrigger on FeedItem (after insert, after update) {
    if (TriggerController.feedItemTriggerEnabled) {
        XECMFacade.processContents(Trigger.new);
    }
}
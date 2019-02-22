/* -----------------------------------------------------------------------------------------------------------------------
Name:       ContentVersionTriggerHelper
Description: Used in ContentVersionTrigger to restrict Blacklisted file types uploaded through case tab
-  Story #4202316
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
04/01/2017     1.0         Ashish Sharma          Initial Release
01/08/2018     1.1         Soniya Sharaff         Bulkification
-------------------------------------------------------------------------------------------------------------------------- */

trigger ContentVersionTrigger on ContentVersion (after insert) {
    if(!(Trigger_Execution_Control__c.getInstance().Skip_ContentVersion_Trigger__c))
    {        
        ContentVersionTriggerHelper.attach(trigger.new);
    }
}
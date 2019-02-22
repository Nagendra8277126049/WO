/* -----------------------------------------------------------------------------------------------------------------------
Name:         AttachmentTrigger
Description:  Trigger to restrict Blacklisted file types uploaded through Live Agent Chat console
and Email to Case
-  Story #4202316
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/28/2017     1.0     Dhamodharan Duraisamy       Initial Release
01/08/2018     1.1     Soniya Sharaff              Bulkifications
01/08/2018     1.2     Roselin Hephzibah           Added additonal parameter to move SOQL queries outside For Loop
-------------------------------------------------------------------------------------------------------------------------- */

trigger AttachmentTrigger on Attachment (after insert) {
       if(!(Trigger_Execution_Control__c.getInstance().Skip_Attachment_Trigger__c))
    {
        AttachmentRestriction.AttRestrict(trigger.new,trigger.newMap);
    }
}
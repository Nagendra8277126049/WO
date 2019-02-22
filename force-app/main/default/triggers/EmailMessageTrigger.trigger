/* -----------------------------------------------------------------------------------------------------------------------
Trigger Name:       EmailMessageTrigger
Description:        To Skip trigger make 'Skip_EmailMessage_Trigger__c' to true,in custom setting 'Trigger_Execution_Control__c'
Story       :       Story #4961381 SFDC Phase 3 :: Case Management :: Prevent users from deleting emails attached to cases.
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
04/19/2018     1.0     Srikanth Parvathareddy        Initial Release
-------------------------------------------------------------------------------------------------------------------------- 
*/ 
trigger EmailMessageTrigger on EmailMessage (before delete) {
    
    if(!(Trigger_Execution_Control__c.getInstance().Skip_EmailMessage_Trigger__c))
    {
         EmailMessageTriggerHandler.deleteprevention(Trigger.Old);
    }
}
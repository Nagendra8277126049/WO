/* -----------------------------------------------------------------------------------------------------------------------
Trigger Name:       ContactTrigger
Description:        To Skip trigger make 'Skip_Contact_Trigger__c' to true,in custom setting 'Trigger_Execution_Control__c'
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/23/2018     1.0            Prasanth              Initial Release
-------------------------------------------------------------------------------------------------------------------------- 
*/

trigger ContactTrigger on Contact (before Insert, before Update) { 
        
    if(!Trigger_Execution_Control__c.getInstance().Skip_Contact_Trigger__c) {
         ContactTriggerHandler.callMethods(Trigger.New);
     } 
}
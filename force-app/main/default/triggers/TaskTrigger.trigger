/* -----------------------------------------------------------------------------------------------------------------------
Trigger Name:       TaskTrigger
Description:        To Skip trigger make 'Skip_Task_Trigger__c' to true,in custom setting 'Trigger_Execution_Control__c'
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/05/2018     1.0            rodrigo carpio                 Initial Release
09/14/2018     1.1         alan birchenough                  Added call to CustomerContactAttemptCounter
-------------------------------------------------------------------------------------------------------------------------- 
*/
trigger TaskTrigger on Task (after insert) {
    if (!(Trigger_Execution_Control__c.getInstance().Skip_Task_Trigger__c)) {
        TaskTriggerHandler.callmethods(Trigger.new);
        CustomerContactAttemptCounter.handleTriggerTasks(Trigger.newMap.keySet());
    }
}
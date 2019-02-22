/* -----------------------------------------------------------------------------------------------------------------------
Trigger Name:       AssetTrigger
Description:        To Skip trigger make 'Skip_Asset_Trigger__c' to true,in custom setting 'Trigger_Execution_Control__c'
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/03/2017     1.0            Sonia                 Initial Release
5th Jan 2017   1.1            R.Hari Krishna        Code Cleansing
-------------------------------------------------------------------------------------------------------------------------- 
*/

trigger AssetTrigger on Asset (before Insert, before Update,after Insert, after Update) { 
        
    if(!Trigger_Execution_Control__c.getInstance().Skip_Asset_Trigger__c) {
         AssetTriggerHandler.callMethods(Trigger.New);
     } 
}
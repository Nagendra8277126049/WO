/* -----------------------------------------------------------------------------------------------------------------------
Class Name :       EmailMessageTriggerHandler
Description:       Handler Class for 'EmailMessageTrigger' to restrict the deletion of email records by service agent.
Story       :       Story #4961381 SFDC Phase 3 :: Case Management :: Prevent users from deleting emails attached to cases.
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
04/19/2018     1.0     Srikanth Parvathareddy        Initial Release
-------------------------------------------------------------------------------------------------------------------------- 
*/ 

public class EmailMessageTriggerHandler {
    
    public static void deleteprevention(List<EmailMessage> emlist)
    {
        if (Trigger.isbefore && trigger.isdelete)
        {
            EmailMessageTriggerHandler.beforedelete(emlist);
        }         
    }
    
    
    /* -----------------------------------------------------------------------------------------------------------------------
Method Name :       beforedelete
Description :       Toasting of error message to user while deleting the email record.
Story       :       Story #4961381 SFDC Phase 3 :: Case Management :: Prevent users from deleting emails attached to cases.
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
04/19/2018     1.0     Srikanth Parvathareddy        Initial Release
-------------------------------------------------------------------------------------------------------------------------- 
*/ 
    
    Public static void beforedelete(List<EmailMessage> emObj)
    {
        try
        {   
            for(EmailMessage em:emObj)
            {
                String ems=String.valueOf(em.RelatedToId);
                if(em.RelatedToId!=null && ems.startsWith('500'))
                {
                    em.adderror('You are not allowed to delete this email');
                }   
            } 
            
        } 
        catch(Exception e){
            ExceptionHandler.logHandledExceptions(e,'EmailMessageTriggerHandler','beforedelete',NULL);
        }
    }    
    
}
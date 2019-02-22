/* -----------------------------------------------------------------------------------------------------------------------
Name:       TaskTriggerHandler
Description:  This class contains the operation to handle task trigger operations Defect#4477993
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
01/04/2018     1.0     Rodrigo Carpio      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */ 
public class TaskTriggerHandler {
    public static void callmethods(List<Task> taskObj)
    {
         if (Trigger.isAfter && trigger.isInsert)
        {
            TaskTriggerHandler.afterInsert(taskObj);
        }
    }
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  updateTaskField
    Description:  perform the DML update on the task record -  Defect #4477993
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------
    01/04/2018     1.0     Rodrigo Carpio       Initial Release
    02/08/2018	   2.0	   Rodrigo Carpio       Added changes for story #4521155 
    -------------------------------------------------------------------------------------------------------------------------- */
    @future
    public static void updateTaskField(Id taskID)
    {
        try{
            EmailMessage emailItem;            
            emailItem =[SELECT Incoming, ToAddress, CcAddress, BccAddress, FromAddress, Subject, CreatedDate, TextBody 
                        FROM EmailMessage WHERE ActivityId = :taskID LIMIT 1];             
            Task taskToUpdate;            
            taskToUpdate =[SELECT EmailTaskOutboundUpdate__c, description FROM Task WHERE Id = :taskID LIMIT 1];                        
            if (emailItem.Incoming == true)
            {
                String descriptionStr = '';                
                descriptionStr = descriptionStr + 'TO: ' + emailItem.ToAddress + '\r\n';
                descriptionStr = descriptionStr + 'CC: ';
                if (emailItem.CcAddress != null)
                    descriptionStr = descriptionStr + emailItem.CcAddress + '\r\n';
                else
                    descriptionStr = descriptionStr + '\r\n';                
                descriptionStr = descriptionStr + 'BCC: '; 
                if (emailItem.BccAddress != null)    
                    descriptionStr = descriptionStr + emailItem.BccAddress + '\r\n';
                else
                    descriptionStr = descriptionStr + '\r\n';                
                descriptionStr = descriptionStr + 'FROM: ' + emailItem.FromAddress + '\r\n';
                descriptionStr = descriptionStr + 'SUBJECT: ' + emailItem.Subject + '\r\n';
                descriptionStr = descriptionStr + 'DATE&TIME: ' + emailItem.CreatedDate + '\r\n';
                descriptionStr = descriptionStr + 'BODY: ' + emailItem.TextBody;                
                taskToUpdate.description = descriptionStr;
            }            
            taskToUpdate.EmailTaskOutboundUpdate__c = true;            
            update taskToUpdate;            
        }
        catch(Exception e){
            ExceptionHandler.logHandledExceptions(e,'TaskTriggerHandler','updateTaskField',NULL);
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  afterInsert
    Description:  process the task information that was sent from the trigger -  Defect #4477993
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------
    01/04/2018     1.0     Rodrigo Carpio       Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
	public static void afterInsert(List<Task> taskObj)
    {
        try
        {
            List<Task> taskList = new List<Task>();
            for(Task taskItem : taskObj){
                if (taskItem.TaskSubType == 'Email')
                {
                    taskList.add(taskItem);
                }
            }
        
            if(taskList.size()>0)
            {
                for(Task tastItem : taskList)       
                {
                    updateTaskField(tastItem.Id);
                }
            }
        }
        catch(Exception e){
            ExceptionHandler.logHandledExceptions(e,'TaskTriggerHandler','afterInsert',NULL);
        }
    }
}
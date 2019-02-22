public class IdsProjectTaskHandler implements Queueable {
    
    private List<pse__Project_Task__c> newProjectTasks;
    private Boolean testMode;
    
    public IdsProjectTaskHandler(List<pse__Project_Task__c> projectTasks, Boolean isTest) {
        newProjectTasks = projectTasks;
        testMode = isTest;
    }
    
    public void execute(QueueableContext context) {
        List<Id> projects = new List<Id>();
        
        for (pse__Project_Task__c projectTask : newProjectTasks) {
            if (projectTask.pse__Project__c != null && !projects.contains(projectTask.pse__Project__c)) {
                projects.add(projectTask.pse__Project__c);
            }
        }
        
        List<Clone_Project_Info__c> cloneProjectInfo = [
            SELECT Id, Queued_Job_Id__c, Async_Apex_Job_Completed__c, Order__c, Project__c
              FROM Clone_Project_Info__c 
             WHERE Project__c IN :projects AND Async_Apex_Job_Completed__c = false];
        
        for (Clone_Project_Info__c info : cloneProjectInfo) {
            Id asyncApexJobId;
            
            if (!testMode) {
            	asyncApexJobId = info.Queued_Job_Id__c;	    
            }
            else {
              asyncApexJobId = [SELECT Id FROM AsyncApexJob WHERE CompletedDate != NULL LIMIT 1].Id;  
            }
            
            for (AsyncApexJob job : [SELECT Id, Status, CompletedDate FROM AsyncApexJob WHERE Id = :asyncApexJobId AND CompletedDate != NULL]) {
                String projectTemplateId = [SELECT Template_Id__c FROM pse__Proj__c WHERE Id = :info.Project__c].Template_Id__c;
                
                List<pse__Project_Task__c> projectTemplateTasks = [SELECT Id, Name FROM pse__Project_Task__c WHERE pse__Project__c = :projectTemplateId];
                List<Id> existingTemplateTasks = new List<Id>();
                
                for (pse__Project_Task__c templateTask : projectTemplateTasks) {
                    for (pse__Project_Task__c projectTask : newProjectTasks) { 
                        
                        if (templateTask.Name == projectTask.Name) {
                            existingTemplateTasks.add(projectTask.Id);
                            
                            break;
                        }
                        
                    }
                }
                
                if (existingTemplateTasks.size() == projectTemplateTasks.size()) {
                    info.Async_Apex_Job_Completed__c = true;
                    
                    if (!testMode) {
                    	FlowRunner.Run_Add_Tasks_based_on_SKU_Mapping(info.Order__c, info.Project__c, true);
                    }
                }
            }
        }
        
        if (cloneProjectInfo != null && cloneProjectInfo.size() > 0) {
        	update cloneProjectInfo;
        } 
    }
}
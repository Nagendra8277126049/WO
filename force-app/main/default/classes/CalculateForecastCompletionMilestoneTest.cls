@isTest public class CalculateForecastCompletionMilestoneTest {
    
    @isTest static void UpdateForecastCompletionDateMilestone() {
        Account account = new Account(Name = 'Test account');
        
        insert(account);
        
        // case low
        pse__Proj__c project = CreateProject('Low', account.Id);
        
        insert(project);
               
        Test.startTest();
        
        CalculateForecastCompletionMilestone.UpdateForecastCompletionDateMilestone(new List<Id> { project.Id });
		
        Test.stopTest();
        
        List<pse__milestone__c> milestones = [SELECT pse__Target_Date__c FROM pse__milestone__c];
        
        System.assert(milestones != null);
		System.assert(milestones.size() == 1);
        System.assert(milestones[0].pse__Target_Date__c != Date.today()); 
    }
    
    // static method to mock project data
    static pse__Proj__c CreateProject(String complexity, String accountId)
    {
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            Project_Complexity__c = 'Low',
            pse__Account__c = accountId,
            pse__Is_Active__c = true
        );
        
        return project;
    }
}
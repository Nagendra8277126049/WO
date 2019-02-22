//to create comment to describe
public class CalculateForecastCompletionMilestone {
    
    @InvocableMethod(label='Update Forecast Completion Date milestone' description='Updates the Forecast Completion Date milestone.' )
    public static void UpdateForecastCompletionDateMilestone(List<Id> projectIds) {
        List<pse__Proj__c> projToUpdate = new List<pse__Proj__c>();
        for(id projectId : projectIds) {
            pse__proj__c project = [SELECT Id, CreatedDate, Project_Complexity__c FROM pse__proj__c where Id =: projectId];

            Date targetDate = ProjectMilestoneCalculator.CaculateTargetDate(project.CreatedDate.date(), project.Project_Complexity__c);
            List<pse__milestone__c> forecastMilestone = [SELECT id FROM pse__milestone__c where pse__Project__c =: project.id and name LIKE '%Milestone 1' limit 1];

            if (forecastMilestone != null && forecastMilestone.size() == 1) {
                forecastMilestone[0].pse__Target_Date__c = targetDate;
                update forecastMilestone;
                // Update Project End Date
                project.pse__End_Date__c = targetDate;
                projToUpdate.add(project);
            }
        }
        update projToUpdate;
    }
}
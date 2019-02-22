public class ProjectMilestoneCreator {

    @InvocableMethod()
    public static void createMilestoneFromProject(List<id> projectIds) {
        List<pse__proj__c> projects = [SELECT Id ,  pse__End_Date__c , CreatedDate , Project_Complexity__c, pse__Account__r.Name from pse__proj__c where Id IN :projectIds];
        List<pse__milestone__c> milestones = [SELECT Id, pse__Project__c, Current__c, Name FROM pse__milestone__c where pse__Project__c IN :projectIds and Current__c = true];
        List<pse__Milestone__c> newMilestones = new List<pse__Milestone__c>();
        
        for (pse__proj__c project : projects) {
            Id idMilestoneCurrent;
            
            for (pse__Milestone__c milestone : milestones) {
                if (milestone.pse__Project__c == project.Id && milestone.Current__c) {
                    	idMilestoneCurrent = milestone.Id;
                        break;
                    }
            }
            
            if (idMilestoneCurrent == null) {
                // Creates Milestone 1.				
                pse__Milestone__c milestone1 = new pse__Milestone__c();
                milestone1.pse__Project__c = project.Id;
                milestone1.Name = project.pse__Account__r.Name + ' - Milestone 1';
                milestone1.pse__Target_Date__c = System.today();
                milestone1.Current__c = true; 
                newMilestones.add(milestone1);
            }
        }
                
        if (newMilestones.size() > 0) {
            insert newMilestones;
        }
    }
}
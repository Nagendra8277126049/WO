@IsTest
public class MilestoneHandlerTest {
 
    @IsTest
    static void testInsertMilestone() {  
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project', pse__Is_Active__c = true);
        insert testProject;
        
        pse__Milestone__c milestone1 = new pse__Milestone__c(Name='Milestone 1', Current__c = true, pse__Project__c = testProject.Id, pse__Target_Date__c = System.today());
        insert milestone1;
        
        pse__Milestone__c milestone2 = new pse__Milestone__c(Name='Milestone 2', Current__c = false, pse__Project__c = testProject.Id, pse__Target_Date__c = System.today());
		insert milestone2;
        
        //insert new Milestone with current = true
        pse__Milestone__c milestone3 = new pse__Milestone__c(Name='Milestone 3', Current__c = true, pse__Project__c = testProject.Id, pse__Target_Date__c = System.today());
        insert milestone3;
        List<pse__Milestone__c> milestonesCurrent = [SELECT Id FROM pse__Milestone__c WHERE pse__Project__c =: testProject.Id AND Current__c = true];
        System.assertEquals(1, milestonesCurrent.size()); //only 1 current
    }
    
    @IsTest
    static void testUpdateMilestone() {
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project', pse__Is_Active__c = true);
        insert testProject;
        
        pse__Milestone__c milestone1 = new pse__Milestone__c(Name='Milestone 1', Current__c = true, pse__Project__c = testProject.Id, pse__Target_Date__c = System.today());
        insert milestone1;
        
        pse__Milestone__c milestone2 = new pse__Milestone__c(Name='Milestone 2', Current__c = false, pse__Project__c = testProject.Id, pse__Target_Date__c = System.today());
		insert milestone2;
        
        List<pse__Milestone__c> milestonesCurrent = [SELECT Id FROM pse__Milestone__c WHERE pse__Project__c =: testProject.Id AND Current__c = true];
        System.assertEquals(1, milestonesCurrent.size()); //only 1 current
        
        milestone2.Current__c = true;
        update milestone2;
        
        milestonesCurrent = [SELECT Id FROM pse__Milestone__c WHERE pse__Project__c =: testProject.Id AND Current__c = true];
        System.assertEquals(1, milestonesCurrent.size()); //again only 1 current
        
        try {
            milestone2.Current__c = false;
        	update milestone2;
		} catch(Exception error) {
        	System.assert(error.getMessage().contains('Update failed.'));
            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			System.assert(error.getMessage().contains('The "current" option cannot be unchecked'));
        }
    }
    
    @IsTest
    static void testDeleteMilestone() {
		try {
            pse__Proj__c testProject = new pse__Proj__c(Name='Test Project', pse__Is_Active__c = true);
            insert testProject;
            
            pse__Milestone__c milestone1 = new pse__Milestone__c(Name='Milestone 1', Current__c = true, pse__Project__c = testProject.Id, pse__Target_Date__c = System.today());
            insert milestone1;
            
            pse__Milestone__c milestone2 = new pse__Milestone__c(Name='Milestone 2', Current__c = false, pse__Project__c = testProject.Id, pse__Target_Date__c = System.today());
            insert milestone2;
            
            //delete milestone that is not current
            delete milestone2;
            //try milestone current
        	delete milestone1;
		} catch(Exception error) {
            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			System.assert(error.getMessage().contains('The Milestone could not be deleted'));
        } 
        
    }
}
@isTest
public class ProjectMilestoneCreatorTest {
    static List<Id> createProject()
    {
        List<id> projectList = new List<id>();
        Account account = new Account();
        account.Name = 'Account Test';
        insert account;
        pse__Proj__c project = new pse__Proj__c();
        project.pse__Account__c = account.Id;
        project.Name = 'Project Test';
        project.pse__Is_Active__c = true;
        project.Project_Visibility__c = 'All';
        project.pse__End_Date__c=date.today().addDays(50); 
        project.CreatedDate=date.today();
        project.Project_Complexity__c='Low';
        insert project;
        projectList.add(project.id);
        return projectList;
        
    }	//with milestone
    
    // Creates Account Test - Milestone 1.
	static void createMilestone1(Id projectId){
        pse__Milestone__c milestone1 = new pse__Milestone__c();
        milestone1.pse__Project__c = projectId;
        milestone1.Name = 'Account Test - Milestone 1';
        milestone1.pse__Target_Date__c =  date.today();
        milestone1.Current__c = true;
        insert milestone1;
    }
    
    //with milestone
    @isTest static void shouldNotCreateNewMilestoneIfProjectHasMilestones(){
        List<id> ListTest = new List<id>();
        ListTest = createProject();
        id idProject = ListTest[0];
        
        createMilestone1(idProject);
        
        List<pse__Milestone__c> milestones =  [SELECT Id, Name FROM pse__Milestone__c WHERE pse__Project__c =: idProject  ] ;//and name LIKE '% Milestone 1'
       
        Test.startTest();
        ProjectMilestoneCreator.createMilestoneFromProject(ListTest);
        Test.stopTest();
        
        List<pse__Milestone__c> milestonesAft =  [SELECT Id, Name FROM pse__Milestone__c WHERE pse__Project__c =: idProject ] ;

        System.assertEquals(milestones.size(),milestonesAft.size());
	}
    
	//without milestone
    @isTest static void shouldCreateMilestonesIfProjectHasNoMilestones(){ 
        List<id> ListTest = new List<id>();
        ListTest = createProject();
        id idProject = ListTest[0];
       
        List<pse__Milestone__c> milestones =  [SELECT Id, Name FROM pse__Milestone__c WHERE pse__Project__c =: idProject and name LIKE '% Milestone 1' ] ;
        System.assertEquals(milestones.size(), 1);
        
        Test.startTest();
        ProjectMilestoneCreator.createMilestoneFromProject(ListTest);
        Test.stopTest();
        
		List<pse__Milestone__c> milestonesAft =  [SELECT Id, Name FROM pse__Milestone__c WHERE pse__Project__c =:idProject ] ;
        
        System.assertEquals(1, milestonesAft.size());
}
        

    
}
@isTest
public class IdsProjectTaskHandlerTest {
    static void setupTemplateProject() {
        pse__Proj__c templateProject = new pse__Proj__c(
            Name = 'Phased Project Template - Custom - Global',
            pse__Is_Template__c = true,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today()
        );

        insert(templateProject);

        List<pse__Project_Task__c> templateTasks = new List<pse__Project_Task__c>();

        pse__Project_Task__c t1 = new pse__Project_Task__c(
            Name = 'Initiate',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t1);

        pse__Project_Task__c t2 = new pse__Project_Task__c(
            Name = 'Plan',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t2);

        pse__Project_Task__c t3 = new pse__Project_Task__c(
            Name = 'Execute',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t3);
        
        pse__Project_Task__c t4 = new pse__Project_Task__c(
            Name = 'Close',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t4);

        insert(templateTasks);
    }
    
    static void setupProjectWithAssociatedOrder() {
        Account account = new Account(Name = 'Test account');
        
        insert(account);
        
        pse__Proj__c templateProj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Phased Project Template - Custom - Global'];
        
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Account__c = account.Id,
            Template_Id__c = templateProj.Id,
            pse__Project_Phase__c = 'Setup',
            pse__Is_Template__c = false,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today(),
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'Low'
        );
        
        insert(project);
		
        List<pse__Project_Task__c> tasks = new List<pse__Project_Task__c>();
        
        pse__Project_Task__c task1 = new pse__Project_Task__c(
        	Name = 'Initiate',
            pse__Project__c = project.Id
        );
        
        tasks.add(task1);
        
        pse__Project_Task__c task2 = new pse__Project_Task__c(
        	Name = 'Plan',
            pse__Project__c = project.Id
        );
        
        tasks.add(task2);
        
		pse__Project_Task__c task3 = new pse__Project_Task__c(
        	Name = 'Execute',
            pse__Project__c = project.Id
        );
        
        tasks.add(task3);

       	pse__Project_Task__c task4 = new pse__Project_Task__c(
			Name = 'Close',
            pse__Project__c = project.Id
        );
        
        tasks.add(task4);
        
        insert(tasks);
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            OrderNumber__c = '555666',
            PriceBook2Id = Test.getStandardPricebookId(),
            Project__c = project.Id
        );
        
        insert(order);
    }
    
    @testSetup
    static void setupData() {
        setupTemplateProject();
		setupProjectWithAssociatedOrder();
    }

    @isTest static void enqueueJobTest() {
		Order order = [SELECT Id FROM Order];
        pse__Proj__c project = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project'];
		List<pse__Project_Task__c> tasks = [SELECT Name, pse__Project__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id];
        
        Clone_Project_Info__c info = new Clone_Project_Info__c(
            Order__c = order.Id,
            Project__c = project.Id,
            Queued_Job_Id__c = '7073D00000Hb0G1QAJ'
        );
        
        insert(info);
        
        Test.startTest();
        
        IdsProjectTaskHandler projectTaskHandlerJob = new IdsProjectTaskHandler(tasks, true);
		
		System.enqueueJob(projectTaskHandlerJob);
        
        Test.stopTest();
        
        List<Clone_Project_Info__c> completedInfo = [SELECT Async_Apex_Job_Completed__c, Queued_Job_Id__c FROM Clone_Project_Info__c WHERE Order__c = :order.Id AND Project__c = :project.Id];
        
        System.assert(completedInfo.size() == 1);
        System.assert(completedInfo[0].Async_Apex_Job_Completed__c == true);
        System.assert(completedInfo[0].Queued_Job_Id__c == info.Queued_Job_Id__c);
    }
}
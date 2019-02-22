/*
      Purpose:
            Test ProjectTaskHandler, which rolls up custom "Standard Hours" field on project task to top of WBS.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/18/18
*/

@IsTest
private class ProjectTaskHandlerTest {
    @IsTest
    static void testSingleLevelRollupToSingleParentAfterInsert() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        Site__c site = new Site__c(Address_1__c = 'Test', City__c = 'test', Country__c = 'test', Postal_Code__c = '12200000', Status__c = 'Active');
        insert site;
        Project_Site__c projectSites = new Project_Site__c(Address_Type__c = 'Install At Contact',
                Project__c = testProject.Id, Site__c = site.Id);
        insert projectSites;

        
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', 13));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        testParentTask = [SELECT PSA_Standard_Hours__c, pse__Project__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];


        System.assertEquals(16, testParentTask.PSA_Standard_Hours__c);
    }
    @IsTest
    static void testSingleLevelRollupToSingleParentAfterUpdate() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        Site__c site = new Site__c(Address_1__c = 'Test', City__c = 'test', Country__c = 'test', Postal_Code__c = '12200000', Status__c = 'Active');
        insert site;
        Project_Site__c projectSites = new Project_Site__c(Address_Type__c = 'Shipping',
                Project__c = testProject.Id, Site__c = site.Id);
        insert projectSites;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', 13));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        testSubTasks[1].PSA_Standard_Hours__c += 5;
        update testSubTasks[1];
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        System.assertEquals(21, testParentTask.PSA_Standard_Hours__c);
    }
    @IsTest
    static void testSingleLevelRollupToSingleParentAfterDelete() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', 13));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 3', 5));
        insert testSubTasks;
        delete testSubTasks[1];
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        System.assertEquals(18, testParentTask.PSA_Standard_Hours__c);
    }
    @IsTest
    static void testMultipleLevelRollupToSingleParentAfterInsert() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = True);
        insert testProject;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        List<pse__Project_Task__c> testSubSubTasks = new List<pse__Project_Task__c>();
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1', 7));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.2', 6));
        insert testSubSubTasks;
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        testSubTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[0].Id];
        System.assertEquals(16, testParentTask.PSA_Standard_Hours__c);
        System.assertEquals(13, testSubTasks[0].PSA_Standard_Hours__c);

    }
    @IsTest
    static void testMultipleLevelRollupToSingleParentAfterUpdate() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        List<pse__Project_Task__c> testSubSubTasks = new List<pse__Project_Task__c>();
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1', 7));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.2', 2));
        insert testSubSubTasks;
        testSubSubTasks[1].PSA_Standard_Hours__c = 6;
        update testSubSubTasks;
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        testSubTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[0].Id];
        System.assertEquals(16, testParentTask.PSA_Standard_Hours__c);
        System.assertEquals(13, testSubTasks[0].PSA_Standard_Hours__c);

    }
    @IsTest
    static void testMultipleLevelRollupsToMultipleParentsAfterInsert() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        List<pse__Project_Task__c> testParentTasks = new List<pse__Project_Task__c>();
        testParentTasks.add(createProjectTask(testProject, null, 'Test Parent Task 1', null));
        testParentTasks.add(createProjectTask(testProject, null, 'Test Parent Task 2', null));
        insert testParentTasks;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTasks[0], 'Test Subtask 1.1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTasks[0], 'Test Subtask 1.2', 3));
        testSubTasks.add(createProjectTask(testProject, testParentTasks[1], 'Test Subtask 2.1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTasks[1], 'Test Subtask 2.2', 5));
        insert testSubTasks;
        List<pse__Project_Task__c> testSubSubTasks = new List<pse__Project_Task__c>();
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1.1', 7));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1.2', 6));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[2], 'Test Subsubtask 2.1.1', 17));
        insert testSubSubTasks;
        testParentTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTasks[0].Id];
        testParentTasks[1] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTasks[1].Id];
        testSubTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[0].Id];
        testSubTasks[2] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[2].Id];
        System.assertEquals(16, testParentTasks[0].PSA_Standard_Hours__c);
        System.assertEquals(13, testSubTasks[0].PSA_Standard_Hours__c);
        System.assertEquals(22, testParentTasks[1].PSA_Standard_Hours__c);
        System.assertEquals(17, testSubTasks[2].PSA_Standard_Hours__c);

    }
    public static pse__Project_Task__c createProjectTask(pse__Proj__c project, pse__Project_Task__c parent, String name, Decimal stdHours) {
        return new pse__Project_Task__c(
                Name = name,
                pse__Project__c = project.Id,
                pse__Parent_Task__c = parent != null ? parent.Id : null,
                PSA_Standard_Hours__c = stdHours
        );
    }
}
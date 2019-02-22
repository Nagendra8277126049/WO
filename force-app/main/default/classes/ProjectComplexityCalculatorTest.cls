@isTest
public class ProjectComplexityCalculatorTest {

    static void setupProjectComplexities() {
        List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();

        projComplexities.add(new Project_Complexity_Threshold__c (
            Name = 'R1',
            Low_Threshold__c = 1000,
            High_Threshold__c = 2000
        ));

        insert(projComplexities);
    }

    static void setupProjectComplexityMappings() {
        List<Project_Complexity_Mapping__c> projComplexityMappings = new List<Project_Complexity_Mapping__c>();

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'Low',
            PM_Complexity__c = 'Low',
            Revenue_Threshold__c = 'Low'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'Medium',
            PM_Complexity__c = 'Medium',
            Revenue_Threshold__c = 'Medium'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'High',
            PM_Complexity__c = 'High',
            Revenue_Threshold__c = 'High'
        ));

        insert(projComplexityMappings);
    }

    static void setupRegions() {
        List<pse__Region__c> regions = new List<pse__Region__c>();

        regions.add(new pse__Region__c (
            Name = 'Test R1',
            ISO_Country_Code__c = 'R1'
        ));

        insert(regions);
    }

    @testSetup
    static void setup() {
      setupProjectComplexities();
      setupProjectComplexityMappings();
      setupRegions();
      setupSkills();
    }
    
    static void setupSkills(){
        pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)');
        pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)');
        pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)');
        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(lowSkill);
        skills.add(mediumSkill);
        skills.add(highSkill);
        insert skills;
    }

    @isTest
    static void CalculeProjectComplexity_Should_Be_Low() {
        pse__Region__c region = [SELECT Id FROM pse__Region__c WHERE Name = 'Test R1'];

        pse__Proj__c project = new pse__Proj__c (
            Name = 'Test Low Project',
            pse__Is_Template__c = false,
            pse__Is_Active__c = true,
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'Low',
            pse__Region__c = region.Id
        );

        insert(project);

        pse__Budget__c budget = new pse__Budget__c (
            pse__Amount__c = 100,
            pse__Project__c = project.Id
        );

        insert(budget);

        Test.startTest();
        
        ProjectComplexityCalculator.CalculeProjectComplexity(new List<Id> {project.Id});

        Test.stopTest();

        pse__Proj__c p1 = [SELECT Project_Complexity__c FROM pse__Proj__c WHERE Id = :project.Id];

        System.assert(p1.Project_Complexity__c == 'Low');
    }

    @isTest
    static void CalculeProjectComplexity_Should_Be_Medium() {
        pse__Region__c region = [SELECT Id FROM pse__Region__c WHERE Name = 'Test R1'];

        pse__Proj__c project = new pse__Proj__c (
            Name = 'Test Medium Project',
            pse__Is_Template__c = false,
            pse__Is_Active__c = true,
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'Medium',
            pse__Region__c = region.Id
        );

        insert(project);

        pse__Budget__c budget = new pse__Budget__c (
            pse__Amount__c = 1500,
            pse__Project__c = project.Id
        );

        insert(budget);

        Test.startTest();
        
        ProjectComplexityCalculator.CalculeProjectComplexity(new List<Id> {project.Id});

        Test.stopTest();

        pse__Proj__c p1 = [SELECT Project_Complexity__c FROM pse__Proj__c WHERE Id = :project.Id];

        System.assertEquals('Medium', p1.Project_Complexity__c);
    }

    @isTest
    static void CalculeProjectComplexity_Should_Be_High() {
        pse__Region__c region = [SELECT Id FROM pse__Region__c WHERE Name = 'Test R1'];

        pse__Proj__c project = new pse__Proj__c (
            Name = 'Test High Project',
            pse__Is_Template__c = false,
            pse__Is_Active__c = true,
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'High',
            pse__Region__c = region.Id
        );

        insert(project);

        pse__Budget__c budget = new pse__Budget__c (
            pse__Amount__c = 5100,
            pse__Project__c = project.Id
        );

        insert(budget);

        Test.startTest();
        
        ProjectComplexityCalculator.CalculeProjectComplexity(new List<Id> {project.Id});

        Test.stopTest();

        pse__Proj__c p1 = [SELECT Project_Complexity__c FROM pse__Proj__c WHERE Id = :project.Id];

        System.assertEquals('High', p1.Project_Complexity__c);
    }

   
}
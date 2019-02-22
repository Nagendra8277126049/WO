/**
 * Thomas Davis
 * 2018-10-10
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Provides test code coverage for the following classes:
 *
 * MassEditOrdersController.cls
 */
@IsTest
public class MassEditOrdersController_Test
{
    @TestSetup
    static void setup()
    {
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;

        pse__Region__c rgn = new pse__Region__c();
        rgn.Name = 'Test Region';
        insert rgn;

        pse__Practice__c prac = new pse__Practice__c();
        prac.Name = 'Test Practice';
        insert prac;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'test@test123456789.com';
        insert con;

        pse__Proj__c prj = new pse__Proj__c();
        prj.Name = 'Test Project';
        prj.pse__Start_Date__c = System.today();
        prj.pse__End_Date__c = System.today() + 7;
        prj.pse__Project_Phase__c = 'Setup';
        prj.pse__Practice__c = prac.Id;
        prj.pse__Region__c = rgn.Id;
        prj.pse__Project_Manager__c = con.Id;
        prj.pse__Is_Active__c = true;
        insert prj;

        Order odr = new Order();
        odr.Status = 'IP';
        odr.OrderNumber__c = '1234';
        odr.AccountId = acct.Id;
        odr.EffectiveDate = System.today();
        odr.Project__c = prj.Id;
        insert odr;

        pse__Milestone__c mstone = new pse__Milestone__c();
        mstone.pse__Project__c = prj.Id;
        mstone.Name = 'Test Milestone';
        mstone.pse__Milestone_Amount__c = 100;
        mstone.pse__Target_Date__c = System.today();
        mstone.Current__c = true;
        insert mstone;

        pse__Skill__c testSkill1 = new pse__Skill__c(Name = 'Project Management (Low)');
        insert testSkill1;

        pse__Skill__c testSkill2 = new pse__Skill__c(Name = 'Project Management (Medium)');
        insert testSkill2;

        pse__Skill__c testSkill3 = new pse__Skill__c(Name = 'Project Management (High)');
        insert testSkill3;
    }

    @IsTest
    static void testGetOrderList()
    {
        Test.startTest();
        MassEditOrdersController.getOrderList(new List<Id>());
        Test.stopTest();
    }

    @IsTest
    static void testDoAllUpdate()
    {
        Order ord = [ SELECT Id FROM Order];
        Id milestoneId = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Test Milestone'].Id;

        Test.startTest();
        MassEditOrdersController.doAllUpdate(new List<Order>{ord}, milestoneId);
        Test.stopTest();
    }
}
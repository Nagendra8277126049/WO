/**
 * Created by tdavis on 2019-01-28.
 */

@IsTest
private class WorkOrderSkillTriggerTest
{
    @TestSetup
    static void setup()
    {
        pse__Skill__c testSkill = new pse__Skill__c(Name = 'Test Skill 1');
        insert testSkill;

        WorkOrder testWorkOrder = new WorkOrder();
        insert testWorkOrder;

        Work_Order_Skill__c testWorkOrderSkill = new Work_Order_Skill__c(Skill_Certification__c = testSkill.Id, Work_Order__c = testWorkOrder.Id);
        insert testWorkOrderSkill;
    }

    @IsTest
    static void test()
    {
        pse__Skill__c testSkill = [ SELECT Id FROM pse__Skill__c LIMIT  1 ];
        WorkOrder testWorkOrder = [ SELECT Id FROM WorkOrder LIMIT  1 ];

        Test.startTest();
        try
        {
            Work_Order_Skill__c skill = new Work_Order_Skill__c(Skill_Certification__c = testSkill.Id, Work_Order__c = testWorkOrder.Id);
            insert skill;
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.assert(e.getMessage().contains('You cannot add duplicate skills.'));
        }
        Test.stopTest();

    }

}
@isTest
public class UserTriggerTest
{
    @testSetup
    static void setupData()
    {
        insert new Federal_Project_Security__c(Enable_Trigger__c = true, Federal_User_Queue_Or_Group_Name__c = 'Test_Group');

        Group testgroup = new Group(
                Name = 'Test_Group',
                DeveloperName = 'Test_Group'
        );

        insert(testgroup);
    }

    @isTest
    private static void insertUserTest()
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        Test.startTest();

        User user = new User(
                UserName = 'test2510@dell.com',
                LastName = 'One',
                Email = 'test2510@dell.com',
                Alias = 't1',
                CommunityNickname = 't1',
                Federal_Access__c = true,
                FederationIdentifier = '111222333',
                External_ID__c = '111222333',
                Organization__c = 'Test Organization',
                File_Source__c = 'AMS - System Admin',
                Dell_NTUserID__c = 'TEST',
                Service_User_Type__c = 'Admin',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No'
        );

        insert(user);

        Test.stopTest();

        Group testGroup = [SELECT Id FROM Group WHERE Name = 'Test_Group'];

        GroupMember groupMember = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :testGroup.Id];

        System.assertNotEquals(null, groupMember);
        System.assertEquals(groupMember.UserOrGroupId, user.Id);
    }

    @isTest
    private static void updateUserTest()
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        Test.startTest();

        User user = new User(
                UserName = 'test2510@dell.com',
                LastName = 'One',
                Email = 'test2510@dell.com',
                Alias = 't1',
                CommunityNickname = 't1',
                Federal_Access__c = true,
                FederationIdentifier = '111222333',
                External_ID__c = '111222333',
                Organization__c = 'Test Organization',
                File_Source__c = 'AMS - System Admin',
                Dell_NTUserID__c = 'TEST',
                Service_User_Type__c = 'Admin',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No'
        );

        insert(user);

        user.Federal_Access__c = false;

        update(user);

        Test.stopTest();

        Group testGroup = [SELECT Id FROM Group WHERE Name = 'Test_Group'];

        List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :testGroup.Id];

        System.assertEquals(0, groupMembers.size());
    }
}
/* -----------------------------------------------------------------------------------------------------------------------
Name:       CaseWorkOrderApproverQueueMapping_Test
Description:  Unit Test Class for CaseWorkOrderApproverQueueMapping Class
-------------------------------------------------------------------------------------------------------------------------a-
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
07/31/2018     1.0    Harsha Reddy       Initial Release
07/31/2018     1.0    Rodrigo Carpio     Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class CaseWorkOrderApproverQueueMapping_Test {
                
    private static User u;
    /* This method creates the test data */
    
    private static void setupTestData() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        u = new User(Alias = 'auser',FirstName='Test', Email='adminuser@dell.com',IsActive=True,
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           FederationIdentifier='12345670',Dell_NTUserID__c='TEST_T',Service_User_Type__c='DEV',
                           External_ID__c='12345670',Organization__c='Dell',File_Source__c='AMS - System Admin',
                           LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                           TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName, OSP__c='Yes');
        insert u;
        //u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        String uniqueUserName2 = 'adminuser2' + DateTime.now().getTime() + '@dell.com';
        Profile objProfile = [SELECT Id FROM Profile WHERE Name=:'System Administrator' ];
        user u2 = new User(Alias = 'auser2',FirstName='Test2', Email='adminuser2@dell.com',IsActive=True,
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           FederationIdentifier='99999977',Dell_NTUserID__c='TEST_T2',Service_User_Type__c='DEV',
                           External_ID__c='99999977',Organization__c='Dell',File_Source__c='AMS - System Admin',
                           LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                           TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName2, OSP__c='Yes');
        insert u2;
        
        //u2 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        //create a test account
        Account acnt = new Account(Name = 'Test Company', Industry = 'Fashion',Type = 'Customer');
        insert acnt;
        
        //create a new product
        Product2 prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
        insert prd;
        
        //create a test contact
        Contact co = new Contact(Email = 'testtag@test.com',firstname='firstname',LastName='testtag',Accountid=acnt.id);
        insert co;
        
        //Create a test Asset
        Asset ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,InstallDate = System.Today(),UsageEndDate = System.Today(),SerialNumber='uighfg1245');
       insert ast;
        
        List<Group> testGroupList = new List<Group>();
        List<GroupMember> memberList = new List<GroupMember>();
        List<QueuesObject> testQueue = new List<QueuesObject>();
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            testGroupList.add(new Group(Name='test group',Type='Queue'));
            testGroupList.add(new Group(Name='test group4', Type='Regular'));
            testGroupList.add(new Group(Name='test group1', Type='Regular'));
            testGroupList.add(new Group(Name='test group2', Type='Queue'));
            testGroupList.add(new Group(Name='test group8', Type='Regular'));
            testGroupList.add(new Group(Name='test group9', Type='Regular'));
            testGroupList.add(new Group(Name='test group6', Type='Queue'));
            testGroupList.add(new Group(Name='test group7', Type='Queue'));
            
            if(!testGroupList.isEmpty()){
                insert testGroupList;   
            }
                
            testQueue.add(new QueueSObject(QueueID = testGroupList[0].id, SObjectType = 'Case'));
            testQueue.add(new QueueSObject(QueueID = testGroupList[3].id, SObjectType = 'Case'));
            testQueue.add(new QueueSObject(QueueID = testGroupList[6].id, SObjectType = 'Case'));
            testQueue.add(new QueueSObject(QueueID = testGroupList[7].id, SObjectType = 'Case'));
            
            if(!testQueue.isEmpty()){
               insert testQueue;   
            }
            
               memberList.add(new GroupMember(UserOrGroupId = u.Id,GroupId = testGroupList[1].Id));
            memberList.add(new GroupMember(UserOrGroupId = u2.Id,GroupId = testGroupList[2].Id));
            memberList.add(new GroupMember(UserOrGroupId = u.Id,GroupId = testGroupList[4].Id));
            memberList.add(new GroupMember(UserOrGroupId = u2.Id,GroupId = testGroupList[5].Id));
                                                memberList.add(new GroupMember(UserOrGroupId = testGroupList[1].Id,GroupId = testGroupList[0].Id));
            memberList.add(new GroupMember(UserOrGroupId = testGroupList[2].Id,GroupId = testGroupList[3].Id));
            memberList.add(new GroupMember(UserOrGroupId = testGroupList[1].Id,GroupId = testGroupList[3].Id));
            memberList.add(new GroupMember(UserOrGroupId = testGroupList[4].Id,GroupId = testGroupList[6].Id));
            memberList.add(new GroupMember(UserOrGroupId = testGroupList[5].Id,GroupId = testGroupList[7].Id));
            memberList.add(new GroupMember(UserOrGroupId = testGroupList[4].Id,GroupId = testGroupList[3].Id));
            
            if(!memberList.isEmpty()){
                                                insert memberList;   
                                                }
        }

                                List<Case> CaseList = new List<Case>();
        
        for (Integer i=0;i<100;i++) {
            CaseList.add(
                new Case(
                    Subject='Test Case',
                    AccountId=acnt.Id,
                    AssetId=ast.Id,
                    ContactId=co.Id,
                    OwnerId = testGroupList[0].id,
                    status='Inprogress'
               ));
        }
        
        
                                // insert 100 Cases  - Owner as User u1
        for (Integer i=0;i<100;i++) {
            CaseList.add(
                new Case(
                    Subject='Test Case',
                    AccountId=acnt.Id,
                    AssetId=ast.Id,
                    ContactId=co.Id,
                    OwnerId = u.Id,
                    status='Inprogress'
               ));
        }
        
        // insert 100 Cases  - Owner as User u2
        for (Integer i=0;i<100;i++) {
            CaseList.add(
                new Case(
                    Subject='Test Case',
                    AccountId=acnt.Id,
                    AssetId=ast.Id,
                    ContactId=co.Id,
                    OwnerId = u2.Id,
                    status='Inprogress'
               ));
        }
        
        if(!CaseList.isEmpty()){
            insert CaseList;   
        }
    }
    
    @isTest
    private static void useCase1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
               List<String> caseIdList = new List<String>();
                for(Case cs:[select id from Case limit 1000]){
                    caseIdList.add(cs.id);
                }
                CaseWorkOrderApproverQueueMapping.ApproverQueueMapping(caseIdList);
            Test.stopTest();
            // after the testing stops, assert records were updated properly
            System.assertEquals(300, [select count() from Case where ApprovalQueueName__c!=null limit 1000]);
        }
    }
    
    @isTest
    private static void useCase2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                CaseWorkOrderApproverQueueMapping.ApproverQueueMapping(null);
            Test.stopTest();
        }
    }
}
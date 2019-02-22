/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchApprovalQueueMappingBatch_Test
Description: Unit Test class for DispatchApprovalQueueMappingBatch
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
07/31/2018     1.0    Harsha Reddy       Initial Release
07/31/2018     1.0    Rodrigo Carpio     Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchApprovalQueueMappingBatch_Test {
	
    private static User u;
    
    /* This method creates the test data */
    private static void setupTestData() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        u = new User(Alias = 'auser', Email='adminuser@dell.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',
                     External_ID__c='1234526',Organization__c='Dell',Dell_NTUserID__c='TEST_T',Service_User_Type__c='DEV',File_Source__c='AMS - System Admin',
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__c='Yes');
        insert u;
        
        String uniqueUserName2 = 'adminuser2' + DateTime.now().getTime() + '@dell.com';
        user u2 = new User(Alias = 'auser', Email='adminuser@dell.com',Dell_NTUserID__c='TEST_Y',Service_User_Type__c='DEV',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='9000777',
                           External_ID__c='9000777',Organization__c='Dell',File_Source__c='AMS - System Admin',
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName2,OSP__c='Yes');
        insert u2;
        
        //create a test account
        String uniqueUserNameAccount = 'Test Company' + DateTime.now().getTime();
		Account acnt = new Account(Name = uniqueUserNameAccount, Industry = 'Fashion',Type = 'Customer');
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
                    status='In Progress'
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
                DispatchApprovalQueueMappingBatch dCSBatch = new DispatchApprovalQueueMappingBatch();
                Id batchId = Database.executeBatch(dCSBatch,1000);
            Test.stopTest();
            // after the testing stops, assert records were updated properly
            System.assertEquals(300, [select count() from Case]);
        }
    }
}
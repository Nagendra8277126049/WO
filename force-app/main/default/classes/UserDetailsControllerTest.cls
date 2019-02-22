@isTest

public class UserDetailsControllerTest
{
    @testSetup
    static void loadTestData()
    {
        User u = new User(Alias = 'auser',FirstName='Test', Email='adminuser@dell.com',IsActive=True,
                          EmailEncodingKey='UTF-8', LastName='Third User',Dell_NTUserID__c='TEST_T', LanguageLocaleKey='en_US', 
                          FederationIdentifier='223344',External_Id__c='223344',
                          Service_User_Type__c='Business',Organization__c='dell',File_Source__c='AMS-Admin',
                          LocaleSidKey='en_US', 
                          ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName='ksam@dell.com', OSP__c='Yes'); 
       insert u;
        
        
       /* User u2 =SRVS_CreateTestDataFactory.createUser('Service Agent');
        User u1 =SRVS_CreateTestDataFactory.createUser('System Administrator');
        u.manager__c= u1.Id; */
        
        User u1 = new User(Alias = 'auser',FirstName='Test', Email='adminuse1r@dell.com',IsActive=True,
                           EmailEncodingKey='UTF-8', LastName='Third User1', LanguageLocaleKey='en_US', 
                           FederationIdentifier='12345261',External_Id__c='12345261',
                           Service_User_Type__c='Business',Organization__c='dell',File_Source__c='AMS-Admin',
                           LocaleSidKey='en_US', Dell_NTUserID__c='TEST_TE',
                           ProfileId = [SELECT Id FROM Profile WHERE Name = 'Service Agent'].Id,
                           manager__c=[select name, Email from user where email= 'adminuser@dell.com'].Id,
                           TimeZoneSidKey='America/Los_Angeles',UserName='ksam1@dell.com', OSP__c='Yes');
        insert u1;
        
        system.RunAs(u)
        {
            //Set1
            Group queue1 = new Group(Name ='Test Queue1', Type='Queue');
            insert queue1;
            Group subgrp1 = new Group(Name = 'Test subGroup1', Type = 'Regular');
            insert subgrp1;                       
            GroupMember Qgm = new GroupMember(GroupId = queue1.Id, UserOrGroupId = subgrp1.Id);
            insert Qgm;            
            GroupMember Qugm1 = new GroupMember(GroupId = subgrp1.Id, UserOrGroupId = u.Id);
            insert Qugm1;
            QueueSobject qso = new QueueSobject(QueueId = Queue1.Id, SobjectType = 'Case'); 
            insert qso; 
            
            //Set2
            Group queue2 = new Group(Name ='Test Queue2', Type='Queue');
            insert queue2;
            Group subgrp2 = new Group(Name = 'Test subGroup2', Type = 'Regular');
            insert subgrp2;                       
            GroupMember Qgm2 = new GroupMember(GroupId = queue2.Id, UserOrGroupId = subgrp2.Id);
            insert Qgm2;            
            GroupMember Qugm2 = new GroupMember(GroupId = subgrp2.Id, UserOrGroupId = u.Id);
            insert Qugm2;
            QueueSobject qso1 = new QueueSobject(QueueId = Queue2.Id, SobjectType = 'DispatchPendingApproval__c'); 
            insert qso1; 
            
            //Set3
            Group queue3 = new Group(Name ='Test Queue3', Type='Queue');
            insert queue3;
            Group subgrp3 = new Group(Name = 'Test subGroup3', Type = 'Regular');
            insert subgrp3;                       
            GroupMember Qgm3 = new GroupMember(GroupId = queue3.Id, UserOrGroupId = subgrp3.Id);
            insert Qgm3;            
            GroupMember Qugm3 = new GroupMember(GroupId = subgrp3.Id, UserOrGroupId = u.Id);
            insert Qugm3;
            QueueSobject qso2 = new QueueSobject(QueueId = Queue3.Id, SobjectType = 'LiveAgentSession'); 
            insert qso2; 
            
            //For Clone Queue User
            //Set1
            Group cqueue1 = new Group(Name ='Test Queue1', Type='Queue');
            insert cqueue1;
            Group csubgrp1 = new Group(Name = 'Test subGroup1', Type = 'Regular');
            insert csubgrp1;                       
            GroupMember cQgm = new GroupMember(GroupId = cqueue1.Id, UserOrGroupId = csubgrp1.Id);
            insert cQgm;            
            GroupMember cQugm1 = new GroupMember(GroupId = csubgrp1.Id, UserOrGroupId = u.Id);
            insert cQugm1;
            
            Group grp1 = new Group(Name = 'Test Group1', Type = 'Queue');
            insert grp1;
            system.debug('#### grp1Id: ' + grp1.Id);
            Group grp2 = new Group(Name = 'Test Group2', Type = 'Regular');
            insert grp2;
            system.debug('#### grp2Id: ' + grp2.Id);
            GroupMember testsb1 = new GroupMember(GroupId = grp1.Id, UserOrGroupId = grp2.Id);
            insert testsb1;
            
            Group grp3 = new Group(Name = 'Test Group3', Type = 'Regular');
            insert grp3;
             
            system.debug('#### grp3Id: ' + grp3.Id);
            Group grp6 = new Group(Name = 'Test Group6', Type = 'Regular');
            insert grp6;
            Group grp4 = new Group(Name = 'Test Group4', Type = 'Queue');
            insert grp4;
            Group grp5 = new Group(Name = 'Test Group5', Type = 'Queue');
            insert grp5;
            
                                   
            GroupMember gm = new GroupMember(GroupId = grp3.Id, UserOrGroupId = grp2.Id);
            insert gm;
            system.debug('#### gmId: ' + gm.Id);
            
            GroupMember gm0 = new GroupMember(GroupId = grp1.Id, UserOrGroupId = grp3.Id);
            insert gm0;
            system.debug('#### gmId0: ' + gm0.Id);
            GroupMember gm1 = new GroupMember(GroupId = grp1.Id, UserOrGroupId = grp6.Id);
            insert gm1;
        }
    } 
    
    @isTest
    static void SearchUserInfoTest()
    {
        Test.startTest();
        UserDetailsController.SearchUserInfo obj=new UserDetailsController.SearchUserInfo();
        Test.stopTest(); 
    }
    
    @isTest
    static void fetchalluserTest()
    {
        Test.startTest();
        // UserDetailsController.fetchalluser();
        Test.stopTest();
    } 
    
    @isTest
    static void fetchsearchuserTest()
    {   
        //List <User> lstOfUser1;
        //String searchKey = '12345261';  //'%'+ 2334 + '%';
       // Id grpId2 = [select id from group where name = 'Test Group2'].Id;
        Id lstOfUser1 = [select Id from user where LastName='Third User'].Id;
        //String usrId = u.id;
        String searchWord = 'Test';
        boolean isAsc=true;
        Boolean isSort =true; 
        Test.startTest();
        UserDetailsController.fetchsearchuser(searchWord,lstOfUser1,isAsc,isSort);
        Test.stopTest();
    } 
    
    @isTest
    static void fetchsearchuserTest1()
    {   
        //List <User> lstOfUser2;
        // String searchKey = '12345261'; //'%'+ 2334 + '%';
       // Id grpId2 = [select id from group where name = 'Test Group2'].Id;
        Id lstOfUser1 = [select Id from user where LastName='Third User'].Id;
        String searchWord = 'Test';
        boolean isAsc=false;
        Boolean isSort =true ; 
        Test.startTest();
        UserDetailsController.fetchsearchuser(searchWord,lstOfUser1,isAsc,isSort);
        Test.stopTest();
    } 
    
    
    @isTest
    static void fetchUserqueueTest()
    {
        String searchWord = 'Test Queue1';
        Id lstOfUser1 = [select Id from user where LastName='Third User'].Id;
        //Id grpId = [select id from group where name = 'Test subGroup1'].Id;
        Test.startTest();
        UserDetailsController.fetchUserqueue(searchWord, lstOfUser1);
        Test.stopTest();
    }
    @isTest
    static void RemoveUserTest()
    {
        List<String> lstRecordId = new List<String>();
        String grpId = [Select id from Group where name = 'Test Group1'].Id;
        lstRecordId.add(grpId);
        String usrId = [Select id from Group where name = 'Test Group2'].Id;
        
        Test.startTest();
        UserDetailsController.RemoveUser(lstRecordId, usrId);
        Test.stopTest();
    }
    
    @isTest
    static void AddqueueTest()
    {
        List<Group> grpId = new List<Group>();
        Group grp1 = [Select id from Group where name = 'Test Group1'];
        Group grp2 = [Select id from Group where name = 'Test Group3'];
        grpId.add(grp1);
        grpId.add(grp2);
        String usrId = [select id from user where lastname = 'Third User1' limit 1].id;
        Test.startTest();
        UserDetailsController.Addqueue(grpId,usrId);
        Test.stopTest();
    }
    
    @isTest
    static void fetchLookUpValuesTest()
    {
        String searchKey = 'Test Group1';
        Id lstOfUser1 = [select Id from user where LastName='Third User'].Id;
        List<Group> grp = [Select id from Group where name = 'Test Queue1'];
        //String type = 'Regular';
        //List<sObject> testSobject = new List<sObject>();
        //testSobject.add(grp);
        Test.startTest();
        UserDetailsController.fetchLookUpValues(searchKey,'Group',grp,lstOfUser1);
        Test.stopTest();
    }
    @isTest
    static void clonequeueusertest()
    {
        List <User> UserId = new List<User> ();
        List<Group> grpId = new List<Group>();
        UserId = [select Id from user where LastName='Third User1'];
        String CloneId = [select id from user where lastname = 'Third User' limit 1].id;
        
        Test.startTest();
        UserDetailsController.clonequeueuser(UserId,CloneId);
        Test.stopTest();
    }
}
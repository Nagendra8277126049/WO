@isTest private class QueueAssignmentControllerTest1
{
    @TestSetup static void loadTestData ()
    {
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Service Agent'].Id,
                             LastName = 'last',
                             Email = 'puser000@dell.com',
                             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                             CompanyName = 'TEST',
                             Title = 'title',
                             Alias = 'alias',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             Dell_NTUserID__c='T_S',
                             FederationIdentifier='kkk',
                            External_Id__c='kkk',
                            Service_User_Type__c='Business',Organization__c='dell',File_Source__c='AMS-Admin',
                             LocaleSidKey = 'en_US');
      //  insert u;
        User u1 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Service Agent'].Id,
                             LastName = 'Second User',
                             Email = 'puser000@amamama.com',
                             Username = 'puser000@amamama.com123' + System.currentTimeMillis(),
                             CompanyName = 'TEST',
                             Title = 'title',
                             Alias = 'alias',
                           FederationIdentifier='lll',
                           External_Id__c='lll',
                           Dell_NTUserID__c='T_T',
                           Service_User_Type__c='Business',Organization__c='dell',File_Source__c='AMS-Admin',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US');
      //  insert u1;
       user u4 = new user(Alias = 'auser',FirstName='Test', Email='adminuser@dell.com',IsActive=True,
                                EmailEncodingKey='UTF-8', LastName='Third User', LanguageLocaleKey='en_US', 
                                FederationIdentifier='12345261',
                          External_Id__c='12345261',
                           Dell_NTUserID__c='T_U',
                           Service_User_Type__c='Business',Organization__c='dell',File_Source__c='AMS-Admin',
                                LocaleSidKey='en_US', 
                                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Service Agent'].Id,
                                TimeZoneSidKey='America/Los_Angeles',UserName='ksam@dell.com', OSP__c='Yes');
                                insert u4 ;
     user u3 = new user(Alias = 'auser',FirstName='Test', Email='adminuser@dell.com',IsActive=True,
                                EmailEncodingKey='UTF-8', LastName='Second User', LanguageLocaleKey='en_US', 
                                FederationIdentifier='1234526',
                         External_Id__c='1234526',
                           Dell_NTUserID__c='T_V',
                           Service_User_Type__c='Business',Organization__c='dell',File_Source__c='AMS-Admin',
                                LocaleSidKey='en_US', 
                                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                                TimeZoneSidKey='America/Los_Angeles',UserName='ksaaam@dell.com', OSP__c='Yes');
                                insert u3 ;
        User u2 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Service Agent'].Id,
                             LastName = 'Third User',
                             Email = 'puser000@amamama.com',
                             Username = 'puser000@amamama.com456' + System.currentTimeMillis(),
                             CompanyName = 'TEST',
                                  FederationIdentifier='mmm',
                         External_Id__c='mmm',
                           Dell_NTUserID__c='T_W',
                           Service_User_Type__c='Business',Organization__c='dell',File_Source__c='AMS-Admin',
                             Title = 'title',
                             Alias = 'alias',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US');
      //  insert u2;
        
        system.RunAs (u3)
        {
            // Insert groups
            Group grp1 = new Group(Name = 'Test Group1', Type = 'Queue');
            insert grp1;
            system.debug('#### grp1Id: ' + grp1.Id);
            
            Group grp2 = new Group(Name = 'Test Group2', Type = 'Regular');
            insert grp2;
            system.debug('#### grp2Id: ' + grp2.Id);
            
            Group grp3 = new Group(Name = 'Test Group3', Type = 'Regular');
            insert grp3;
            system.debug('#### grp3Id: ' + grp3.Id);
            Group grp4 = new Group(Name = 'Test Group4', Type = 'Queue');
            insert grp4;
            Group grp5 = new Group(Name = 'Test Group5', Type = 'Queue');
            insert grp5;
            
            //Insert GroupMember
            GroupMember gm = new GroupMember(GroupId = grp1.Id, UserOrGroupId = grp2.Id);
            insert gm;
            system.debug('#### gmId: ' + gm.Id);
            
            GroupMember gm0 = new GroupMember(GroupId = grp2.Id, UserOrGroupId = u4.Id);
            insert gm0;
            system.debug('#### gmId0: ' + gm0.Id);
            
            GroupMember gm1 = new GroupMember(GroupId = grp2.Id, UserOrGroupId = grp3.Id);
            insert gm1;
            
            
            //Insert QueueSobject
            //QueueSobject qso = new QueueSobject(QueueId = grp1.Id, SobjectType = 'WorkOrder'); DispatchPendingApproval__c
            QueueSobject qso = new QueueSobject(QueueId = grp4.Id, SobjectType = 'LiveAgentSession'); 
            insert qso;  
             QueueSobject qs2 = new QueueSobject(QueueId = grp5.Id, SobjectType = 'Case'); 
            insert qs2; 
            
            QueueSobject qso1 = new QueueSobject(QueueId = grp1.Id, SobjectType = 'DispatchPendingApproval__c'); 
            insert qso1;
        }       
    }
    
    @isTest static void fetchSearchQueueUserTest ()
    {
        String name = 'last';
        Id grpId = [select id from group where name = 'Test Group1'].Id;
        
        Test.StartTest();
        QueueAssignmentController.fetchSearchQueueUser(name, String.valueOf(grpId));
        Test.StopTest();
    }
    
    
    @isTest static void fetchQueueTest1 ()
    {
        Test.startTest();
        QueueAssignmentController.fetchQueue('Test Group1');
        QueueAssignmentController.fetchQueue('Test Group4');
        QueueAssignmentController.fetchQueue('Test Group5');
        Test.stopTest();
    }
    @isTest static void fetchQueueUserTest ()
    {
        Id grpId = [select id from group where name = 'Test Group1'].Id;
        Test.startTest();
        QueueAssignmentController.fetchQueueUser(String.valueOf(grpId));
        Test.stopTest();
    } 
    
    @isTest static void RemoveUserTest ()
    {
        Id grpId = [select id from group where name = 'Test Group1'].Id;
        Id usergrpId = [select id from group where name = 'Test Group2'].Id;
        List<String> lstRecordId = new List<String>();
        lstRecordId.add(usergrpId);
        Test.startTest();
        QueueAssignmentController.RemoveUser(lstRecordId, String.valueOf(grpId));
        Test.stopTest();
    } 
    @isTest static void fetchLookUpValuesTest ()
    {
        Id grpId = [select id from group where name = 'Test Group1'].Id;
        String searchKeyWord = 'last';
        User secUser = [select id, name from User where LastName = 'Second User'];
        String userid=secUser.id;
        List<sObject> testSobject = new List<sObject>();
        testSobject.add(secUser);
        User thirdUser = [select id, name from User where LastName = 'Third User'];
        List<User> lstUsers = new List<User>();
        lstUsers.add(thirdUser);
        Test.startTest();
        QueueAssignmentController.fetchLookUpValues(searchKeyWord, 'DispatchPendingApproval__c', testSobject, lstUsers,userid);
        Test.stopTest();
    }
    
    @isTest static void addUsersTest ()
    {
        Id grpId = [select id from group where name = 'Test Group1'].Id;
        User thirdUser = [select id, name from User where LastName = 'Third User'];
        List<User> lstUsers = new List<User>();
        lstUsers.add(thirdUser);
        Test.startTest();
        QueueAssignmentController.addUsers(lstUsers, String.valueOf(grpId));
        Test.stopTest();
    }
    
    @isTest static void userinfoTest()
    {
        Test.startTest();
        QueueAssignmentController.userInfo obj = new QueueAssignmentController.userInfo();
        Test.stopTest();
    }
    
}
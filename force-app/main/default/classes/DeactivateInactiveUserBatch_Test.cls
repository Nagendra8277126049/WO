/* -----------------------------------------------------------------------------------------------------------------------
Name:       DeactivateInactiveUserBatch_Test
Description:Test class for DeactivateInactiveUsersBatch Class
----------------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
03/12/2018     1.0           Abhishek Pandey       Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/
@isTest
Private class DeactivateInactiveUserBatch_Test {
    static list<User> userList=new list<User>();
    private static void setupTestData() 
    {
        EmailTemplate ed=SRVS_CreateTestDataFactory.createStdEmailTemplate();
        insert ed;   
    }
    @isTest
    private static void unitTest1()
    { 
        User use=SRVS_CreateTestDataFactory.createUser('System Administrator');
        use.FederationIdentifier='5678';
        use.External_ID__c='5678';
        use.Dell_NTUserID__c='A_T';
        use.File_Source__c='AMS - Admin';       
        use.Organization__c='dell';
        use.Service_User_Type__c='Business';
        userList.add(use);
        User use1=SRVS_CreateTestDataFactory.createUser('Service Integration Profile');
        use1.FederationIdentifier='9098';
         use1.External_ID__c='9098';
        use1.Dell_NTUserID__c='B_T';
        use1.File_Source__c='AMS - Admin';       
        use1.Organization__c='dell';
        use1.Service_User_Type__c='Business';
        userList.add(use1);
        User use2=SRVS_CreateTestDataFactory.createUser('System Read Only');
        use2.FederationIdentifier='4567';
        use2.External_ID__c='4567';
        use2.Dell_NTUserID__c='C_T';
        use2.File_Source__c='AMS - Admin';
        use2.organization__c='dell';
        use2.Service_User_Type__c='Business';
        userList.add(use2);
        User use3=SRVS_CreateTestDataFactory.createUser('System Administrator');
        use3.FederationIdentifier='9876';
        use3.External_ID__c='9876';
        use3.Dell_NTUserID__c='D_T';
        use3.File_Source__c='AMS - Admin';       
        use3.Organization__c='dell';
        use3.Service_User_Type__c='Business';
        userList.add(use3);
        Database.insert(userList);
        system.debug('userList'+userList);
        User use4=SRVS_CreateTestDataFactory.createUser('System Administrator');
        use4.FederationIdentifier='8796';
         use4.External_ID__c='8796';
        use4.Dell_NTUserID__c='E_T';
        use4.File_Source__c='AMS - Admin';       
        use4.Organization__c='dell';
        use4.Service_User_Type__c='Business';
        insert use4; 
        List<User> usrLst = userList.clone();
        system.runAs(use4)
        {  
            Test.startTest();
            DeactivateInactiveUserBatch uca = new DeactivateInactiveUserBatch();
           list<string> lst= new list<string>{'adminuser@dell.com','badminuser@dell.com','cadminuser@dell.com','dadminuser@dell.com'};
           uca.Emaillist = lst.clone();
            uca.userlist = usrLst.clone();
            Database.QueryLocator ql = uca.start(null);
            uca.execute(null,userList);
            uca.Finish(null);
            Test.stopTest();
            System.assertEquals(4, userList.size());
        }
    }
    @isTest
    private static void unitTest2()
    {
        User use5=SRVS_CreateTestDataFactory.createUser('System Administrator');
        use5.FederationIdentifier='8006';
         use5.External_ID__c='8006';
        use5.Dell_NTUserID__c='F_T';
        use5.File_Source__c='AMS - Admin';       
        use5.Organization__c='dell';
        use5.Service_User_Type__c='Business';
        insert use5;
        system.runAs(use5)
        {
            Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? *';
            SchedulableContext SC;
            //DeactivateInactiveUserScedule u=new DeactivateInactiveUserScedule();
            //u.execute(SC);
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new DeactivateInactiveUserScedule());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
         // System.assertEquals(0, ct.TimesTriggered);
            //System.abortJob(jobId);
           Test.stopTest();
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals(CRON_EXP, ct.CronExpression); 
        }
    }
    @isTest
    private static void email()
    {   
        User use6=SRVS_CreateTestDataFactory.createUser('System Administrator');
        use6.FederationIdentifier='8730';
        use6.External_ID__c='8730';
        use6.Dell_NTUserID__c='G_T';
        use6.File_Source__c='AMS - Admin';       
        use6.Organization__c='dell';
        use6.Service_User_Type__c='Business';
        User use7=SRVS_CreateTestDataFactory.createUser('System Read Only');
        use7.FederationIdentifier='8731';
        use7.External_ID__c='8731';
        use7.Dell_NTUserID__c='H_T';
        use7.File_Source__c='AMS - Admin';       
        use7.Organization__c='dell';
        use7.Service_User_Type__c='Business';
        userList.add(use6);
        userList.add(use7);
        Database.insert(userList);
        system.runAs(use7)
        {
            Test.startTest();
            EmailUtilityClass.emailTemp(userList);
            Test.stopTest();
            System.assertEquals(2, UserList.size());
        }
    }   
}
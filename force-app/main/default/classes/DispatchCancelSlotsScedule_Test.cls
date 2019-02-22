/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchCancelSlotsScedule_Test
Description:  Unit Test Class for  DispatchCancelSlotsScedule
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
06/13/2017     1.0         Harsha Reddy              Initial Release
06/13/2017     1.0         Rodrigo Carpio            Initial Release
01/06/2019     2.0         Harsha & Carpio           FY190102 - Jan Release             
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchCancelSlotsScedule_Test
{
    /* This method creates the test data */
    @testSetup 
    private static void setupTestData() {
                //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        insert con;
        
        string tomorrowDate =  Datetime.now().addDays(1).formatGMT('yyyy-MM-dd')+'T'+'00:00:000';
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        insert cse; 
        List<WorkOrder> workOrList = new List<WorkOrder>();
        // insert 50 WorkOrders  
        for (Integer i=0;i<50;i++) 
        {
            workOrList.add(
                new WorkOrder(     
                    caseId = cse.Id,
                    assetId = ast.Id,
                    accountId = acnt.Id,
                    ContactId = con.Id,
                    Status='Pending Review',
                    IsScheduled__c=true,
                    schedulingInternalLogic__c = 'Scheduled',
                    ScheduleStartDate__c=tomorrowDate,
                    ScheduleEndDate__c=tomorrowDate,
                    startDate = system.now().addDays(1),
                    endDate = system.now().addDays(1),
                    Street='650 Louis Henna Blvd', 
                    city='Round Rock', 
                    statecode='TX', 
                    countryCode='US', 
                    Region__c='1', 
                    postalcode='78664',
                    TimeZone__c='America/Chicago'
               ));
        }
        insert workOrList;
        
        // Create a unique UserName
        
        
    }
    /*
    private static testmethod void schedulerTest() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        List<WorkOrder> workOrList = new List<WorkOrder>();
        
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        insert con;
        
        string tomorrowDate =  Datetime.now().addDays(1).formatGMT('yyyy-MM-dd')+'T'+'00:00:000';
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        insert cse; 
        
        // insert 50 WorkOrders  
        for (Integer i=0;i<50;i++) 
        {
            workOrList.add(new WorkOrder(Status='Pending Review',caseId = cse.Id, IsScheduled__c=true, AssetId = ast.id, AccountId = acnt.id, ContactId = con.id,
                                        ScheduleStartDate__c=tomorrowDate,ScheduleEndDate__c=tomorrowDate,
                                        StartDate=System.now().addDays(1),EndDate=System.Now().addDays(1),
                                        schedulingInternalLogic__c='Scheduled', Street='street', city='citi', statecode='TX', countryCode='US', Region__c='1', postalcode='12345'));
        }
        insert workOrList;
        
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        User u = new User(Alias = 'auser', Email='adminuser@dell.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__c='Yes');
        insert u;
        
        system.runAs(u){
            Test.startTest();
                String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new DispatchCancelSlotsScedule());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            Test.stopTest();
            // Add assert here to validate result
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }
    */
    
    
    
    private static testmethod void schedulerTest() {
        String CRON_EXP = '0 0 0 15 3 ? *';
         User  u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
                String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new DispatchCancelSlotsScedule());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            Test.stopTest();
            // Add assert here to validate result
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }
}
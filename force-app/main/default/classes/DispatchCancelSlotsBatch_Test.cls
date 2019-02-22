/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchCancelSlotsBatch_Test
Description:  Unit Test Class for  DispatchCancelSlotsBatch
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
06/13/2017     1.0         Harsha Reddy              Initial Release
06/13/2017     1.0         Rodrigo Carpio            Initial Release
01/06/2019     2.0         Harsha & Carpio	         FY190102 - Jan Release        		
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchCancelSlotsBatch_Test {
    
    /* This method creates the test data */
    @testSetup 
    private static void setupTestData() {
        List<WorkOrder> workOrList = new List<WorkOrder>();
        
        string tomorrowDate =  Datetime.now().addDays(1).formatGMT('yyyy-MM-dd')+'T'+'00:00:000';
        /*
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
        
        //create a test case
        Case cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id,ContactId=co.Id);
        insert cse;
        
		*/
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
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        insert cse; 
        
        // insert 200 WorkOrders  
        for (Integer i=0;i<200;i++) {
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
       /*
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        User u = new User(Alias = 'auser', 
                     Email='adminuser@dell.com',
                     EmailEncodingKey='UTF-8',
                     LastName='Testing', 
                     LanguageLocaleKey='en_US', 
                     FederationIdentifier='1234526',
                     LocaleSidKey='en_US',
                     ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                     TimeZoneSidKey='America/Los_Angeles',
                     UserName=uniqueUserName,
                     OSP__c='Yes'
                    );
        insert u;
		*/
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        insert u;
    }
    
    @isTest
    private static void useCase1(){
        //setupTestData();
        User u = [SELECT Id FROM User LIMIT 1];
        system.runAs(u){
            Test.startTest();
               	String q = 'SELECT Id,ScheduleEndDate__c,CountryCode,TimeZone__c,ScheduleStartDate__c,DispatchEvent__c,StartDate,EndDate FROM WorkOrder WHERE Status IN (\'Pending Schedule\',\'Pending Review\',\'Awaiting Acknowledgement\',\'Approved\',\'Queued\') AND schedulingInternalLogic__c=\'Scheduled\' AND StartDate=NEXT_N_DAYS:1';
                DispatchCancelSlotsBatch dCSBatch = new DispatchCancelSlotsBatch(q);
                Id batchId = Database.executeBatch(dCSBatch);
            Test.stopTest();
            // after the testing stops, assert records were updated properly
           // System.assertEquals(200, [select count() from WorkOrder where DispatchEvent__c='SCHEDULE_CANCEL']);
        }
    }
}
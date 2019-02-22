/* -----------------------------------------------------------------------------------------------------------------------
Name:         TaskTriggerHandler_Test
Description:  Unit Test Class for AssetAlertsController class -  Defect #4477993
Date         Version  Author               Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
01/04/2018     1.0     Rodrigo Carpio          Initial Release
01/09/2018     1.1     Surya Subramanian       Changes are based on Code Review Defect 4378242
07/26/2018     1.2     Srikanth Parvathareddy  Changes are based on Defect #5374166
10/25/2018     1.3     Sreeram Konatham     Added changes for story #5737497 
-------------------------------------------------------------------------------------------------------------------------- */ 
@isTest
private class TaskTriggerHandler_Test {
    @isTest static void task_test()
    {
        //TaskTriggerHandler taskHandler=new TaskTriggerHandler();
        Task task1=new Task(description='Test Task1', tasksubtype='Email');
        Task task2=new Task(description='Test Task2', tasksubtype='Email');
        
        List<Task> tsk=new List<Task>();
        tsk.add(task1);
        tsk.add(task2);    
        
        Test.startTest();
        //taskHandler.afterInsert(tsk);
        insert tsk;
        for(Task at:tsk)
        {
            system.assertEquals(True, at.EmailTaskOutboundUpdate__c==false);
        }
        
        Test.stopTest();
    }
    
    @isTest static void UnitTest1(){
        
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
        ast.Invoice_Date__c= system.today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        insert con;
        
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        
        cse.assetId= ast.id;
        insert cse;  
        
        Task task1=new Task(description='Test Task1', tasksubtype='Email', Status = 'Open');
        insert task1;
        
        EmailMessage EmailMessageObj = new EmailMessage(FromAddress = 'test1@dell.com', Incoming = True,
        												ToAddress= 'test2@dell.com', Subject = 'Test email', 
    													TextBody = '12345', ParentId = cse.Id, ActivityId = task1.id);
		
		insert EmailMessageObj;
        List<Task> tasks=new List<Task>();
        tasks.add(task1);
        Test.startTest();
        TaskTriggerHandler.afterInsert(tasks);
        Test.stopTest();
    }
    
    @isTest static void UnitTest2(){
        
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
        ast.Invoice_Date__c= system.today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        insert con;
        
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        
        cse.assetId= ast.id;
        insert cse;  
        
        Task task1=new Task(description='Test Task1', tasksubtype='Email', Status = 'Open');
        insert task1;
        
        EmailMessage EmailMessageObj = new EmailMessage(FromAddress = 'test1@dell.com', Incoming = True, CcAddress = 'test1@dell.com',
        												ToAddress= 'test2@dell.com', Subject = 'Test email', 
    													TextBody = '12345', ParentId = cse.Id, ActivityId = task1.id);
		
		insert EmailMessageObj;
         List<Task> tasks=new List<Task>();
        tasks.add(task1);
        Test.startTest();
        TaskTriggerHandler.afterInsert(tasks);
        Test.stopTest();
    }
}
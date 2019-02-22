/* -----------------------------------------------------------------------------------------------------------------------
Name:       SlotWrapper_Test
Description:  This class contain the test method for SlotWrapper to validate coverage - story #4916977
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/13/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class SlotWrapper_Test {
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
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        cse.TranscriptId__c = lct.Id;
        insert cse;        
        
        //create a test Product
        Product2 prd = new Product2();
        prd.ProductCode = 'AH129';
        prd.Name = 'AH129';
        prd.LOB_Code__c = 'AH129';
        prd.LOB_Description__c = 'AH129';
        prd.Description = 'AH129 TEST Product';
        
        insert prd;
        
        // create work Order
        string lineAddress = '';
        lineAddress = lineAddress + 'line 1\n\r';
        lineAddress = lineAddress + 'line 2\n\r';
        lineAddress = lineAddress + 'line 3\n\r';
        lineAddress = lineAddress + 'line 4';
        WorkOrder wo = new WorkOrder();
        wo.AssetId = ast.id;
        wo.AccountId = acnt.id;
        wo.ContactId = con.id;
        wo.CaseId = cse.id;
        wo.Street = lineAddress;
        wo.city = 'city';
        wo.StateCode = 'TX'; 
        wo.PostalCode = '12345';
        wo.CountryCode = 'US';
        wo.Subject = 'test work order';
        
        insert wo;
    }
    @isTest
    private static void SlotWrapper_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            
            Test.startTest();
            
            SlotWrapper wrapper = new SlotWrapper('123345', '2018-04-18T13:00:00Z', '2018-04-18T13:00:00Z', '2018-04-18', '13:00', '17:00');
            
			Test.stopTest();   
            system.assertNotEquals(wrapper, null);            
        }
    } 
    
    
}
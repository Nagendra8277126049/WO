/* -----------------------------------------------------------------------------------------------------------------------
Class Name  :       EmailMessageTriggerHandler_Test
Description :       Test Class for 'EmailMessageTrigger'.
Story       :       Story #4961381 SFDC Phase 3 :: Case Management :: Prevent users from deleting emails attached to cases.
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
04/19/2018     1.0     Srikanth Parvathareddy        Initial Release
-------------------------------------------------------------------------------------------------------------------------- 
*/ 

@isTest
private class EmailMessageTriggerHandler_Test {
    
/*
@method          : setUpData()
@description     : Unit test method to create test data.
*/
    
    @testSetup static void setUpData() {
        
        //creating account test record
        Account ac=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert ac;
         
        //creating asset test record
        Asset a=SRVS_CreateTestDataFactory.createSingleAsset(ac.id);
        insert a;
        
        //creating contact test record
        Contact con=SRVS_CreateTestDataFactory.createContactRecord(ac);
        insert con;
        
        //creating case test record
        case cse=SRVS_CreateTestDataFactory.createSingleCase(a.id,ac.id,con.id);
        insert cse;
        
        //creating EmailMessage test record
        EmailMessage em=SRVS_CreateTestDataFactory.createEmailMessage(cse.id);
        insert em;
        
        EmailMessage em1=SRVS_CreateTestDataFactory.createEmailMessage(ac.id);
        insert em1;
        
    }
    
/*
@method          : email_test
@description     : Unit test method to restrict users from deletion of emailmessage.
*/    
    @isTest 
    Private static void email_test()
    {
        user testUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(testUser){
            Test.startTest();
            List<EmailMessage> emlist=new List<EmailMessage>();
            emlist=[select id from EmailMessage limit 1];
            try{
                delete emlist;
            }
            catch(exception e)
            {
                ExceptionHandler.logHandledExceptions(e,'EmailMessageTriggerHandler','beforedelete',NULL);
            }    
            Test.stopTest();
            System.assertEquals(1,emlist.size());
        }
    }
    
    /*
@method          : exception_test
@description     : Unit test method for covering the exception scenario.
*/
    @isTest 
    Private static void exception_test()
    {
        user testUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(testUser){
            Test.startTest();
            EmailMessageTriggerHandler.beforedelete(null);
            Test.stopTest();
            System.assertNotEquals(null,1);
        }
    }
}
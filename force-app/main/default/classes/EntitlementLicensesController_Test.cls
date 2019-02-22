/*--------------------------------------------------------------------------------------------------------------------------
Name:         EntitlementLicensesController_Test
Description:  Test class for EntitlementLicensesController class - Story #4559894
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
02/20/2018     1.0     Sri Harsha Gangi Reddy       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class EntitlementLicensesController_Test {

    // This method creates the test data 
    @testSetup
    private static void setupTestData() {
     
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        insert cse;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;
    }
    
 
    /* This method tests the entitlement Details by Case - first Page */
    @isTest
    private static void getEntDetailsByCase_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
          Test.startTest();
            case ce=[select id from case limit 1];
          EntitlementLicensesController.EntitlementPagerWrapper entlmntListWrapper = 
                              EntitlementLicensesController.getDeeEntitlements(ce.Id);    
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].status, 'Open');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
    
    /* This method tests the entitlement Details by Asset - first Page */
    @isTest
    private static void getEntDetailsByAsset_Test(){
        User u2=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u2){
          Test.startTest();
            Asset ae=[select id from Asset Limit 1]; 
            EntitlementLicensesController.EntitlementPagerWrapper entlmntListWrapper = 
            					        EntitlementLicensesController.getDeeEntitlements(ae.Id);
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].status, 'Open');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
        
    /* This method tests the entitlement Details by Live Chat Transcript - first Page */
    @isTest
    private static void getEntDetailsByChatTrans_Test(){
        User u3=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u3){
          Test.startTest();
            LivechatTranscript lt=[select id from LivechatTranscript Limit 1];
            
            EntitlementLicensesController.EntitlementPagerWrapper entlmntListWrapper = 
                          EntitlementLicensesController.getDeeEntitlements(lt.Id);
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].status, 'Open');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
}
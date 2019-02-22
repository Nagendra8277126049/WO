/* -----------------------------------------------------------------------------------------------------------------------
Name:       AccidentalDamageController
Description:  Makes OData call to external system and fetches the Entitlements Accidental Damage Details
                to display this information in Lightning Component - AccidentalDamage.cmp - Story #4559894
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
02/19/2018     1.0     Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class AccidentalDamageController_Test {

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
    
    /* This method tests the entitlement accidental damage Details by Case */
    @isTest
    private static void getEntAccidentalDamageDetailsByCase_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
        	Test.startTest();
			case ce=[select id from case limit 1];
        	AccidentalDamageController.AccidentalDamagePagerWrapper entlmntListWrapper = 
            					        AccidentalDamageController.getAccidentalDamageDetails(ce.Id);    
          	Test.stopTest();
            system.assertEquals(entlmntListWrapper.serviceResponse, 'MSG1234');
          	system.assertEquals(entlmntListWrapper.detailsADList.size(), 3);
        }
    }
    /* This method tests the entitlement accidental damage Details by Asset */
    @isTest
    private static void getEntAccidentalDamageDetailsByAsset_Test(){
		User u4=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u4){
        	Test.startTest();
			Asset ae=[select id from Asset Limit 1]; 
        	AccidentalDamageController.AccidentalDamagePagerWrapper entlmntListWrapper = 
            							AccidentalDamageController.getAccidentalDamageDetails(ae.Id);    
          	Test.stopTest();
          	system.assertEquals(entlmntListWrapper.serviceResponse, 'MSG1234');
          	system.assertEquals(entlmntListWrapper.detailsADList.size(), 3);
        }
    }
    
    /* This method tests the entitlement accidental damage Details by Live Chat Transcript */
    @isTest
    private static void getEntAccidentalDamageDetailsByChatTrans_Test(){
        User u3=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u3){
        	Test.startTest();
			LivechatTranscript lt=[select id from LivechatTranscript Limit 1];
          	AccidentalDamageController.AccidentalDamagePagerWrapper entlmntListWrapper = 
            							AccidentalDamageController.getAccidentalDamageDetails(lt.Id);    
          	Test.stopTest();
          	system.assertEquals(entlmntListWrapper.serviceResponse, 'MSG1234');
          	system.assertEquals(entlmntListWrapper.detailsADList.size(), 3);
        }
    }
}
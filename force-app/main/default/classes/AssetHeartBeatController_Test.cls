/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetHeartBeatController_Test
Description:  Unit Test Class for AssetHeartBeatController.cls - Story #4794544 - Phase2
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
03/14/2018     1.0     Harsha Reddy              Initial Release
05/21/2017     1.1     Srikanth Parvathareddy    Story #5091877-SFDC Phase 3 :SA Changes on Asset Details
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class AssetHeartBeatController_Test {
    
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
    }
    
    /* This method tests the Support Assit Details by Asset */
    @isTest
    private static void getSupportAssistDetailsByAsset_Test(){
        
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            Asset a=[Select id, Name from Asset Limit 1];
            AssetHeartBeatController.HeartBeatWrapper SAWrapper = 
            AssetHeartBeatController.getSupportAssitDetails(a.Id);     
            Test.stopTest();        
            system.assertNotEquals(SAWrapper.UTCDate, '');
        }
    }
    
    /* This method tests the Exception by passing UserId */
    @isTest
    private static void getSupportAssistException_Test(){
        
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            AssetHeartBeatController.HeartBeatWrapper SAWrapper = 
            AssetHeartBeatController.getSupportAssitDetails(u1.Id);     
            Test.stopTest();        
            system.assertEquals(SAWrapper, null);
        }
    }
    
}
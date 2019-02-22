/* -----------------------------------------------------------------------------------------------------------------------
Test Class Name:       CaseQuickLinkController_Test
Description:           Unit Test Class for CaseQuickLinkController class -  Story #5251997
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
6/30/2018     1.0     Brundha Rajkumar       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class CaseQuickLinkController_Test {
    
    /* This method creates the test data */
    
    @testSetup
    private static void setupTestData() {
        
        Account acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.AccountNumber='1234567';
        acnt.BUID__c='12345';
        insert acnt;
        
        Asset ast = SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Status = 'Installed';
        ast.InstallDate = System.Today();
        ast.UsageEndDate = System.Today();
        insert ast;
        
        Contact con = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Primary_Phone_Type__c='Mobile';
        insert con;
        
        Case cse = SRVS_CreateTestDataFactory.createSingleCase(ast.Id,acnt.Id,con.Id);
        insert cse;
        
    }
    
    @isTest 
    private static void getAssetName_Test() {
        
        // Implement test code
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        system.runAs(u){
            
            Test.startTest();
            Case c = [SELECT Id from Case Limit 1];
            Asset a = [SELECT Id from Asset Limit 1];
            CaseQuickLinkController.CaseQuickWrapper wrapCase=CaseQuickLinkController.getAssetName(c.id);
            CaseQuickLinkController.CaseQuickWrapper wrapCaseException=CaseQuickLinkController.getAssetName(null);
            CaseQuickLinkController.CaseQuickWrapper wrapAsset=CaseQuickLinkController.getAssetName(a.id);
            Test.stopTest();        
            system.assertEquals(wrapCase.serviceTag, 'Sample Asset');
            
        }
    }
    
}
/* -----------------------------------------------------------------------------------------------------------------------
Test Class Name:       CaseAlertsController_Test
Description:           Unit Test Class for CaseAlertsController class -  Story #4142699
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/27/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
01/09/2018     1.1     Surya Subramanian            Changes are based on Code Review Defect 4378242
01/17/2018     1.2     Surya Subramanian            Changes are based on Code Review Defect 4561213
01/22/2018     1.3     Sonia Sharaff                Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018     1.4     Roselin Hephzibah            Changes are based on Code Review Defect 4561229
5/24/2018      1.5     Brundha Rajkumar             Changes are based on User Story #5096431
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class CaseAlertsController_Test {

    private static string flag = 'false';
    
    /* This method creates the test data */
   @testSetup
   private static void setupTestData() {

        Test.startTest();
        Account acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.AccountNumber='1234567';
       acnt.Link_Number__c='1979548';
        acnt.BUID__c='12345';
        insert acnt;
       
        Asset ast = SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Status = 'Installed';
        ast.InstallDate = System.Today();
        ast.UsageEndDate = System.Today();
        ast.Order_Number__c='8887777892';
        ast.Order_BUID__c='11';
        insert ast;
       
        Contact con = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
       
        Case cse = SRVS_CreateTestDataFactory.createSingleCase(ast.Id,acnt.Id,con.Id);
        insert cse;

        flag= 'false';
        Test.stopTest();
    }
    
    @isTest 
    private static void alertsBasedonAsset_test() {
        // Implement test code

        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Case c = [SELECT Id from Case Limit 1];
            List<CaseAlertsController.AlertListWrapper> alertList = CaseAlertsController.getAlerts(c.Id, flag);    // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper> -User Story #5096431 
            Test.stopTest();        
            system.assertEquals(alertList[0].ResponseCode, '100');
        }
    }
    
    @isTest 
    private static void alertsBasedonServiceTag_test() {
        // Implement test code

        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        flag='true';//User Story #5096431
        system.runAs(u){
            Test.startTest();
            Case c2 = [SELECT Id from Case Limit 1];
            List<CaseAlertsController.AlertListWrapper> alertList = CaseAlertsController.getAlerts(c2.Id, flag);    // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper> -User Story #5096431 
            Test.stopTest();        
            system.assertEquals(alertList.size(), 4);
            
             //Wrapper Class Code Coverage - User Story #5096431
            AssetAlertsController.AlertListWrapper  alrtWrap=new AssetAlertsController.AlertListWrapper ();

        }
    }

    @isTest 
    private static void alertsException_test() {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Account a = [SELECT Id from Account Limit 1];
            List<CaseAlertsController.AlertListWrapper> alertList = CaseAlertsController.getAlerts(a.Id, flag);  // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper> -User Story #5096431   
            Test.stopTest();        
            system.assertEquals(alertList, null);
        }
    }

}
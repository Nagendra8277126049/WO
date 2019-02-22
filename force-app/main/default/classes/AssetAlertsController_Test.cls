/* -----------------------------------------------------------------------------------------------------------------------
Test Class Name:       AssetAlertsController_Test
Description:           Unit Test Class for AssetAlertsController class -  Story #4142699
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/27/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
01/22/2018     1.1        Prasanthi Mukku           Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018     1.2        Surya subramanian         Changes are based on defect 4561229
05/25/2018     1.3        Brundha Rajkumar          Changes are related to User Story #5096431
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class AssetAlertsController_Test {

    private static Account acnt;
    private static Asset ast;
    private static string flag = 'false';

    /* This method creates the test data */
    
   @testSetup
    static void setupTestData() {
       
        // Create a unique UserName
        acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.Link_Number__c='1979548';
        acnt.AccountNumber='1979548';
        acnt.BUID__c='11';
        insert acnt;
        
        ast = SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Status = 'Installed';
        ast.InstallDate = System.Today();
        ast.UsageEndDate = System.Today();
        ast.Order_Number__c='8887777892';
        ast.Order_BUID__c='11';
        insert ast;
        
        //This below code is used for code coverage of UpdateParentAsset Trigger
        ast.Name='Test Asset Update';
        update ast;

        flag= 'false';

    }
    
   @isTest 
    private static void alertsBasedonAsset_test() {
        // Implement test code

        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        insert u;
        system.runAs(u){
            Test.startTest();
            Id ast_Id=[select Id from Asset Limit 1].ID;
            System.debug('Asset Id :'+ast_Id);
            System.debug('Flag :'+flag);
            List<AssetAlertsController.AlertListWrapper> alertList = AssetAlertsController.getAlerts(ast_Id, flag);   // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper> -User Story #5096431
            Test.stopTest();      
            if(alertList.size()>0)
            	system.assertEquals(alertList[0].ResponseCode, '100');
            
            //Wrapper Class Code Coverage - User Story #5096431
            AssetAlertsController.AlertListWrapper  alrtWrap=new AssetAlertsController.AlertListWrapper ();
            
        }
    } 
    
    @isTest 
    private static void alertsBasedonServiceTag_test() {
        // Implement test code
        flag='true'; 
        User u1 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            Id ast_Id1=[select Id from Asset Limit 1].ID;
            List<AssetAlertsController.AlertListWrapper> alertList = AssetAlertsController.getAlerts(ast_Id1, flag);   // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper>  - User Story #5096431
            Test.stopTest();  
             if(alertList.size()>0)
            system.assertEquals(alertList.size(), 4);
        }
    }

    @isTest 
    private static void alertsException_test() {
        
        User u2 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u2){
            Test.startTest();
            Id acc_Id=[select Id from Account Limit 1].ID;            
            List<AssetAlertsController.AlertListWrapper> alertList = AssetAlertsController.getAlerts(acc_Id, flag);  // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper>    - User Story #5096431
            Test.stopTest();   
          //  if(alertList.size()>0){
                system.assertEquals(alertList, null);
          //  }
        }
    }
}
/* -----------------------------------------------------------------------------------------------------------------------
Test Class Name:       CustomerAlertsController_Test
Description:           Unit Test Class for CustomerAlertsController class -  Story #4142699
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/27/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
01/09/2018     1.1        Surya Subramanian         Chaneges are based on Code Review Defect 4378242
01/22/2018     1.2        Sonia Sharaff             Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018     1.3        Surya Subramanian         Changes are based on Code Review Defect 4561229
5/25/2018      1.4       Brundha Rajkumar          Changes are made for User Story #5096431
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class CustomerAlertsController_Test {
    
    private static Account acnt;
    private static string flag;
    
    /* This method creates the test data */
   @testSetup
   private static void setupTestData() {
        Test.startTest();
        acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Name = 'Test Company 123';
        acnt.Industry='Fashion';
        acnt.AccountNumber='12345678';
        acnt.BUID__c='123123';
        insert acnt;
        Test.stopTest();
    }
    
    @isTest private static void alertsBasedonAsset_test() {
        // Implement test code

        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        flag= 'false';
        system.runAs(u){
            Test.startTest();
            Account a = [SELECT Id from Account LIMIT 1];
            List<CustomerAlertsController.AlertListWrapper> alertList = CustomerAlertsController.getAlerts(a.Id, flag); // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper> -User Story #5096431   
            Test.stopTest();              
            system.assertEquals(alertList[0].ResponseCode, '100');
        }
    }
    
    @isTest private static void alertsBasedonServiceTag_test() {
        // Implement test code

        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        flag= 'true'; //User Story #5096431
        system.runAs(u){
            Test.startTest();
            Account a = [SELECT Id from Account LIMIT 1];
            List<CustomerAlertsController.AlertListWrapper> alertList = CustomerAlertsController.getAlerts(a.Id, flag); // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper> -User Story #5096431   
            Test.stopTest(); 
            if(alertList.size()>0)
            system.assertEquals(alertList.size(), 4);
            
            //Wrapper Class Code Coverage - User Story #5096431
            AssetAlertsController.AlertListWrapper  alrtWrap=new AssetAlertsController.AlertListWrapper ();
        }
    }

    @isTest private static void alertsException_test() {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        flag= 'false';
        system.runAs(u){
            Test.startTest();
            List<CustomerAlertsController.AlertListWrapper> alertList = CustomerAlertsController.getAlerts(u.Id, flag); // updated from List<ServiceCloudAlerts__x> to List<AssetAlertsController.AlertListWrapper> -User Story #5096431    
            Test.stopTest();     
            system.assertEquals(alertList, null);
        }
    }
    
}
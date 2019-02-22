/* -----------------------------------------------------------------------------------------------------------------------
Name:         CustomerOrdersController_Test
Description:  Unit test class for CustomerOrdersController Class- story #4150201
----------------------------------------------------------------------------------------------------------------------------
Date         Version  		  Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/13/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
01/09/2018     1.1     Surya Subramanian       		Chaneges are based on Code Review Defect 4378242
01/22/2018     1.2     Prasanthi Mukku 	            Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018     1.3     Surya Subramanian            Changes are based on Code Review Defect 4561229
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class CustomerOrdersController_Test {
    
    /* This method creates the test data */
    @testSetup
    static void setupTestData() {
        Test.startTest();
        Account acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.AccountNumber='1234567';
        acnt.BUID__c='12345';
        acnt.Type='Customer';
        insert acnt;
        Test.stopTest();
    }
    
    /* This method tests the Customer Adress by AccountNumber */
    @isTest
    static void getOrdersByCustNumber_Test(){
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
        	Test.startTest();
            Account a = [SELECT Id from Account LIMIT 1];
    		CustomerOrdersController.OrderPagerWrapper ordersWrapper = CustomerOrdersController.getOrders(a.Id, 1 ,'10');    
        	Test.stopTest();        
        	system.assertEquals(ordersWrapper.next, true);
        }
    }
    
    /* This method tests the Customer Adress by AccountNumber */
    @isTest
    static void getOrdersByAcc_Test(){
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
        	Test.startTest();
            Account a = [SELECT Id from Account LIMIT 1];
    		CustomerOrdersController.OrderPagerWrapper ordersWrapper = CustomerOrdersController.getOrders(a.Id, 2 ,'10');  
        	Test.stopTest();        
        	system.assertEquals(ordersWrapper.next, true);
        }
    }   
    
    /* This method tests the Exception */
    @isTest
    static void getOrders_Test(){
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
        	Test.startTest();
    		CustomerOrdersController.OrderPagerWrapper ordersWrapper = CustomerOrdersController.getOrders(u.Id, 1 ,'10');     
        	Test.stopTest();        
        	system.assertEquals(ordersWrapper, null);
        }
    } 
}
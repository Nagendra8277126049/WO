/* -----------------------------------------------------------------------------------------------------------------------
Name:         GetOrderLineItems_Test.apx
Description:  Test Call for GetOrderLineItems.apx - Story #4146442 & Story #4192504
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author                   Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/17/2017     1.0     Sri Harsha Gangi Reddy     Initial Release
01/09/2018     1.1     Surya Subramanian          Chaneges are based on Code Review Defect 4378242
01/22/2018     1.2     Srikanth Parvathareddy     Changes are based on utility class "SRVS_CreateTestDataFactory"
01/24/2018     1.3     Surya Subramanian           Changes are based on Code Review Defect 4561229
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class GetOrderLineItems_Test {
    
    private static Account acnt;
    private static Asset ast;
    private static User u;
    
    /* This method creates the test data */
    @testSetup
    static void setupTestData() {
        
        //create an account
        acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        insert acnt;
        
        //create an asset
        ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Order_Number__c='1234567';
        ast.Order_BUID__c='01';
        ast.InstallDate = System.Today();
        ast.UsageEndDate = System.Today();
        insert ast;
        
    }
    
    /* This method tests the orderLineItems by asset */
    @isTest
    private static void getOrderLineByAsset_Test(){
        User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Id ast_Id=[select Id from Asset].Id;
            GetOrderLineItems.OrderLineWrapper orderWrapper = GetOrderLineItems.getItems(ast_Id, 1, '10');    
            Test.stopTest();        
            system.assertEquals(orderWrapper.orderLine[0].PartNumber__c, '1234');
        }
    }
    
    /* This method tests the orderLineItems by asset */
    @isTest
    private static void getOrderLineItemsByAsset_Test(){
        User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Asset ast1=[select Id,Name from Asset];
            GetOrderLineItems.OrderLineWrapper orderWrapper = GetOrderLineItems.getItems(ast1.Id, 1, '10');    
            Test.stopTest();        
            system.assertEquals(orderWrapper.serviceTag,ast1.Name);
        }
    }
    
    /* This method tests the orderLineItems by asset */
    @isTest
    private static void getOrdItemsByAsset_Test(){
        User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Id ast_Id=[select Id from Asset].Id;
            GetOrderLineItems.OrderLineWrapper orderWrapper = GetOrderLineItems.getItems(ast_Id, 2, '10');    
            Test.stopTest();        
            system.assertEquals(orderWrapper.orderLine.size(), 3 );
        }
    }
    
    /* This method tests the Exception in orderLineItems */    
    @isTest
    private static void getOrdersByAsset_Test(){
        User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Id acnt_Id=[select Id from Account].Id;
            GetOrderLineItems.OrderLineWrapper orderWrapper = GetOrderLineItems.getItems(acnt_Id, 1, '10');    
            Test.stopTest();        
            system.assertEquals(orderWrapper, null);
        }
    }
    
    /* This method tests the OrderDetails by asset */
    @isTest
    private static void getOrderDetailsByAsset_Test(){
        User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Id ast_Id=[select Id from Asset].Id;
            GetOrderLineItems.OrderWrapper ordWrapper = GetOrderLineItems.getDetail(ast_Id);    
            Test.stopTest();        
            system.assertEquals(ordWrapper.OrderNumber,'1234567');
        }
    }    
    
    /* This method tests the OrderDetails by asset */
    @isTest
    private static void getOrderDetailsExpByAccount_Test(){
        User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();
            Id acnt_Id=[select Id from Account].Id;
            GetOrderLineItems.OrderWrapper ordWrapper = GetOrderLineItems.getDetail(acnt_Id);    
            Test.stopTest();        
            system.assertEquals(ordWrapper,null);
        }
    }   
}
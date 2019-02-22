/* -----------------------------------------------------------------------------------------------------------------------
Name:       Dispatch_WorkOrderDetailsTest
Description:  Unit Test Class for  Dispatch_WorkOrderDetails
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
06/13/2017     1.0         Megha/Prakhar             Initial Release
06/13/2017     1.0         Harsha Reddy              Updated Code Based on Defect
06/13/2017     1.0         Rodrigo Carpio            Updated Code Based on Defect
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class Dispatch_WorkOrderDetailsTest
{
    
    private static User u;
    private static User u1;
    private static WorkOrder wo;
    private static WorkOrder wo1;
    private static WorkOrder wo2;
    
    private static void createWorkOrder(){
        
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        
        
        u1 = SRVS_CreateTestDataFactory.createUser('System Administrator');
       
        
        
        //create a test account
        Account acnt = new Account(Name = 'Test Company', Industry = 'Fashion',Type = 'Customer');
        insert acnt;
        
        //create a new product
        Product2 prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
        insert prd;
        
        //create a test contact
        Contact co = new Contact(Email = 'testtag@test.com',firstname='firstname',LastName='testtag',Accountid=acnt.id);
        insert co;
        
        //Create a test Asset
        Asset ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,InstallDate = System.Today(),UsageEndDate = System.Today(),SerialNumber='uighfg1245');
        insert ast;
        
        //create a test case
        Case cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id,ContactId=co.Id);
        insert cse;
        
        // create a test Work order
        wo = new workorder(caseId=cse.Id,status='Cancellation Request',assetId=ast.Id,AccountId=acnt.Id,ContactId=co.Id,Sub_Status__c='Acknowledged',Comments__c='this is the test comment',
                                Labor_Status__c='test labor',Parts_Status__c='test parts',Street='street', city='citi', statecode='TX', countryCode='US', Region__c='1', postalcode='12345');
        insert wo;
        
        // create a test Work order2
        wo1 = new workorder(caseId=cse.Id,status='Rework', assetId=ast.Id,AccountId=acnt.Id,ContactId=co.Id, Sub_Status__c='Acknowledged',Comments__c='this is the test comment',
                                Labor_Status__c='test labor',Parts_Status__c='test parts',Street='street', city='citi', statecode='TX', countryCode='US', Region__c='1', postalcode='12345');
        insert wo1;
        
        
        wo2 = new workorder(caseId=cse.Id,status='Service Complete', assetId=ast.Id,AccountId=acnt.Id,ContactId=co.Id,Sub_Status__c='Acknowledged',Comments__c='this is the test comment',
                                Labor_Status__c='test labor',Parts_Status__c='test parts',Street='street', city='citi', statecode='TX', countryCode='US', Region__c='1', postalcode='12345');
        insert wo2;
 
    }
    
    @isTest
    private static void fetchStatusFieldsDataTest(){
        createWorkOrder();
        system.runAs(u1){
            Test.startTest();
                Dispatch_WorkOrderDetails.statusWrapper sWrap = Dispatch_WorkOrderDetails.fetchStatusFieldsData(wo.Id);
                String response = Dispatch_WorkOrderDetails.saveWorkOrder(wo);
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void fetchStatusFieldsDataTest5(){
        createWorkOrder();
        system.runAs(u1){
            Test.startTest();
                Dispatch_WorkOrderDetails.statusWrapper sWrap = Dispatch_WorkOrderDetails.fetchStatusFieldsData(wo2.Id);
                String response = Dispatch_WorkOrderDetails.saveWorkOrder(wo);
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void fetchStatusFieldsDataTest4(){
        createWorkOrder();
        system.runAs(u1){
            Test.startTest();
                Dispatch_WorkOrderDetails.statusWrapper sWrap = Dispatch_WorkOrderDetails.fetchStatusFieldsData(null);
                String response = Dispatch_WorkOrderDetails.saveWorkOrder(null);
            Test.stopTest();
            system.assertEquals(sWrap,null);
        }
    }
    
    @isTest
    private static void fetchStatusFieldsDataTest3(){
        createWorkOrder();
        system.runAs(u1){
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Work_Order_GCC_User'];
        insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id );
            Test.startTest();
                Dispatch_WorkOrderDetails.statusWrapper sWrap = Dispatch_WorkOrderDetails.fetchStatusFieldsData(wo2.Id);
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
        }
    }
    
    @isTest
    private static void fetchStatusFieldsDataTest_Excep(){
        createWorkOrder();
        system.runAs(u1){
            Test.startTest();
                String response = Dispatch_WorkOrderDetails.saveWorkOrder(null);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void fetchStatusFieldsDataTest2(){
        createWorkOrder();
        system.runAs(u1){
            Test.startTest();
                Dispatch_WorkOrderDetails.statusWrapper sWrap = Dispatch_WorkOrderDetails.fetchStatusFieldsData(wo1.Id);
                String response = Dispatch_WorkOrderDetails.saveWorkOrder(wo1);
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
            system.assertNotEquals(response,null);
        }
    }
    
}
/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchApproveRejectController_Test
Description:  Unit Test Class for DispatchApproveRejectController Class
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
07/31/2018     1.0    Harsha Reddy       Initial Release
07/31/2018     1.0    Rodrigo Carpio     Initial Release
09/26/2018     1.1    Harsha Reddy       STORY 5499262
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchApproveRejectController_Test {
    
    /* This method creates the test data */
    @testSetup 
    private static void setupTestData() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
       
        User u = new User(Alias = 'auser',FirstName='Test', Email='adminuser@dell.com',IsActive=True,
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                FederationIdentifier='1234567',Dell_NTUserID__c='TEST_T',Service_User_Type__c='DEV',
                                External_ID__c='1234567',Organization__c='Dell',File_Source__c='AMS - System Admin',
                                LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id,
                                TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName, OSP__c='Yes');
        insert u;
        //create a test account
        Account acnt = new Account(Name = 'Test Company', Industry = 'Fashion',Type = 'Customer');
        insert acnt;
        //create a new product
        Product2 prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
        insert prd;
        
        //create a test asset
        Asset ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,
                        InstallDate = System.Today(),UsageEndDate = System.Today(),SerialNumber='Test8890990906');
        insert ast;
        
        //create a test contact
        Contact co = new Contact(Email = 'testtag@test.com',firstname = 'firstname', 
                         LastName = 'testtag',Accountid = acnt.id);
        insert co;
            
        //create a test case
        Case cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id, 
                       ContactId=co.Id);
        insert cse;
        
        //create a test work Order
        WorkOrder wo = new  WorkOrder();
        
        wo.assetId=ast.id;
        wo.accountId=acnt.id;
        wo.contactId=co.id;
        wo.caseId=cse.id;
        wo.City='Round Rock';
        wo.Street='Dell Way123';
        wo.Country='United States';
        wo.State='Texas';
        wo.Region__c='1';
        wo.PostalCode='78664';
        wo.AdditionalContactId__c=co.id;
        wo.CountryCode='US';
        wo.subject='testing Work Order';
        wo.status='Open';
        wo.TimeZone__c='America/Chicago';
        insert wo;
        
        //Update work Order
        wo.status='Pending Review';
        update wo;

        Approval_Attribute_Set__c aas = new Approval_Attribute_Set__c(AAS_Name__c = 'Test', AD_Override_Request__c = true, Approval_Criteria_Message__c = 'Criteria 1 Msg',Billable__c = true,
                     Bill_To__c = true,Category__c = true,Commodity__c = 'Include',Complete_Care__c = true,Cost__c = 'Equals To',CRU__c = true,
                     Day_of_Week__c = true,DPS_Type__c = true,FRU__c = true,Individual_Dispatch_Probation__c = true,KYC__c = true,KYHD__c = true,Model__c = true,
                     Out_of_Warranty__c = true,Overall__c = true,Part_ID__c = 'Include',Product_LOB__c = true,Quantity_excluding_Also_Shipped_Parts__c = 'Equals To',
                     Quantity__c = 'Equals To',Repeat_Dispatch_Count__c = 'Equal To',Repeat_Reason__c = true,SanBao__c = true,Service_Hours__c = true,
                     Service_Level__c = true,Service_Type__c = true,SR_Diagnostic_Results__c = true,SR_Diagnostic_Tool__c = true,System_Class__c = true,
                     Time_of_Day__c = true,APS_Flag__c = true);
            
            insert aas;
        // Create a test Queue Approval Attribute Record
        Queue_Approval_Attribute_Map__c qAAMap = new Queue_Approval_Attribute_Map__c(Queue_User__c='Test', Approver__c = 'Test Approver', Approval_Attribute_Set__c = aas.id );
        insert qAAMap;
        
        // Create a test Queue Approval Attribute Record
        Queue_Approval_Attribute_Map__c qAAMap1 = new Queue_Approval_Attribute_Map__c(Queue_User__c='Test', Approver__c = 'Test Approver', Approval_Attribute_Set__c = aas.id, Rejected_Count__c= 1 );
        insert qAAMap1;
        
        //create a test Dispatch Pending Approval Record
        DispatchPendingApproval__c dpa = new DispatchPendingApproval__c(Work_Order__c=wo.Id,OwnerId=u.Id,Queue_Approval_Attribute_Map__c=qAAMap.Id);
        insert dpa;
        
        //create a test Dispatch Pending Approval Record
        DispatchPendingApproval__c dpa1 = new DispatchPendingApproval__c(Work_Order__c=wo.Id,OwnerId=u.Id,Queue_Approval_Attribute_Map__c=qAAMap1.Id);
        insert dpa1;
    }
    
    /* This method is to do Positive Unit Testing for  ApproveDispatch Method - Use Case 1*/
    private static testMethod void ApproveDispatch_UseCase1() {
        User u = [SELECT Id FROM User LIMIT 1];
        WorkOrder wo = [SELECT Id,TimeZone__c FROM WorkOrder LIMIT 1];
        DispatchPendingApproval__c dpa = [SELECT Id FROM DispatchPendingApproval__c WHERE Work_Order__c=:wo.Id LIMIT 1];
        system.runAs(u){
            Test.startTest();
                string currentTime = system.now().addHours(3).format('HH:mm',wo.TimeZone__c);
               // DispatchApproveRejectController.mockDateTime = system.now().addHours(-1);
               // DispatchApproveRejectController.mockedAssetCountry.add(new Asset_Country__mdt(CutOff__c=currentTime,Active__c=true,CountryCode__c='US'));
                String recId = DispatchApproveRejectController.ApproveDispatch(dpa.Id,'Approved','Test');
            Test.stopTest();
            system.assertNotEquals(recId,null);
        }
    }
    
   /* This method is to do Positive Unit Testing for  ApproveDispatch Method - Use Case 2*/
    private static testMethod void ApproveDispatch_UseCase2() {
        User u = [SELECT Id FROM User LIMIT 1];
        WorkOrder wo = [SELECT Id,TimeZone__c FROM WorkOrder LIMIT 1];
        DispatchPendingApproval__c dpa = [SELECT Id FROM DispatchPendingApproval__c WHERE Work_Order__c=:wo.Id LIMIT 1];
        system.runAs(u){
            Test.startTest();
                string currentTime = system.now().addHours(-3).format('HH:mm',wo.TimeZone__c);
               // DispatchApproveRejectController.mockDateTime = system.now().addHours(-1);
               // DispatchApproveRejectController.mockedAssetCountry.add(new Asset_Country__mdt(CutOff__c=currentTime,Active__c=true,CountryCode__c='US'));
                String recId = DispatchApproveRejectController.ApproveDispatch(dpa.Id,'Approved','Test');
            Test.stopTest();
            system.assertNotEquals(recId,null);
        }
    }
    
    /* This method is to do Negative Unit Testing for  ApproveDispatch Method  - Exception Scenario*/
    private static testMethod void ApproveDispatch_UseCase3() {
        User u = [SELECT Id FROM User LIMIT 1];
        system.runAs(u){
            Test.startTest();
              //  DispatchApproveRejectController.mockDateTime = system.now().addHours(-1);
                String recId = DispatchApproveRejectController.ApproveDispatch(u.Id,'Approved','Test');
            Test.stopTest();
            system.assertEquals(recId,null);
        }
    }
    
        /* This method is to do Positive Unit Testing for  ApproveDispatch Method - Use Case 1*/
    private static testMethod void ApproveDispatch_UseCase4() {
        User u = [SELECT Id FROM User LIMIT 1];
        WorkOrder wo = [SELECT Id,TimeZone__c,CountryCode__c FROM WorkOrder LIMIT 1];
        DispatchPendingApproval__c dpa = [select Id from DispatchPendingApproval__c WHERE Work_Order__c =: wo.Id  LIMIT 1];
        List<DispatchPendingApproval__c> dpaList = [SELECT Id, Work_Order__c, Work_Order__r.CountryCode__c, Work_Order__r.TimeZone__c FROM DispatchPendingApproval__c WHERE Work_Order__c =: wo.Id  LIMIT 1];
      //  List<WorkOrderHistory> woHList = [SELECT Id,CreatedDate,OldValue,NewValue,Field,WorkOrderId FROM WorkOrderHistory where WorkOrderId=:dpAList[0].Work_Order__c];
        system.runAs(u){
            Test.startTest();
                string currentTime = system.now().addHours(3).format('HH:mm',wo.TimeZone__c);
                List<WorkOrderHistory> woHList = [SELECT Id,CreatedDate,OldValue,NewValue,Field,WorkOrderId FROM WorkOrderHistory where WorkOrderId=:dpAList[0].Work_Order__c];
               // DispatchApproveRejectController.mockedAssetCountry.add(new Asset_Country__mdt(CutOff__c=currentTime,Active__c=true,CountryCode__c='US'));
               // DispatchApproveRejectController.mockDateTime = system.now().addHours(-1);
                String recId = DispatchApproveRejectController.ApproveDispatch(dpa.Id,'Approved','Test');
                DispatchPendingApproval__c dpaRec = [SELECT Approval_Status__c FROM DispatchPendingApproval__c WHERE Work_Order__c =: wo.Id LIMIT 1];
                //DispatchApproveRejectController.isInCountryCutoff(wo.CountryCode__c,wo.Timezone__c,system.now().addHours(2));
                //DispatchApproveRejectController.isInCountryCutoff(dpaList[0].Work_Order__r.CountryCode__c,dpaList[0].Work_Order__r.Timezone__c,system.now().addHours(2));
            Test.stopTest();
            system.assertNotEquals(recId,null);
        }
    }
    
    /* This method is to do Positive Unit Testing for  RejectDispatch Method - Use Case 1*/
    private static testMethod void RejectDispatch_UseCase1() {
        User u = [SELECT Id FROM User LIMIT 1];
        WorkOrder wo = [SELECT Id,TimeZone__c FROM WorkOrder LIMIT 1];
        DispatchPendingApproval__c dpa = [SELECT Id FROM DispatchPendingApproval__c WHERE Work_Order__c=:wo.Id LIMIT 1];
        system.runAs(u){
            Test.startTest();
                String recId = DispatchApproveRejectController.RejectDispatch(dpa.Id,'Fraud Suspected','Test');
                DispatchPendingApproval__c dpaRec = [SELECT Approval_Status__c FROM DispatchPendingApproval__c WHERE Id=:dpa.Id LIMIT 1];
            Test.stopTest();
            system.assertEquals(dpaRec.Approval_Status__c,'Rejected');
            system.assertNotEquals(recId,null);
        }
    }
    
    private static testMethod void RejectDispatch_UseCase2() {
        User u = [SELECT Id FROM User LIMIT 1];
        WorkOrder wo = [SELECT Id,TimeZone__c FROM WorkOrder LIMIT 1];
        DispatchPendingApproval__c dpa1 = [SELECT Id FROM DispatchPendingApproval__c WHERE Work_Order__c=:wo.Id LIMIT 1];
        system.runAs(u){
            Test.startTest();
                String recId = DispatchApproveRejectController.RejectDispatch(dpa1.Id,'Fraud Suspected','Test');
                DispatchPendingApproval__c dpaRec1 = [SELECT Approval_Status__c FROM DispatchPendingApproval__c WHERE Id=:dpa1.Id LIMIT 1];
            Test.stopTest();
            system.assertEquals(dpaRec1.Approval_Status__c,'Rejected');
            system.assertNotEquals(recId,null);
        }
    }
    
    /* This method is to do Negative Unit Testing for  RejectDispatch Method - Exception Scenario*/
    private static testMethod void RejectDispatch_UseCase3() {
        User u = [SELECT Id FROM User LIMIT 1];
        system.runAs(u){
            Test.startTest();
                String recId = DispatchApproveRejectController.RejectDispatch(u.Id,'Fraud Suspected','Test');
            Test.stopTest();
            system.assertEquals(recId,null);
        }
    }
    
    private static testMethod void isInCountryCutoff_Test1() {
        User u = [SELECT Id FROM User LIMIT 1];
        WorkOrder wo = [SELECT Id,TimeZone__c,CountryCode__c FROM WorkOrder LIMIT 1];
        system.runAs(u){
            Test.startTest();
                string currentTime = system.now().addHours(3).format('HH:mm',wo.TimeZone__c);
              //  DispatchApproveRejectController.mockedAssetCountry.add(new Asset_Country__mdt(CutOff__c=currentTime,Active__c=true,CountryCode__c='US'));
              //  Boolean recId = DispatchApproveRejectController.isInCountryCutoff(wo.CountryCode__c,wo.Timezone__c,system.now().addHours(2));
            Test.stopTest();
        }
    }
    
    private static testMethod void isInCountryCutoff_Test2() {
        User u = [SELECT Id FROM User LIMIT 1];
         WorkOrder wo = [SELECT Id,TimeZone__c,CountryCode__c FROM WorkOrder LIMIT 1];
        system.runAs(u){
            Test.startTest();
             //   Boolean recId = DispatchApproveRejectController.isInCountryCutoff('',wo.Timezone__c,system.now().addHours(2));
            Test.stopTest();
        }
    }
    
    private static testMethod void isInCountryCutoff_Test3() {
        User u = [SELECT Id FROM User LIMIT 1];
        system.runAs(u){
            Test.startTest();
             //   Boolean recId = DispatchApproveRejectController.isInCountryCutoff('US','',system.now().addHours(2));
            Test.stopTest();
        }
    }
    
    private static testMethod void isInCountryCutoff_Test4() {
        User u = [SELECT Id FROM User LIMIT 1];
         WorkOrder wo = [SELECT Id,TimeZone__c,CountryCode__c FROM WorkOrder LIMIT 1];
        system.runAs(u){
            Test.startTest();
             //   Boolean recId = DispatchApproveRejectController.isInCountryCutoff('55555555',wo.Timezone__c,system.now().addHours(2));
            Test.stopTest();
        }
    }
    
    private static testMethod void isInCountryCutoff_Test5() {
        User u = [SELECT Id FROM User LIMIT 1];
         WorkOrder wo = [SELECT Id,TimeZone__c,CountryCode__c FROM WorkOrder LIMIT 1];
        system.runAs(u){
            Test.startTest();
             //   Boolean recId = DispatchApproveRejectController.isInCountryCutoff('55555555',wo.Timezone__c,null);
            Test.stopTest();
        }
    }
}
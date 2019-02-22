@isTest
private class DispatchGccConfiguration_Test
{
    
    private static User u;
    private static User u1;
    private static WorkOrder wo;
    private static WorkOrder wo1;
    private static WorkOrder wo2;
    private static DispatchInstruction__c dinst;
    private static DispatchInstruction__c dinst1;
    private static DispatchInstruction__c dinst2;
    private static DispatchDSPDLP__c dlp1;
    private static DispatchDSPDLP__c dlp2;
    private static List<DispatchDSPDLP__c> dlpList;
    private static DispatchDefaults__c dd1;
    private static DispatchDefaults__c dd2;
    private static DispatchDefaults__c dd11;
    private static DispatchDefaults__c dd22;
    private static List<DispatchDefaults__c> ddList;
    
    
    
    private static void createWorkOrder(){
        
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        
        
        
        //User u= SRVS_CreateTestDataFactory.createUser('System Administrator');
        //USer u1 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        u = new User(Alias = 'auser1', Email = 'adminusert1@dell.com', File_Source__c='AMS - System Admin', Dell_NTUserID__c='TEST1_T',
        Service_User_Type__c='Admin',EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US',
        External_ID__c='1234526', FederationIdentifier = '1234526',LocaleSidKey = 'en_US', Organization__c='Dell',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminuser1@dell.com', OSP__C = 'No'); 
        insert u;
        
        u1 = new User(Alias = 'auser1', Email = 'adminusert2@dell.com', File_Source__c='AMS - System Admin', Dell_NTUserID__c='TEST1_U',
        Service_User_Type__c='Admin',EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US',
        External_ID__c='1234527', FederationIdentifier = '1234527',LocaleSidKey = 'en_US', Organization__c='Dell',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminuser2@dell.com', OSP__C = 'No'); 
        insert u1;
        
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
                                Labor_Status__c='test labor',Parts_Status__c='test parts',Street='street', city='citi', statecode='TX', countryCode='US', Region__c='1', postalcode='12345', CallType__c = 'Test', DPSType__c = 'Test', DLP_Name__c='TestDLP', DSPName__c = 'TestDSP');
        insert wo;
        
        // create a test Work order2
        wo1 = new workorder(caseId=cse.Id,status='Rework', assetId=ast.Id,AccountId=acnt.Id,ContactId=co.Id, Sub_Status__c='Acknowledged',Comments__c='this is the test comment',
                                Labor_Status__c='test labor',Parts_Status__c='test parts',Street='street', city='citi', statecode='TX', countryCode='US', Region__c='1', postalcode='12345');
        insert wo1;
        
        
        wo2 = new workorder(caseId=cse.Id,status='Service Complete', assetId=ast.Id,AccountId=acnt.Id,ContactId=co.Id,Sub_Status__c='Acknowledged',Comments__c='this is the test comment',
                                Labor_Status__c='test labor',Parts_Status__c='test parts',Street='street', city='citi', statecode='TX', countryCode='US', Region__c='1', postalcode='12345');
        insert wo2;
        
         //create dispatch Instruction Record
        dinst = new DispatchInstruction__c(Work_Order__c=wo.id,/*Instruction__c='Good Service with Care',*/DSP_Override_Request__c=true, Instruction_Identifier__c = 'Cancellation Comments');
        insert dinst;
        
        dinst1 = new DispatchInstruction__c(Work_Order__c=wo.id, Instruction__c='Good Service with Care',DSP_Override_Request__c=true, Instruction_Identifier__c = 'Cancellation Comments');
        insert dinst1;
 
        dd1 = new DispatchDefaults__c(Work_Order__c = wo.Id, DSP_Override_Request__c = true);
        dd2 = new DispatchDefaults__c(Work_Order__c = wo.Id, DSP_Override_Request__c = true);
        ddList = new List<DispatchDefaults__c>();
        ddList.add(dd1);
        ddList.add(dd2); 
        insert ddList;
        
        dd11 = new DispatchDefaults__c(Work_Order__c = wo1.Id, DSP_Override_Request__c = true);
        dd22 = new DispatchDefaults__c(Work_Order__c = wo1.Id, DSP_Override_Request__c = true);
        ddList = new List<DispatchDefaults__c>();
        ddList.add(dd11);
        ddList.add(dd22); 
        insert ddList;
        
        dlp1 = new DispatchDSPDLP__c(PartnerName__c = 'TestName', PartnerCode__c = 'Test', Type__c = 'DSP', CountryCode__c = 'US');
        
        dlp2 =  new DispatchDSPDLP__c(PartnerName__c = 'TestName', PartnerCode__c = 'Test', Type__c = 'DSP', CountryCode__c = 'US');
        
        dlpList = new List<DispatchDSPDLP__c>();
        dlpList.add(dlp1);
        dlpList.add(dlp2);
        
        insert dlpList; 
 
    }
 
    @isTest
    private static void saveGccDSPUpdateTest(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
                DispatchGccConfiguration.saveGccDSPUpdate(wo.Id,'1234','TestDSP');
            Test.stopTest();
            //System.assert(false, 'a NullPointerException was expected but was not thrown');
         }
        
        
    }
    
    @isTest
    private static void UpdateWoAndInstructionGccTest(){
        
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
                //create dispatch Instruction Record
                dinst = new DispatchInstruction__c(Work_Order__c=wo.id,DSP_Override_Request__c=true, Instruction_Identifier__c = 'Cancellation Comments');
                insert dinst;
                DispatchGccConfiguration.UpdateWoAndInstructionGcc(wo.Id,'resubmit',dinst);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void UpdateWoAndInstructionGccTest1(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
                dinst1 = new DispatchInstruction__c(Work_Order__c=wo.id, Instruction__c='Good Service with Care',DSP_Override_Request__c=true, Instruction_Identifier__c = 'Cancellation Comments');
                insert dinst1;
                DispatchGccConfiguration.UpdateWoAndInstructionGcc(wo.Id,'cancel',dinst1);
                DispatchGccConfiguration.UpdateWoAndInstructionGcc(wo.Id,'',dinst1);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void UpdateWoAndInstructionGccTest2(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
                DispatchGccConfiguration.UpdateWoAndInstructionGcc(wo.Id,'cancel',null);
            Test.stopTest();
       }
    }
    
    
    @isTest
    private static void getGccConfigurationsTest(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
                DispatchGccConfiguration.getGccConfigurations(wo.id, 'US');
                DispatchGccConfiguration.getGccConfigurations(null, 'US');
            Test.stopTest();
        }
    }
   
    @isTest
    private static void GetInstructionsGCCTest(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
            DispatchGccConfiguration.InstructionsWrapper gccWrap = DispatchGccConfiguration.GetInstructionsGCC(wo.id);
            DispatchGccConfiguration.GetInstructionsGCC(null);
            Test.stopTest();
        }
    }
   
    @isTest
    private static void GetInstructionsGCCTest1(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
                DispatchGccConfiguration.InstructionsWrapper gccWrap = DispatchGccConfiguration.GetInstructionsGCC(wo1.Id);
            Test.stopTest();
        }
    }
    @isTest
    private static void GetInstructionsGCCTest2(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
               dinst2 = new DispatchInstruction__c(Work_Order__c=wo.id);
               insert dinst2;
               DispatchGccConfiguration.InstructionsWrapper gccWrap =  DispatchGccConfiguration.GetInstructionsGCC(u.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void isGCCuserTest(){
        createWorkOrder();
        system.runAs(u1){
            Test.startTest();
                PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Work_Order_GCC_User'];
                insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id );
                DispatchGccConfiguration.isGCCuser();
            Test.stopTest();
        }
    }
    
    @isTest
    private static void checkBussinessHourLogicTest(){
        createWorkOrder();
        system.runAs(u){
            Test.startTest();
                DateTime curDT = DateTime.now();
                DispatchGccConfiguration.checkBussinessHourLogic(curDT, 'US');
            Test.stopTest();
        }
    }
    
    
   
}
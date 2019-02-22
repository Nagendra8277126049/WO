/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchEditController_Test
Description:  Unit Test Class for DispatchEditController Class - Story 5263685
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
08/28/2018     1.0    Harsha Reddy       Initial Release
08/28/2018     1.0    Rodrigo Carpio     Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchEditController_Test {
        
    /* This method creates the test data */
    @testSetup static void setup() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        insert u;
        //create a test account
         List < Account > accListList = DispatchTestSetupData.createAccountList();
        List < Asset > assetList = DispatchTestSetupData.createAssetList(accListList[0].id);
        List < Contact > conlist = DispatchTestSetupData.createContactList(accListList[0].id);
        List < Case > caselist = DispatchTestSetupData.createCaseList(accListList[0].id, assetList[0].id, conlist[0].id);
        List < WorkOrder > workOrderList = DispatchTestSetupData.createworkorderList(accListList[0].id, assetList[0].id, conlist[0].id, caselist[0].id);
               
    DispatchInstruction__c   dIns = new DispatchInstruction__c(Work_Order__c = workOrderList[0].Id,Is_Type_CompleteCareOption__c=true);
          insert dIns;
        
        //create a test Dispatch Pending Approval Records
        List<DispatchPendingApproval__c> dpaList = new List<DispatchPendingApproval__c>();
        dpaList.add(new DispatchPendingApproval__c(Work_Order__c=workOrderList[0].Id,OwnerId=u.Id,Approval_Status__c = 'Pending'));
        dpaList.add(new DispatchPendingApproval__c(Work_Order__c=workOrderList[0].Id,OwnerId=u.Id,Approval_Status__c = 'Pending'));
        insert dpaList;
    }
    
    /* This method is to do Positive Unit Testing for  updateWorkOrder Method - Use Case 1*/
    private static testMethod void updateWorkOrder_UseCase1() {
       
        WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
        wo.status='Problem';
        update wo;
       // system.runAs(u){
            Test.startTest();
              DispatchEditController.updateWorkOrder(wo.Id);
            Test.stopTest();
           // system.assert(response.equalsIgnoreCase('SUCCESS'));
        //}
    }
    
    /* This method is to do Positive Unit Testing for  updateWorkOrder Method - Use Case 2*/
    private static testMethod void updateWorkOrder_UseCase2() {
        //setupTestData();
        WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
        //system.runAs(u){
            Test.startTest();
                String response = DispatchEditController.updateWorkOrder(wo.Id);
            Test.stopTest();
            //system.assert(String.isNotBlank(response));
        //}
    }
    
    private static testMethod void updateWorkOrder_UseCase3() {
        //setupTestData();
        WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
        DispatchInstruction__c   dIns = new DispatchInstruction__c(Work_Order__c = wo.Id,Is_Type_CompleteCareOption__c=true);
        //system.runAs(u){
            Test.startTest();
                String response = DispatchEditController.UpdateWoAndInstructionGcc(wo.Id, '', dIns);
            Test.stopTest();
            //system.assert(String.isNotBlank(response));
        //}
    }
    
    private static testMethod void updateWorkOrder_UseCase4() {
        //setupTestData();
         WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
         DispatchInstruction__c   dIns = new DispatchInstruction__c(Work_Order__c = wo.Id,Is_Type_CompleteCareOption__c=true);
          insert dIns;
        //system.runAs(u){
            Test.startTest();
                String response = DispatchEditController.UpdateWoAndInstructionGcc(wo.Id, 'Test', dIns);
            Test.stopTest();
            //system.assert(String.isNotBlank(response));
        //}
    }
    
    private static testMethod void updateWorkOrder_UseCase5() {
        //setupTestData();
        WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
               //system.runAs(u){
            Test.startTest();
                DispatchGccConfiguration.InstructionsWrapper InstWrap = DispatchEditController.GetInstructionsGCC(wo.Id);
            Test.stopTest();
           // system.assert(String.isNotBlank(response));
        //}
    }
    
     private static testMethod void updateWorkOrder_UseCase6() {
        //setupTestData();
        
        //system.runAs(u){
            Test.startTest();
                DispatchGccConfiguration.InstructionsWrapper InstWrap = DispatchEditController.GetInstructionsGCC('');
            Test.stopTest();
           // system.assert(String.isNotBlank(response));
        //}
    }
    
    /* This method is to do Negative Unit Testing for  updateWorkOrder Method - Exception*/
    private static testMethod void updateWorkOrder_Exception() {
        //setupTestData();
        
        //system.runAs(u){
            Test.startTest();
                String response = DispatchEditController.updateWorkOrder(null);
            Test.stopTest();
            //system.assert(String.isNotBlank(response));
        //}
    }
}
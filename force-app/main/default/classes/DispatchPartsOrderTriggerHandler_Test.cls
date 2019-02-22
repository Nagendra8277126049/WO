/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchPartsOrderTriggerHandler_Test
Description:  This test class DispatchPartsOrderTriggerHandler - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchPartsOrderTriggerHandler_Test{ 
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static User u;
    private static Contact co;
    private static WorkOrder wo;
    private static WorkOrderLineItem woLi;
    private static Product2 prd;
    private static DispatchPartsOrderLine__c dpLines;
    private static DispatchPartsOrder__c dporder;
    private static DispatchDefaults__c dd;
    private static DispatchInstruction__c dinst; 
    
    /* This method creates the test data */
    @testSetup static void setup() {
        // Create a unique UserName
        
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
        
         Address_Data_GCC__c indAdress = new Address_Data_GCC__c ();
        indAdress.Name='VILE PARLE WEST';
        indAdress.POSTCODE__c='400056';
        indAdress.COUNTRYCODE__c='IN';
        indAdress.STATENAME__c ='MRT:MUMBAI';
        insert indAdress;
        Address_Data_GCC__c ausAdress = new Address_Data_GCC__c ();
        ausAdress.Name='PUCKAPUNYAL MILPO';
        ausAdress.POSTCODE__c='WA 1234';
        ausAdress.COUNTRYCODE__c='AU';
        ausAdress.STATENAME__c ='VIC';
        insert ausAdress;
        
    }
    
    @isTest
    private static void PartsStatusUpdateTest_Exception(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
             WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Acknowledged';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test PartsStatusUpdate',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'ACCEPTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
    
    @isTest
    private static void PartsStatusUpdateTest(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
             WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Acknowledged';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test PartsStatusUpdate',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'ACCEPTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
    
    @isTest
    private static void PartsOrderCancellationTest(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderCancellation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Acknowledged', 
                                                                  PartsStatus__c='Cancelled');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
              WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Work in Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsOrderCancellation';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test ',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'ACCEPTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
        
    
    @isTest
    private static void PartsOrderCancelConfirmationTest_ACCEPTED(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts Only', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderCancelConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='NA', LaborStatus__c='Acknowledged', 
                                                                  PartsStatus__c='Cancelled');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
              WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts Only';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Work in Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsOrderCancelConfirmation';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test ',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'ACCEPTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
    @isTest
    private static void PartsOrderCancelConfirmationTest_REJECTED(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderCancelConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Service Call Closure', 
                                                                  PartsStatus__c='Cancellation Rejected');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
              WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Work in Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsOrderCancelConfirmation';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test ',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'REJECTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
    
    @isTest
    private static void PartsOrderCancelConfirmationTest2_REJECTED(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderCancelConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='NA', 
                                                                  PartsStatus__c='Cancellation Rejected');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
              WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Service Call Closure';
            wo.Parts_Status__c='';
            wo.Status='Work in Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsOrderCancelConfirmation';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test ',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'REJECTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
    
    @isTest
    private static void PartsOrderConfirmationTest_ACCEPTED(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Acknowledged', 
                                                                  PartsStatus__c='Acknowledged');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
              WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Service Call Closure';
            wo.Parts_Status__c='';
            wo.Status='Work in Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsOrderConfirmation';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test ',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'ACCEPTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }   
    @isTest
    private static void PartsOrderConfirmationTest_REJECTED(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts Only', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Acknowledged', 
                                                                  PartsStatus__c='Rejected');
            
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
              WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Acknowledged';
            wo.Status='Work in Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsOrderConfirmation';
            wo.WO_Type__c = 'Break Fix';
            
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test  REJECTED',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'REJECTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
    @isTest
    private static void PartsOrderConfirmationTest_REJECTED2(){
        //setupTestData();
        //system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts Only', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Acknowledged', 
                                                                  PartsStatus__c='Rejected');
            
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
            
              WorkOrder wo= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
                wo.IsDeferralAllowed__c=false;
                /*wo.Country='India';
                wo.State='Maharashtra';
                wo.City='Mumbai';
                wo.PostalCode='400056';
                wo.Street='40 Vallabhbhai Patel Road';*/
                wo.Country='NETHERLANDS';
                wo.CountryCode ='NL';
                //wo.State='';
                wo.City='Den Haag';
                wo.PostalCode='2585 GJ';
                wo.Street='Surinamestraat 27';
                wo.DPS_Region__c ='EMEA';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'PartsOrderConfirmation';
                wo.WO_Type__c = 'Break fix';           
            update wo;
                
            dporder = new DispatchPartsOrder__c(ISP_PUDO_Name__c='test  REJECTED',Work_Order__c=Wo.Id, ISP_Operation_Type__c = 'REJECTED'); 
            insert dporder;
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        //}
    }
    
   
}
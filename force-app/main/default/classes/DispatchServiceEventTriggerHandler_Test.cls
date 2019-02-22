/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchServiceEventTriggerHandler_Test
Description:  This test class for DispatchServiceEventTriggerHandler - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchServiceEventTriggerHandler_Test {
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
    private static void setupTestData() {
        // Create a unique UserName
        //String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        //u = new User(Alias='auser', Email='adminuser@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__c='Yes');
       u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        //create a test account
        String uniqueAccntName = 'Test Account'+DateTime.now().getTime();
        acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Name=uniqueAccntName;
        acnt.Industry='Fashion';
        acnt.Type = 'Prospect';
        insert acnt;
        
        //create a new product
        prd=SRVS_CreateTestDataFactory.createProduct2();
        prd.Product_Identifier__c='S360';
        prd.External_Id__c = 'AH129';
        prd.Name='Test Product';
        prd.LOB_Code__c='4SV';
        insert prd;                
        
        //create a test asset
        String uniqueAssetName = 'Test Asset'+DateTime.now().getTime();
        ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Product2Id=prd.Id;
        ast.Name = uniqueAssetName;
        ast.Status = 'Installed';
        ast.InstallDate = System.Today();
        ast.UsageEndDate = System.Today();
        ast.serialNumber='TestNumber89768';
        //ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,InstallDate = System.Today(),UsageEndDate = System.Today(),serialNumber='TestNumber89768');
        insert ast;
        
        //create a test contact
        co=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        co.Email = 'testtag@test.com';
        co.firstname = 'firstname';
        co.LastName = 'testtag';
        co.Accountid = acnt.id;
        //co = new Contact(Email = 'testtag@test.com',firstname = 'firstname',LastName = 'testtag',Accountid = acnt.id);
        insert co;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;
        
        // create a LiveChatTranscript without Asset
        LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorId=visitor.Id);
        lct1.Asset__c=null;
        insert lct1;
        
        //create a test case
        cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,co.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.AssetId=ast.id;
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        cse.TranscriptId__c = lct.Id;
        //cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id,ContactId=co.Id);
        insert cse;
        
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
    private static void ServiceCallConfirmationAck_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
                wo.Service_Type__c='Mail-In';
                wo.Labor_Status__c = 'Work In Progress';
                wo.Parts_Status__c='All Parts Returned';
                wo.Status='Work In Progress';
                wo.DPS_Region__c='AMERICAS';
                wo.DPS_Sub_Region__c='US';
                wo.MessageTypeID__c='ServiceCallConfirmation';
                wo.WO_Type__c = 'Break Fix';
                
            Insert wo;
                DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='Acknowledged', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='0');
            insert se;
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='NA', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='Acknowledged', 
                                                                      ProgressEvent__c='Acknowledged');
            
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void ServiceCallConfirmationAck_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
                wo.Service_Type__c='Mail-In';
                wo.Labor_Status__c = 'Work In Progress';
                wo.Parts_Status__c='All Parts Returned';
                wo.Status='Work In Progress';
                wo.DPS_Region__c='AMERICAS';
                wo.DPS_Sub_Region__c='US';
                wo.MessageTypeID__c='SvcCallCancelConfirmation';
                wo.WO_Type__c = 'Break Fix';
                
            Insert wo;
                DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='Acknowledged', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='0');
            insert se;
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='NA', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='Acknowledged', 
                                                                      ProgressEvent__c='Acknowledged');
            
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            Test.stopTest();
        }
    }
    @isTest
    private static void ServiceCallConfirmation_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='VENDOR GENERATED ALERT');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='All Parts Returned';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceCallConfirmation';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='VENDOR GENERATED ALERT', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='0');
            insert se;
            
            Test.stopTest();
        }
    }
    
     @isTest
    private static void ServiceCallRejection_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='VENDOR GENERATED ALERT');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='All Parts Returned';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceCallRejection';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='VENDOR GENERATED ALERT', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='112');
            insert se;
            
            Test.stopTest();
        }
    }
    @isTest
    private static void ServiceCallConfirmationEMEA_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'EMEA', 
                                                                  SubRegion__c='', MessageType__c = 'ServiceCallConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='VENDOR GENERATED ALERT');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='All Parts Returned';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='EMEA';
            wo.DPS_Sub_Region__c='';
            wo.MessageTypeID__c='ServiceCallConfirmation';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='VENDOR GENERATED ALERT', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='0');
            insert se;
            
            Test.stopTest();
        }
    }
    @isTest
    private static void ServiceCallConfirmationAP_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AP', 
                                                                  SubRegion__c='AP', MessageType__c = 'ServiceCallConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='VENDOR GENERATED ALERT');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='All Parts Returned';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AP';
            wo.DPS_Sub_Region__c='AP';
            wo.MessageTypeID__c='ServiceCallConfirmation';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='VENDOR GENERATED ALERT', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='0');
            insert se;
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void ServiceStatusUpdate_TRN_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='VENDOR GENERATED ALERT');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='All Parts Returned';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='VENDOR GENERATED ALERT', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='0');
            insert se;
            
            Test.stopTest();
        }
    }
    @isTest
    private static void ServiceStatusUpdate_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='VENDOR GENERATED ALERT');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            DispatchServiceEventTriggerHandler.mockedReplyDesc = 'BACKLOG';
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='VENDOR GENERATED ALERT', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='');
            insert se;
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void ServiceStatusUpdate2_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='Acknowledge');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='Acknowledge', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='');
            insert se;
            
            Test.stopTest();
        }
    }
    
    
    
    @isTest
    private static void ServiceCallClosureCancelRequest_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallClosure', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Service Complete', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Service Complete', DeliveryStatus__c='ServiceCallClosure');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='';
            wo.Status='Cancellation Request';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';            
            wo.MessageTypeID__c='ServiceCallClosure';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='ServiceCallClosure', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='111');
            insert se;
            Test.stopTest();
        }
    }
    
     @isTest
    private static void ServiceCallClosureCancelRequest_Test12(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallClosure', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Service Complete', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Service Complete', DeliveryStatus__c='ServiceCallClosure');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Service Call Closure';
            wo.Parts_Status__c='';
            wo.Status='Cancellation Request';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';            
            wo.MessageTypeID__c='ServiceCallClosure';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='ServiceCallClosure', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='111');
            insert se;
            Test.stopTest();
        }
    }
    
    
    
    @isTest
    private static void ServiceCallClosureCancelRequest_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Labor Only', Region__c = 'EMEA', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallClosure', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Service Complete', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Service Complete', DeliveryStatus__c='ServiceCallClosure');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Labor Only';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='';
            wo.Status='Cancellation Request';
            wo.DPS_Region__c='EMEA';
            wo.DPS_Sub_Region__c='Europe';            
            wo.MessageTypeID__c='ServiceCallClosure';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='ServiceCallClosure', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='111');
            insert se;
            Test.stopTest();
        }
    }
    
    @isTest
    private static void ServiceCallClosureCancelRequest_Test11(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Labor Only', Region__c = 'EMEA', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallClosure', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Service Complete', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Service Complete', DeliveryStatus__c='ServiceCallClosure');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Labor Only';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='Test';
            wo.Status='Cancellation Request';
            wo.DPS_Region__c='EMEA';
            wo.DPS_Sub_Region__c='Europe';            
            wo.MessageTypeID__c='ServiceCallClosure';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='ServiceCallClosure', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='111');
            insert se;
            Test.stopTest();
        }
    }
    
    
    
    @isTest
    private static void ServiceCallClosureCancelRequest_Test2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Labor Only', Region__c = 'AP', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallClosure', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Service Complete', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Service Complete', DeliveryStatus__c='ServiceCallClosure');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Labor Only';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='';
            wo.Status='Cancellation Request';
            wo.DPS_Region__c='AP';
            wo.DPS_Sub_Region__c='Singapore';            
            wo.MessageTypeID__c='ServiceCallClosure';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='ServiceCallClosure', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='111');
            insert se;
            Test.stopTest();
        }
    }
    
    @isTest
    private static void ServiceCallClosure_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceCallClosure', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Service Complete', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Service Complete', DeliveryStatus__c='ServiceCallClosure');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='Work In Progress';
            wo.Status='Cancelled';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';            
            wo.MessageTypeID__c='ServiceCallClosure';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='ServiceCallClosure', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='111');
            insert se;
            Test.stopTest();
        }
    }
    
    @isTest
    private static void MailInNot109_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='Work In Progress';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='Acknowledged', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='112');
            insert se;
            Test.stopTest();
        }
    }
    
     @isTest
    private static void MailIn109_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='Work In Progress';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='Acknowledged', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='109');
            insert se;
            Test.stopTest();
        }
    } 
    
    @isTest
    private static void MailIn_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Cancelled';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='ServiceStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            Insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='SERVICE_COMPLETED', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='109');
            insert se;
            Test.stopTest();
        }
    } 
    
    @isTest
    private static void MailIn_TestEMEA(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'EMEA', 
                                                                  SubRegion__c='', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
             WorkOrder wo = new WorkOrder();
                wo.assetId = ast.id;
                wo.accountId=acnt.id;
                wo.contactId=co.id;
                wo.caseId=cse.id;
                wo.status='open';
                wo.AdditionalContactId__c=co.id;
                wo.subject='testing Work Order';
                wo.IsDeferralAllowed__c=false;
                wo.Country='NETHERLANDS';
                wo.CountryCode ='NL';
                //wo.State='';
                wo.City='Den Haag';
                wo.PostalCode='2585 GJ';
                wo.Street='Surinamestraat 27';
                wo.DPS_Region__c ='EMEA';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'ServiceCallClosure';
                wo.WO_Type__c = 'Break fix';
            
            insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='SERVICE_COMPLETED', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='109');
            insert se;
            Test.stopTest();
        }
    } 
    
     @isTest
    private static void MailIn_TestEMEA2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'EMEA', 
                                                                  SubRegion__c='', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
             WorkOrder wo = new WorkOrder();
                wo.assetId = ast.id;
                wo.accountId=acnt.id;
                wo.contactId=co.id;
                wo.caseId=cse.id;
                wo.status='open';
                wo.AdditionalContactId__c=co.id;
                wo.subject='testing Work Order';
                wo.IsDeferralAllowed__c=false;
                wo.Country='NETHERLANDS';
                wo.CountryCode ='NL';
                //wo.State='';
                wo.City='Den Haag';
                wo.PostalCode='2585 GJ';
                wo.Street='Surinamestraat 27';
                wo.DPS_Region__c ='EMEA';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'ServiceStatusUpdate';
                wo.WO_Type__c = 'Break fix';
            
            insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='SERVICE_COMPLETED', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='113');
            insert se;
            Test.stopTest();
        }
    } 
    @isTest
    private static void LaborOnly_TestAP2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Labor Only', Region__c = 'AP', 
                                                                  SubRegion__c='', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            WorkOrder wo = new WorkOrder();
                wo.assetId = ast.id;
                wo.accountId=acnt.id;
                wo.contactId=co.id;
                wo.caseId=cse.id;
                wo.status='Cancellation Request';
                wo.AdditionalContactId__c=co.id;
                wo.subject='testing Work Order';
                wo.IsDeferralAllowed__c=false;
                wo.Labor_Status__c = 'Service Call Closure';
                wo.Parts_Status__c = 'Part Order Complete';
                wo.Service_Type__c = 'Parts Only';
                wo.DLP_Rejected_Cancellation__c = 'Y';
                wo.Country='Australia';
                wo.CountryCode ='AU';
                //wo.State='';
                wo.City='NEW CANBERRA';
                wo.PostalCode='WA 1234';
                wo.Street='240 WANDALOO ESP';
                wo.DPS_Region__c ='AP';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'ServiceCallClosure';
                wo.WO_Type__c = 'Break fix';
              
            insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='SERVICE_COMPLETED', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='109');
            insert se;
            Test.stopTest();
        }
    } 
    
    @isTest
    private static void LaborOnly_TestAP(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Labor Only', Region__c = 'AP', 
                                                                  SubRegion__c='', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            WorkOrder wo = new WorkOrder();
                wo.assetId = ast.id;
                wo.accountId=acnt.id;
                wo.contactId=co.id;
                wo.caseId=cse.id;
                wo.status='Cancellation Request';
                wo.AdditionalContactId__c=co.id;
                wo.subject='testing Work Order';
                wo.IsDeferralAllowed__c=false;
                wo.Labor_Status__c = 'Service Call Closure';
                wo.Parts_Status__c = 'Part Order Complete';
                wo.Service_Type__c = 'Labor Only';
                wo.DLP_Rejected_Cancellation__c = 'Y';
                wo.Country='Australia';
                wo.CountryCode ='AU';
                //wo.State='';
                wo.City='NEW CANBERRA';
                wo.PostalCode='WA 1234';
                wo.Street='240 WANDALOO ESP';
                wo.DPS_Region__c ='AP';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'ServiceCallClosure';
                wo.WO_Type__c = 'Break fix';
              
            insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='SERVICE_COMPLETED', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='109');
            insert se;
            Test.stopTest();
        }
    } 

    @isTest
    private static void LaborOnly_TestAP3(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Labor Only', Region__c = 'AP', 
                                                                  SubRegion__c='', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            WorkOrder wo = new WorkOrder();
                wo.assetId = ast.id;
                wo.accountId=acnt.id;
                wo.contactId=co.id;
                wo.caseId=cse.id;
                wo.status='Cancellation Request';
                wo.AdditionalContactId__c=co.id;
                wo.subject='testing Work Order';
                wo.IsDeferralAllowed__c=false;
                wo.Labor_Status__c = 'Service Call Closure';
                //wo.Parts_Status__c = 'Work In Progress';
                wo.Service_Type__c = 'Parts Only';
                wo.DLP_Rejected_Cancellation__c = 'Y';
                wo.Country='Australia';
                wo.CountryCode ='AU';
                //wo.State='';
                wo.City='NEW CANBERRA';
                wo.PostalCode='WA 1234';
                wo.Street='240 WANDALOO ESP';
                wo.DPS_Region__c ='AP';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'ServiceCallClosure';
                wo.WO_Type__c = 'Break fix';
              
            insert wo;
            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='SERVICE_COMPLETED', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='109');
            insert se;
            Test.stopTest();
        }
    } 
    
    @isTest
    private static void LaborOnly_TestAP4(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Labor Only', Region__c = 'AP', 
                                                                  SubRegion__c='', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SERVICE_COMPLETED');
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            WorkOrder wo = new WorkOrder();
                wo.assetId = ast.id;
                wo.accountId=acnt.id;
                wo.contactId=co.id;
                wo.caseId=cse.id;
                wo.status='Cancellation Request';
                wo.AdditionalContactId__c=co.id;
                wo.subject='testing Work Order';
                wo.IsDeferralAllowed__c=false;
                wo.Labor_Status__c = 'Service Call Closure';
                //wo.Parts_Status__c = 'Work In Progress';
                wo.Service_Type__c = 'Parts Only';
                wo.DLP_Rejected_Cancellation__c = 'N';
                wo.Country='Australia';
                wo.CountryCode ='AU';
                //wo.State='';
                wo.City='NEW CANBERRA';
                wo.PostalCode='WA 1234';
                wo.Street='240 WANDALOO ESP';
                wo.DPS_Region__c ='AP';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'ServiceCallClosure';
                wo.WO_Type__c = 'Break fix';
              
            insert wo;            
            DispatchServiceEvent__c se = new DispatchServiceEvent__c(Service_Event__c='SERVICE_COMPLETED', 
                                                                     Work_Order__c=wo.id, Event_DateTime__c='2018-09-28 08:00:00'
                                                                     , Reply_Code__c='109');
            insert se;
            Test.stopTest();
        }
    } 
    
}
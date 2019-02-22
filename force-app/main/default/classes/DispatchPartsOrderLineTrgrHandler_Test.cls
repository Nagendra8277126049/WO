/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchPartsOrderLineTrgrHandler_Test
Description:  This test class DispatchPartsOrderLineTrgrHandler - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchPartsOrderLineTrgrHandler_Test {
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
        //u = new User(Alias='auser', Email='adminuser@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='Service Integration Profile'].Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__c='Yes');
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        insert u;
        
        //create a test account
        String uniqueAccntName = 'Test Account'+DateTime.now().getTime();
        acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Name=uniqueAccntName;
        acnt.Industry='Fashion';
        acnt.Type = 'Prospect';
        //acnt.Partner_Name__c='test partner';
        //acnt.Address_Line_1__c='line1';
        //acnt.Region__c='NORTH AMERICA';
        //acnt.Country__c='INDIA';
        //acnt.Address_1__c='address1';
        //acnt.Region_1__c='NORTH AMERICA';
        //acnt.Partner_Email__c='partener@gmail.com';
        //acnt.Partner_Phone_number_Office__c='0699685743';
        //acnt.PM_Name__c='Emp Name';
        //acnt.Partner_Employee_Role__c='Engineering Project Manager';
        //acnt.PM_Email__c='test@gmail.com';
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
                
    }
    
    @isTest
    private static void Initial_test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'BreakFixCancelConfirmation', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='DELIVERED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Cancelled';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='BreakFixCancelConfirmation';
            wo.WO_Type__c = 'Break Fix';
 
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='DELIVERED',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            DispatchPartsOrderLineTriggerHandler.addInstruction(null, 'test instruction');
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void RETURNED_testEMEA(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts Only', Region__c = 'EMEA', 
                                                                  SubRegion__c='', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='RETURNED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
           /* wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts Only';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='EMEA';
            wo.DPS_Sub_Region__c='Europe';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';*/
            WorkOrder wo = new WorkOrder();
                wo.assetId = ast.id;
                wo.accountId=acnt.id;
                wo.contactId=co.id;
                wo.caseId=cse.id;
                wo.status='open';
                wo.AdditionalContactId__c=co.id;
                wo.subject='testing Work Order';
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
                wo.MessageTypeID__c = '';
                wo.WO_Type__c = 'Break fix';
            
            insert wo;
            
            List<WorkOrderLineItem> workorderItemList=DispatchTestSetupData.createworkorderListItem(wo.id,'Info Parts-Hard Drive');
                 workorderItemList[0].PartCommodity__c='SOLID STATE DRIVE';
                 workorderItemList[0].Line_Item_type__c='Info Parts-Hard Drive';
                 workorderItemList[0].Selected_Work_Order__c=wo.id;
            workorderItemList[0].Part_Quantity__c = '10';
            workorderItemList[0].PartDescription__c = 'workorderItemList[0]';
            workorderItemList[0].PartPrice__c='1234.56';
            workorderItemList[0].PartNumber__c = '1234';
                 update workorderItemList[0];
            
            dpLines = new DispatchPartsOrderLine__c(Part__c = workorderItemList[0].id, ExternalId__c = 'xy12345', ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=5,ISP_Description__c='test Description',ISP_Status__c='RETURNED',ISP_Type__c='RETURNED',Work_Order__c=Wo.Id); 
            insert dpLines;
        	dpLines = new DispatchPartsOrderLine__c(Part__c = workorderItemList[0].id, ExternalId__c = 'x123456', ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=5,ISP_Description__c='test Description',ISP_Status__c='RETURNED',ISP_Type__c='RETURNED',Work_Order__c=Wo.Id); 
            insert dpLines;
            
            
            
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void DELIVERED_test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='DELIVERED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts Only';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='DELIVERED',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            dpLines.ISP_Status__c = 'SHIPPED';            
            update dpLines;
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void DELIVERED_test3(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='DELIVERED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts Only';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            dpLines.ISP_Status__c = 'SHIPPED';            
            update dpLines;
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void DELIVERED_testAP(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AP', 
                                                                  SubRegion__c='Singapore', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='DELIVERED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
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
                wo.Service_Type__c = 'Parts Only';
                wo.Country='Australia';
                wo.CountryCode ='AU';
                //wo.State='';
                wo.City='NEW CANBERRA';
                wo.PostalCode='WA 1234';
                wo.Street='240 WANDALOO ESP';
                wo.DPS_Region__c ='AP';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'TradeComplianceUpdate';
                wo.WO_Type__c = 'Break fix';
              
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_New_PPID__c = 'NOT APPLICABLE',ISP_Description__c='test Description',ISP_Status__c='DELIVERED',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            dpLines.ISP_Status__c = 'SHIPPED';            
            update dpLines;
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    
    @isTest
    private static void DELIVERED_testAP1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AP', 
                                                                  SubRegion__c='Singapore', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='DELIVERED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
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
                wo.Labor_Status__c = 'Service Call Closure';
                wo.Parts_Status__c = 'Work In Progress';
                wo.Country='Australia';
                wo.CountryCode ='AU';
                //wo.State='';
                wo.City='NEW CANBERRA';
                wo.PostalCode='WA 1234';
                wo.Street='240 WANDALOO ESP';
                wo.DPS_Region__c ='AP';
                //wo.DPS_Sub_Region__c = 'US';
                wo.MessageTypeID__c = 'TradeComplianceUpdate';
                wo.WO_Type__c = 'Break fix';
              
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Old_PPID__c = 'NOT APPLICABLE',ISP_Description__c='test Description',ISP_Status__c='RETURNED',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            dpLines.ISP_Status__c = 'SHIPPED';            
            update dpLines;
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void DELIVERED_testEMEA(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts Only', Region__c = 'EMEA', 
                                                                  SubRegion__c='', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='DELIVERED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
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
                wo.MessageTypeID__c = '';
                wo.WO_Type__c = 'Break fix';
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='DELIVERED',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            dpLines.ISP_Status__c = 'SHIPPED';            
            update dpLines;
                          
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void DELIVERED_test2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Mail-In', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='DELIVERED');
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = '';
            wo.Parts_Status__c='';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='DELIVERED',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            dpLines.ISP_Status__c = 'SHIPPED';            
            update dpLines;
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    
    
    @isTest
    private static void BACKLOG_test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='BACKLOG');
            
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Acknowledged';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
 
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='BACKLOG',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void INSTOCK_test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='IN STOCK');
            
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Acknowledged';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
 
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='IN STOCK',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    @isTest
    private static void INSTOCKLA_test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='IN STOCK');
            
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Work In Progress';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.CountryCode='AR';
            wo.state='Salta';
            wo.stateCode='';
            wo.MessageTypeID__c='PartsStatusUpdate';
            //wo.WO_Type__c = 'Break Fix';
 
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='IN STOCK',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void SHIPPED_test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SHIPPED');
            
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Acknowledged';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.ShipmentStatus__c='SHIPPED';
            wo.WO_Type__c = 'Break Fix';
 
            
            insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='SHIPPED',Work_Order__c=Wo.Id); 
            insert dpLines;
        
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }
    
    @isTest
    private static void SHIPPEDPARTIAL_test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='Parts and Labor', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='TRN', 
                                                                  ActivityStatus__c='Work In Progress', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Work In Progress', DeliveryStatus__c='SHIPPED');
            
            DispatchPartsOrderTriggerHandler.mockedETMList.add(etmItem);
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts and Labor';
            wo.Labor_Status__c = 'Acknowledged';
            wo.Parts_Status__c='Acknowledged';
            wo.Status='Awaiting Acknowledgement';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsStatusUpdate';
            wo.ShipmentStatus__c='PARTIALLY SHIPPED';
            wo.WO_Type__c = 'Break Fix';
            
            insert wo;
                        
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='SHIPPED',Work_Order__c=Wo.Id); 
            insert dpLines;
            
            

            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    } 
}
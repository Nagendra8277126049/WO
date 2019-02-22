/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchServiceEventTriggerHandler_Test
Description:  This test class for DispatchServiceEventTriggerHandler - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchExceptionTriggerHandler_Test {
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
        insert u;
        
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
    }
    
    @isTest
    private static void ServiceStatusUpdate_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='NA', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='NA', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='Acknowledged', 
                                                                      ProgressEvent__c='Acknowledged');
            
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
            
            DispatchException__c se = new DispatchException__c(ISP_FSD_DLP_Exception_Code__c='CAD', 
                                                                     Work_Order__c=wo.id, ISP_FSD_DLP_Exception_Date_Time__c='2018-09-28 08:00:00'
                                                                     , ISP_FSD_DLP_Exception_Description__c='this is the description');
            insert se;
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void ServiceStatusUpdate_Test1(){
        setupTestData();
        system.runAs(u){
            DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='NA', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'ServiceStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='NA', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='Acknowledged', 
                                                                      ProgressEvent__c='Acknowledged');
            
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
            
            DispatchException__c se = new DispatchException__c(ISP_FSD_DLP_Exception_Code__c='CAD', 
                                                                     Work_Order__c=wo.id, ISP_FSD_DLP_Exception_Date_Time__c='2018-09-28 08:00:00'
                                                                     , ISP_FSD_DLP_Exception_Description__c='this is the description');
            insert se;
            Test.startTest();
                update etmItem;
                update wo;
                update se;
            
            Test.stopTest();
        }
    }
    
    @isTest
    private static void PartsOrderStatusUpdate_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c='NA', Region__c = 'AMERICAS', 
                                                                  SubRegion__c='US', MessageType__c = 'PartsOrderStatusUpdate', 
                                                                  EventCode__c='VS', FileType__c='NA', OperationType__c='NA', 
                                                                  ActivityStatus__c='Closed', LaborStatus__c='Work In Progress', 
                                                                  PartsStatus__c='Closed', DeliveryStatus__c='Acknowledged', 
                                                                      ProgressEvent__c='Acknowledged');
            
            DispatchServiceEventTriggerHandler.mockedETMList.add(etmItem);
            
            insert etmItem;
            
            wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Mail-In';
            wo.Labor_Status__c = 'Work In Progress';
            wo.Parts_Status__c='All Parts Returned';
            wo.Status='Work In Progress';
            wo.DPS_Region__c='AMERICAS';
            wo.DPS_Sub_Region__c='US';
            wo.MessageTypeID__c='PartsOrderStatusUpdate';
            wo.WO_Type__c = 'Break Fix';
            
            Insert wo;
            
            dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='BACKLOG',Work_Order__c=wo.Id); 
            insert dpLines;
            
            DispatchException__c se = new DispatchException__c(ISP_FSD_DLP_Exception_Code__c='FTC', 
                                                                     Work_Order__c=wo.id, ISP_FSD_DLP_Exception_Date_Time__c='2018-09-28 08:00:00'
                                                                     , ISP_FSD_DLP_Exception_Description__c='this is the description');
            insert se;
            
            DispatchExceptionTriggerHandler.performStatusUpdate(null, null);
            Test.stopTest();
        }
    }
}
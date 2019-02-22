/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchServiceLevelHandler_Test
Description:  This class contain the test method for DispatchServiceLevelHandler to validate coverage - story #4916686
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/07/2018     1.0    Rodrigo Carpio       Initial Release
06/11/2018     1.1     Sri Harsha G        DEFECT 5070477
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchServiceLevelHandler_Test {
    
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
    private static List<String> WoIdList;
    
    /* This method creates the test data */
    private static void setupTestData() {
        // Create a unique UserName
        
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        /*u = new User(Alias='auser', Email='adminuser@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__c='Yes');
        //u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        insert u;
		*/
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
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
        
        wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
            wo.Service_Type__c='Parts and Labor';
            wo.StateCode='TX';
            wo.CountryCode='US';
            wo.PostalCode='78664';
        wo.City = 'Austin';
        wo.FSD_DASP_Flag__c = true;
        wo.Region__c = '1';
            wo.Service_Option__c = 'NextDay-8x5';
            wo.DSP__c='UNY'; 
        wo.Deferred__c = 'N';
        wo.Sanbao_FLG__c = 'N';
        wo.DPS_BUID__c = '11';        
        wo.Sanbao_FLG__c = 'Y';
        wo.DPS_Region__c = 'AMERICAS';
        wo.DPS_Sub_Region__c = 'US';
        wo.Dispatch_Country__c  = 'Global except LATAM';
        insert wo;
        
        //create a test Dispatch Default
        dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',
                            PO_Number__c='18458',selected_service_option__c='Available-24x5',OutOfWarranty__c = True, 
                            Service_Configurations__c='XPS Notebooks',SpecialOptions__c='CBBF',Bill_To__c='Customer',
                            Keep_Your_Components__c=True,DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',
                            AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c=True,
                            OrderNumber__c='124563',Work_Order__c=wo.Id, AD_Override__c='CSAT',DPSType__c='test',DefaultDPSType__c='test',
                            CallType__c='test',DefaultCallType__c='test',ServiceLevel__c='test',ServiceHours__c='test',
                            Billable__c='Y',KYHDOption__c=true,OconusDispatch__c='N',PremierCode__c='yy',OutOfHours__c=true,
                            complete_care_option__c=false, GroundShipFlg__c='Y');
        insert dd;
                                       
        WoIdList = new List<String>();
        WoIdList.add(wo.Id);
    }
    
    @isTest
    private static void testGetBestFitDSP(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                GetBestFitDSP__x mockedRequest = new GetBestFitDSP__x(DSP__c = 'Y', ISPDSPScheduleEnabled__c = 'Y', DSPSchedulingURL__c = 'http://test.scheduling.dell.com',CommunicationChannel__c = '123',ResponseCode__c='100');
                DispatchServiceLevelHandler.mockedBestFit.add(mockedRequest);
            
                List<GetBestFitDSP__x> dspStatusList = DispatchServiceLevelHandler.callGetDSPFitService(dd, 'Labor Only', '10x5', 'Next Business Day');
            Test.stopTest();
            System.assertNotEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testGetBestFitDSPNull(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                GetBestFitDSP__x mockedRequest = null;
                DispatchServiceLevelHandler.mockedBestFit.add(mockedRequest);
            
                List<GetBestFitDSP__x> dspStatusList = DispatchServiceLevelHandler.callGetDSPFitService(null, 'Labor Only', '10x5', 'Next Business Day');
            Test.stopTest();
            System.assertEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testgetDPSTypeAndCallTypeNew(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                DPSAndCallType__x mockedRequest = new DPSAndCallType__x(DPSType__c='Test',CallType__c='Type', ResponseCode__c='100',ResponseMessage__c='Sucess');
                DispatchServiceLevelHandler.mockedRequests.add(mockedRequest);
                List<DPSAndCallType__x> dspStatusList = DispatchServiceLevelHandler.getDPSTypeAndCallType(dd, 'Labor Only', '10x5', 'Next Business Day');
            Test.stopTest();
            System.assertNotEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testgetDPSTypeAndCallTypeNewNull(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                DPSAndCallType__x mockedRequest = null;
                DispatchServiceLevelHandler.mockedRequests.add(mockedRequest);
                List<DPSAndCallType__x> dspStatusList = DispatchServiceLevelHandler.getDPSTypeAndCallType(null, 'Labor Only', '10x5', 'Next Business Day');
            Test.stopTest();
            System.assertEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testgetProviderAttributes(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                Asset_Country__mdt mockedMdt = new Asset_Country__mdt(DeveloperName='United States', CountryCode__c='US');
                DispatchServiceLevelHandler.mockedAssetCountry.add(mockedMdt); 
                GetProviderAttributes__x mockedRequest = new GetProviderAttributes__x(ResponseCode__c='100',ResponseMessage__c='Sucess');
                DispatchServiceLevelHandler.mockedGetProviderAttributes.add(mockedRequest);            
                List<GetProviderAttributes__x> dspStatusList = DispatchServiceLevelHandler.getProviderAttributes(dd, 'Labor Only', 'Next Business Day-10x5', 'billToValue', false, false, false, 'serProviderCode');
            
            Test.stopTest();
            System.assertNotEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testgetProviderAttributesNull(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                //GetProviderAttributes__x mockedRequest = null;
                //DispatchServiceLevelHandler.mockedGetProviderAttributes.add(mockedRequest);            
                List<GetProviderAttributes__x> dspStatusList = DispatchServiceLevelHandler.getProviderAttributes(null, 'Labor Only', 'Next Business Day-10x5', 'billToValue', false, false, false, 'serProviderCode');
            Test.stopTest();
            System.assertEquals(dspStatusList, null);
        }
    }
    @isTest
    private static void testGetDPSTypeAndCallType(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                DPSAndCallType__x mockedRequest = new DPSAndCallType__x(DPSType__c='Test',CallType__c='Type',ResponseCode__c='100',ResponseMessage__c='Sucess');
                DispatchServiceLevelHandler.mockedRequests.add(mockedRequest);
                List<DispatchServiceLevelHandler.DPSTypeCallTypeStatus> dspStatusList = DispatchServiceLevelHandler.getDPSTypeAndCallType(WoIdList);
            Test.stopTest();
            System.assertNotEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testGetDPSTypeAndCallType1(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                DPSAndCallType__x mockedRequest = new DPSAndCallType__x(DPSType__c='Test',CallType__c='Type',ResponseCode__c='101',ResponseMessage__c='Sucess');
                DispatchServiceLevelHandler.mockedRequests.add(mockedRequest);
                List<DispatchServiceLevelHandler.DPSTypeCallTypeStatus> dspStatusList = DispatchServiceLevelHandler.getDPSTypeAndCallType(WoIdList);
            Test.stopTest();
            System.assertNotEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testGetDPSTypeAndCallType2(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                List<DispatchServiceLevelHandler.DPSTypeCallTypeStatus> dspStatusList = DispatchServiceLevelHandler.getDPSTypeAndCallType(WoIdList);
            Test.stopTest();
            System.assertNotEquals(dspStatusList, null);
        }
    }
    
    @isTest
    private static void testGetDPSTypeAndCallType_Exception(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                List<DispatchServiceLevelHandler.DPSTypeCallTypeStatus> dspStatusList = DispatchServiceLevelHandler.getDPSTypeAndCallType(null);
            Test.stopTest();
            System.assertEquals(dspStatusList, null);
        }
    }
}
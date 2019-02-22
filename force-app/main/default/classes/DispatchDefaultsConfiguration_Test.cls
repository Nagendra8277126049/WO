/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchDefaultsConfiguration_Test
Description: Test Class for DispatchDefaultsConfiguration Class  - story #4346869 
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/03/2018     1.0    Rodrigo Carpio       Initial Release
04/03/2018     1.0    Harsha Reddy         Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchDefaultsConfiguration_Test 
{
    
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static User u;
    private static Contact co;
    private static WorkOrder wo;
    private static WorkOrder wo1;
    private static DispatchDefaults__c dd;
    private static DispatchInstruction__c dinst;
    private static Product2 prd;
    private static String dInstrcutId;
    private static GetDispatchDefaults__x getDefault;
     
    
    /* This method creates the test data */
    private static void setupTestData() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        //create a test account
        acnt = new Account(Name = 'Test Company', Industry = 'Fashion', Type = 'Customer');
        insert acnt;
        
        //create a new product
        prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
        insert prd;
        
        //create a test asset
        ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,
                        InstallDate = System.Today(),UsageEndDate = System.Today());
        insert ast;
        
        //create a test contact
        co = new Contact(Email = 'testtag@test.com',firstname = 'firstname', 
                         LastName = 'testtag',Accountid = acnt.id);
        insert co;
            
        //create a test case
        cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id, 
                       ContactId=co.Id);
        insert cse;
        
        
        //create a test work Order
        wo = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,
                            AdditionalContactId__c=co.id,subject='test', Service_Option__c = 'NextDay-8x5', City = 'Round Rock', Country='United States', State='Texas', Street='Dell Way123', PostalCode  ='78664' );
        insert wo;
        
        //ceate a test work Order 2
        wo1 = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,City='Hyderabad',
                            Country='India',Region__c='1',PostalCode='786664',AdditionalContactId__c=co.id,CountryCode='IN',
                            subject='testing Work Order', State='Andhra Pradesh', Street='Ring Road');
        insert wo1;
        
        
        //create a test Dispatch Default
        dd= new DispatchDefaults__c(Work_Order__c=wo.id, Service_Options_Picklist_values__c='NextDay-8x5', 
                            PO_Number__c='18458',OutOfWarranty__c = True, 
                            Service_Configurations__c='XPS Notebooks', Service_Type__c='Parts and Labor', selected_service_option__c='Available-24x5', Bill_To__c='Customer',SpecialOptions__c='CBBF',
                            Keep_Your_Components__c=True,DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',
                            AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c=True,
                            OrderNumber__c='124563', AD_Override__c='CSAT', AvailableOptions__c='-' ,
                             Default_Service_Type__c = 'Test Service', ErrorCode__c = '111', WarningMessage__c = 'Warning', Reason_for_the_Damage__c = 'TestReason', Billable__c = 'Y' );
        insert dd;
        
        
        //create dispatch Instruction Record
        dinst = new DispatchInstruction__c(Work_Order__c=wo.id,Instruction__c='Good Service with Care',DSP_Override_Request__c=true);
                                           
        insert dinst;
        
        dInstrcutId = dinst.Id;
        
        
        getDefault = new GetDispatchDefaults__x(AvailableOptions__c = '2 Hour-24x7', BasicEntitlement__c = 'N', Billable__c = 'N', BUID__c = '11', CallType__c = 'testType',
                    CustomSKU__c = 'N', category__c = '', City__c = 'Hyderabad', CompleteCareOption__c = 'Y', Country__c = 'India', CustomerNumber__c = '8987',
                    CustomerPreference__c = 'XYZ', DataRecovery__c = 'N', DefaultCallType__c = 'testType', DefaultDPSType__c = 'Test DPS Type',
                    DefaultDSP__c = 'test dsp', DefaultSKU__c = 'test sku', CustomerRegionId__c = '1', DigitalEntitlements__c = 'Y', DLP__c = 'Test dlp',
                    DPSType__c = 'test type', DSP__c = 'Test', EntitlementId__c = 'EId123455', EntitlementName__c = 'EName', ErrorCode__c = '100000',
                    GroundShipFlg__c = 'test', ISPWarrantyOrderBUID__c = '123', ISPWarrantyOrderNum__c = '122445', KYCOption__c = 'N', KYHDOption__c = 'Y',
                    LaborCountry__c = 'India', LOB__c = '4SV', MaxCapabilityDLP__c = 'Test', MaxCapabilityServiceHours__c = 'Found,24x7,24x7,24x7,10x5,24x7',
                    MaxCapabilityServiceLevel__c = 'Not,2 Hour,4 Hour,Remote Effort', MaxCapabilityServiceSubType__c = 'Not Found,Parts and Labor,Parts and Labor',
                    OconusDispatch__c = 'testDisp', OrderNumber__c = '1223', OutOfHours__c = 'N', OutOfWarranty__c = 'Y', PartsCountry__c = 'India',
                    PostalCode__c = '509199', PPID__c = '12', PremierCode__c = '100', PremierType__c = 'test Type', ProSupport__c = 'N', Region__c = '1',
                    ReverseAgency__c = 'N', ServiceHours__c = '8x5', ServiceLevel__c = 'Next Business Day', ServiceTagId__c = 'CAT2077', ServiceType__c = 'Parts and Labor',
                    SKUNumber__c = '123', State__c = 'TN', UserID__c = '9090', uuid__c = '12', WarningMessage__c = 'Sucessful', WarrantyEndDate__c = '12/07/12',
                    AvailableCoverages__c = '||2 Hour-24x7 ||4 Hour-24x7 ||4 Hour-10x5 ||Remote Effort-24x7');
       }
    
    /* This Method will test - getDispatchDefaults method  */ 
    @isTest
    private static void dispatchDefaultsRecordExists(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.defaultWrapper pWrapper =                                                                      
                              DispatchDefaultsConfiguration.getDispatchDefaults(wo.Id);    
            Test.stopTest();        
            system.assertNotEquals(pWrapper,null);
        }
    }
    
    /* This Method will test - getDispatchDefaults method  */
    @isTest
    private static void dispatchDefaultsRecordNotExists(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.defaultWrapper pWrapper = 
                            DispatchDefaultsConfiguration.getDispatchDefaults(wo1.Id);    
            Test.stopTest();        
            system.assertNotEquals(pWrapper,null);
        }
    }
  
    /* This Method will test - getDispatchDefaults method - Exception  */
    @isTest
    private static void dispatchDefaultsExpn(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.defaultWrapper pWrapper = 
                            DispatchDefaultsConfiguration.getDispatchDefaults(u.Id);    
            Test.stopTest();        
            system.assertEquals(pWrapper,null);
        }
    }
    
    /* This Method will test - getselectOptions method  */
    
    @isTest
    private static void getPicklistOptions(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<String> optionsList = 
                            DispatchDefaultsConfiguration.getselectOptions(acnt.Id.getSObjectType(), 'Industry');
            Test.stopTest();
            system.assertNotEquals(optionsList.size(),0);
        }
    }
    
    /* This Method will test - getselectOptions method  - Exception */
    @isTest
    private static void getPicklistOptionsExcep(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<String> optionsList = 
                            DispatchDefaultsConfiguration.getselectOptions(acnt.Id.getSObjectType(),'Name__c');
            Test.stopTest();
            system.assertEquals(optionsList,null);
        }
    }
    
    /* This Method will test - updateDefaultsRecord method  */
    @isTest
    private static void saveRecordUseCase(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = 
                            DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'Parts and Labor','Remote Effort-24x5','CBBF',
                                                                              'XPS Notebooks',true,true,true,'Customer','12445',servOptionPicklist,
                                                                               'Instructions','dInstrcutId',true,true,'ADOverrideReason',true,true, 'street', '78667', 'Round Rock', 'Texas', 'United States', 'Test','Unisys','UNY',false);

            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    
    @isTest
    private static void saveRecordUseCase_Test2(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        
        
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = 
                            DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'Parts and Labor','Remote Effort-24x5','CBBF',
                                                                              'XPS Notebooks',true,true,true,'Customer','12445',servOptionPicklist,
                                                                               'Instructions','dInstrcutId',true,true,'ADOverrideReason',true,true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
           
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    
    @isTest
    private static void saveRecordUseCase_Test3(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'','Remote Effort-24x5','CBBF',
                                                                              'XPS Notebooks',true,false,true,'Customer','12445',servOptionPicklist,
                                                                       'Instructions','',true,true,'ADOverrideReason',true,true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
             
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    
    @isTest
    private static void saveRecordUseCase_Test4(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'','Remote Effort-24x5','CBBF',
                                                                              'XPS Notebooks',true,true,false,'Customer','12445',servOptionPicklist,
                                                                       'Instructions',dInstrcutId,true,true,'ADOverrideReason',true,true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
             
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    
    
    /* This Method will test - updateDefaultsRecord method  */
    @isTest
    private static void saveRecordUseCase2(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = 
                            DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'Parts and Labor','Best Effort-24x5','CBBF',
                                                                              'XPS Notebooks',True,True,False,'Customer','12445',serviceOptions,
                                                                               'Instructions','',True, true, 'ADOverrideReason', True, true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    
        /* This Method will test - updateDefaultsRecord method  */
    @isTest
    private static void saveRecordUseCase33(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = 
                            DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'Labor Only','Best Effort-24x5','CBBF',
                                                                              'XPS Notebooks',True,True,False,'Customer','12445',serviceOptions,
                                                                               'Instructions','',True, true, 'ADOverrideReason', True, true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    
    /* This Method will test - updateDefaultsRecord method  -  Exception */
    @isTest
    private static void saveRecordException(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = 
                            DispatchDefaultsConfiguration.updateDefaultsRecord(wo.Id,u.Id,'Parts and Labor','Best Effort-24x5','CBBF',
                                                                              'XPS Notebooks',True,True,True,'Customer','12445',serviceOptions,
                                                                               'Instructions',dInstrcutId,False, false, 'ADOverrideReason',True, true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    
    /* This Method will test - getBillToAvailableOptions method  */
    @isTest
    private static void getAvailableOptions(){
        setupTestData();
        system.runAs(u){
            Test.startTest();            
            List<AvailableOptions__x> mockedAvailableOptionsList = new List<AvailableOptions__x>();
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'NextDay-8x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Next 2days-4x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Next Week-8x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Extended-24x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Exclusive-24x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Next 3days-24x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            DispatchDefaultsConfiguration.mockedAvailableOptions.addall(mockedAvailableOptionsList);              
            
            DispatchDefaultsConfiguration.optionsWrapper oWrap = DispatchDefaultsConfiguration.getBillToAvailableOptions(wo.Id,'Y','Parts and Labor','','');
            Test.stopTest();
            system.assertNotEquals(oWrap,null);
        }
    }
    
    /* This Method will test - getBillToAvailableOptions method  - Exception*/
    @isTest
    private static void getAvailableOptionsExcept(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.optionsWrapper oWrap = DispatchDefaultsConfiguration.getBillToAvailableOptions(u.Id,'Y','Parts and Labor','','');
            Test.stopTest();
            system.assertEquals(oWrap,null);
        }
    }
    
    /* This Method will test - getBillToAvailableOptions method  */
    @isTest
    private static void getAvailableOptions_UseCase1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();        
            DispatchDefaultsConfiguration.optionsWrapper oWrap = DispatchDefaultsConfiguration.getBillToAvailableOptions(wo.Id,'Y','Parts and Labor','','');
            Test.stopTest();
            system.assertNotEquals(oWrap,null);
        }
    }
    
    /* This Method will test - getBillToAvailableOptions method  */
    @isTest
    private static void getAvailableOptions_UseCase2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<AvailableOptions__x> mockedAvailableOptionsList = new List<AvailableOptions__x>();
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Available-24x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'NextDay-8x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Next 2days-4x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Next Week-8x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Extended-24x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Exclusive-24x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            mockedAvailableOptionsList.add(new AvailableOptions__x(AvailableOptions__c = 'Next 3days-24x5', ProviderCode__c = '100', DefaultAvailableOptions__c = 'Available-24x5',ResponseCode__c='100',ResponseMessage__c='Sucess'));
            DispatchDefaultsConfiguration.mockedAvailableOptions.addall(mockedAvailableOptionsList);            
            
            DispatchDefaultsConfiguration.optionsWrapper oWrap = DispatchDefaultsConfiguration.getBillToAvailableOptions(wo.Id,'N','Parts and Labor','','');
            Test.stopTest();
            system.assertNotEquals(oWrap,null);
        }
    }
    
    /* This Method will test - getEntitlementSLA method*/
    @isTest
    private static void getEntitlementSLAUseCase(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            GetSLADates__x obj = DispatchDefaultsConfiguration.getEntitlementSLA('1234','Remote Effort-24x7','78660','US','TX');
            Test.stopTest();
            system.assertNotEquals(obj.SLAStartDate__c,null);
        }
    }

    /* This Method will test - getEntitlementSLA method*/
    @isTest
    private static void getEntitlementSLAUseCase1(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            GetSLADates__x obj = DispatchDefaultsConfiguration.getEntitlementSLA('1234','Remote Effort-24x7','78660','USA','TX');
            Test.stopTest();
            system.assertNotEquals(obj,null);
        }
    }
    
    /* This Method will test - updateDispatchDefaults */
    @isTest
    private static void testUpdateDispatchDefaults(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            GetDispatchDefaults__x mockedGetDispatchDefaults =new GetDispatchDefaults__x(AvailableOptions__c = '2 Hour-24x7', BasicEntitlement__c = 'Y', Billable__c = 'Y', BUID__c = '11', CallType__c = 'testType',
                    CustomSKU__c = 'Y', category__c = 'CPS1', City__c = 'Hyderabad', CompleteCareOption__c = 'Y', Country__c = 'India', CustomerNumber__c = '8987',
                    CustomerPreference__c = 'XYZ', DataRecovery__c = 'Y', DefaultCallType__c = 'testType', DefaultDPSType__c = 'Test DPS Type',
                    DefaultDSP__c = 'test dsp', DefaultSKU__c = 'test sku', CustomerRegionId__c = '1', DigitalEntitlements__c = 'Y', DLP__c = 'Test dlp',
                    DPSType__c = 'test type', DSP__c = 'Test', EntitlementId__c = 'EId123455', EntitlementName__c = 'EName', ErrorCode__c = '100000',
                    GroundShipFlg__c = 'test', ISPWarrantyOrderBUID__c = '123', ISPWarrantyOrderNum__c = '122445', KYCOption__c = 'Y', KYHDOption__c = 'Y',
                    LaborCountry__c = 'India', LOB__c = '4SV', MaxCapabilityDLP__c = 'Test', MaxCapabilityServiceHours__c = 'Found,24x7,24x7,24x7,10x5,24x7',
                    MaxCapabilityServiceLevel__c = 'Not,2 Hour,4 Hour,Remote Effort', MaxCapabilityServiceSubType__c = 'Not Found,Parts and Labor,Parts and Labor',
                    OconusDispatch__c = 'testDisp', OrderNumber__c = '1223', OutOfHours__c = 'Y', OutOfWarranty__c = 'Y', PartsCountry__c = 'India',
                    PostalCode__c = '509199', PPID__c = '12', PremierCode__c = '100', PremierType__c = 'test Type', ProSupport__c = 'Y', Region__c = '1',
                    ReverseAgency__c = 'Y', ServiceHours__c = '8x5', ServiceLevel__c = 'Next Business Day', ServiceTagId__c = 'CAT2077', ServiceType__c = 'Parts and Labor',
                    SKUNumber__c = '123', State__c = 'TN', UserID__c = '9090', uuid__c = '12', WarningMessage__c = 'Sucessful', WarrantyEndDate__c = '12/07/12',
                    AvailableCoverages__c = '||2 Hour-24x7 ||4 Hour-24x7 ||4 Hour-10x5 ||Remote Effort-24x7');
            DispatchDefaultsConfiguration.mockedGetDispatchDefaults.add(mockedGetDispatchDefaults);
            DispatchDefaultsConfiguration.defaultWrapper dWrap = DispatchDefaultsConfiguration.updateDispatchDefaults(wo1.Id,dd.Id);
            Test.stopTest();
            system.assertNotEquals(dWrap,null);
        }
    }
    
    /* This Method will test Expection - updateDispatchDefaults */
    @isTest
    private static void testExpectUpdateDispatchDefaults(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.defaultWrapper dWrap =
                DispatchDefaultsConfiguration.updateDispatchDefaults(u.Id,dd.Id);
            Test.stopTest();
            system.assertEquals(dWrap,null);
        }
    }
     
    /* This Method will test - getDispatchDefaut */
    @isTest
    private static void testGetDispatchDefaut(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            GetDispatchDefaults__x mockedGetDispatchDefaults =new GetDispatchDefaults__x(AvailableOptions__c = '2 Hour-24x7', BasicEntitlement__c = 'Y', Billable__c = 'Y', BUID__c = '11', CallType__c = 'testType',
                    CustomSKU__c = 'Y', category__c = 'CPS1', City__c = 'Hyderabad', CompleteCareOption__c = 'Y', Country__c = 'India', CustomerNumber__c = '8987',
                    CustomerPreference__c = 'XYZ', DataRecovery__c = 'Y', DefaultCallType__c = 'testType', DefaultDPSType__c = 'Test DPS Type',
                    DefaultDSP__c = 'test dsp', DefaultSKU__c = 'test sku', CustomerRegionId__c = '1', DigitalEntitlements__c = 'Y', DLP__c = 'Test dlp',
                    DPSType__c = 'test type', DSP__c = 'Test', EntitlementId__c = 'EId123455', EntitlementName__c = 'EName', ErrorCode__c = '100000',
                    GroundShipFlg__c = 'test', ISPWarrantyOrderBUID__c = '123', ISPWarrantyOrderNum__c = '122445', KYCOption__c = 'Y', KYHDOption__c = 'Y',
                    LaborCountry__c = 'India', LOB__c = '4SV', MaxCapabilityDLP__c = 'Test', MaxCapabilityServiceHours__c = 'Found,24x7,24x7,24x7,10x5,24x7',
                    MaxCapabilityServiceLevel__c = 'Not,2 Hour,4 Hour,Remote Effort', MaxCapabilityServiceSubType__c = 'Not Found,Parts and Labor,Parts and Labor',
                    OconusDispatch__c = 'testDisp', OrderNumber__c = '1223', OutOfHours__c = 'Y', OutOfWarranty__c = 'Y', PartsCountry__c = 'India',
                    PostalCode__c = '509199', PPID__c = '12', PremierCode__c = '100', PremierType__c = 'test Type', ProSupport__c = 'Y', Region__c = '1',
                    ReverseAgency__c = 'Y', ServiceHours__c = '8x5', ServiceLevel__c = 'Next Business Day', ServiceTagId__c = 'CAT2077', ServiceType__c = 'Parts and Labor',
                    SKUNumber__c = '123', State__c = 'TN', UserID__c = '9090', uuid__c = '12', WarningMessage__c = 'Sucessful', WarrantyEndDate__c = '12/07/12',
                    AvailableCoverages__c = '||2 Hour-24x7 ||4 Hour-24x7 ||4 Hour-10x5 ||Remote Effort-24x7');
            DispatchDefaultsConfiguration.mockedGetDispatchDefaults.add(mockedGetDispatchDefaults);
            GetDispatchDefaults__x dispDefault = DispatchDefaultsConfiguration.getDispatchDefaut(wo1);
            Test.stopTest();
            system.assertNotEquals(dispDefault,null);
        }
    }
    
    /* This Method will test excpection - getDispatchDefaut */
    @isTest
    private static void testExpGetDispatchDefaut(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            GetDispatchDefaults__x dispDefault =
                DispatchDefaultsConfiguration.getDispatchDefaut(null);
            Test.stopTest();
            system.assertEquals(dispDefault,null);
        }
    }
    
    private static void testGetDispatchDefaut_UseCase1(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
                GetDispatchDefaults__x dispDefault = DispatchDefaultsConfiguration.getDispatchDefaut(wo1);
            Test.stopTest();
            system.assertEquals(dispDefault,null);
        }
    }
    
    /* This Method will test - updateDispatchDefaults */
    @isTest
    private static void testUpdateDispDefaults(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            string result =
                DispatchDefaultsConfiguration.updateDispatchDefaults(getDefault,wo.Id,dd.Id);
            Test.stopTest();
            system.assertNotEquals(result,null);
        }
    }
    
    /* This Method will test exception - updateDispatchDefaults */
    @isTest
    private static void testExpUpdateDispDefaults(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            string result = DispatchDefaultsConfiguration.updateDispatchDefaults(getDefault,wo1.Id,u.Id);
            //string result1 = DispatchDefaultsConfiguration.updateDispatchDefaults(null,null,null);
            Test.stopTest();
            system.assertEquals(result,null);
           // system.assertEquals(result,null);
        }
    }
    
    /* This Method will test exception - createDispatchDefaults */
    @isTest
    private static void testExpCreateDispatchDefaults(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            string result =
                DispatchDefaultsConfiguration.createDispatchDefaults(getDefault,u.Id,'test');
            Test.stopTest();
            system.assertEquals(result,null);
        }
    }
    
    @isTest
    private static void testExpCreateDispatchDefaults_Test2(){
        setupTestData();        
        system.runAs(u){
            Test.startTest();
            
            Id result = DispatchDefaultsConfiguration.createDispatchDefaults(getDefault,wo.Id,'test');
            Test.stopTest();
            system.assertNotEquals(result,null);
        }
    }
    
    /*@isTest
    private static void testgetProviderAttributes(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<GetProviderAttributes__x> getproviderattr =
            DispatchServiceLevelHandler.getProviderAttributes(dd,'Parts and Labor','NextDay-8x5','12445', true, true, true, '12345');
           // DispatchDefaultsConfiguration.serviceTypeInstructions('Parts and Labor', wo.Id, '1');
            DispatchDefaultsConfiguration.checkPreference('12345');
            DispatchDefaultsConfiguration.performCallToDelta(wo.Id);
            DispatchDefaultsConfiguration.validateSLADates(dd);
            DispatchDefaultsConfiguration.getServiceTypesBasedBillTo(dd.Id,'TestFlag');
            DispatchDefaultsConfiguration.getServiceTypeByOrder('TestServiceType','N');
            Test.stopTest();
            system.assertEquals(getproviderattr,null);
        }
    }*/
  
    @isTest
    private static void testgetDispatchCategoryOptions(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                List<String> categoryOptionsList = DispatchDefaultsConfiguration.getDispatchCategoryOptions(dd,wo.Id, getDefault);
            Test.stopTest();
            system.assertNotEquals(categoryOptionsList,null);
        }
    }
    @isTest
    private static void validateSLADates_UnitTest(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<DispatchDefaults__c> ddList = [select Work_Order__r.WorkOrderNumber,Work_Order__r.PostalCode, Work_Order__r.Country,Work_Order__r.Service_Option__c, Work_Order__r.DeltaTimezone__c from DispatchDefaults__c where id = :dd.id];
            if(ddList != null && !ddList.isEmpty()){
                ddList[0].Work_Order__r.Service_Option__c = 'test';
                update ddList[0].Work_Order__r;
                 DispatchDefaultsConfiguration.validateSLADates(ddList[0]);
            }
           
            Test.stopTest();
            
        }
    }
    
    @isTest
    private static void createDeltaDispatch_UnitTest(){
        setupTestData();
        DispatchDefaultsConfiguration.createDeltaDispatch(new List<string>{});
        DispatchDefaultsConfiguration.validateSLADates(null);
        DispatchDefaultsConfiguration.performCallToDelta(dd.id);
        DispatchDefaultsConfiguration.getServiceTypesBasedBillTo(dd.id,'TestBillTo');
        DispatchDefaultsConfiguration.getServiceTypeByOrder('TestServiceType','N','US','Customer');
        DispatchDefaultsConfiguration.optionsWrapper wap = new DispatchDefaultsConfiguration.optionsWrapper();
        wap  = DispatchDefaultsConfiguration.getWOdata(wo.id,'Parts Only', 'Available-24x5','unisys');
        wap.categoryOptions = null;
        getDefault.CompleteCareOption__c = 'true';
        getDefault.KYHDOption__c = 'Y';
        getDefault.KYCOption__c = 'N';
        DispatchDefaultsConfiguration.createDispatchDefaults(getDefault,u.Id,'test');
        GetSLADates__x obj = DispatchDefaultsConfiguration.getEntitlementSLA('1234',null,'78660','US','TX');   
    }
    
    @isTest
    private static void createDeltaDispatch_UnitTestExcep(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchDefaultsConfiguration.createDeltaDispatch(null);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testgetProviderAttributes_Test2(){
        setupTestData();
        system.runAs(u){
            //dd.Work_Order__r.CountryCode = 'US';
            DispatchServiceLevelHandler.getProviderAttributes(dd,'Parts and Labor','NextDay-8x5','', true, true, true, '12345');
            DispatchDefaultsConfiguration.checkPreference('12345');
            DispatchDefaultsConfiguration.checkPreference(null);
            DispatchDefaultsConfiguration.getDispatchCategoryOptions(null,null,new GetDispatchDefaults__x());
        }
    }
    
    @isTest
    private static void performCallToDelta_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            GetWorkOrderDetails__x mockedGetWorkOrderDetails = new GetWorkOrderDetails__x(ResponseCode__c = '100', ResponseMessage__c = 'Successful',
                                                                                          WorkOrderId__c=wo.id, WorkOrderNumber__c=wo.WorkOrderNumber);
            DispatchDefaultsConfiguration.mockedGetWorkOrderDetails.add(mockedGetWorkOrderDetails);
            DispatchDefaultsConfiguration.performCallToDelta(wo.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void performCallToDeltaExcep_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.performCallToDelta(null);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void performCallToDelta_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.performCallToDelta(wo.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void getServiceTypeByOrder_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<String> serviceTypeList = DispatchDefaultsConfiguration.getServiceTypeByOrder('Parts and Labor','Y','US','Customer');
            List<String> serviceTypeBillToList = DispatchDefaultsConfiguration.getServiceTypeByOrder('Parts and Labor','Y','US','Customer');
            List<String> serviceTypeListExcp1 = DispatchDefaultsConfiguration.getServiceTypeByOrder('Parts and Labor','Y','US','Customer');
            List<String> serviceTypeListExcp2 = DispatchDefaultsConfiguration.getServiceTypeByOrder('Parts and Labor','Y','US','Customer');
            Test.stopTest();
            system.assert(!serviceTypeList.isEmpty());
            system.assert(!serviceTypeBillToList.isEmpty());
           // system.assert(!serviceTypeListExcp1.isEmpty());
           // system.assert(serviceTypeListExcp2.isEmpty());
        }
    }
    
    @isTest
    private static void fetchCountryAndStateMap_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.fetchCountryAndStateMap();         
            Test.stopTest();
        }
    }
    
    @isTest
    private static void queryPartsAndDelete_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.queryPartsAndDelete(wo.id);         
            Test.stopTest();
        }
    }
    
    @isTest
    private static void calculateServiceOption_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
             DispatchDefaultsConfiguration.optionsWrapper opwrapper =  DispatchDefaultsConfiguration.calculateServiceOption(wo.id);         
            Test.stopTest();
        }
    }
    @isTest
    private static void testgetDispatchCategoryOptionsException(){
    
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<String> categoryOptionsList = DispatchDefaultsConfiguration.getDispatchCategoryOptions(dd, '0WOK0000000071a', getDefault);
            Test.stopTest();
        }
    }
    @isTest
    private static void getServiceTypeByOrderException(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<String> serviceTypeList = DispatchDefaultsConfiguration.getServiceTypeByOrder(null,null,null,null);
            Test.stopTest();
        }
    }
    @isTest
    private static void queryPartsAndDeleteWithPartsData(){
    
        setupTestData();
        system.runAs(u){
            Test.startTest();
            WorkOrderLineItem  woli = new WorkOrderLineItem();
            woli.Selected_By_user__c = true;
            woli.WorkOrderId = wo.Id;
            insert woli;
            DispatchDefaultsConfiguration.queryPartsAndDelete(wo.Id);         
            Test.stopTest();
        }
    }
    @isTest
    private static void queryPartsAndDeleteException(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchDefaultsConfiguration.partsList = null;
            DispatchDefaultsConfiguration.queryPartsAndDelete(null);         
            Test.stopTest();
        }
    }
    @isTest
    private static void checkHardDrivePartsWithPartsRecords(){
    
        setupTestData();
        system.runAs(u){
            Test.startTest();
            
            wo.Out_of_Warranty__c = false;
            update wo;
            WorkOrderLineItem  woli = new WorkOrderLineItem();
            woli.Selected_By_user__c = true;
            woli.WorkOrderId = wo.Id;
            woli.PartCommodity__c = 'HARD DRIVE';
            insert woli;
            DispatchDefaultsConfiguration.checkHardDriveParts(wo.Id,true);         
            Test.stopTest();
        }
    }  
    @isTest
    private static void testgetProviderAttributesException(){
        setupTestData();
        system.runAs(u){
            DispatchDefaultsConfiguration.checkPreference(null);    
        }
    }
    @isTest
    private static void calculateServiceOptionWithIncorrectSO(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            dd.BasicEntitlement__c = true;
            dd.SpecialOptions__c = 'test SO';
            update dd;
            DispatchDefaultsConfiguration.optionsWrapper opwrapper =  DispatchDefaultsConfiguration.calculateServiceOption(wo.id);         
            Test.stopTest();
        }
    }
    @isTest
    private static void saveRecordUseCaseWithdSPOverideValueTrue(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'','Remote Effort-24x5','CBBF',
                                                                              'XPS Notebooks',true,true,false,'Customer','12445',servOptionPicklist,
                                                                       'Instructions',dInstrcutId,true,true,'CSAT',true,true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','UNISYS','UNY',false);
             
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    @isTest
    private static void saveRecordUseCaseWithCorrectADReason(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'','Remote Effort-24x5','CBBF',
                                                                              'XPS Notebooks',true,true,true,'Customer','12445',servOptionPicklist,
                                                                       'Instructions',dInstrcutId,true,true,'CSAT',true,true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
             
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    @isTest
    private static void saveRecordUseCaseWithNoInstruction(){
        List<String> serviceOptions = new List<String>();
        serviceOptions.add('Available-24x5');
        serviceOptions.add('NextDay-8x5');
        serviceOptions.add('Extended-24x7');
        
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list<string> servOptionPicklist = new list<string>();
            servOptionPicklist.add('serviceOptions');
            DispatchDefaultsConfiguration.updateWrapper uWrap = DispatchDefaultsConfiguration.updateDefaultsRecord(wo1.Id,dd.Id,'','Remote Effort-24x5','CBBF',
                                                                              'XPS Notebooks',true,true,true,'Customer','12445',servOptionPicklist,
                                                                       'Instructions',null,true,true,'CSAT',true,true, 'street', '78667', 'Round Rock', 'Texas', 'United States','Test','Unisys','UNY',false);
             
            Test.stopTest();
            system.assertNotEquals(uWrap,null);
        }
    }
    /*
    @isTest
    private static void callGetDSPFitServiceException(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<GetBestFitDSP__x> getDSPRecordList = DispatchDefaultsConfiguration.callGetDSPFitService(null,null,null,null); 
            Test.stopTest();
            system.assertEquals(getDSPRecordList,null);
        }
    }
    */
    @isTest
    private static void checkPreferenceTest(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchDefaultsConfiguration.mokedCheckPreference.add(new CheckPreference__x(WF_DSP__c='IBM', DSPSelectionMethod__c='Dynamic', Dispatch_Number__c='385013883',ResponseCode__c='100'));
                List<CheckPreference__x> checkPreferenceException = DispatchDefaultsConfiguration.checkPreference('12338'); 
            Test.stopTest();
            system.assertNotEquals(checkPreferenceException,null);
        }
    }
    
    @isTest
    private static void checkPreferenceTest_Excep(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchDefaultsConfiguration.mokedCheckPreference.add(new CheckPreference__x(WF_DSP__c='IBM', DSPSelectionMethod__c='Dynamic', Dispatch_Number__c='385013883'));
                List<CheckPreference__x> checkPreferenceException = DispatchDefaultsConfiguration.checkPreference('12338'); 
            Test.stopTest();
            system.assertEquals(checkPreferenceException,null);
        }
    }
    
    @isTest
    private static void getProviderAttributesTest_Excep(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchDefaultsConfiguration.mockedGetProviderAttributes.add(new GetProviderAttributes__x(ISPDSPScheduleEnabled__c='Y',ServiceProviderCode__c='IBM',DSPSchedulingURL__c='https://localhost.com/customer/scheduling', CommunicationChannel__c=''));
                List<GetProviderAttributes__x> getPreference = DispatchServiceLevelHandler.getProviderAttributes(dd,'Parts and Labor','NextDay-8x5','12445', true, true, true, '12345');
            Test.stopTest();
            system.assertEquals(getPreference,null);
        }
    }
    
    @isTest
    private static void getProviderAttributesTest(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DispatchDefaultsConfiguration.mockedGetProviderAttributes.add(new GetProviderAttributes__x(ISPDSPScheduleEnabled__c='Y',ServiceProviderCode__c='IBM',DSPSchedulingURL__c='https://localhost.com/customer/scheduling', CommunicationChannel__c='',ResponseCode__c='100'));
                List<GetProviderAttributes__x> getPreference = DispatchServiceLevelHandler.getProviderAttributes(dd,'Parts and Labor','NextDay-8x5','12445', true, true, true, '12345');
            Test.stopTest();
            system.assertEquals(getPreference,null);
        }
    }
}
/* -----------------------------------------------------------------------------------------------------------------------
    Name:         DispatchDefaultDetailsController_Test
    Description:  Test class for DispatchDefaultDetailsController
    Date          Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    05/22/2018     1.0     Bikram Bebarta      Initial Release
    06/31/2018     1.0     Harsha Reddy        Updated Code based on Code Review Defect
    -------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchDefaultDetailsController_Test{ 
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static User u;
    private static Contact co;
    private static WorkOrder wo;
    private static WorkOrderLineItem woLi;
    private static Product2 prd;
    private static DispatchPartsOrderLine__c dpLines;
    private static DispatchPartsOrderLine__c dpLines1;
    private static DispatchDefaults__c dd;
    private static DispatchInstruction__c dinst; 
    
    /* This method creates the test data */
    private static void setupTestData() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        //create a test account
        acnt = new Account(Name = 'Test Company', Industry = 'Fashion',Type = 'Customer');
        insert acnt;   
        
        //create a new product
        prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
        insert prd;
        
        //create a test asset
        ast = new Asset(Name='Test Asset',Status='Installed',AccountId=acnt.Id,Product2Id=prd.Id,InstallDate = System.Today(),UsageEndDate = System.Today());
        insert ast;
        
        //create a test contact
        co = new Contact(Email='testtag@test.com',firstname='firstname',Primary_Phone__c='123456789',LastName='testtag',Accountid=acnt.id);
        insert co;
            
        //create a test case
        cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id,ContactId=co.Id);
        insert cse;
        
        //ceate a test work Order 2
        wo = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,City='Round Rock',Country='United States',Region__c='1',PostalCode='78664',
                            AdditionalContactId__c=co.id,CountryCode='US',subject='testing Work Order', state='Texas', Street='Dell Way123', ISPDispatchPPID__c = '12345');
        insert wo;
        
        woLi = new WorkOrderLineItem(WorkOrderId=wo.Id,assetId=ast.id,Part_Quantity__c='10',Selected_Work_Order__c=wo.Id,PartNumber__c='1234',PartPrice__c='1234',PartType__c='type',
                                    PartCommodity__c='HARD DRIVE',Selected_By_user__c=true,DefectiveComponent__c='test');
        insert woLi;
        
        dpLines = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c='available',Work_Order__c=wo.Id); 
        insert dpLines;
        
        dpLines1 = new DispatchPartsOrderLine__c(ISP_Part__c='HARD DRIVE|1234',ISP_Qty__c=10,ISP_Description__c='test Description',ISP_Status__c ='Returned', ISP_Return_Date__c = System.Today()+ 10,Work_Order__c=wo.Id); 
        insert dpLines1;
        
        //create a test Dispatch Default
        dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',PO_Number__c='18458',selected_service_option__c='Available-24x5',
                                    OutOfWarranty__c=True,Service_Configurations__c='XPS Notebooks',SpecialOptions__c='CBBF',Bill_To__c='Customer',Keep_Your_Components__c=True,
                                    DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||',
                                    CompleteCareOption__c=True,OrderNumber__c='124563',Work_Order__c=wo.id);
        insert dd;
        
        //create dispatch Instruction Record
        dinst = new DispatchInstruction__c(Work_Order__c=wo.id,Instruction__c='Good Service with Care',DSP_Override_Request__c=true);
        insert dinst;
        
    }
    
    @isTest
    private static void UnitTest(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
           // string recId = '';
               // recId = DispatchDefaultDetailsController.getDispatchDefaultRecord(wo.Id);
               DispatchDefaultDetailsController.getDispatchDefaultRecord(wo.Id);
               DispatchDefaultDetailsController.getServiceEvents(wo.Id);
            Test.stopTest();        
            //system.assertNotEquals(dispatchDefWo,null);
        }
    }   
    
    @isTest
    private static void UnitTest1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
             list<DispatchDefaultDetailsController.SelectedPartsWrapper> partsWrapper;
                partsWrapper = DispatchDefaultDetailsController.getSelectedParts(wo.Id);
        Test.stopTest();
            system.assertNotEquals(partsWrapper,null);          
        }
    }
    
    @isTest
    private static void UnitTest2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
               DispatchDefaultDetailsController.getDispatchDefaultRecord(wo.Id);
               DispatchDefaultDetailsController.getServiceEvents(wo.Id);
               DispatchDefaultDetailsController.UpdateDispatchAttributes(wo.Id,'DLPTest','1234','colDLPTest','12345','TestDPS','TestCallType');
               DispatchDefaultDetailsController.getProviderValues('US','Partner');
               DispatchDefaultDetailsController.updateDisprecord(wo.Id,true);
            Test.stopTest();        
        }
    }
    
    @isTest
    private static void UnitTest3(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                list<DispatchDefaultDetailsController.ReturnedPartsWrapper> partsReturnedWrapper;
                //partsReturnedWrapper = DispatchDefaultDetailsController.getReturnedParts(wo.Id);
        Test.stopTest();
            system.assertEquals(partsReturnedWrapper,null);          
        }
    }
}
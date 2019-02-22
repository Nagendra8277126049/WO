/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchDefaultHelper_Test
Description:  This class contain the test method for DispatchDefaultHelper to validate coverage
-----------  -------  -----------------  ------------------------------------------------------------------------------*/


@isTest
private class DispatchDefaultHelper_Test
{
    
    private static ServiceCloudEntitlmentDetails__x sce1;
    private static ServiceCloudEntitlmentDetails__x sce2;
    private static ServiceCloudEntitlmentDetails__x sce3;
    private static ServiceCloudEntitlmentDetails__x sce4;
    private static ServiceCloudEntitlmentDetails__x sce5;
    private static List<ServiceCloudEntitlmentDetails__x> sceList;
    private static AssetComponentResponse__x assetComp1;
    private static AssetComponentResponse__x assetComp2;
    private static List<AssetComponentResponse__x> assetCompList;
    private static WorkOrder_CFI__c woFI;
    
    private static testMethod void DispatchDefaultHelperTest() { 
           test.startTest();
          //List<Account> accListList=DispatchTestSetupData.createAccountList();
          account acc = new account(name='Test Account');
          insert acc;
          //List<Account> accListList = SRVS_CreateTestDataFactory.createMultipleAccountRecords(100);
          
          //List<Asset>   assetList= DispatchTestSetupData.createAssetList(accListList[0].id);
          asset ast = new Asset(AccountId=acc.id,name='Test Asset');
          insert ast;
          //List<Contact>  conlist= DispatchTestSetupData.createContactList(accListList[0].id);
          contact cont = new contact(FirstName='Dispatch Contact',lastName='TestLastName',Verified__c=true,Country_Code__c='USA & Canada (1)',Primary_Phone__c='1231231231',Email='testContact@test.com',AccountId=acc.id);
          insert cont;
          //List<Case>  caselist = DispatchTestSetupData.createCaseList(accListList[0].id,assetList[0].id,cont.id);
          case cs = new case(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,status='In Progress',Priority= 'Low',Service_Tag__c='test Tag');
          insert cs;
          //List<WorkOrder> workOrderList= DispatchTestSetupData.createworkorderList(accListList[0].id,assetList[0].id,cont.id,caselist[0].id);
          workOrder wo1 = new workOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true,status = 'Service Complete',Entitlement_Details__c='', Region__c='1',PostalCode='786664',AdditionalContactId__c=cont.Id,CountryCode='US',
                            subject='testing Work Order', statecode='TX', Street= 'Ring Road', City= 'Round Rock' );
          insert wo1;
          
          
          
          DispatchDefaults__c DD = new DispatchDefaults__c(Default_Service_Option__c='test', selected_service_option__c = 'test', Country__c = 'US', Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo1.id);
          DispatchDefaults__c DD1 = new DispatchDefaults__c(Default_Service_Option__c='test',selected_service_option__c = 'test', Country__c = 'US', Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo1.id);
          List<DispatchDefaults__c> DDLst = new list<DispatchDefaults__c>();
          DDLst.add(DD);
          DDLst.add(DD1);
          insert DDLst;
          
          List<Id> DdIds = new List<Id>();
          for(DispatchDefaults__c ddid : DDLst  ){
              DdIds.add(ddid.Id);
          }
          
          Customer_Reminder__c CR = new Customer_Reminder__c(name='Accidental Damage Coverage',Type__c='KYHD',Reminder__c='The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.',Work_Order__c = wo1.Id);
          insert CR;
          Customer_Reminder__c CR1 = new Customer_Reminder__c(name='Test',Reminder__c='Test Reminder', Link__c = 'https://test.cr.com',Work_Order__c = wo1.Id);
          insert CR1;
          Customer_Reminder__c CR2 = new Customer_Reminder__c(name='Accidental Damage Coverage',Type__c='KYC',Reminder__c='The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.',Work_Order__c = wo1.Id);
          insert CR2;  
          workOrderLineItem woli = new workOrderLineItem(WorkOrderId = wo1.Id, Line_Item_Type__c='Info Parts-Hard Drive');
          insert woli;
          DispatchInstruction__c dIns = new DispatchInstruction__c(Work_Order__c = wo1.Id,Is_Type_CompleteCareOption__c=true);
          insert dIns;
          /*WorkOrder workorder1=[select id from WorkOrder Limit 1];
          EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = EntitlementDashboardController.getEntDetails(workorder1.Id, firstPage, pageSize);*/
          
          sce1 = new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='Accidental Damage',Status__c='Active', ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), Name__c='Accidental Damage',OrderNumber__c='ORD1234', PageKey__c = '1', ResponseCode__c='100',ResponseMessage__c='MSG1234', ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10', UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'), CreationDate__c = DateTime.parse('05/22/2022 11:46 AM'));

          sce2 = new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='Keep Your Hard Drive',Status__c='Active', ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), Name__c='Keep Your Hard Drive',OrderNumber__c='ORD1234', PageKey__c = '1', ResponseCode__c='100',ResponseMessage__c='MSG1234',  ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'), CreationDate__c = DateTime.parse('05/22/2022 11:46 AM'));

          sce3 = new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='Data Recovery',Status__c='Active', ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), Name__c='Data Recovery',OrderNumber__c='ORD1234', PageKey__c = '1',ResponseCode__c='100',ResponseMessage__c='MSG1234', ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'),CreationDate__c = DateTime.parse('05/22/2022 11:46 AM'));
          
          sce4 = new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='Active', ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), Name__c='Data Destruction',OrderNumber__c='ORD1234', PageKey__c = '1', ResponseCode__c='100',ResponseMessage__c='MSG1234',ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'), CreationDate__c = DateTime.parse('05/22/2022 11:46 AM'));
          
          sce5 = new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='Active', ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), Name__c='Keep Your Component',OrderNumber__c='ORD1234', PageKey__c = '1', ResponseCode__c='100',ResponseMessage__c='MSG1234',ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'), CreationDate__c = DateTime.parse('05/22/2022 11:46 AM'));
          
            sceList = new List<ServiceCloudEntitlmentDetails__x>();
            sceList.add(sce1);
            sceList.add(sce2);
            sceList.add(sce3);
            sceList.add(sce4);
            sceList.add(sce5);
            
           Database.insertAsync(sceList);
           DispatchDefaultHelper.addEntitlementDetails(sceList,wo1.Id); 
           DDLst[0].Complete_Care_Option__c = false;
           update DDLst[0];
           DispatchDefaultHelper.deleteCustomerReminders(DdIds);  
           test.stopTest();
          
   }
   
    
   private static testMethod void DispatchDefaultHelperTest1() {
         test.startTest();
         account acc = new account(name='Test Account');
         insert acc;
         
         asset ast = new Asset(AccountId=acc.id,name='Test Asset');
         insert ast;
         
         contact cont = new contact(FirstName='Dispatch Contact',lastName='TestLastName',Verified__c=true,Country_Code__c='USA & Canada (1)',Primary_Phone__c='1231231231',Email='testContact@test.com',AccountId=acc.id);
         insert cont;
         
         case cs = new case(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,status='In Progress',Priority= 'Low',Service_Tag__c='test Tag');
         insert cs;
         
         WorkOrder wo2 = new WorkOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true, status = 'Service Complete');
         
         
          sce1 = new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='Active', ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), Name__c='Data Destruction',OrderNumber__c='ORD1234', PageKey__c = '1', ResponseCode__c='100',ResponseMessage__c='MSG1234',ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'), CreationDate__c = DateTime.parse('05/22/2022 11:46 AM'));
          
          sce2 = new ServiceCloudEntitlmentDetails__x(BasisType__c='BType1234',EntitlementId__c='ENT1234',Status__c='Active', ExpiryDate__c=DateTime.parse('05/22/2022 11:46 AM'), Name__c='Keep Your Component',OrderNumber__c='ORD1234', PageKey__c = '1', ResponseCode__c='100',ResponseMessage__c='MSG1234',ServiceTag__c='STAG1234', LastPage__c = 'false', PageSize__c = '10',UserId__c='USR1234',StartDate__c=DateTime.parse('05/22/2012 11:46 AM'), CreationDate__c = DateTime.parse('05/22/2022 11:46 AM'));
         
        sceList = new List<ServiceCloudEntitlmentDetails__x>();
        sceList.add(sce1);
        sceList.add(sce2);
        Database.insertAsync(sceList);
        DispatchDefaultHelper.addEntitlementDetails(sceList,wo2.Id);
        DispatchDefaultHelper.ADdispatchValidation(null); //Megha: added this to cover catch scenaio written in this method
        test.stopTest();
     }
     
   
     private static testMethod void DispatchDefaultHelperTest2(){
         test.startTest();
         account acc = new account(name='Test Account');
         insert acc;
         
         asset ast = new Asset(AccountId=acc.id,name='Test Asset');
         insert ast;
         
         contact cont = new contact(FirstName='Dispatch Contact',lastName='TestLastName',Verified__c=true,Country_Code__c='USA & Canada (1)',Primary_Phone__c='1231231231',Email='testContact@test.com',AccountId=acc.id);
         insert cont;
         
         case cs = new case(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,status='In Progress',Priority= 'Low',Service_Tag__c='test Tag');
         insert cs;
         
         WorkOrder wo3 =  new WorkOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,CFINumber__c = '1234',CFINumCheck__c = true, Out_of_Warranty__c = true, AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true, status = 'Service Complete', City = 'Round Rock', State = 'Texas', Country = 'United States', Street = 'Dell Way', PostalCode = '78556', Service_Option__c = 'Test');
         WorkOrder wo4 =  new WorkOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,CFINumber__c = '1234',CFINumCheck__c = true, Out_of_Warranty__c = true, AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true, status = 'Service Complete', City = 'Round Rock', State = 'Texas', Country = 'United States', Street = 'Dell Way', PostalCode = '78556', Service_Option__c = 'Test');
         List<WorkOrder> woList = new List<WorkOrder>();
         woList.add(wo3);
         woList.add(wo4);
         
         insert woList;
         
          DispatchDefaults__c DD = new DispatchDefaults__c(Default_Service_Option__c='test',AD_Coverage_Flag__c = true, CompleteCareOption__c = true,Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo3.id);
          DispatchDefaults__c DD1 = new DispatchDefaults__c(Default_Service_Option__c='test',AD_Coverage_Flag__c = true, CompleteCareOption__c = true,Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo3.id);
          List<DispatchDefaults__c> DDLst = new list<DispatchDefaults__c>();
          DDLst.add(DD);
          DDLst.add(DD1);
          insert DDLst;
          
          Customer_Reminder__c CR = new Customer_Reminder__c(name='Accidental Damage Coverage',Reminder__c='The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.',Work_Order__c = wo3.Id, Type__c = 'Accidental Damage');
          insert CR;
          
         set<Id> woIds = new set<Id>();
         for(WorkOrder woid : woList ){
            woIds.add(woid.Id);
         }
         
         List<Id> woListId = new List<Id>();
         for(WorkOrder woid : woList ){
            woListId.add(woid.Id);
         }
         
         assetComp1 = new AssetComponentResponse__x (ResponseCode__c = '100', serviceTag__c = 'Test');  
         assetComp2 = new AssetComponentResponse__x (ResponseCode__c = '100', serviceTag__c = 'Test'); 
         assetCompList = new List<AssetComponentResponse__x >();
         assetCompList.add(assetComp1);
         assetCompList.add(assetComp2);
         
         Database.InsertAsync(assetCompList);
         
         
         WorkOrder_CFI__c woFI= new WorkOrder_CFI__c(Name = 'Test');
         insert woFI;
         
        // DispatchDefaultHelper.InsertCustomerReminders(woIds);
         DispatchDefaultHelper.populateCFINumCheckOnWO(woIds);
         DispatchDefaultHelper.callAssetComponents(woListId);
         test.stopTest();
     }    
     
      private static testMethod void DispatchDefaultHelperTest4(){
         test.startTest();
         account acc = new account(name='Test Account');
         insert acc;
         
         asset ast = new Asset(AccountId=acc.id,name='Test Asset');
         insert ast;
         
         contact cont = new contact(FirstName='Dispatch Contact',lastName='TestLastName',Verified__c=true,Country_Code__c='USA & Canada (1)',Primary_Phone__c='1231231231',Email='testContact@test.com',AccountId=acc.id);
         insert cont;
         
         case cs = new case(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,status='In Progress',Priority= 'Low',Service_Tag__c='test Tag');
         insert cs;
         
         workOrder wo1 = new workOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true,status = 'Service Complete',Entitlement_Details__c='', Region__c='1',PostalCode='786664',AdditionalContactId__c=cont.Id,CountryCode='US',
                            subject='testing Work Order', statecode='TX', Street= 'Ring Road', City= 'Round Rock' );
          insert wo1;
         
         WorkOrder wo3 =  new WorkOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,CFINumber__c = '1234',CFINumCheck__c = true, Out_of_Warranty__c = true, AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true, status = 'Service Complete', City = 'Round Rock', State = 'Texas', Country = 'United States', Street = 'Dell Way', PostalCode = '78556', Service_Option__c = 'Test');
         WorkOrder wo4 =  new WorkOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,CFINumber__c = '1234',CFINumCheck__c = true, Out_of_Warranty__c = true, AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true, status = 'Service Complete', City = 'Round Rock', State = 'Texas', Country = 'United States', Street = 'Dell Way', PostalCode = '78556', Service_Option__c = 'Test');
         List<WorkOrder> woList = new List<WorkOrder>();
         woList.add(wo3);
         woList.add(wo4);
         
         insert woList;
         
         
         
          DispatchDefaults__c DD = new DispatchDefaults__c(Default_Service_Option__c='test',AD_Coverage_Flag__c = true, CompleteCareOption__c = true,Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo3.id);
          DispatchDefaults__c DD1 = new DispatchDefaults__c(Default_Service_Option__c='test',AD_Coverage_Flag__c = true, CompleteCareOption__c = true,Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo3.id );
          List<DispatchDefaults__c> DDLst = new list<DispatchDefaults__c>();
          DDLst.add(DD);
          DDLst.add(DD1);
          insert DDLst;
          
          Customer_Reminder__c CR = new Customer_Reminder__c(name='Accidental Damage Coverage',Reminder__c='The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.',Work_Order__c = wo1.Id, Type__c = 'Accidental Damage');
          insert CR;
          
         set<Id> woIds = new set<Id>();
         for(WorkOrder woid : woList ){
            woIds.add(woid.Id);
         }
        
         
         DispatchDefaultHelper.InsertCustomerReminders(woIds);
        test.stopTest();
     }    



    private static testMethod void DispatchDefaultHelperTest3(){
         test.startTest();
         account acc = new account(name='Test Account');
         insert acc;
         
         asset ast = new Asset(AccountId=acc.id,name='Test Asset');
         insert ast;
         
         contact cont = new contact(FirstName='Dispatch Contact',lastName='TestLastName',Verified__c=true,Country_Code__c='USA & Canada (1)',Primary_Phone__c='1231231231',Email='testContact@test.com',AccountId=acc.id);
         insert cont;
         
         case cs = new case(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,status='In Progress',Priority= 'Low',Service_Tag__c='test Tag');
         insert cs;
         
         WorkOrder wo3 =  new WorkOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true, status = 'Service Complete', City = 'Round Rock', State = 'Texas', Country = 'United States', Street = 'Dell Way', PostalCode = '78556');
         WorkOrder wo4 =  new WorkOrder(AccountId=acc.id,AssetId=ast.id,ContactId=cont.id,AddressBUID__c='3696',CaseId=cs.id,Complete_Care_Option__c=true, status = 'Service Complete', City = 'Round Rock', State = 'Texas', Country = 'United States', Street = 'Dell Way', PostalCode = '78556');
         List<WorkOrder> woList = new List<WorkOrder>();
         woList.add(wo3);
         woList.add(wo4);
         
         insert woList;
         
          DispatchDefaults__c DD = new DispatchDefaults__c(Default_Service_Option__c='test',AD_Coverage_Flag__c = true, CompleteCareOption__c = true,Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo3.id);
          DispatchDefaults__c DD1 = new DispatchDefaults__c(Default_Service_Option__c='test',AD_Coverage_Flag__c = true, CompleteCareOption__c = true,Complete_Care_Option__c=true,Service_Type__c='Parts Only',Service_Configurations__c='AppAssure',ServiceTagId__c='Y203G24',Work_Order__c=wo3.id);
          List<DispatchDefaults__c> DDLst = new list<DispatchDefaults__c>();
          DDLst.add(DD);
          DDLst.add(DD1);
          insert DDLst;
          
          Customer_Reminder__c CR = new Customer_Reminder__c(name='Accidental Damage Coverage',Reminder__c='The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.',Work_Order__c = wo3.Id, Type__c = 'Accidental Damage');
          insert CR;
          
         set<Id> woIds = new set<Id>();
         for(WorkOrder woid : woList ){
            woIds.add(woid.Id);
         }
         
         List<Id> woListId = new List<Id>();
         for(WorkOrder woid : woList ){
            woListId.add(woid.Id);
         }
         
         DispatchDefaultHelper.InsertCustomerReminders(null);
         DispatchDefaultHelper.populateCFINumCheckOnWO(null);
         DispatchDefaultHelper.callAssetComponents(null);
         DispatchDefaultHelper.deleteCustomerReminders(null);
         test.stopTest();
     }   
}
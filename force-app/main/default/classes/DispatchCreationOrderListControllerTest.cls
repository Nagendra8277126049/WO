@isTest
public class DispatchCreationOrderListControllerTest {
    @isTest static void testGetOrderItems() {
        
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today(), pse__Account__c = a.Id);
        insert project;
        
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.pse__Project__c = project.Id;
        insert pt;
        
        //pse__Project_Task__c pt = new pse__Project_Task__c();
        //pt.pse__Project__c = 'a352a0000005HsTAAU';
        //insert pt;
        
        WorkOrder wo = new WorkOrder();
        wo.Status = 'FF - New';
        //wo.RecordTypeId = Id.valueOf('0122a0000004RvsAAE');
        wo.Project_Task__c = pt.Id;
        
        insert wo;
        
        Order o = new Order();
        o.OrderNumber__c = '123456';
        o.AccountId = a.Id;
        o.EffectiveDate = Date.newInstance(2019, 2, 7);
        o.Status = 'Draft';
        o.Project__c = pt.pse__Project__c;
        insert o;
        
        Asset ast = new Asset();
        ast.Order_Number__c = o.OrderNumber__c;
        ast.Order_Tie_Number__c = 1;
        ast.Name = 'AssetName';
        insert ast;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'FF - New';
        woli.WorkOrderId = wo.Id;
        woli.AssetId = ast.Id;
        insert woli;
        
        
        //OrderListResponse response = new OrderListResponse();
        //DispatchCreationFromOrderListProvider provider = new DispatchCreationFromOrderListProvider();
        
        //DispatchCreationFromOrderListController controller = new DispatchCreationFromOrderListController();
        
        //OrderListResponse response = DispatchCreationFromOrderListController.GetOrderItems(wo.Id);
       
		
		//act
		Test.startTest();
		DispatchCreationFromOrderListController.GetOrderItems(wo.Id);
		Test.stopTest();
        
        //System.assert(response.Assets.lenght > 0);     
    }
    
    @isTest static void testGetOrderStatus() {
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today(), pse__Account__c = a.Id);
        insert project;
        
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.pse__Project__c = project.Id;
        insert pt;
        
        //pse__Project_Task__c pt = new pse__Project_Task__c();
        //pt.pse__Project__c = 'a352a0000005HsTAAU';
        //insert pt;
            
        WorkOrder wo = new WorkOrder();
        wo.Status = 'FF - New';
        wo.Project_Task__c = pt.Id;
        insert wo;
        
        Order o = new Order();
        o.OrderNumber__c = '123456';
        o.AccountId = a.Id;
        o.EffectiveDate = Date.newInstance(2019, 2, 7);
        o.Status = 'Draft';
        o.Project__c = pt.pse__Project__c;
        insert o;
        
        Asset ast = new Asset();
        ast.Order_Number__c = o.OrderNumber__c;
        ast.Order_Tie_Number__c = 1;
        ast.Name = 'AssetName';
        insert ast;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'FF - New';
        woli.WorkOrderId = wo.Id;
        woli.AssetId = ast.Id;
        insert woli;
        
        Test.startTest();
        DispatchCreationFromOrderListController.GetWorkOrderStatus(wo.Id);
        Test.stopTest();
    }
    
    @isTest static void testSetWorkOrderLineItems() {
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today(), pse__Account__c = a.Id);
        insert project;
        
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.pse__Project__c = project.Id;
        insert pt;
            
        WorkOrder wo = new WorkOrder();
        wo.Status = 'FF - New';
        wo.Project_Task__c = pt.Id;
        insert wo;
        
        Order o = new Order();
        o.OrderNumber__c = '123456';
        o.AccountId = a.Id;
        o.EffectiveDate = Date.newInstance(2019, 2, 7);
        o.Status = 'Draft';
        o.Project__c = pt.pse__Project__c;
        insert o;
        
        Asset ast = new Asset();
        ast.Order_Number__c = o.OrderNumber__c;
        ast.Order_Tie_Number__c = 1;
        ast.Name = 'AssetName';
        insert ast;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'FF - New';
        woli.WorkOrderId = wo.Id;
        woli.AssetId = ast.Id;
        insert woli;
        
        String assets = ast.Id;
        
        Test.setMock(HttpCalloutMock.class, new DeltaCalloutMock());
        Test.startTest();
        DispatchCreationFromOrderListController.SetWorkOrderLineItems(wo.Id, assets);
        Test.stopTest();
    }
    
    @isTest static void testCallWebService() {
        String assetName = 'AssetName';
        String woli = 'WorkOrderLineItem';
        Test.startTest();
        DispatchCreationFromOrderListController.CallWebService(assetName,woli);
        Test.stopTest();
    }
}
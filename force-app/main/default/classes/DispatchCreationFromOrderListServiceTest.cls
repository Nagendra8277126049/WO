@isTest
public class DispatchCreationFromOrderListServiceTest {
    
    @isTest 
    static void createDeltaDispatchTest() {
        //arrange
        // - account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        // - project
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today(), pse__Account__c=a.Id);
        insert project;
        
        // - project task
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.pse__Project__c = project.Id;
        insert pt;
        
        // - order
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
        
        // - work order
        WorkOrder wo = new WorkOrder();
        wo.Status = 'FF - New';
        wo.Project_Task__c = pt.Id;
        insert wo;
        
        // - work order line item
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'FF - New';
        woli.WorkOrderId = wo.Id;
        woli.AssetId = ast.Id;
        insert woli;
        
        Project_Task_SKU_Effort_Mapping_Entry__c projMapEntry = new Project_Task_SKU_Effort_Mapping_Entry__c();
        projMapEntry.Project_Task__c = wo.Project_Task__c;
        insert projMapEntry;
        
        /* Start SKU Effort and other objects 
        pse__Project_Phase__c projectPhase = new pse__Project_Phase__c();
        projectPhase.pse__Description__c = 'Description';
        projectPhase.pse__Project__c = project.Id;
        projectPhase.Name = 'Test';
        insert projectPhase;
        
        SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c();
        skuEffortMap.Description__c = 'Asset';
        skuEffortMap.SKU_Number__c = '123456';
        insert skuEffortMap;
        
        SKU_Effort_Map_Entry__c skuEffortMapEntry = new SKU_Effort_Map_Entry__c();
        skuEffortMapEntry.project__c = project.Id;
        skuEffortMapEntry.Phase__c = 'Execute';
        skuEffortMapEntry.Estimated_Hours__c = 3;
        skuEffortMapEntry.SKU_Effort_Map__c = skuEffortMap.Id;
        insert skuEffortMapEntry;
        */
        
        List<Id> workOrderLineItemIds = new List<Id>();
        workOrderLineItemIds.add(woli.Id);
        
        //act
        Test.setMock(HttpCalloutMock.class, new DeltaCalloutMock());
        Test.startTest();
        DispatchCreationFromOrderListService.createDeltaDispatch(workOrderLineItemIds, wo.Id);
        Test.stopTest();

        //assert  
     }
}
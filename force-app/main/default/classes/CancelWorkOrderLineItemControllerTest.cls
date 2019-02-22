@isTest()
public class CancelWorkOrderLineItemControllerTest {
	@isTest()
    static void cancelWorkOrderLineItemsTest() {
        //arrange
        // project
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today());
        insert project;
        
		// work order
        WorkOrder workOrder = new WorkOrder(Status='FF - Work In Progress', Project__c=project.Id);
        insert workOrder;
		
        // asset
        Asset asset = new Asset(Name='Asset Test', Order_Number__c='43215678', Order_BUID__c='11');
        insert asset;
        
		// work order line item
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(WorkOrderId=workOrder.Id, DPS_Number__c='1234', AssetId=asset.Id, Status='FF - Submitted');
        insert workOrderLineItem;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(workOrder);
		
		//controller
		CancelWorkOrderLineItemController controller = new CancelWorkOrderLineItemController(standardController);
		controller.workOrder = workOrder;
		
		
		//act
		Test.setMock(HttpCalloutMock.class, new DeltaCalloutMock());
		Test.startTest();
		PageReference result = controller.cancelWorkOrderLineItems();
		Test.stopTest();
        
		//assert
		System.assertNotEquals(null, result);
    }
    
    @isTest()
    static void shouldNotCancelWorkOrderLineItemsInvalidStatusTest() {
        //arrange
        // project
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today());
        insert project;
        
		// work order
        WorkOrder workOrder = new WorkOrder(Status='FF - New', Project__c=project.Id);
        insert workOrder;
		
        // asset
        Asset asset = new Asset(Name='Asset Test', Order_Number__c='43215678', Order_BUID__c='11');
        insert asset;
        
		// work order line item
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(WorkOrderId=workOrder.Id, DPS_Number__c='1234', AssetId=asset.Id, Status='FF - New');
        insert workOrderLineItem;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(workOrder);
		
		//controller
		CancelWorkOrderLineItemController controller = new CancelWorkOrderLineItemController(standardController);
		controller.workOrder = workOrder;
		
		
		//act
		Test.setMock(HttpCalloutMock.class, new DeltaCalloutMock());
		Test.startTest();
		PageReference result = controller.cancelWorkOrderLineItems();
		Test.stopTest();
        
		//assert
		System.assertEquals(null, result);
    }
    
    @isTest()
    static void shouldNotCancelWorkOrderLineItemsMissingDPSNumberTest() {
        //arrange
        // project
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today());
        insert project;
        
		// work order
        WorkOrder workOrder = new WorkOrder(Status='FF - Working In Progress', Project__c=project.Id);
        insert workOrder;
		
        // asset
        Asset asset = new Asset(Name='Asset Test', Order_Number__c='43215678', Order_BUID__c='11');
        insert asset;
        
		// work order line item
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(WorkOrderId=workOrder.Id, AssetId=asset.Id, Status='FF - Submitted');
        insert workOrderLineItem;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(workOrder);
		
		//controller
		CancelWorkOrderLineItemController controller = new CancelWorkOrderLineItemController(standardController);
		controller.workOrder = workOrder;
		
		
		//act
		Test.setMock(HttpCalloutMock.class, new DeltaCalloutMock());
		Test.startTest();
		PageReference result = controller.cancelWorkOrderLineItems();
		Test.stopTest();
        
		//assert
		System.assertEquals(null, result);
    }
}
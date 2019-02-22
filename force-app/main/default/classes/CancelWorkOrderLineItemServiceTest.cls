@isTest()
public class CancelWorkOrderLineItemServiceTest {
    
   static Order createOrder() {
        Account account = new Account();
        account.Name = 'Create order test';
        insert(account);
        Order order = new Order();
        order.OrderNumber__c = '43215678';
        order.EffectiveDate = Date.valueOf('2018-07-17');
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'IP';
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.OCI_Order_Type__c = 'US Order';
        
        return order;   
    }
    

    @isTest()
    static void cancelDispatchTest() {
        //arrange
        // project
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today());
        insert project;
        
        // work order
        WorkOrder workOrder = new WorkOrder(Status='FF-New', Project__c=project.Id);
        insert workOrder;
        
        // asset
        Asset asset = new Asset(Name='Asset Test', Order_Number__c='43215678', Order_BUID__c='11');
        insert asset;
        
        // work order line item
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(WorkOrderId=workOrder.Id, DPS_Number__c='1234', AssetId=asset.Id, Status='FF-New');
        insert workOrderLineItem;
        
        // order
        Order order = createOrder();
        order.Project__c=project.Id;
        insert order;
        
        //act
        Test.setMock(HttpCalloutMock.class, new DeltaCalloutMock());
        Test.startTest();
        CancelWorkOrderLineItemService.cancelDeltaDispatch(workOrder.Id);
        Test.stopTest();
        
        //assert 
        WorkOrder resultWO = [SELECT Status FROM WorkOrder WHERE id =: workOrder.Id];
        
        System.assertEquals(resultWO.Status, 'FF - Cancellation Request');        
    }
    
}
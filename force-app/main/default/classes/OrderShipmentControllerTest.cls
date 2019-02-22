@isTest
private class OrderShipmentControllerTest {  
    static Order createOrder()
    {
        Account account = new Account();
        account.Name = 'Create Order Test';
        insert(account);
        Order order = new Order();
        order.OrderNumber__c = '12345';
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'IP';
        order.Pricebook2Id = Test.getStandardPricebookId();
        return order;
    }  
    
	@isTest
    static void getShipmentDetailsForOrder_Should_Return_ShipmentDetails(){
        Order order = createOrder();
        insert(order);
        
        Test.startTest();
        
        OrderShipmentController.mockedOrderShipments.add(new OrderShipment__x(
            OrderNumber__c = order.OrderNumber__c,
            CurrencyIsoCode = 'USD'
        ));
            
        OrderShipment__x details = OrderShipmentController.getShipmentDetailsForOrder(order.Id);
            
        Test.stopTest();
        
        System.assert(details != null);
    	System.assertEquals(order.OrderNumber__c, details.OrderNumber__c);
    }
    
    @isTest
    static void getShipmentItemsDetailsForOrder_Should_Return_ShipmentItems(){
        Order order = createOrder();
        insert(order);
        
        Test.startTest();
        
        ShipmentItem__x mockedShipItem = new ShipmentItem__x(
        	OrderNumber__c = order.OrderNumber__c,
            ServiceTag__c = 'SVCTAG123'
        );
        
        OrderShipmentController.mockedShipmentItems.add(mockedShipItem);
                    
        List<ShipmentItem__x> details = OrderShipmentController.getShipmentItemsDetailsForOrder(order.Id);
            
        Test.stopTest();
        
        System.assert(details.size() > 0);
    }
    
    @isTest
    static void getShipmentDetailsForOrder_Should_Return_Null() {
        Order order = createOrder();
        insert(order);

        Test.startTest();
        
        OrderShipment__x details = OrderShipmentController.getShipmentDetailsForOrder(order.Id);
        
        Test.stopTest();
        
        System.assertEquals(null, details);
    }
        
}
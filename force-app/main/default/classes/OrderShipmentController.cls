public class OrderShipmentController {
   	@TestVisible private static List<OrderShipment__x> mockedOrderShipments = new List<OrderShipment__x>();
    @TestVisible private static List<ShipmentItem__x> mockedShipmentItems = new List<ShipmentItem__x>();
    
	@AuraEnabled
    public static OrderShipment__x getShipmentDetailsForOrder(string orderId)
    {        
        Order order = [SELECT OrderNumber__c, BUID__c FROM Order WHERE Id =: orderId];
                
        List<OrderShipment__x> orderShipments = (mockedOrderShipments.size() > 0) ? mockedOrderShipments : 
        								[SELECT CarrierId__c, PostalCode__c, ActualShipDate__c, BoxQuantity__c, StatusDescription__c, TargetDeliveryDate__c, ShipToName__c,
                                          ShipTo__c, Address1__c, Address2__c, City__c, State__c, Country__c FROM OrderShipment__x WHERE OrderNumber__c =: order.OrderNumber__c and BusinessUnitId__c =: order.BUID__c LIMIT 1];
                                                  
		if(orderShipments.size() <= 0)
			return null;
                                              
        return orderShipments[0];
    }
    
    @AuraEnabled
    public static List<ShipmentItem__x> getShipmentItemsDetailsForOrder(string orderId)
    {       
        Order order = [SELECT OrderNumber__c, BUID__c FROM Order WHERE Id =: orderId];
                
        List<ShipmentItem__x> shipmentItems = (mockedShipmentItems.size() > 0) ? mockedShipmentItems : [SELECT SourceBoxId__c, Boxweight__c, ServiceTag__c FROM ShipmentItem__x WHERE OrderNumber__c =: order.OrderNumber__c and BusinessUnitId__c =: order.BUID__c];
                           
        return shipmentItems;
    }
}
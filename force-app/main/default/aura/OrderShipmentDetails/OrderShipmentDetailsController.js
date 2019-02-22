({
	init : function(component) {
        var detailsAction = component.get("c.getShipmentDetailsForOrder");
        var itemsAction = component.get("c.getShipmentItemsDetailsForOrder");
        var orderId = component.get("v.recordId");
               
        detailsAction.setParams({
            orderId: orderId
        });
         itemsAction.setParams({
            orderId: orderId
        });
        
        detailsAction.setCallback(this, function(a){
            if(a.getState() === "SUCCESS"){
                var shipmentDetails = a.getReturnValue();
                
                component.set("v.shipmentDetails", shipmentDetails);
            }
        });
        
        itemsAction.setCallback(this, function(a){
            if(a.getState() === "SUCCESS"){
                var shipmentItems = a.getReturnValue();
                
                component.set("v.shipmentItems", shipmentItems);
            }
        });
                
        $A.enqueueAction(detailsAction);
        $A.enqueueAction(itemsAction);
	},
    setOrderStatus: function(component){
        var order = component.get("v.order");
        var shouldShowShipment = order.Status == 'MN' || order.Status == 'TG' || order.Status == 'CD' || order.Status == 'IN' || order.Status == 'CL';
              
        component.set("v.shouldShowShipment", shouldShowShipment);
    }
})
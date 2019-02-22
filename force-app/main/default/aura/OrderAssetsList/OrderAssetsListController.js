({
	init : function(component) {
          
        // fetching assets list from apex controller
        var action = component.get("c.getAssetsFromOrder");
        
        var orderId = component.get("v.recordId");
        
        action.setParams({
            orderId: orderId
        });
        
        action.setCallback(this, function(a){
            if(a.getState() === "SUCCESS"){
                var assets = a.getReturnValue();
                
                component.set("v.assets", assets);
            }
        });
        
        $A.enqueueAction(action);
	}
    
})
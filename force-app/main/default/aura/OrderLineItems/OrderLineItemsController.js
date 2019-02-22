({
    doInit: function(component, event, helper) {
        try{
            var page = component.get("v.page") || 1;
        	helper.getOrderLineItem(component, page);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
        }
    },
 	
    openSPMD: function(component, event, helper) {
        try{
            var partNumber = event.target.name;
            helper.openURL(component, partNumber);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
        }
    },
    
    nextPage:function(component,event,helper){
        try{ 
    	  	var direction = event.getSource().get("v.label"); 
            helper.buttonLogic(component, direction);
        }catch(Err){
           	helper.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
        }
    },
    previousPage:function(component,event,helper){
        try{
      		var direction = event.getSource().get("v.label");
      		helper.buttonLogic(component, direction);
        }catch(Err){
           	//console.log(Err);
            helper.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
        }
    }
})
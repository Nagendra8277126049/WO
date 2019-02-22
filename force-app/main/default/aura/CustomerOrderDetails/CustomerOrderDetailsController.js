({
    doInit: function(component, event, helper) {
        try{
        	var page = component.get("v.page") || 1;
        	helper.getOrders(component,page);
       	}catch(Err){
           	//console.log(Err);
            helper.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
        }
    },
    nextPage:function(component,event,helper){
        try{ 
    	  	var direction = event.getSource().get("v.label"); 
            helper.buttonLogic(component, direction);
        }catch(Err){
           	//console.log(Err);
           	helper.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
        }
    },
    previousPage:function(component,event,helper){
        try{
      		var direction = event.getSource().get("v.label");
      		helper.buttonLogic(component, direction);
        }catch(Err){
           	//console.log(Err);
            helper.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
        }
    }
})
({
    doInit: function(component, event, helper) { 
        try{
        	var idx = component.get("v.recordId");
            if (idx != null)
        		helper.getOrderDetail(component, idx);
        }catch(Err){
           	//console.log(Err);
            helper.showToast(component,'Error', $A.get("$Label.c.OrderDetailsErrorMessage"), "Error");
        }
    },
    /*
    handleClick: function (component, event, helper) {
        try{
            var navEvt = $A.get("e.force:navigateToSObject");
            if (navEvt != null) {
                navEvt.setParams({
                    "recordId": component.get("v.recordId")
                });
                navEvt.fire();
            }
        }catch(Err){
           	//console.log(Err);
			helper.showToast(component,'Error', $A.get("$Label.c.OrderDetailsErrorMessage"), "Error");
        }
    } 
    */
})
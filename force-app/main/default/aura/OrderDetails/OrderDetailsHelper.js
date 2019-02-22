({
	getOrderDetail : function(component, idx) {
        try{
            var action = component.get("c.getDetail");
            component.set("v.Spinner", true);
            action.setParams({
                "assetRowID": idx
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {	
                    var result = response.getReturnValue();
                
                    if (result!=null && result!= undefined){
                    	component.set("v.OrderDetail", result); 
                    }
                    else{
                        component.set("v.OrderDetail", null);
                        this.showToast(component,'Error', $A.get("$Label.c.OrderDetailsErrorMessage"), "Error");
                    }
                    
                }
                else if (status === "INCOMPLETE") {
	                //console.log("No response from server or client is offline.");
                    this.showToast(component,'Error', $A.get("$Label.c.OrderDetailsErrorMessage"), "Error");
                    // Show offline error
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " + errors[0].message);
                            this.showToast(component,'Error', $A.get("$Label.c.OrderDetailsErrorMessage"), "Error");
                        }
                    } else {
                        //console.log("Unknown error");
                        this.showToast(component,'Error', $A.get("$Label.c.OrderDetailsErrorMessage"), "Error");
                    }
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
  	    }catch(Err){
           	//console.log(Err);
            this.showToast(component,'Error', $A.get("$Label.c.OrderDetailsErrorMessage"), "Error");
        }
    },
    
    showToast : function(component, title, message, type) {
       try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message, 
                "type": type,
                "mode": "pester",
                "duration": "3000"
            });
            toastEvent.fire();
       }catch(Err){
           console.log(Err);
       }
    },  
})
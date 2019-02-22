({
    getOrders: function(component,page){
        try{
            var recordID = component.get("v.recordId");
            var pageSize = component.get("v.pageSize");
            var action = component.get("c.getOrders");
            component.set("v.Spinner", true);
            action.setParams({
                "recordID" : recordID,
                "PageKey" : page,
                "PageSize" : pageSize,       
            });
            action.setCallback(this,function(response){
                var state = response.getState();            
                if(state=="SUCCESS"){
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined ){   
                        
                        if(result.serviceCode == true){
                            // set the component attributes value with wrapper class properties.   
                            component.set("v.orders", result.custOrder);
                            component.set("v.page", result.page);
                            component.set("v.next",result.next);
                            component.set("v.previous",result.previous);         
                        }
                        
                        else if (result.serviceCode == false){
                            component.set ("v.errorMessage", result.serviceResponse);
                            var error = component.get("v.errorMessage");
                            this.showToast(component,'Order Details', error, "Warning");
                        }
                    }
                    else{
                        component.set("v.orders", null);
        	            component.set("v.page", null);
            	        component.set("v.next", false);
                	    component.set("v.previous", false);
                        this.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
                    }
                }
                
                else if (status === "INCOMPLETE") {
                        //console.log("No response from server or client is offline.");
                        this.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
                }
                
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " + errors[0].message);
                            this.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
                        }
                    } else {
                        //console.log("Unknown error");
                        this.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
                    }
                }
                component.set("v.Spinner", false);
                component.set("v.alerts", true);
            });        
            $A.enqueueAction(action);
        }catch(Err){
           	//console.log(Err);
            this.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
        }
    },
    
    buttonLogic: function(component, direction){
        try{
	        var page = component.get("v.page") || 1; 
    	  	page = direction === "Previous" ? (page - 1) : (page + 1);  
      		this.getOrders(component, page);
        }catch(Err){
            //console.log(Err);
            this.showToast(component,'Error', $A.get("$Label.c.CustomerOrderDetailErrorMessage"), "Error");
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
    }
})
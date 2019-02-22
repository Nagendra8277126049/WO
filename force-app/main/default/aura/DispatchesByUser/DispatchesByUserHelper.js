({
    getUserDispatchList : function(component,page) {
		try{ 
            var action = component.get("c.getUserSRDispatches"); 	
            var pageSize = $A.get("$Label.c.DispatchByUserPageSize");
            action.setParams({
				"PageKey" : page,
                "PageSize" : pageSize  
            });
            action.setCallback(this, function(response) {
                var state = response.getState();  
                
                if(state=="SUCCESS"){
                    var result = response.getReturnValue();
                    if (result!=null || result!=undefined){
                        component.set("v.dispatchList", result.rltdDispatch);
                        component.set("v.page", result.page);
                        component.set("v.next", result.next);
                        component.set("v.previous", result.previous);
                    }
                    else{
                        component.set("v.dispatchList", null);
						component.set("v.page", 0);
						component.set("v.next", false);
                	    component.set("v.previous", false);
                        this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
                    }
                }
                
                else if (status === "INCOMPLETE") {
                        //console.log("No response from server or client is offline.");
                        this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
                }
                
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " + errors[0].message);
                            this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
                        }
                    } else {
                        //console.log("Unknown error");
                        this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
                    }
                }
                this.turnOffSpinner(component, event);
            });
            $A.enqueueAction(action);
        }catch(Err){
           	//console.log(Err);
            this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
            this.turnOffSpinner(component, event);
        }
	},
	buttonLogic: function(component, direction){
        try{
	        var page = component.get("v.page") || 1; 
    	  	page = direction === "Previous" ? (page - 1) : (page + 1);  
      		this.getUserDispatchList(component, page);
            this.turnOnSpinner(component, event);
        }catch(Err){
            //console.log(Err);
            this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
        }
    },
    
	turnOffSpinner: function (component, event) {
        try{
            var spinner = component.find("mySpinner");
        	$A.util.toggleClass(spinner, "slds-hide");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
        }
    },
    
    turnOnSpinner: function (component,event) {
        try{
    		var spinner = component.find("mySpinner");
    		$A.util.toggleClass(spinner, "slds-show");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
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
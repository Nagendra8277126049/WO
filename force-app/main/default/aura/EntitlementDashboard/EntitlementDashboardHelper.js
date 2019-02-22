({
    getResponse: function(component, recID) {   
        try{
            var action = component.get("c.getEntitlements");
            component.set("v.Spinner", true);
            action.setParams({
                recordId: recID
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {	
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined){
	                    component.set("v.entitlementList", response.getReturnValue());
                    }
                    else{
                        component.set("v.entitlementList", null);
                    }
                }
                else if (status === "INCOMPLETE") {
                     this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                           this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
                        }
                    } else {
                        this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
                    }
                }
                
                component.set("v.Spinner", false);
                component.set("v.alerts", true);
                
            });
            $A.enqueueAction(action);
        }catch(Err){
			this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },


    openWindow : function(component, event, helper) {
        try{
		    var evt = $A.get("e.force:navigateToComponent");
    		evt.setParams({
        		componentDef : "c:EntitlementDetails",
                componentAttributes: {
                	recId : component.get("v.recordId")
        		}
    		});
    		evt.fire();
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
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
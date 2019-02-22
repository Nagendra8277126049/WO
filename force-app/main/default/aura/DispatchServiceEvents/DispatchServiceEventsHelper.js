({
	getServiceEvents: function(component) {
        try {
            // Record Id
            var recId = component.get("v.recordId");
            var action = component.get("c.getServiceEvents");
            action.setParams({
                workOrderId: recId
            });
            action.setCallback(this, function(response) {                
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //response from Apex Controller
                    if (!$A.util.isUndefinedOrNull(result)) {
                        component.set("v.ServiceEvents", result);
                    } 
                } else {
                    this.showToast(component,'ERROR',"Error occured in loading service events.","Error");
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component,'ERROR',"Error occured in loading service events.","Error");
        }
    }, 
    getAllServiceEvents : function(component) {
        try {
            /*
            var evt = $A.get("e.force:navigateToComponent");
            if (evt != null && evt !=undefined) {
                var workOrderId = component.get("v.recordId"); 
                if (workOrderId != null && workOrderId!=undefined) {
                    evt.setParams({
                        componentDef : "c:DispatchServiceEventsAll",
                        componentAttributes: {
                            workOrderId : workOrderId
                        }
                    });
                    evt.fire();    
                } else {
                    this.showToast("",'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
                }                    
            } else {
            	this.showToast("",'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
            }
            */
            // Added by Harsha - DEFECT 5443199 - 08/07/2018
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__DispatchServiceEventsAll"
                },
                "state": {
                    "workOrderId": component.get("v.recordId")
                }
            };
            navService.navigate(pageReference);
        } catch(Err){
           	this.showToast(component,'ERROR',"Error occured in loading service events.","Error");
        }    
	},
    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
})
({
    tabInfo: function(component) {
        try {
            var workspaceAPI = component.find("detailWorkspace");
            if (!$A.util.isUndefinedOrNull(workspaceAPI)) {
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        var focusedTabId = tabId;
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:work_order_item",
                            iconAlt: "Service Events"
                        });
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: "Service Events"
                        });
                    })
                    .catch(function(error) {
                        this.showToast(component, 'ERROR', "Error occured in loading service events : " + error, "Error");
                    });
            }
        } catch (Err) {
            this.showToast(component, 'ERROR', "Error occured in loading service events : " + Err, "Error");
        }
    },
    getServiceEvents: function(component) {
        try {
            var recId = component.get("v.workOrderId");
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
		             this.showToast(component,'ERROR',"Error occured in loading service events.", "Error");
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
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
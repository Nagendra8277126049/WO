({
	//To toast 
    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            //"mode": "sticky",
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
   	doInitHelper: function(component) {
        try {
            // Record Id
            var recId = component.get("v.workOrderId");
            var action = component.get("c.getSelectedParts");
            action.setParams({
                //set RecordId
                workOrderId: recId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result !== null && result !== undefined) {
                        component.set("v.SelectedPartItems", result);
                    } 
                } 
            });
            $A.enqueueAction(action);
            
        } catch (Err) {
            this.showToast(component, 'ERROR', $A.get("Error occured in loading selected parts."), "Error");
        }
    },
    tabInfo: function(component) {
        try {
            var workspaceAPI = component.find("detailWorkspace");
            if (!$A.util.isUndefinedOrNull(workspaceAPI)) {
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        var focusedTabId = tabId;
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:work_order_item",
                            iconAlt: "Parts Ordered And Shipped"
                        });
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: "Parts Ordered And Shipped"
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
})
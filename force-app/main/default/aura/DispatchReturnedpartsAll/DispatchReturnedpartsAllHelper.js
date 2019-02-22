({
    //To toast 
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
    doInitHelper: function(component) {
        try {
            // Record Id
            var recId = component.get("v.workOrderId");
            var action = component.get("c.getReturnedParts");
            action.setParams({
                //set RecordId
                workOrderId: recId
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)) {
                        component.set("v.dispatchPartsOrderLineList", result);
                    } else {
                        var List = [];
                        component.set("v.dispatchPartsOrderLineList", List);
                    }
                } else {
                    this.showToast(component, 'ERROR', "Error occured in loading returned parts.", "Error");
                }
            });
            $A.enqueueAction(action);

        } catch (Err) {
            this.showToast(component, 'ERROR', "Error occured in loading returned parts : " + Err, "Error");
        }
    },
    tabInfo: function(component) {
        try {
            var workspaceAPI = component.find("detailWorkspace");
            if (!$A.util.isEmpty(workspaceAPI)) {
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        var focusedTabId = tabId;
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:work_order_item",
                            iconAlt: "Parts Returned"
                        });
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: "Parts Returned"
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
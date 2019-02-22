({
    tabInfo: function(component) {
        try {
            var workspaceAPI = component.find("workspace");
            //workspaceAPI.getFocusedTabInfo().then(function(response) 
            workspaceAPI.getEnclosingTabId().then(function(tabId) {
                    //var focusedTabId = response.tabId;
                    var focusedTabId = tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Alerts"
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "custom:custom53",
                        iconAlt: "Alerts"
                    });
                })
                .catch(function(error) {
                    this.showToast(component, 'Error', error, "Error");
                });

        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertDetailsErrorMessage"), "Error");
        }
    },

    getAlertList: function(component, recID) {
        try {
            var flag = component.get("v.flag");
            var action = component.get("c.getAlerts");
            action.setParams({
                "recordId": recID,
                "dashFlag": flag
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (!$A.util.isUndefinedOrNull(result)) {
                        component.set("v.assetAlerts", result);
                    } else {
                        component.set("v.assetAlerts", null);
                        //this.showToast(component,'Error', $A.get("$Label.c.CaseAlertDetailsErrorMessage"), "Error");
                    }
                } else {
                    //console.log("No response from server or client is offline.");
                    this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertDetailsErrorMessage"), "Error");
                }
                this.turnOffSpinner(component);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertDetailsErrorMessage"), "Error");
            this.turnOffSpinner(component);
        }
    },

    turnOffSpinner: function(component) {
        try {
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertDetailsErrorMessage"), "Error");
        }
    },

    turnOnSpinner: function(component) {
        try {
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-show");
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertDetailsErrorMessage"), "Error");
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
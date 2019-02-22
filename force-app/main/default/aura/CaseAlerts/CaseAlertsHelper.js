({
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
                        //this.showToast(component,'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
                    }
                } else {
                    //console.log("No response from server or client is offline.");
                    this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
                }
                this.turnOffSpinner(component);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            //console.log(Err);
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
            this.turnOffSpinner(component);
        }
    },

    openSubTab: function(component) {
        try {
            // Commented by Harsha - DEFECT 5443199 - 08/07/2018
            /*
		    var evt = $A.get("e.force:navigateToComponent");
    		evt.setParams({
        		componentDef : "c:CaseAlertDetails",
                componentAttributes: {
                	recId : component.get("v.recordId")
        		}
    		});
    		evt.fire();
            */

            // Added by Harsha - DEFECT 5443199 - 08/07/2018
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__CaseAlertDetails"
                },
                "state": {
                    "recordId": component.get("v.recordId")
                }
            };
            navService.navigate(pageReference);
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
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

    turnOffSpinner: function(component) {
        try {
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
        }
    },

    turnOnSpinner: function(component) {
        try {
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-show");
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
        }
    },
})
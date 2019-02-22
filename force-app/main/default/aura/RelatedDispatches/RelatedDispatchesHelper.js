({
    getResponse: function(component, page) {
        try {
            var recID = component.get("v.recordId");
            var pageSize = $A.get("$Label.c.RelatedDispatchesPageSize");
            var action = component.get("c.getRelatedDispatches");
            action.setParams({
                recordId: recID,
                PageKey: page,
                PageSize: pageSize
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (!$A.util.isUndefinedOrNull(result)) {
                        component.set("v.dispatchList", result.rltdDispatch);
                    } else {
                        component.set("v.dispatchList", null);
                        this.showToast(component,'Error',$A.get("$Label.c.DispatchDashboardErrorMessage"),"Error");
                    }
                } else {
                    this.showToast(component,'Error',$A.get("$Label.c.RelatedDispatchErrorMessage"),"Warning");
                } 
                this.turnOffSpinner(component);
            });

            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component,'ERROR',$A.get("$Label.c.RelatedDispatchErrorMessage"),"Error");
            this.turnOffSpinner(component);
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
            this.showToast(component, 'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
        }
    },

    turnOnSpinner: function(component) {
        try {
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-show");
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
        }
    },

    navigateToCompHelper: function(component) {
        // Commented by Harsha - DEFECT 5443199 - 08/07/2018
        /*
        try {
            var evt = $A.get("e.force:navigateToComponent");
            if (evt != null && evt !=undefined) 
            {
                var sAssetId = component.get("v.assetId"); 
                if (sAssetId != null && sAssetId!=undefined) {
                    evt.setParams({
                        componentDef : "c:RelatedDispatchDetails",
                        componentAttributes: {
                            assetId : sAssetId
                        }
                    });
                    evt.fire();    
                }
                else {
                    helper.showToast("",'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
                }                    
            }
            else {
            	helper.showToast("",'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
            }
        }
        catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
        } 
        */ 
        try {
            // Added by Harsha - DEFECT 5443199 - 08/07/2018
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__RelatedDispatchDetails"
                },
                "state": {
                    "assetId": component.get("v.recordId")
                }
            };
            navService.navigate(pageReference);
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
        }
    }
})
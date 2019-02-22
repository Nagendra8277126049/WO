({
    tabInfo: function(component) {
        try {
            var workspaceAPI = component.find("detailWorkspace");
            //var sAssetId = component.get("v.assetId");
            if (!$A.util.isUndefinedOrNull(workspaceAPI)) {
                //workspaceAPI.getFocusedTabInfo().then(function(response) 
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        //var focusedTabId = response.tabId;
                        var focusedTabId = tabId;
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:service_appointment",
                            iconAlt: "Related Work Orders"
                        });
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: "Work Orders"
                        });
                    })
                    .catch(function(error) {
                        this.showToast("", 'ERROR', error, "Error");
                    });
            }
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
        }
    },
    getResponse: function(component, page) {
        try {
            var action = component.get("c.getRelatedDispatchDetails");
            var recID = component.get("v.assetId");
            var pageSize = $A.get("$Label.c.RelatedDispatchDetailsPageSize");

            component.set("v.Spinner", true);

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
                        component.set("v.page", result.page);
                        component.set("v.next", result.next);
                        component.set("v.previous", result.previous);
                    } else {
                        component.set("v.dispatchList", null);
                        component.set("v.page", 0);
                        component.set("v.next", false);
                        component.set("v.previous", false);
                        this.showToast(component, 'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
                    }
                } else {
                    this.showToast(component, 'Error', $A.get("{!$Label.c.RelatedDispatchErrorMessage}"), "Error");
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
            component.set("v.Spinner", false);
        }
    },

    buttonLogic: function(component, direction) {
        try {
            var page = component.get("v.page") || 1;
            page = direction === "Previous" ? (page - 1) : (page + 1);
            this.getResponse(component, page);
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
        }
    },
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
})
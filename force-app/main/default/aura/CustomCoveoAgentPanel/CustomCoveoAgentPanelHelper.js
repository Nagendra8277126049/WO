({
    getUserLanguage : function(component, event, helper) {
        var action = component.get("c.getUserLanguage");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userLanguage = response.getReturnValue();
                component.set("v.userLanguage", userLanguage);
            }
        });
        $A.enqueueAction(action);
    }
/*
    openNewTab : function(url, sfid) {
        var openInNewTabEvent = $A.get("e.c:OpenInNewTab");
        openInNewTabEvent.setParams({
            url: url ? url.replace(/&/g, "%26") : url,
            recordId: sfid
        })
        openInNewTabEvent.fire();
    }
*/
})
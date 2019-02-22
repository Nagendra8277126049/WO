({
    getToken: function(component) {
        console.log("calling Apex controller");
        var action = component.get("c.getEinsteinApiToken");
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a);
                component.set("v.EinsteinApiToken", a.getReturnValue());
                console.log("callback SUCCESS");
            } else if (state === "ERROR") {
                component.find("leh").passErrors(a.getError());
                console.log(a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    doInitUsage : function(component, event, helper) {
        let action = component.get("c.getUsage");
        action.setCallback(this, function(a){
            let state = a.getState();
            if (state === "SUCCESS") {
                console.log(a.getReturnValue());
                component.set("v.usage", a.getReturnValue());
            }  else if (state === "ERROR") {
                component.find("leh").passErrors(a.getError());
            }
        });
        $A.enqueueAction(action);
        
    }
})
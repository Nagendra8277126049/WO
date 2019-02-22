({
    closeMe: function(component, event, helper) {
        helper.closeMe(component);
    },

    init: function(component, event, helper) {
        helper.initHandler(component);
    },
    
    onButtonPressed: function(component, event, helper) {
        try {
            // Figure out which action was called
            var actionClicked = event.getSource().getLocalId();
            if (actionClicked === "NEXT") {
                component.set("v.Acknowledged", true);
                helper.callApexToCreateRecord(component);
            } else {
                component.set("v.Acknowledged", false);
                component.destroy();
            }
        } catch (Err) {
            // Toast Error to User
            helper.showToast(component, 'ERROR', "Error Occured : " + Err, "Error");
        }
    },
})
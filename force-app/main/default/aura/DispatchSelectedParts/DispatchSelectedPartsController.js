({
	doInit: function(component, event, helper) {
    	helper.doInitHelper(component);
    },
    viewAll: function(component, event, helper) {
        try {
            helper.getAllSelectedParts(component);        
        } catch (Err) {
            helper.showToast(component,'ERROR',"Error occured in loading service events.","Error");
        }
    },
    showDetailsPopup : function(component, event, helper) {
        helper.showDetailsPopupWindow(component, event);
    }
})
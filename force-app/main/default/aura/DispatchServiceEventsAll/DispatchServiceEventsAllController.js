({
	doInit: function(component, event, helper) {
        try {
            helper.getServiceEvents(component);  
            helper.tabInfo(component);
        } catch (Err) {
            helper.showToast(component, 'ERROR',"Error occured in loading service events.", "Error");
        }
    },
})
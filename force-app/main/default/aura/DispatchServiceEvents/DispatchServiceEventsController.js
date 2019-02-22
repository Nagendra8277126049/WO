({
	doInit: function(component, event, helper) {
        try {
            helper.getServiceEvents(component);             
        } catch (Err) {
            helper.showToast(component,'ERROR',"Error occured in loading service events.","Error");
        }
    },
    viewAll: function(component, event, helper) {
        try {
            helper.getAllServiceEvents(component);        
        } catch (Err) {
            helper.showToast(component,'ERROR',"Error occured in loading service events.","Error");
        }
    },
})
({
    openModal: function(component,event,helper) {
        try{
            helper.openWindow(component, event, helper);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }        
    },
    
    doInit: function(component, event, helper) {
        try{
	       	var recID = component.get("v.recordId");        
    	    helper.getResponse(component, recID);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },
})
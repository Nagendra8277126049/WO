({
    doInit : function(component, event, helper) {
        try{
	   		helper.tabInfo(component);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },
})
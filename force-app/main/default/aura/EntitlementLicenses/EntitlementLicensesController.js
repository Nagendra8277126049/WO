({
    doInit: function(component, event, helper) {
        try{ 
            helper.getResponses(component);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.EntitlementLicensesErrorMessage"), "Error");
        }
    },
    /*
    // handle Menu Select - this will be developed in Sprint 3 
    handleMenuSelect: function(cmp, event, helper) {
    	var selectedMenuItemValue = event.getParam("value");
	}
    */
})
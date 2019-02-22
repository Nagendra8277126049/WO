({
    doInit: function(component, event, helper) {
        try {
            var recID = component.get("v.recordId"); 
            component.set("v.assetId", recID);
 			var page = component.get("v.page") || 1;           
            helper.getResponse(component, page); 
            helper.turnOnSpinner(component);
        } catch(Err) {
           	helper.showToast("",'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
            helper.turnOffSpinner(component);
        } 
    },    
    navigateToMyComponent : function(component, event, helper) { 
        helper.navigateToCompHelper(component);
	},
})
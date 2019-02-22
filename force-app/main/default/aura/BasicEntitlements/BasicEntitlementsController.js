({
    // invokes during Component Loading
    doInit: function(component, event, helper) {
        try{ 
            // page default value is 1
            var page = component.get("v.page") || 1;
            helper.getResponses(component, page);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },
    
    //on click of Next Button
    nextPage:function(component,event,helper){
        try{ 
    	  	var direction = event.getSource().get("v.label"); 
            helper.buttonLogic(component, direction);
        }catch(Err){
           	helper.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },
    
    //on click of Previous Button
    previousPage:function(component,event,helper){
        try{
      		var direction = event.getSource().get("v.label");
      		helper.buttonLogic(component, direction);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    }
})
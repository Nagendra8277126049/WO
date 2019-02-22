({
	doInit: function(component, event, helper) {
        // setting tab information
        try {
        	var page = component.get("v.page") || 1; 
            helper.getResponse(component, page);
            helper.tabInfo(component);
        }
        catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
        }
    },
	nextPage:function(component,event,helper){
        try{ 
    	  	var direction = event.getSource().get("v.label"); 
            helper.buttonLogic(component, direction);
        }catch(Err){
           	helper.showToast(component,'Error', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
        }
    },
    previousPage:function(component,event,helper){
        try{
      		var direction = event.getSource().get("v.label");
      		helper.buttonLogic(component, direction);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.RelatedDispatchErrorMessage"), "Error");
        }
    }
})
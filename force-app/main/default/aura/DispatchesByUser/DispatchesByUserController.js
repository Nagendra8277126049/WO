({  
	doInit : function(component, event, helper) {
    	try{
			var page = component.get("v.page") || 1;
            var recID = component.get("v.recordId");
            helper.turnOnSpinner(component, event);
        	helper.getUserDispatchList(component, page);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
            helper.turnOffSpinner(component, event);
        }	
	},
	nextPage:function(component,event,helper){
        try{ 
    	  	var direction = event.getSource().get("v.label"); 
            helper.buttonLogic(component, direction);
        }catch(Err){
           	//console.log(Err);
           	helper.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
        }
    },
    previousPage:function(component,event,helper){
        try{
      		var direction = event.getSource().get("v.label");
      		helper.buttonLogic(component, direction);
        }catch(Err){
           	//console.log(Err);
            helper.showToast(component,'Error', $A.get("$Label.c.DispatchDashboardErrorMessage"), "Error");
        }
    }
})
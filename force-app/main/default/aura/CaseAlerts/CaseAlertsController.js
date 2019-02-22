({
	doInit : function(component, event, helper) {
    	try{
            var recID = component.get("v.recordId");
            helper.turnOnSpinner(component);
        	helper.getAlertList(component, recID);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
            helper.turnOffSpinner(component);
        }	
	},
    
    openDetails : function(component, event, helper) {
        try{
            helper.openSubTab(component);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.CaseAlertsDashboardErrorMessage"), "Error");
        }
    },
})
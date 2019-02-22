({
    doInit : function(component, event, helper) {
        try{
            //var recID = component.get("v.recordId");
            var recID = component.get("v.recId");
            helper.turnOnSpinner(component);
        	helper.getAlertList(component, recID);
       		helper.tabInfo(component);
        }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.AssetAlertDetailsErrorMessage"), "Error");
        }
    },
})
({
	doInit : function(component, event, helper) {
        var errMessage = component.get("v.ErrorMessage");

        try{
            var recID = component.get("v.recId");
            helper.getLastCollectionDate(component, recID);
            helper.getLastCollectionAlerts(component, recID);
        }catch(Err){
            helper.showToast(component,'Error', errMessage, "Error");
        }
    },
})
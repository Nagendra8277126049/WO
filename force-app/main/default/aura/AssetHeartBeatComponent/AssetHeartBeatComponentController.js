({
    doInit: function(component, event, helper) {
        try{
        	var recID = component.get("v.recordId");
        	helper.getResponse(component, recID);
        }catch(Err){
           	var errMessage = component.get("v.ErrorMessage");
            helper.showToast(component,'Error', errMessage, "Error");
        }
    },
})
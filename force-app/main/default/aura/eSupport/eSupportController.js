({
	doInit : function(component, event, helper) {
        try{
            var recID = component.get("v.recId");
      		helper.geteSupportFieldsFn(component, event, helper);
        }catch(Err){
            var errMessage = component.get("v.ErrorMessage");
            helper.showToast(component,'Error', errMessage, "Error");
        }
    },
    
})
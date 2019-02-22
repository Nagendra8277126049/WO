({
    closeMe : function(component, event, helper) {
        helper.closeMe(component, event, helper);
    },
    Associate : function(component,event,helper){
        try {            
            var recID = component.get("v.recordId");
            //getting the asset number
            var assetRecord = component.get("v.newAsset");
            helper.showSpinner(component, event, helper);
            helper.updateCase(component, recID, assetRecord);
            
        }catch(Err){
            var errMessage = component.get("v.searchAssetErrorMessage");
            this.showToast(component,'Error', errMessage, "Error");
            helper.hideSpinner(component, event);
        }
    }
})
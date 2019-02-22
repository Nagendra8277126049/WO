({
    doInit: function(component,event,helper) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        //var getConValue = component.find("contactValue").get("v.value");
        helper.getWorkOrderAndPicklistValHelper(component);
    },
    
    handleCont: function(component, event, helper) {
        try{
            var getConValue = component.find("contactValue").get("v.value");
            //if(getConValue!=null && getConValue!=undefined && getConValue != "" && getConValue.length != 0 ){
            if(!$A.util.isUndefinedOrNull(getConValue) && getConValue !== "" && getConValue.length !== 0 ){
                if (getConValue !== '--None--'){
                    component.set("v.contactAlertType", getConValue);
                    helper.callApex(component, event, getConValue, 'primaryContact');
                }
                else{
                    component.set("v.contactAlertType", getConValue);
                    //helper.handleSaveRecord(component);
                    helper.callApexToSavePMContact(component);
                }
            }
            //}
        }catch(Err){
            helper.showToast(component,'Error',"Error Occured while loading component", "Error");
        }	
    },
    
    handleAddCont: function(component, event, helper){
        try{
            var getAddConValue= component.find("addContactValue").get("v.value");
            //if(getAddConValue!=null && getAddConValue!=undefined && getAddConValue != "" && getAddConValue.length != 0){
            if(!$A.util.isUndefinedOrNull(getAddConValue) && getAddConValue !== "" && getAddConValue.length !== 0){ 
                if (getAddConValue !== '--None--'){
                    component.set("v.addContactAlertType", getAddConValue);
                    helper.callApex(component, event, getAddConValue, 'additionalContact');
                }
                else{
                    component.set("v.addContactAlertType", getAddConValue);
                    //helper.handleSaveRecord(component);
                    helper.callApexToSaveADContact(component);
                }
            }
            //}
        }catch(Err){
            //console.log("Error in Controller Function2 ==>  "+Err);
            helper.showToast(component,'Error',"Error Occured while loading component", "Error");
        }
    },
    
    /**
     * Control the component behavior here when record is changed (via any component)
     */
    handleRecordUpdated: function(component, event, helper) {
        try{
            var eventParams = event.getParams();
            if(eventParams.changeType === "CHANGED") {
                // get the fields that changed for this record
                //var changedFields = eventParams.changedFields;
                helper.checkContactChange(component,eventParams.changedFields); // Added by Harsha - DEFECT 5446043
            } else if(eventParams.changeType === "LOADED") {
                // record is loaded in the cache
            } else if(eventParams.changeType === "REMOVED") {
                // record is deleted and removed from the cache
            } else if(eventParams.changeType === "ERROR") {
                // there’s an error while loading, saving or deleting the record
            }
        }catch(Err){
            helper.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
        }
    }
})
({
	handleRecordUpdatedHelper: function(component, event, helper){
		var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
        } else if(eventParams.changeType === "LOADED") {
            
            if(!$A.util.isEmpty(component.get("v.simpleRecord.Dispatch_Country__c"))){
                component.set("v.options",$A.get("$Label.c.DispatchCountry").split(','));
                //console.log('options are:'+component.get("v.options"));
                //component.find("countrySelectorId").set("v.value",component.get("v.simpleRecord.Dispatch_Country__c"));
				console.log('Dispatch Country is not empty on Load :'+component.get("v.simpleRecord.Dispatch_Country__c"));
				//component.set("v.simpleRecord.Dispatch_Country__c",component.get("v.simpleRecord.Dispatch_Country__c"));
            	component.set("v.selectedValue1",component.get("v.simpleRecord.Dispatch_Country__c"));
                console.log('Selected Value on Load :'+component.get("v.selectedValue1"));
                //console.log('global Value on Load :'+component.get("v.globalValue"));
            }
            
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            this.showToast(component, 'Error', "Error Occured While Loading Dispatch Country ", "Error");
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            this.showToast(component, 'Error', "Error Occured While Loading Dispatch Country ", "Error");
            // there’s an error while loading, saving or deleting the record
        }
	},
	handleSaveRecordHelper: function(component, event, helper) {
        try{
            component.set("v.showSpinner",true);
            component.set("v.simpleRecord.Dispatch_Country__c",component.get("v.changedValue1"));
            component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // Turn off the Spinner
                    component.set("v.showSpinner",false);
                    //Refresh View - After Record is Saved to Database - Refresh the Screen.
                    $A.get("e.force:refreshView").fire();
                } else {
                    // Turn off the Spinner
                    component.set("v.showSpinner",false);
                    //this.showToast(component, 'Error', "Error Occured : "+JSON.stringify(saveResult.error), "Error");
                    console.log("Error ===> "+JSON.stringify(saveResult.error));
                }
            }));
        } catch (Err){
            component.set("v.showSpinner",false);
            this.showToast(component, 'Error', "Error Occured : "+Err,"Error");
        }
	},
    
    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
})
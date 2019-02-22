({
    //Open Modal
    openModalWindow: function(component, event, helper) {
        try {
            component.set("v.openReadForm", false);
            // Create Modal Component - dynamically
            helper.openWindow(component);
        } catch (Err) {
            helper.showToast(component, 'Error', $A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"), "Error");
        }
    },

    // handle Updated Values from Component Event
    handleComponentEvent: function(component, event, helper) {
        try {
            helper.handleEventUpdate(component, event);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured While Refreshing Component","Error");
        }
    },

    closeEditForm: function(component, event,helper) {
        try {
            component.set("v.openReadForm", event.getParam("openReadForm"));
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured While Closing Edit View","Error");
        }
    },
    
    onRender: function(component, event,helper)
    {
        try {
            $A.get('e.force:refreshView').fire();

        }  
        catch (err){
            
        }
    },

    handleRecordUpdated: function(component, event, helper) {
        try {
            helper.recordUpdatedHelper(component, event);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
        }
    },
	closeAddressUpdateModel: function(component, event, helper) {
		try {
            helper.closeAddressUpdateModelHelper(component, event);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured While Closing the Modal Box", "Error");
        }
	},
	updateAddress: function(component, event, helper) {
		try {
            helper.updateAddressHelper(component, event);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
        }
	},
    closeChooseCityPopUp: function(component, event, helper) {
		component.set('v.showChooseCityPopUp', false);
    },
    updateCityOnWorkOrder: function(component, event, helper) {
        helper.updateCityOnWorkOrderHelper(component, event, helper);
    }
	/*,
    
    handleOverrideGroundShipment: function(component, event,helper){
        try{
            alert('reached Handle Override Ground Shipment');
        	helper.calculateServiceOptionHelper(component,event);
        }catch(Err){
            helper.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
        }
    }*/
})
({
	openModalWindow: function (component, event, helper) {
	    try{
    		helper.openWindow(component);
	    } catch (Err) {
            helper.showToast(component,'Error',"Error Occured in Opening Edit View", "Error");
        }
	},
	handleRecordUpdated: function (component, event, helper) {
	    try{
		    helper.handleRecordUpdateHelper(component, event);
	    } catch (Err) {
	        helper.showToast(component,'Error',"Error Occured - While Updating Read View", "Error");
	    }
	},
	closeEditForm: function (component, event, helper) {
	    try{
    		helper.handleCloseEdit(component, event);
	    } catch (Err) {
	        helper.showToast(component,'Error',"Error Occured in Opening Read View", "Error");
	    }
	},
	updateReadForm: function (component, event, helper) {
	    try{
	        $A.get("e.force:refreshView").fire();
    		//helper.updReadEvent(component, event);
	    } catch (Err) {
	        helper.showToast(component,'Error',"Error Occured - While Updating Read View", "Error");
	    }
	}
})
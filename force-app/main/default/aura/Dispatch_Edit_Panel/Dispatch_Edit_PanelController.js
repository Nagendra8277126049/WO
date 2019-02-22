({
    handleEdit: function(component,event,helper) {
        try{
            helper.handleEditHelper(component);
        } catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    handleGccEvent: function(component,event,helper){
        try{
            helper.handleGccEventHelper(component,event);
        } catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
            console.log("Err>>>"+Err);
        }
    },
    handleGCCCancel: function(component,event,helper){
        try{
            helper.handleGCCCancelHelper(component,event);
        } catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    handleGCCSubmit: function(component,event,helper){
        try{
            helper.handleGCCSubmitHelper(component,event);
        } catch(Err){
            console.log(Err);
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    closeModalPopUp: function(component, event, helper) {
        try {
            helper.closeModalPopUpHandler(component);
        } catch (Err) {
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    handleResubmit: function(component, event, helper) {
        try {
            helper.handleResubmithelper(component);
        } catch (Err) {
            console.log(Err);
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    handleCancel: function(component, event, helper) {
        try {
            helper.handleCancelHelper(component);
        } catch (Err) {
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
})
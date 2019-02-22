({    
    handleCancel: function(component,event,helper) {
        try{
            helper.cancelHelper(component,event);
        } catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },

    handleSubmit: function(component,event,helper) {
        try{
            helper.submitHelper(component,event);
        } catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
})
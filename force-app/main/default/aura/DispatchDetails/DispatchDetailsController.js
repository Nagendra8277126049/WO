({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component);
    },
    closeModal : function(component, event, helper){  
        helper.closeModalHelper(component);	
    },
    saveRecord : function(component, event, helper){
        helper.saveRecordValidationHelper(component);	
    },
    OpenEditForm: function(component,event,helper){
        try{
            helper.handleOpenDSPEditHelper(component,event);
            helper.handleOpenCallTypeEditHelper(component,event);
            helper.OpenDLPEditHelper(component);
        } catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },

})
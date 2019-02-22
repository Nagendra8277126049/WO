({
    recordUpdated: function(component, event, helper) {
        helper.recordUpdatedHelper(component,event);
    },
    openModalWindow : function(component,event,helper){
        helper.helperOpenModalWindow(component);
    },
    closeEditForm: function (component, event, helper) {
		helper.handleCloseEdit(component, event);
	},
    OpenDSPEdit : function (component, event, helper) {
        helper.handleOpenDSPEdit(component, event);
    },
    cancelEdit : function (component, event, helper){
        helper.handleCancelEdit(component, event);
    },
    SaveDSP : function (component, event, helper){
        helper.handleSaveDSP(component, event);
    }
})
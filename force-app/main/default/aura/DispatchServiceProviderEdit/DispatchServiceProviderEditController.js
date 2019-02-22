({
    destroyComp: function(component, event, helper) {
        helper.closeEditScreen(component);
    },
    doInit: function(component, event, helper) {
        helper.doInitHelper(component);
    },
    handleChange: function(component, event, helper) {
        helper.handleChangeHelper(component, event);
    },
    handleSave : function(component,event,helper){
        helper.handleSaveHelper(component);
    }
})
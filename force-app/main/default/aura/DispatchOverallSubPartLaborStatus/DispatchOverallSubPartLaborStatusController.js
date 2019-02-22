({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component);
        // Moved Code from Controller to Helper - Harsha Gangi Reddy
    },
    closeModalPopUp: function(component, event, helper) {

        component.set('v.showModal', false);
        if(component.get("v.GCCUser"))
            helper.checkForReadOnlyFlagGCC(component);
        else
        helper.checkForReadOnlyFlag(component);
        component.set('v.commentsRequiredForCancelRequest', '');
         component.set("v.validationError", false);
        component.set("v.errorMessage", '');
    },
    OpenModalPopUp: function(component) {

        component.set('v.showModal', true);
        console.log(component.get("v.workorderStatusToShowOnUI"));
        component.find("statuses").set("v.value", component.get("v.workorderStatusToShowOnUI"));
        component.find("commentsBox").set("v.value", component.get("v.workorder.Comments__c"));
        component.set('v.commentsRequiredForCancelRequest', '');

    },
    handleSaveWorkOrder: function(component, event, helper) {
		helper.handleSaveWorkOrderHelper(component);
        // Moved Code from Controller to Helper - Harsha Gangi Reddy
    },

    handleOnChangeStatus: function(component) {
        component.set("v.validationError", false);
        component.set("v.errorMessage", ' ');
        component.set("v.commentsRequiredForCancelRequest", '');
    },
    
    handleRecordUpdated : function(component,event, helper) {
        helper.handleRecordUpdatedHelper(component,event);
    },
})
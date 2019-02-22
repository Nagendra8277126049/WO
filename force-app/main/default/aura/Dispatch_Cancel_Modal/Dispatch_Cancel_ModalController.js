({
    closeMe: function(component, event, helper) {
        try {
            helper.closeMe(component, event);
        } catch (Err) {
            helper.showToast(component, 'Error',
                "Error Occured While Loading Component", "Error");
        }
    },

    onClickYes: function(component, event, helper) {
        try {
            helper.onClickYes(component, event);
        } catch (Err) {
            helper.showToast(component, 'Error',
                "Error Occured While Loading Component", "Error");
        }
    },
})
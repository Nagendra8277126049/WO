({
    showErrorMessage: function(component, title, message){
        component.find('redirectErrorNotification').showCustomModal({
            header: title? title : "Error",
            body: message? message : "Whoops, an unknown error occured when making the request. Please, try again later.", 
            showCloseButton: true,
            cssClass: "error-message-theme",
            closeCallback: function() {
                $A.get("e.force:closeQuickAction").fire();
            }
        });
    }
})
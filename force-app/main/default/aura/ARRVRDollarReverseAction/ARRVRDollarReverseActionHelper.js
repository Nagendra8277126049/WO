({
    showErrorMessage: function(component, title, message){
        component.find('actionErrorNotification').showCustomModal({
            header: title? title : "Error",
            body: message? message : "Whoops, an unknown error occured when making the request. Please, try again later.", 
            showCloseButton: true,
            cssClass: "error-message-theme",
            closeCallback: function() {
                $A.get("e.force:closeQuickAction").fire();
            }
        });
    },
    formatErrorMessageType: function(string) {
        var parsedValue = string[0] != '[' ? string : JSON.parse(string);
        if (typeof parsedValue == "object"){
            var response = "";
            
            for (var i = 0; i < parsedValue.length; i++) { 
                response += parsedValue[i] + "\n";
            }
            
            return response;
        }
        else {
            if (parsedValue[0] == '<') {
                return parsedValue.substring(parsedValue.indexOf("<Message>") + 9, parsedValue.indexOf("</Message>"));
            }
            else {
                return parsedValue.replace(/^"(.+)"$/, '$1');
            }
        }
    }
})
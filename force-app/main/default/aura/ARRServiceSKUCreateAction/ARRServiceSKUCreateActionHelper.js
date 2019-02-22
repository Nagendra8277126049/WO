({
    showErrorMessage: function(component, title, message){
        component.find('errorNotification').showCustomModal({
            header: title? title : "Error",
            body: message? "An error occured on the request: " +  message : "Whoops, an unknown error occured when making the request. Please, try again later.", 
            showCloseButton: true,
            cssClass: "error-message-theme"
        });
    },
    showLoadingSpinner: function(toggle){
        var spinner = document.getElementById('loading-spinner');
        if (spinner != null && spinner.style != null)
			spinner.style.display = toggle ? "block" : "none";
    },
    clearStringResponse: function(string){
        return string.replace(new RegExp('\"', 'g'), '');
    },
    formatErrorMessageType: function(string) {
        var parsedValue = string[0] != '[' ? string.trim() : JSON.parse(string);
        if (typeof parsedValue == "object"){
            var response = "";
            
            for (var i = 0; i < parsedValue.length; i++) { 
                response += parsedValue[i] + "\n";
            }
            
            return response;
        }
        else {
            if (parsedValue[0] == '<' || parsedValue[1] == '<') { // datapower errors
                return parsedValue.substring(parsedValue.indexOf("<Message>") + 9, parsedValue.indexOf("</Message>"));
            }
            else {
                return parsedValue.replace(/^"(.+)"$/, '$1');
            }
        }
	}
 })
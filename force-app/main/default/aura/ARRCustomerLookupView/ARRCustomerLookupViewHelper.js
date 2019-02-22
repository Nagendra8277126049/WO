({
    showLoadingSpinner: function(toggle){
        var spinner = document.getElementById('lookup-loading-spinner');
        if (spinner != null && spinner.style != null)
            spinner.style.display = toggle ? "block" : "none";
    },
    showErrorMessage: function(component, title, message){
        component.find('lookupErrorNotification').showCustomModal({
            header: title? title : "Error",
            body: message? "An error occured when processing the request: " +  message : "Whoops, an unknown error occured when making the request. Please, try again later.", 
            showCloseButton: true,
            cssClass: "error-message-theme"
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
	},
    sortData: function (component, fieldName, sortDirection) {
        component.set("v.sortedBy", fieldName);
    	component.set("v.sortedDirection", sortDirection);
        var data = component.get("v.customerAssets");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.customerAssets", data);
    },
 	sortBy: function (field, reverse, primer) {
        var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
         }
     }
})
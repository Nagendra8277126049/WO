({
	sortData: function (component, fieldName, sortDirection) {
    	var data = component.get("v.OrderItems");
     	var reverse = sortDirection !== 'asc';
     	//sorts the rows based on the column header that's clicked
     	data.sort(this.sortBy(fieldName, reverse))
     	component.set("v.OrderItems", data);
   	},
 	sortBy: function (field, reverse, primer) {
    	var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
     	//checks if the two rows should switch places
     	reverse = !reverse ? 1 : -1;
     	return function (a, b) {
        	return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
     	}
 	},
    showSuccessToast: function(component, event, helper) {
        this.showToast('Dispatch submitted!', 'Record {0} submitted! See it {1}!', 'Success Message', 'success');
    },
    showToast: function(message, messageTemplate, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            messageTemplate: messageTemplate,
            duration:'5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})
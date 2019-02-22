({
    init : function(component, event, helper) {
        component.set('v.gridColumns', [
            {label: 'Service Tag', fieldName: 'serviceTag', type: 'text', sortable: true},
			{label: 'Serial Number', fieldName: 'serialNumber', type: 'text', sortable: true},
            {label: 'Ship Date', fieldName: 'shipDate', type: 'date', sortable: true},
            {label: 'Description', fieldName: 'productDescription', type: 'text', sortable: true}
        ]);
        component.set("v.customerAssets", null);
    },
    loadValues : function(component, event, helper) {
        const buid = component.get("v.buid");
        const customerNum = component.get("v.customerNumber");
        
        const action = component.get("c.getAssetsFromCustomer");
        action.setParams({"buid": buid, "customerNum": customerNum});
        action.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") {
                try {
                    let result = response.getReturnValue();
                    
                    if (result.Status == 404)
                    {
                        helper.showErrorMessage(component, "Not found","No Assets found for the given Customer");
                    }
                    else if (result.Status != 200) {
                        helper.showErrorMessage(component, null, helper.formatErrorMessageType(result.Body));
                        //component.set("v.customerAssets", null); 
                    } else {
                        const parsedResponse = JSON.parse(result.Body);
                        //component.set("v.customerAssets", null); 
                        component.set("v.customerAssets", parsedResponse.ownedAssets); 
                    }
                }
                catch (e) {
                    helper.showErrorMessage(component, null);
                    //component.set("v.customerAssets", null); 
                }
                finally {
                    helper.showLoadingSpinner(false);
                }
            } else {
                let errors = response.getError();
                
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
                
                helper.showErrorMessage(component);
                //component.set("v.response", null); 
                helper.showLoadingSpinner(false);
            }
        });
        
        $A.enqueueAction(action);
    },
    sendValues : function(component, event, helper) {  
        const selectedValues = component.get("v.selectedRows")
        return selectedValues && selectedValues.length > 0? selectedValues.map(x => x.serviceTag).join(' ') : null;
    },
    clearSelection : function(component, event, helper){
        return 0;
    },
    updateColumnSorting: function(component, event, helper) {
    	var fieldName = event.getParam('fieldName');
    	var sortDirection = event.getParam('sortDirection');
    	// assign the latest attribute with the sorted column fieldName and sorted direction
    	component.set("v.sortedBy", fieldName);
    	component.set("v.sortedDirection", sortDirection);
    	helper.sortData(component, fieldName, sortDirection);
    },
    updateSelectedRows: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRows', selectedRows);
    },
   
})
({
    makeRequest : function(component, event, helper) {
        var button = event.getSource();
        button.set('v.disabled',true);
        
    	var deleteAction = component.get("c.deleteVrp");
        deleteAction.setParams({"requestId": component.get("v.recordId")});
        deleteAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                
                if (result.Status != 200) {
					var msg = result.Body != null && result.Body != ""?
                        helper.formatErrorMessageType(result.Body) :
                        "An error occured while deleting this proposal. Please try again later :(";
    
                    helper.showErrorMessage(component, null, msg);
                } else {
                    window.location.pathname = "/lightning/o/Proposal__x/list";
                }
            } else {
                helper.showErrorMessage(component, null, "An internal error occured at Salesforce while making this request.");
            }
        });
        $A.enqueueAction(deleteAction);
    },
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
({
    init : function(component, event, helper) {       
        let action = component.get('c.releaseSettlement');
        action.setParams({ "requestId": component.get("v.recordId") });
        action.setCallback(this, function(response) {
            component.set("v.isRequesting", false);
            
            if (response.getState() === "SUCCESS") {
                const result = response.getReturnValue();
                
                if (result.Status != 200 && result.Status != 204) {
                    const msg = result.Body != null && result.Body != ""?
                        helper.formatErrorMessageType(result.Body) :
                    "An error occured while trying to release this Settlement. Please try again.";
                    
                    helper.showErrorMessage(component, null, msg);
                } else {
                    setTimeout(function(){window.location.reload();},500);
                }
            } else {
                helper.showErrorMessage(component, null, "An internal error occured at Salesforce while making this request.");
            }
        });
        
        $A.enqueueAction(action);  
    }
})
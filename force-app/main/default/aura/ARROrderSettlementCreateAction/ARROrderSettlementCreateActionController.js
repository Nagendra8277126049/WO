({
    init : function(component, event, helper) {
        const request = {
            "requestId": component.get("v.recordId"), 
        };
        
        let action = component.get('c.postOrderForSettlement');
        action.setParams(request);
        action.setCallback(this, function(response) {
            component.set("v.isRequesting", false);
            
            if (response.getState() === "SUCCESS") {
                const result = response.getReturnValue();
                
                if (result.Status != 200 && result.Status != 204) {
                    const msg = result.Body != null && result.Body != ""?
                        helper.formatErrorMessageType(result.Body) :
                    "An error occured while trying to create an Order. Please try again.";
                    
                    helper.showErrorMessage(component, null, msg);
                } else {
                    let elem = document.getElementById('message');
                    if (elem)
                        elem.innerHTML= "Request successful.";
                        
                    setTimeout(function(){window.location.reload();},2000);
                }
            } else {
                helper.showErrorMessage(component, null, "An internal error occured at Salesforce while making this request.");
            }
        });
        
        $A.enqueueAction(action);  
    }
})
({
	init : function(component, event, helper) {
		var postDispatch = component.get("c.postDispatch");
        postDispatch.setParams({"requestId": component.get("v.recordId")});
        postDispatch.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                var dispatchResult = JSON.parse(result.Body);

                if (result.Status != 200) {
                    var errorMsg = (dispatchResult.errors || ['An error occurred when tyring to create a dispatch.'])
                    	.reduce((acc,current) => acc == '' ? current : acc + "\n" +current,'');
                    
                    errorMsg = helper.formatErrorMessageType(errorMsg);
                    
                    helper.showErrorMessage(component, null, errorMsg);
                    
                } else {
                    var elem = document.getElementById('refresh-message');
                    
                    if (elem) {
                        elem.innerHTML="Dispatch "+ dispatchResult.dispatchId + " created!";
					}
                }
            } else {
                helper.showErrorMessage(component, null, "An internal error occured at Salesforce while making this request.");
            }
        });
        $A.enqueueAction(postDispatch);
	}
})
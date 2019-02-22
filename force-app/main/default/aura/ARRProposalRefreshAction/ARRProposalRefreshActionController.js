({
	init : function(component, event, helper) {
        var refreshAction = component.get("c.refreshVrp");
        refreshAction.setParams({"requestId": component.get("v.recordId")});
        refreshAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();

                if (result.Status != 200) {
                    var msg = result.Body != null && result.Body != ""?
                        helper.formatErrorMessageType(result.Body) :
                    	"An error occured while refresh this proposal. Please try again later :(";
                    
                    helper.showErrorMessage(component, null, msg);
                } else {
                    var elem = document.getElementById('refresh-message');
                    
                    if (elem) {
                        elem.innerHTML="Proposal refreshed!";
                        setTimeout(function(){window.location.reload();},3000);
					}
                }
            } else {
                helper.showErrorMessage(component, null, "An internal error occured at Salesforce while making this request.");
            }
        });
        $A.enqueueAction(refreshAction);
	}
})
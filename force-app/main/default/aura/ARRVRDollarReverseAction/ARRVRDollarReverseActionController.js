({
	init : function(component, event, helper) {
        const transaction = component.get('v.transaction');
        
        if (transaction.Status__c == 'Reversed')
            helper.showErrorMessage(component, null, "This Transaction is already reversed.");    
        if (transaction.Type == 'Credit')
            helper.showErrorMessage(component, null, "It's not possible to reverse a Credit Transaction.");            
        
        const body = {
            transactionId: component.get('v.transaction').ValueRecoveryTransactionID__c
        }
        
        let reverseAction = component.get("c.RevertInvoice");
        reverseAction.setParams({"body": JSON.stringify(body)});
        reverseAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();

                if (result.Status != 200) {
                    const msg = result.Body != null && result.Body != ""?
                        helper.formatErrorMessageType(result.Body) :
                    	"An error occured while reversing this Transaction. Please try again later :(";
                    
                    helper.showErrorMessage(component, null, msg);
                } else {
                    var elem = document.getElementById('refresh-message');
                    
                    if (elem) {
                        elem.innerHTML="Transaction reversed!";
                        setTimeout(function(){window.location.reload();},3000);
					}
                }
            } else {
                helper.showErrorMessage(component, null, "An error occured when processing the request: An internal error occured at Salesforce while making this request.");
            }
        });
        $A.enqueueAction(reverseAction);
	}
})
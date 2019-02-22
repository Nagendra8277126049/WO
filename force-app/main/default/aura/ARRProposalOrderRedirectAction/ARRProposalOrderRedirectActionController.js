({
    openOrderLink : function(component, event, helper) {
        const proposal = component.get("v.Proposal");
		const account = component.get("v.Account");
        
        // TEMP, should be validating by BUID at account
        const buid = proposal.Buid__c || account.BUID__c;
        const country = proposal.Country__c || account.Country__c || account.BUID__c == 11 ? 'US' : account.BUID__c == 11 ? 'CA' : null; 
        const customer = proposal.CustomerNumber__c || account.AccountNumber;
        
        let setRedirectAtion = component.get("c.getOrderLink");
        setRedirectAtion.setParams({ "countryCode": country });
        setRedirectAtion.setCallback(this, function(response) {
            try {
                if (response.getState() === "SUCCESS") {
                    const url = response.getReturnValue();
                    
                    if (url != null) {
                    	let result = response.getReturnValue().replace('{buid}', buid).replace('{customerNumber}', customer).replace('{customerNumber}', customer);
                    
                    	window.open(result, '_blank');
                    } else {
                        helper.showErrorMessage(component, null, "This action is only valid for AMER region.");
                    }
                } else {
                    helper.showErrorMessage(component, null, "An error occured when processing the request: An internal error occured at Salesforce while making this request.");
                }
            } finally {
                $A.get("e.force:closeQuickAction").fire();
            }

        });
        $A.enqueueAction(setRedirectAtion);  
	}
})
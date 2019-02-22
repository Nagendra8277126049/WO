({
    init: function(component, event, helper) {
        var getSummaryAction = component.get("c.getSummary");
        var proposal = component.get("v.Proposal");
        helper.showLoadingSpinner(true);
        
        getSummaryAction.setParams({"proposalId": proposal.ProposalID__c}); 
        getSummaryAction.setCallback(this, function(response, component){
            try {
                var result = response.getReturnValue();
                
                if (result.Status != 200) {
                    helper.showErrorMessage(component, null, helper.formatErrorMessageType(result.Body));
                } else
                {
                    component.set("v.summary", JSON.parse(result.Body))
                }
            }
            catch (e) {
                helper.showErrorMessage(component, null, "An issue occured while loading the Summary Section information.");
            }
            finally {
                helper.showLoadingSpinner(false);
            }
        });
        $A.enqueueAction(getSummaryAction); 
    }
})
({
    startFlow : function (cmp, event, helper) {
        var flow = cmp.find("flow");
        var settlement = cmp.get("v.settlement");
        
        if((settlement.AmountRemaining__c || settlement.AmountAvailable__c) > 0)
        	helper.startFlow(settlement, flow);
        else{
            alert("Settlement has no amount available to invoice.");
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    
    statusChange : function (cmp, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            var outputVariables = event.getParam("outputVariables");
            var output = null;        
            for(var i = 0; i < outputVariables.length; i++) {
                output = outputVariables[i];
                if(output.name == "ApiSuccess") helper.handleFlowEnd(cmp, output.value);
            }
        }
    }
})
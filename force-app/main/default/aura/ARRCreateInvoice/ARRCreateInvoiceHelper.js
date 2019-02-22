({
	startFlow : function(settlement, flow) {
		var hasAccount = !!settlement.Account__c;
        var inputVariables = [
            {
                name : 'BuId',
                type : 'Number',
                value : hasAccount ? settlement.Account__c.split("-")[1] : settlement.BusinessUnit__c
            },
            {
                name : 'Currency',
                type : 'String',
                value : settlement.Currency__c
            },
            {
                name : 'CustomerNumber',
                type : 'String',
                value : hasAccount? settlement.Account__c.split("-")[0] : '' + settlement.CustomerNumber__c 
            },
            {
                name : 'DispatchId',
                type : 'Number',
                value : settlement.DispatchID__c
            },
            {
                name : 'SettlementAmount',
                type : 'Number',
                value : hasAccount? settlement.AmountRemaining__c : settlement.AmountAvailable__c
            }
        ];
        flow.startFlow("arr_invoiceCreationFlow", inputVariables);
	},
    handleFlowEnd : function(cmp, apiSuccess) {
        if(apiSuccess == 'OK'){
            
            var settlement = cmp.get("v.settlement");
            var getSettlementRecoveryBalance = cmp.get("c.GetSettlementRecoveryBalance");
            getSettlementRecoveryBalance.setParams({valueRecoveryBalanceID : settlement.ValueRecoveryBalanceID__c});
            getSettlementRecoveryBalance.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": response.getReturnValue(),
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
                else if(state == "ERROR"){
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(getSettlementRecoveryBalance);
        }
        else
        	$A.get("e.force:closeQuickAction").fire();
	}
})
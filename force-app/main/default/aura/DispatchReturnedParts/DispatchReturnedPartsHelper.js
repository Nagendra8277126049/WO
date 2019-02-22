({
	//To toast 
    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
   	doInitHelper: function(component) {
        try {
            // Record Id
            var recId = component.get("v.recordId");
            var action = component.get("c.getReturnedParts");
            action.setParams({
                //set RecordId
                workOrderId: recId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)) {
                        component.set("v.dispatchPartsOrderLineList", result);
                    } else {
                        var list = [];
                        component.set("v.dispatchPartsOrderLineList", list);
                    }
                } else {
                    this.showToast(component, 'ERROR', "Error occured in loading returned parts.", "Error");
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component, 'ERROR', "Error occured in loading returned parts : "+Err, "Error");
        }
    },
    getAllReturnedParts : function(component) {
        try {
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__DispatchReturnedpartsAll"
                },
                "state": {
                    "workOrderId": component.get("v.recordId"),
                    "Label_PARTNUMBER": component.get("v.Label_PARTNUMBER"),
                    "Label_DESCRIPTION": component.get("v.Label_DESCRIPTION"),
                    "Label_QUANTITY": component.get("v.Label_QUANTITY"),
                    "Label_RETURNDATE": component.get("v.Label_RETURNDATE"),
                    "Label_UNITPRICE": component.get("v.Label_UNITPRICE"),
                    "Label_SERVICETAG": component.get("v.Label_SERVICETAG"),
                    "Label_WAYBILL": component.get("v.Label_WAYBILL"),
                    "Label_CARRIER": component.get("v.Label_CARRIER"),
                    "Label_UserName": component.get("v.Label_UserName"),
                    "Label_PartsReturnedCompName": component.get("v.Label_PartsReturnedCompName")
                }
            };
            navService.navigate(pageReference);
        } catch(Err){
            this.showToast(component,'ERROR',"Error occured in loading service events : "+Err,"Error");
        }    
	},
})
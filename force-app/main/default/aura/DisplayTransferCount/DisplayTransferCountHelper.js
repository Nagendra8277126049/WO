({
	transferCountValue : function(component, event, helper){
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            console.log("eventParams" +eventParams.changeType);
		     var action = component.get('c.GetTransferCount');
             action.setParams({
                 "ctId" : component.get('v.recordId'),
                 "Agent_Id" : component.get('v.sample.Agent_ID__c'),
                 "IVR_Input" : component.get('v.sample.IVR_Input__c')
             });
            action.setCallback(this, function(a){
                var state = a.getState(); // get the response state
                if(state == 'SUCCESS') {
                    component.set('v.transferCount', a.getReturnValue());
                }
            });
            $A.enqueueAction(action);
  		 }
    }
})
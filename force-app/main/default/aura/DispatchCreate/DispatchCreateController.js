({
    doInit: function(component, event, helper) {
        try {
            // check if there is any workorder has been created in last 28 days
            helper.CheckRepeatDispatchInAsset(component);
            helper.createLDSFrameWork(component);
            helper.createPPIDData(component);
        }catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");            
        }
    },
    
    handleSaveWorkOrder: function(component, event, helper) {   		
        try {
            helper.handleSaveWorkOrderHelper(component);
        }catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    
    handleRepeatReason: function(component, event, helper) {
        try {
            helper.handleRepeatReasonHelper(component);
        }catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    
    handleReason: function(component, event, helper) {
        try{
            var getReasonVal = component.find("ReasonWorkOrderId").get("v.value");
            if(!$A.util.isEmpty(getReasonVal)){
                component.set("v.ReasonWorkOrder", getReasonVal);
            }
        }catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    
    addNewRow: function(component, event, helper) {
        //component.set("v.DisabledPPIDLink",false);
        helper.createPPIDData(component, event);
    },
    
    removePPID: function(component, event, helper) {
		helper.removePPIDData(component, event);
	},
    
    keyCheck : function(component, event, helper) {
		var targetCmp = event.getSource();
  		var message = targetCmp.get('v.value');  	    
        var finalMessage='';
        
        if(message!==null){
            finalMessage=helper.keyCheckGeneric(message,component);
            //component.set("v.textAreaValue",finalMessage);
            targetCmp.set('v.value',finalMessage);
            /*if(!$A.util.isEmpty(finalMessage))
            {
                console.log('The message is not null'+JSON.stringify(finalMessage));
                component.set("v.DisabledPPIDLink",true);
            }
           else{
               console.log('The message is  null'+JSON.stringify(finalMessage));
                component.set("v.DisabledPPIDLink",false);
            }*/
        }
        /*else
        {
            component.set("v.DisabledPPIDLink",false);
        }*/
	},
     // Added By Harsha - STORY 5240855 - Starts Here
    handleMWDDiagnosticTeir : function (component,event,helper){
        helper.handleMWDDiagnosticTeirHelper(component,event);
    }
     // Added By Harsha - STORY 5240855 - Ends Here
})
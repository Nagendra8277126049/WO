({
    getResponses: function(component, event, helper){
        try{
            var assetId = component.get("v.assetId");
            //turn on the Spinner
            this.turnOnSpinner(component);
            var action = component.get("c.getAccidentalDamageDetails");
            action.setParams({
                recordId: assetId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state == "SUCCESS") 
                {                    
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined){  
                       if(result.serviceCode == "100")
                       {
                            // set the component attributes value with wrapper class properties.   
                            component.set("v.entADList", result.detailsADList);        
                        }else {
                            component.set ("v.errorMessage", result.serviceResponse);
                            component.set("v.entADList", null);
                            var error = component.get("v.errorMessage");
                            this.showToast(component,'Accidental Entitlements', error, "Warning");
                        }
                    }
                    else{
                        component.set("v.entADList", null);
                        this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
                    }
                }
                else {
                    this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
                } 
                // turn off the Spinner
                this.turnOffSpinner(component);
            });
            $A.enqueueAction(action);
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
            // turn off the Spinner
            this.turnOffSpinner(component);
        }
    },
    // To Toast Error Message
  	showToast : function(component, title, message, type) {
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message, 
                "type": type,
                "mode": "pester",
                "duration": "3000"
            });
            toastEvent.fire();
        }catch(Err){
           console.log(Err);
        }
    },
    // turn off spinner    
    turnOffSpinner: function (component) {
        try{
            var spinner = component.find("mySpinner");
        	$A.util.toggleClass(spinner, "slds-hide");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },
    // turn on Spinner
    turnOnSpinner: function (component) {
        try{
    		var spinner = component.find("mySpinner");
    		$A.util.toggleClass(spinner, "slds-show");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
	},
})
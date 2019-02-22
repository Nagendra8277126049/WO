({
    getResponses: function(component){
        // call apex controller
        try{
            var assetId = component.get("v.assetId");
            this.turnOnSpinner(component);
            var action = component.get("c.getDeeEntitlements");
             
            action.setParams({
                recordId: assetId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined){  
                       if(result.serviceCode == '100'){
                            // set the component attributes value with wrapper class properties.   
                            component.set("v.entDetList", result.entDetails);       
                        }
                        
                        else{
                            component.set("v.entDetList", null);
                            component.set ("v.errorMessage", result.serviceResponse);
                            var error = component.get("v.errorMessage");
                            this.showToast(component,'Digital Entitlements', error, "Warning");
                        }
                    }
                    else{
                        component.set("v.entDetList", null);
                        this.showToast(component,'Error', $A.get("$Label.c.EntitlementLicensesErrorMessage"), "Error");
                    }
                }
                else {
                    this.showToast(component,'Error', $A.get("$Label.c.EntitlementLicensesErrorMessage"), "Error");
                } 
                this.turnOffSpinner(component);
            });
            $A.enqueueAction(action);
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementLicensesErrorMessage"), "Error");
            this.turnOffSpinner(component);
        }
    },
    // Toast Error Messages
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
    // Turn off Spinner    
    turnOffSpinner: function (component) {
        try{
            var spinner = component.find("mySpinner");
        	$A.util.toggleClass(spinner, "slds-hide");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementLicensesErrorMessage"), "Error");
        }
    },
    // Turn on Spinner
    turnOnSpinner: function (component) {
        try{
    		var spinner = component.find("mySpinner");
    		$A.util.toggleClass(spinner, "slds-show");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementLicensesErrorMessage"), "Error");
        }
	}
})
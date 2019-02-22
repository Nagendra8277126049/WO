({
    // call apex controller
    getResponses: function(component, page){
        try{
            //var assetId = component.get("v.assetId");
            var pageSize = $A.get("$Label.c.EntitlementDetailsPageSize");
            this.turnOnSpinner(component);
            var action = component.get("c.getEntDetails");
             
            action.setParams({
                recordId: component.get("v.recordId"),
                PageKey: page,
                PageSize: pageSize
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined){  
                       if(result.serviceCode == '100'){
                            // set the component attributes value with wrapper class properties.   
                            component.set("v.entDetList", result.entDetails);
                            component.set("v.page", result.page);
                            component.set("v.next",result.next);
                            component.set("v.previous",result.previous);  
                           component.set("v.asset",result.AssetId);
                        }
                        
                        else{
                            component.set ("v.errorMessage", result.serviceResponse);
                            component.set ("v.entDetList",null);
                            var error = component.get("v.errorMessage");
                            this.showToast(component,'Basic Entitlement Details', error, "Warning");
                        }
                    }
                    else{
                        component.set("v.entDetList", null);
                        this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
                    }
                }
                else {
                    this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
                } 
                this.turnOffSpinner(component);
            });
            $A.enqueueAction(action);
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
            this.turnOffSpinner(component);
        }
    },

    // button Logic for Next & Previous Page
    buttonLogic: function(component, direction){
        try{
	        var page = component.get("v.page") || 1; 
    	  	page = direction === "Previous" ? (page - 1) : (page + 1);  
      		this.getResponses(component, page);
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },
    
    // to toast Error messages
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
    
    // turn off Spinner  
    turnOffSpinner: function (component) {
        try{
            var spinner = component.find("mySpinner");
        	$A.util.toggleClass(spinner, "slds-hide");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },
    
    // turn on spinner
    turnOnSpinner: function (component) {
        try{
    		var spinner = component.find("mySpinner");
    		$A.util.toggleClass(spinner, "slds-show");
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
	},
    openWindow: function(component) {
        try {
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__EntitlementDetails"
                },
                "state": {
                    "recordId": component.get("v.asset")
                }
            };
            navService.navigate(pageReference);
        } catch (Err) {
            this.showToast(component, 'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    }
})
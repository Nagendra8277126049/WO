({
    getResponses: function(component, event, helper){
        try{
            var recId = component.get("v.recordId");
            //turn on the Spinner
            this.turnOnSpinner(component);
            var action = component.get("c.getTrackingInfoList");
            action.setParams({
                recordId:recId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state == "SUCCESS") {                    
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)){
                        if(!result.NoRecordsFound){
                            component.set("v.trackList", result.tracKInfoList);        
                        } else {
                            component.set("v.trackList", null);
                        }
                    } else {
                        component.set("v.trackList", null);
                        this.showToast(component,'Error',"Error Occured While Loading Component", "Error");
                    }
                } else {
                    this.showToast(component,'Error',"Error Occured While Loading Component", "Error");
                } 
                // turn off the Spinner
                this.turnOffSpinner(component);
            });
            $A.enqueueAction(action);
        }catch(Err){
            this.showToast(component,'Error',"Error Occured While Loading Component", "Error");
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
            this.showToast(component,'Error', "Error Occured While Loading Component", "Error");
        }
    },
    // turn on Spinner
    turnOnSpinner: function (component) {
        try{
    		var spinner = component.find("mySpinner");
    		$A.util.toggleClass(spinner, "slds-show");
        }catch(Err){
            this.showToast(component,'Error', "Error Occured While Loading Component", "Error");
        }
	},
})
({
    // Call ApexController to get LastCollectionDate
    getResponse: function(component, recID) {        
        try{
            var action = component.get("c.getSupportAssitDetails");
            this.turnOnSpinner(component);
            action.setParams({
                recordId: recID
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {	
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined){ 
                        if(result.ResponseCode === "100"){
                            component.set("v.LastCollectionDate", result.UTCDate);
                            component.set("v.noRecordsFound",result.noRecordsFound);
                            component.set("v.Status",result.Status);
                            component.set("v.URL",result.URL);
                        }
                        else{
                            component.set("v.LastCollectionDate", null);
                            var errMessage = component.get("v.ErrorMessage");
                            this.showToast(component,'Error', errMessage, "Error");
                        }
                    }
                } else if (state === "INCOMPLETE") {
                    var errMessage = component.get("v.ErrorMessage");
                    this.showToast(component,'Error', errMessage, "Error");
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message);
                        }
                    } else{
                        var errMessage = component.get("v.ErrorMessage");
                        this.showToast(component,'Error', errMessage, "Error");
                    }
                }
                this.turnOffSpinner(component);
            });
            $A.enqueueAction(action);
        }catch(Err){
            var errMessage = component.get("v.ErrorMessage");
            this.showToast(component,'Error', errMessage, "Error");
            this.turnOffSpinner(component);
        }
    },
    
    // Show Toast Message to User When Error Occurs
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
    
    // turn on spinner
    turnOnSpinner: function (component) {
        try{
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-show");
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
            console.log(Err);
        }
    },
})
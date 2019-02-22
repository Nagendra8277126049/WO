({
    getLastCollectionDate: function (component, recID){
        var errMessage = component.get("v.ErrorMessage");
        try{
            var action = component.get("c.getLastCollectionDate");
            component.set("v.Spinner", true);
            action.setParams({
                recordId: recID
            });
            action.setCallback(this, function(response) {
                var state = response.getState(); 
                if(state==="SUCCESS"){
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined){
                        if(result.ResponseCode==="100")
                        {
                            component.set("v.lastCollDate",result.lastCollectionDate); 
                            component.set("v.CollectionStatusURL",result.CollectionStatusURL);
                        } 
                        else{
                            component.set("v.lastCollDate", null);
                            component.set("v.CollectionStatusURL",result.CollectionStatusURL);
                        } 
                        
                    }
                }
                else if(state === "INCOMPLETE") {
                    //console.log("No response from server or client is offline.");
                    this.showToast(component,'Error', errMessage, "Error");
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors!= null || errors!=undefined) {
                            if (errors[0] && errors[0].message) {
                                //console.log("Error message: " + errors[0].message);
                                this.showToast(component,'Error', errMessage, "Error");
                            }
                            else{
                                this.showToast(component,'Error', errMessage, "Error");
                                console.log("Some unknown error");
                            }
                        } else {
                            console.log("Unknown error");
                            this.showToast(component,'Error', errMessage, "Error");
                        }
                    }
                 component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }catch(Err){
            //console.log(Err);
            this.showToast(component,'Error', errMessage, "Error");
            component.set("v.Spinner", false);
        }
    },
    
    getLastCollectionAlerts: function (component, recID){
        var errMessage = component.get("v.ErrorMessage");
        try{
            var action = component.get("c.getLastCollectionAlerts");
            component.set("v.Spinner", true);
            action.setParams({
                recordId: recID
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state==="SUCCESS"){
                    var result = response.getReturnValue();
                    if (result!=null && result!=undefined){
                        if(result[0].ResponseCode=="100")
                        {
                            component.set("v.supportAssistList", response.getReturnValue()); 
                        }
                        else{
                            component.set("v.supportAssistList", null);
                        }
                        
                    }
                }
                else if(state === "INCOMPLETE") {
                    //console.log("No response from server or client is offline.");
                    this.showToast(component,'Error', errMessage, "Error");
                }
                    else if (state === "ERROR") {
                        console.log("Some error, check the getError");
                        var errors = response.getError();
                        if (errors!= null || errors!=undefined) {
                            if (errors[0] && errors[0].message) {
                                //console.log("Error message: " + errors[0].message);
                                this.showToast(component,'Error', errMessage, "Error");
                            }
                            else{
                                this.showToast(component,'Error', errMessage, "Error");
                                console.log("Some unknown error");
                            }
                        } else {
                            console.log("Unknown error");
                            this.showToast(component,'Error', errMessage, "Error");
                        }
                    }
                  component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }catch(Err){
            //console.log(Err);
            this.showToast(component,'Error', errMessage, "Error");
            component.set("v.Spinner", false);
        }
    },
      
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
    }
})
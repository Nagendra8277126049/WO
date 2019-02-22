({
    geteSupportFieldsFn: function (component, event, helper){
        var errMessage = component.get("v.ErrorMessage");
        try{
            var recID = component.get("v.recId");
            var action = component.get("c.searchForCase");
            component.set("v.Spinner", true);
            action.setParams({
                "recordId": recID
            });
            action.setCallback(this, function(response) {
                var state = response.getState();            
                if(state=="SUCCESS"){
                    var result = response.getReturnValue();
                    if (result!=null || result!=undefined){
                        if(result[0].ResponseCode =="100"){
                            component.set("v.EsupportDiagList", response.getReturnValue());
                        }else{
                            component.set("v.EsupportDiagList", null);
                        }  
                    }
                }
                else if (status === "INCOMPLETE") {
                    this.showToast(component,'Error', errMessage, "Error");
                }
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors!= null || errors!=undefined) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            this.showToast(component,'Error', errMessage, "Error");
                        }
                        else {
                            console.log("Some Unknown error");
                            this.showToast(component,'Error', errMessage, "Error");
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
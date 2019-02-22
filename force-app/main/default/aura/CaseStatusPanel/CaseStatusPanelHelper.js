({
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
    
    submitHelper: function(component,event){
        try{
            var caseId= component.get("v.recordId");
            var action = component.get("c.SubmitToQueue");
            action.setParams({
                Cid : caseId
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS") {
                    var rec = response.getReturnValue();
                    this.showToast(component,'Success',"Case has been Submitted Successfully","Success");
                }
                else
                {
                    this.showToast(component,'Error',"Error on Case Submission","Error");
                }    
            });
            $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire();
            
        }catch(Err){
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },
    
    cancelHelper:function(component,event){
        try{
            var caseId= component.get("v.recordId");
            var action = component.get("c.StatusUpdateCancel");
            action.setParams({
                Cid : caseId
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS") {
                    var rec = response.getReturnValue();
                    this.showToast(component,'Success',"Case has been Cancelled", "Success");
                }
                else
                {
                    this.showToast(component,'Error',"Error on Cancelling Case","Error");
                }
            });
            $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire();
        }catch(Err){
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },
    
    // turn on spinner
    showSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    // turn off Spinner
    hideSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})
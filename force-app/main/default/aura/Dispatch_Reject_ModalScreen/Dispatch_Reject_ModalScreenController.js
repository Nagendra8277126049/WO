({
   handleCancel : function(component, event, helper) {
       // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
   },
   
   /*
   handleWorkOrderRecordUpdated:function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
        } 
        else if(eventParams.changeType === "CHANGED") {
        }
    },
   
    // Control the component behavior here when record is changed (via any component)
    handleRecordUpdated: function(component, event, helper) {
        try{
            var eventParams = event.getParams();
            if(eventParams.changeType === "LOADED") {
                var recId = component.get("v.simpleRecord.Work_Order__c");
                component.set("v.WorkOrderId",recId);
            } else if(eventParams.changeType === "CHANGED") {
                var recId = component.get("v.simpleRecord.Work_Order__c");
                component.set("v.WorkOrderId",recId);
            } else{
                console.log("Error");
            }
        }catch(Err){
            console.log("Error in handleRecordUpdate"+Err);
        }
    },
    */
    
    handleReject: function(component,event,helper){
        helper.handleSaveHelper(component);
    }
})
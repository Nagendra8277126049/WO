({
    onClickYes:function(component,event){
    	try{
            var thisObj = this;
            var status = "Cancelled";
            var rTypeId = $A.get("$Label.c.Dispatch_Record_Type_Approval");
            component.set("v.simpleRecord.Status",status);
            component.set("v.simpleRecord.RecordTypeId",rTypeId);
            component.find("recordLoader").saveRecord(function(saveResult){
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT"){
                    // Refresh View
                    $A.get("e.force:refreshView").fire();
                    // Show Success Toast
                    thisObj.showToast(component, 'Success',"Cancelled Work Order", "Success");
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state +', error: ' + JSON.stringify(saveResult.error));
                    // Show Failure Toast
                    thisObj.showToast(component, 'Error',"Failed To Cancel Work Order", "Error");
                }                
            });
        } catch (Err){
            this.showToast(component, 'Error',"Failed To Cancel Work Order", "Error");
            //console.log("Error While Cancelling Work Order   ===>  "+Err);
        }
    },
    
    closeMe : function(component, event)  {
        // Destroy Component
        component.destroy();
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
    }
})
({
    /*
	handleSaveHelper : function(component) {
	    try{
    	    if(this.handleSaveValidate(component)){
    	        //Update Dispatch pending Approval Record
    	        this.handleApprovalRecordUpdate(component,event);
    	        //Update Work Order Record
    	        this.handleWorkOrderRecordUpdate(component,event);
    	    }
	    }catch(Err){
	        console.log("Error Occured While Updating Record"+Err);
	    }
	},
	*/
	
	handleSaveHelper : function(component) {
	    try{
    	    if(this.handleSaveValidate(component)){
    	        this.callApexToSave(component,event);
    	    }
	    }catch(Err){
	        console.log("Error Occured While Updating Record"+Err);
	    }
	},
	
	handleSaveValidate : function(component) {
	    try{
    	    component.set("v.validationError", false);
            component.set("v.errorMessage",'');
    	    var validate = true;
    	    var rejectReason = component.find("rejectReasonId").get("v.value");
    	    var rejectComment = component.find("rejectCommentsId").get("v.value");
    	    if($A.util.isEmpty(rejectReason) || $A.util.isEmpty(rejectComment) || 
    	        rejectReason===null || rejectComment===null ||
    	        rejectReason===undefined || rejectComment===undefined ) {
                component.set("v.validationError", true);
                component.set("v.errorMessage",'Please fill all fields');
    	        return false;
    	    }
    	    return validate;
	    }catch(Err){
	        console.log("Error Occured During Save Validation "+Err);
	    }
	},
	
	/*
	handleWorkOrderRecordUpdate: function(component, event) {
	    try{
	        var thisObj = this;
	        var status = "Canceled";
    	    var workOrderRecTypeId =  $A.get("$Label.c.Dispatch_Record_Type_Submitted");
    	    var userId = $A.get("$SObjectType.CurrentUser.Id");
    	    var currentDateTime = new Date();
            var rejectReason = component.find("rejectReasonId").get("v.value");
    	    var rejectComment = component.find("rejectCommentsId").get("v.value");
    
    	    component.set("v.simpleWorkOrderRecord.RecordTypeId",workOrderRecTypeId);
            component.set("v.simpleWorkOrderRecord.Approver_Id__c",userId);
            component.set("v.simpleWorkOrderRecord.Approved_Rejected__c","Rejected");
            component.set("v.simpleWorkOrderRecord.Approve_Reject_Reason__c",rejectReason);
            component.set("v.simpleWorkOrderRecord.Approve_Reject_DateTime__c",currentDateTime);
            component.set("v.simpleWorkOrderRecord.Approve_Reject_Comments__c",rejectComment);
            component.set("v.simpleWorkOrderRecord.status",status);
            
            console.log("Work Order Record  ==> "+JSON.stringify(component.get("v.simpleWorkOrderRecord")));
            
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // handle component related logic in event handler
                    var WorkOrderId = component.get("v.WorkOrderId");
                    $A.get("e.force:refreshView").fire();
                    //Navigate to WorkOrder
                    thisObj.navigateWorkOrderTab(component,event,WorkOrderId);
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
	    }catch(Err){
	        console.log("Error During Work Order Updation ==> "+Err);
	    }
    },
    
    handleApprovalRecordUpdate: function(component, event){
        try{
            var approved = false;
            var rejected = true;
            var rejectRecordTypeId = $A.get("$Label.c.DispatchApproval_ReordTypeId");
            var rejectReason = component.find("rejectReasonId").get("v.value");
    	    var rejectComment = component.find("rejectCommentsId").get("v.value");
    	    
            component.set("v.simpleRecord.RecordTypeId",rejectRecordTypeId);
            component.set("v.simpleRecord.Approved__c",approved);
            component.set("v.simpleRecord.Reject_Comments__c",rejectComment);
            component.set("v.simpleRecord.Reject_Reason__c",rejectReason);
            component.set("v.simpleRecord.Rejected__c",rejected);
            
            component.find("record").saveRecord($A.getCallback(function(saveResult){
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // handle component related logic in event handler
                    
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        }catch(Err){
            console.log("Error Occured While Updating Approvel Record",+Err);
        }
    },
    
    */
    
    navigateWorkOrderTab: function(component, event, workOrderId){
        try {
            if (!$A.util.isEmpty(workOrderId)) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": workOrderId,
                    "slideDevName": "related"
                });
                navEvt.fire();               
            }
        }
        catch(Err){
            console.log("Error Occured During Navigation   "+Err);
        } 	
    },
    
    callApexToSave : function(component){
        try{
            // Call Apex Controller to update Record
            //turn on Spinner
            this.showSpinner(component);
            
            var rejectReason = component.find("rejectReasonId").get("v.value");
    	    var rejectComment = component.find("rejectCommentsId").get("v.value");
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            
            var action = component.get("c.RejectDispatch");
            
            action.setParams({
                recordId: component.get("v.recordId"),
                rejectReason: rejectReason,
                rejectComment: rejectComment
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)) 
                    {
                        // Refresh the Dispatch pending Approval View
                        $A.get("e.force:refreshView").fire();
                        // Navigate to Work order Record
                        this.navigateWorkOrderTab(component,event,result);
                    } 
                    else 
                    {
                        this.showToast(component, 'ERROR',"Error Occured While Updating Record", "Error");
                    }
                } 
                else 
                {
                    this.showToast(component, 'ERROR',"Error Occured While Updating Record", "Error");
                }
                //turn Off Spinner
                this.hideSpinner(component);
                dismissActionPanel.fire();
                
            });
            $A.enqueueAction(action);
        } catch (Err) {
            // Log
            console.log(Err);
            //turn Off Spinner
            this.hideSpinner(component);
            // Toast Error to User
            this.showToast(component, 'ERROR',"Error Occured While Loading The Form", "Error");
        }
    },
    
    // turn on spinner
    showSpinner: function(component) {
        component.set("v.Spinner", true);
    },

    // turn off Spinner
    hideSpinner: function(component) {
        component.set("v.Spinner", false);
    },
    
    // Toast message
    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
})
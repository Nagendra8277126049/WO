({
    /*
	handleSaveHelper : function(component,event) {
	    //component.set("v.simpleWorkOrderRecord.AccountId", component.get("v.recordId"));
	    
	    if(this.handleSaveValidate(component)){
	        //Update Dispatch pending Approval Record
	        this.handleApprovalRecordUpdate(component,event);
	        //Update Work Order Record
	        this.handleWorkOrderRecordUpdate(component,event);
	    }

	},
	*/
	
	handleSaveHelper : function(component,event) {
	    //component.set("v.simpleWorkOrderRecord.AccountId", component.get("v.recordId"));
	    if(this.handleSaveValidate(component)){
	        //Update Dispatch pending Approval Record
	        this.callApexToSave(component);
	    }

	},
	
	handleSaveValidate : function(component) {
	    try{
    	    component.set("v.validationError", false);
            component.set("v.errorMessage",'');
    	    var validate = true;
    	    var approveReason = component.find("approveReasonId").get("v.value");
    	    var approveComment = component.find("approvalCommentsId").get("v.value");
    	    if($A.util.isEmpty(approveReason) || $A.util.isEmpty(approveComment) || approveReason ===null || approveReason=== undefined || approveComment===null || approveComment===undefined) {
    	    //if($A.util.isEmpty(approveReason)) {
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
	        var status = "Submitted";
    	    var workOrderRecTypeId =  $A.get("$Label.c.Dispatch_Record_Type_Submitted");
    	    var userId = $A.get("$SObjectType.CurrentUser.Id");
    	    var currentDateTime = new Date();
            var approveReason = component.find("approveReasonId").get("v.value");
    	    var approveComment = component.find("approvalCommentsId").get("v.value");
    
    	    component.set("v.simpleWorkOrderRecord.RecordTypeId",workOrderRecTypeId);
            component.set("v.simpleWorkOrderRecord.Approver_Id__c",userId);
            component.set("v.simpleWorkOrderRecord.Approved_Rejected__c","Approved");
            component.set("v.simpleWorkOrderRecord.Approve_Reject_Reason__c",approveReason);
            component.set("v.simpleWorkOrderRecord.Approve_Reject_DateTime__c",currentDateTime);
            component.set("v.simpleWorkOrderRecord.Approve_Reject_Comments__c",approveComment);
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
    */
    /*
    handleApprovalRecordUpdate: function(component, event){
        try{
            var approved = true;
            var rejected = false;
            var approveRecordTypeId = $A.get("$Label.c.DispatchApproval_ReordTypeId");
            var approveReason = component.find("approveReasonId").get("v.value");
    	    var approveComment = component.find("approvalCommentsId").get("v.value");
    	    
            component.set("v.simpleRecord.RecordTypeId",approveRecordTypeId);
            component.set("v.simpleRecord.Approved__c",approved);
            component.set("v.simpleRecord.Approval_Reason__c",approveReason);
            component.set("v.simpleRecord.Approval_Comments__c",approveComment);
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
            
            var approveReason = component.find("approveReasonId").get("v.value");
    	    var approveComment = component.find("approvalCommentsId").get("v.value");
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            
            var action = component.get("c.ApproveDispatch");
            
            action.setParams({
                recordId: component.get("v.recordId"),
                approveReason: approveReason,
                approveComment: approveComment
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)) 
                    {
                        // refresh View
                        $A.get("e.force:refreshView").fire();
                        //Navigate to Work Order
                        this.navigateWorkOrderTab(component,event,result);
                        // refresh View
                        $A.get("e.force:refreshView").fire();
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
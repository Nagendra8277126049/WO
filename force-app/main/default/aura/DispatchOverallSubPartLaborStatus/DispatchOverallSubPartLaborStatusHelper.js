({
    checkForReadOnlyFlag: function(component) {
		try {
            if (component.get('v.workorderStatusToShowOnUI') === 'Closed' ||
                component.get('v.workorderStatusToShowOnUI') === 'Cancelled' ||
                component.get('v.workorderStatusToShowOnUI') === 'Delay' ||
                component.get('v.workorderStatusToShowOnUI') === 'Service Complete' ||
                component.get('v.workorderStatusToShowOnUI') === 'Awaiting Compliance' ||
                component.get('v.workorderStatusToShowOnUI') === 'Pending Schedule' ||
                component.get('v.workorderStatusToShowOnUI') === 'Open' ||
                component.get('v.workorderStatusToShowOnUI') === 'Cancellation Request' ||
               component.get('v.workorderStatusToShowOnUI') === 'Rework') {
    
                component.set('v.markOverallStatusReadOnly', true);
            }
        } catch (Err) {
            this.showToast(component, 'ERROR', $A.get(
                "$Label.c.Dispatch_ErrorMessageLoadingComponent"
            ), "Error");
        }
    },
    checkForReadOnlyFlagGCC: function(component) {
		try {
            component.set('v.markOverallStatusReadOnly', true);
            if (component.get('v.workorderStatusToShowOnUI') === 'Awaiting Acknowledgement' ||
                component.get('v.workorderStatusToShowOnUI') === 'Work In Progress' ||
                component.get('v.workorderStatusToShowOnUI') === 'Delay/Service Interruption' || 
                component.get('v.workorderStatusToShowOnUI') === 'Pending Review' ||
               component.get('v.workorderStatusToShowOnUI') === 'Problem' ||
               component.get('v.workorderStatusToShowOnUI') === 'Approved' ||
               component.get('v.workorderStatusToShowOnUI') === 'Cancellation Request'){
   
                component.set('v.markOverallStatusReadOnly', false);
            }
        } catch (Err) {
            this.showToast(component, 'ERROR', $A.get(
                "$Label.c.Dispatch_ErrorMessageLoadingComponent"
            ), "Error");
        }
    },

    doInitHelper: function(component) {
        // Moved Code from Controller to Helper - Harsha Gangi Reddy
        try{
            var action = component.get("c.fetchStatusFieldsData");            
    
            action.setParams({
                workOrderId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.workorder', response.getReturnValue().workOrderRecord);
                    component.set('v.comments', response.getReturnValue().workOrderRecord.Comments__c);
                    component.set('v.allWorkOrderStatusList', response.getReturnValue().allWorkOrderStatusList);
                    component.set('v.workOrderStatus', response.getReturnValue().workOrderRecord.Status);
                    component.set('v.subStatus', response.getReturnValue().workOrderRecord.Sub_Status__c);
                    component.set('v.partStatus', response.getReturnValue().workOrderRecord.Parts_Status__c);
                    component.set('v.laborStatus', response.getReturnValue().workOrderRecord.Labor_Status__c);
                    component.set('v.woStatusLastUpdatedDate', response.getReturnValue().woStatusLastUpdatedDate);
                    component.set('v.subStatusLastUpdatedDate', response.getReturnValue().subStatusLastUpdatedDate);
                    component.set('v.partsStatusLastUpdatedDate', response.getReturnValue().partStatusLastUpdatedDate);
                    component.set('v.laborStatusLastUpdatedDate', response.getReturnValue().laborStatusLastUpdatedDate);
                    component.set('v.workorderStatusToShowOnUI', response.getReturnValue().workOrderRecord.Status);
                    component.set('v.GCCUser', response.getReturnValue().GCCUser);
                    if (response.getReturnValue().disableEditOption) {
                        component.set('v.markOverallStatusReadOnly', true);
                    }
                    if (!response.getReturnValue().GCCUser ) { //adding Logic for GCC
                        this.checkForReadOnlyFlag(component);
                    }
                    else{
                        //adding Logic for GCC
                        this.checkForReadOnlyFlagGCC(component);
                    }
                    
                }
            });
            $A.enqueueAction(action);
        
        } catch (Err) {
           this.showToast(component, 'ERROR', $A.get(
                "$Label.c.Dispatch_ErrorMessageLoadingComponent"
            ), "Error");
        }
    },

    handleSaveWorkOrderHelper: function(component) {
        // Moved Code from Controller to Helper - Harsha Gangi Reddy
        try{
            component.set("v.validationError", false);
            component.set("v.errorMessage", ' ');
            var cancellationRequestStatus = $A.get("$Label.c.DispatchCancellationRequest");
            // added by rodrigo for defect 5187490 - start here
            if (component.find("statuses").get("v.value") === "Cancelled") {
                var subStatus = component.get('v.workorder.Sub_Status__c');
                if (!$A.util.isEmpty(subStatus) && subStatus !== null && subStatus !== undefined) {
                    if (subStatus.toUpperCase() === "REJECTED") {
                        component.set("v.validationError", true);
                        component.set("v.errorMessage", "The Status Transition is not Allowed.");
                        return;
                    }
                }
            }
            // added by rodrigo for defect 5187490 - ends here
          
            
        if(undefined !== component.find("commentsBox").get("v.value"))
         {     
            
          var commentwithoutspace = component.find("commentsBox").get("v.value").replace(/^\s+|\s+$/gm,'');
         }
            /*if (undefined !== component.find("statuses") && component.find("statuses").get("v.value") === cancellationRequestStatus &&
                undefined !== component.find("commentsBox") && (undefined === component.find("commentsBox").get("v.value") ||
                    component.find("commentsBox").get("v.value") === null || component.find("commentsBox").get("v.value") === ''|| commentwithoutspace.length === 0) ) {
                component.set('v.commentsRequiredForCancelRequest', 'Comments are required when requesting a cancellation');
                return;
            }*/

            component.set('v.workorder.Comments__c', component.find("commentsBox").get("v.value"));
            component.set('v.workorder.Status', component.find("statuses").get("v.value"));
            if (component.find("statuses").get("v.value") == 'Cancellation Request') {
                component.set('v.workorder.DispatchEvent__c', 'DISPATCH_CANCELLATION');
               //component.set('v.workorder.StatusCode__c', 'CNR');
            }
                
            
            var action = component.get("c.saveWorkOrder");
            action.setParams({
                workOrderRecord: component.get('v.workorder')
            });
            action.setCallback(this, function(response) {

                //var state = response.getState();
                if (response.getReturnValue() === 'SUCCESS') {
    
                    component.set('v.workorderStatusToShowOnUI', component.find("statuses").get("v.value"));
                    this.checkForReadOnlyFlag(component);
                    component.set('v.commentsRequiredForCancelRequest', '');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Status has been updated successfully."
                    });
                    toastEvent.fire();
                    component.set('v.showModal', false);
                } else {
                    component.set("v.validationError", true);
                    component.set("v.errorMessage", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component, 'ERROR', $A.get(
                "$Label.c.Dispatch_ErrorMessageLoadingComponent"
            ), "Error");
        }
    },

    handleRecordUpdatedHelper: function(component, event) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            this.doInitHelper(component);
           // record is loaded (render other component which needs record data value)
            //console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
            this.doInitHelper(component);
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
            this.doInitHelper(component);
        }
    }
})
({
    handleRecordUpdateHelper: function(component, event) {
        try {
            var eventParams = event.getParams();
            if (eventParams.changeType === "LOADED") {
                this.onPageLoad(component);
                if(!$A.util.isEmpty(component.find("SchedulingEditViewId"))){
                	component.find("SchedulingEditViewId").destroy();
                    component.set("v.readView", true);
                }
            } else if (eventParams.changeType === "CHANGED") {
                this.onPageLoad(component);
               	if(!$A.util.isEmpty(component.find("SchedulingEditViewId"))){
                	component.find("SchedulingEditViewId").destroy();
                    component.set("v.readView", true);
                }
            } else if (eventParams.changeType === "REMOVED") {
                // record is deleted
            } else if (eventParams.changeType === "ERROR") {
                // there’s an error while loading, saving, or deleting the record
            }
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in Fectching Information", "Error");
        }
    },

    //handle Event
    handleCloseEdit: function(component, event) {
        try {
            component.set("v.readView", event.getParam("openReadView"));
            $A.get("e.force:refreshView").fire();
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in Opening Read View", "Error");
        }
    },

    //Create Dynamic Component Asynchronosuly
    openWindow: function(component) {
        try {
            component.set("v.readView", false);
            $A.createComponent(
                "c:SchedulingEditForm", {
                    //Work Order Record Id
                    "recordId": component.get("v.recordId"),
                    //Schedule Enable Flag
                    "scheduleEnableFlag": component.get("v.scheduleEnableFlag"),
                    //Work Order Status
                    "workOrderStatus": component.get("v.simpleRecord.Status"),
                    // Date Field Label
                    "dateFieldLabel": component.get("v.dateFieldLabel"),
                    // Time Field Label
                    "timeFieldLabel":component.get("v.timeFieldLabel"),
                    // Component Header Label
                    "componentHeader":component.get("v.componentHeader"),
                    //Is Scheduled
                    "IsScheduled":component.get("v.simpleRecord.IsScheduled__c")
                },
                function(newcomponent) {
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(newcomponent);
                        component.set("v.body", body);
                    }
                }
            );
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in Opening Edit View", "Error");
        }
    },
   
    // to toast messages
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
    
    onPageLoad: function(component){
        try{
            var scheduleFlag = component.get("v.simpleRecord.Schedule_Enable_Flag__c");
            var entStartDate = component.get("v.simpleRecord.EntitlementStartDate__c");
            var entEndDate = component.get("v.simpleRecord.EntitlementEndDate__c");
            var scheduleInternalFlag = component.get("v.simpleRecord.schedulingInternalLogic__c");
            
            if(scheduleInternalFlag !== null && scheduleInternalFlag!==undefined){
                if(scheduleInternalFlag === 'Deferred'){
                    if(entStartDate!==null && entStartDate!==undefined && entEndDate!==null && entEndDate!==undefined){
                        if (!entStartDate.endsWith("Z")) {
                            entStartDate = entStartDate + 'Z';
                        }
                        
                        if (!entEndDate.endsWith("Z")) {
                            entEndDate = entEndDate + 'Z';
                        }
                    }
                }
                component.set("v.EntStartDateValue",entStartDate);
                component.set("v.EntEndDateValue",entEndDate);
            }
            
            if (!$A.util.isEmpty(scheduleFlag)) {
                component.set("v.scheduleEnableFlag", scheduleFlag);
            }
        } catch(Err){
            this.showToast(component,'Error',"Error Occured in Whiling Loading Component", "Error");
        }
    }
})
({
    recordUpdatedHelper: function(component, event) {
        try {
            var eventParams = event.getParams();
            if (eventParams.changeType === "CHANGED") {
                this.setEntitlementDates(component);
                this.setScheduleDates(component);
                this.reScheduleEnableFlag(component);
                this.gccCheck(component);
            } else if (eventParams.changeType === "LOADED") {
                this.setEntitlementDates(component);
                this.setScheduleDates(component);
                this.reScheduleEnableFlag(component);
                this.gccCheck(component);
            }
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in the Component : "+Err, "Error");
        }
    },
    reScheduleEnableFlag : function(component){
        try{
            var status = component.get("v.WorkOrderRecord.Status");
            var logicFlag = component.get("v.WorkOrderRecord.schedulingInternalLogic__c");
            var SerOption = component.get("v.WorkOrderRecord.Service_Option__c");
            var arrSerOpt = '';
            var serLevel = '';
            if(!$A.util.isEmpty(SerOption)){
                arrSerOpt = SerOption.split('-');
                serLevel = arrSerOpt[0];
            }      
            if (status==='Work In Progress' && !$A.util.isEmpty(logicFlag) && logicFlag==='Scheduled' && serLevel==='Next Business Day') {
                this.isInBusinessHours(component);
            } else {
                component.set("v.reScheduleEnableFlag",false);
            }  
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in the Component : "+Err, "Error");
        }
    },
    setEntitlementDates: function(component) {
        try {
            var EntitlementEndDate;
            var EntitlementStartDate;
            EntitlementEndDate = component.get("v.WorkOrderRecord.EntitlementEndDate__c");
            EntitlementStartDate = component.get("v.WorkOrderRecord.EntitlementStartDate__c");
            if (EntitlementStartDate !== null && EntitlementStartDate !== undefined) {
                if (!EntitlementStartDate.endsWith("Z")) {
                    EntitlementStartDate = EntitlementStartDate + 'Z';
                }
            }
            if (EntitlementEndDate !== null && EntitlementEndDate !==undefined) {
                if (!EntitlementEndDate.endsWith("Z")) {
                    EntitlementEndDate = EntitlementEndDate + 'Z';
                }
            }
            component.set("v.EntitlementEndDateValue",EntitlementEndDate);
            component.set("v.EntitlementStartDateValue",EntitlementStartDate);
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in the Component : "+Err, "Error");
        }
    },
    
    setScheduleDates: function(component) {
        try {
            var ScheduleEndDate;
            var ScheduleStartDate;
            ScheduleStartDate = component.get("v.WorkOrderRecord.StartDate");
            ScheduleEndDate = component.get("v.WorkOrderRecord.EndDate");
            
            if (ScheduleStartDate !== null && ScheduleStartDate !== undefined) {
                if (!ScheduleStartDate.endsWith("Z")) {
                    ScheduleStartDate = ScheduleStartDate + 'Z';
                }
            }
            if (ScheduleEndDate !== null && ScheduleEndDate !==undefined) {
                if (!ScheduleEndDate.endsWith("Z")) {
                    ScheduleEndDate = ScheduleEndDate + 'Z';
                }
            }
            component.set("v.ScheduleEndDateValue", ScheduleEndDate);
            component.set("v.ScheduleStartDateValue", ScheduleStartDate);
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in the Component : "+Err, "Error");
        }
    },
    
    helperOpenModalWindow : function (component) {
        try {
            component.set("v.openEditView",true);
            $A.createComponent(
                "c:DispatchServiceProviderEdit", {
                    "recordId":component.get("v.recordId"),
                    "ComponentLabel":component.get("v.ComponentLabel"),
                    "DSPFieldLabel":component.get("v.DSPFieldLabel"),
                    "ScheduleStartDateFieldLabel":component.get("v.ScheduleStartDateFieldLabel"),
                    "ScheduleEndDateFieldLabel":component.get("v.ScheduleEndDateFieldLabel"),
                    "TimezoneFieldLabel":component.get("v.TimezoneFieldLabel"),
                    "EntitlementStartDateFieldLabel":component.get("v.EntitlementStartDateFieldLabel"),
                    "EntitlementEndDateFieldLabel": component.get("v.EntitlementEndDateFieldLabel"),
                    "WorkOrderRecord":component.get("v.WorkOrderRecord"),
                    "EntitlementEndDateValue": component.get("v.EntitlementEndDateValue"),
                    "EntitlementStartDateValue": component.get("v.EntitlementStartDateValue")
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
            component.set("v.openEditView",false);
            this.showToast(component,'Error',"Error Occured in Opening Edit View : "+Err, "Error");
        }
    },
    //this will check if DSP need to be enabled for GCC users or not.
    gccCheck : function(component){
        var status = component.get("v.WorkOrderRecord.Status");
        var substatus = component.get("v.WorkOrderRecord.Sub_Status__c");
        if(!$A.util.isUndefinedOrNull(status)){
            //from these statuses GCC users can update the status
            var CancelledAllowedStatus=["pending review","approved","cancellation request","problem","rework","open"];
            if(CancelledAllowedStatus.includes(status.toLowerCase())){
                var recId = component.get("v.recordId");
                var CountryCode = component.get("v.WorkOrderRecord.CountryCode");
                var action = component.get("c.getGccConfigurations");
                action.setParams({
                    //set RecordId
                    workOrderId: recId,
                    CountryCode: CountryCode,
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        if(!$A.util.isUndefinedOrNull(result.GccUser)){
                            if( !$A.util.isUndefinedOrNull(status) && (status.toLowerCase().indexOf("problem")!== -1) && ( $A.util.isEmpty(substatus) ||(!$A.util.isUndefinedOrNull(substatus) && (substatus.toLowerCase().indexOf("pudo assignment failure") == -1  && substatus.toLowerCase().indexOf("box assignment failure") == -1 ) ) )   ){
                            	component.set("v.enableDSP",result.GccUser);
                            }
                            //firing the appevent from here
                            var gccEvent = $A.get("e.c:DisPatchGCCUserCheckEvent");
                            gccEvent.setParams({
                                "GccUser" : result.GccUser,
                                "woStatus" : status,
                                "woSubStatus" : substatus,
                                "woId": component.get("v.recordId"),
                            });
                            gccEvent.fire();

                        }
                        if(!$A.util.isUndefinedOrNull(result.DSPOptionsWrap)){
                            var dspOptions=this.createPicklist(component,result.DSPOptionsWrap);
                            component.set("v.dspOptions",dspOptions);
                        }
                    }
                });
                /*
                 *  Comment by Harsha 
                 *  Use @AuraEnabled(cacheable=true) in Apex Controller 
                 * 	instead of setStorable in JavaScript - Supported form version 44.0
                 */
                action.setStorable();
                $A.enqueueAction(action);
            }
            else{
                //firing the appevent from here
                //If the WO status is not problem then GCC user should not be able to update the record. 
                component.set("v.enableDSP",false);
                var gccEvent = $A.get("e.c:DisPatchGCCUserCheckEvent");
                gccEvent.setParams({
                    "GccUser" : false,
                    "woStatus" : status,
                    "woSubStatus" : substatus,
                    "woId": component.get("v.recordId"),
                });
                    gccEvent.fire();
                
            }
        }
    },
    handleOpenDSPEdit: function(component, event) {
        component.set("v.editDSP",true);
    },
    handleCancelEdit : function(component, event) {
        component.set("v.editDSP",false);
    },
    handleSaveDSP : function(component, event) {
        component.set("v.IsSpinner",true);
        var recId = component.get("v.recordId");
        var DSPCode= component.get("v.DSPValue");
        var DSPName="";
        if(!$A.util.isUndefinedOrNull(status)){
            var dspOptions=component.get("v.dspOptions",dspOptions);
            //console.log("DSPCode>>>"+DSPCode);
            var dspIndex= dspOptions.findIndex(item => item.value == DSPCode);
            DSPName= dspIndex >= 0? dspOptions[dspIndex].label: null;
        }
        var action = component.get("c.saveGccDSPUpdate");
        action.setParams({
            //set RecordId
            workOrderId: recId,
            DSPCode: DSPCode,
            DSPName: DSPName
        });
        action.setCallback(this, function(response) {
            component.set("v.IsSpinner",false);
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.editDSP",false);
                $A.get("e.force:refreshView").fire();
            }    
        });
        $A.enqueueAction(action);
    },
    //handle Event
    handleCloseEdit: function(component, event) {
        try {
            component.set("v.openEditView", event.getParam("openReadView"));
            $A.get("e.force:refreshView").fire();
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured in Opening Read View : "+Err, "Error");
        }
    },
    //Show Toast
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
    //create picklist from list of strings
    createPicklist: function(component, inputvalue) {
        var opts = [];
        if (inputvalue !== undefined && inputvalue.length > 0) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for (var i = 0; i < inputvalue.length; i = i + 1) {
                if (!$A.util.isEmpty(inputvalue[i])) {
                    opts.push({
                        class: "optionClass",
                        label: inputvalue[i].label,
                        value: inputvalue[i].value
                    });
                }
            }
        } else
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
        return opts;
    },
    
    // Call Apex to  Check Business Hours
    isInBusinessHours: function (component){
        try {
            component.set("v.IsSpinner",true);
            var action = component.get("c.checkBussinessHourLogic");
            if(!$A.util.isEmpty(action)){
                 action.setParams({
                    EntStartDate: component.get("v.EntitlementStartDateValue"),
                    Country: component.get("v.WorkOrderRecord.Country")
                });
                action.setCallback(this, function(response) {
                    component.set("v.IsSpinner",false);
                    var state = response.getState();
                	if (state === "SUCCESS") {
                    	var result = response.getReturnValue();
                    	if (!$A.util.isEmpty(result)) {
                            component.set("v.reScheduleEnableFlag",result);
                        } else {
                             component.set("v.reScheduleEnableFlag",false);
                        }
                    } else {
                        component.set("v.reScheduleEnableFlag",false);
                    }
                });
                $A.enqueueAction(action);
            }
        } catch (Err){
            this.showToast(component,'Error',"Error Occured in the Component : "+Err, "Error");
            component.set("v.IsSpinner",false);
            component.set("v.reScheduleEnableFlag",false);
        }
    }
})
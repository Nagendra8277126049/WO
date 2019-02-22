({
    doInitHelper: function(component) {
        this.getSlots(component);
    },

    //Get Slots When Component is loading
    getSlots: function(component) {
        try {
            // Turn On Spinner
            component.set("v.IsSpinner", true);
            var optsDate = [];
            var action = component.get('c.getReScheduleSlots');
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)) {
                        component.set('v.apexResult', result);
                        if (result.errorMessage === 'SUCCESS') {
                            if (!$A.util.isEmpty(result.sWrapperList)) {
                                var unique_array = [];
                                for (var i = 0; i < result.sWrapperList.length; i=i+1) {
                                    if (!$A.util.isEmpty(result.sWrapperList[i].startDate)) {
                                        if (unique_array.indexOf(result.sWrapperList[i].startDate) === -1) {
                                            unique_array.push(result.sWrapperList[i].startDate);
                                        }
                                    }
                                }
                                optsDate.push({
                                    label: "-- None --",
                                    value: ""
                                });
                                for (var j = 0; j < unique_array.length; j = j + 1) {
                                    if (!$A.util.isEmpty(unique_array[j])) {
                                        optsDate.push({
                                            label: unique_array[j],
                                            value: unique_array[j]
                                        });
                                    }
                                }
                                if (!$A.util.isEmpty(optsDate)) {
                                    component.set("v.dateOptions", optsDate);
                                }
                            } else {
                                this.showToast(component, 'Error', result.errorMessage, "Error");
                            }
                        } else {
                            this.showToast(component, 'Error', result.errorMessage, "Error");
                        }
                    }
                } else {
                    this.showToast(component, 'Error', 'Error Occured While Invoking Service Controller', "Error");
                }
                // Turn Off Spinner
                component.set("v.IsSpinner", false);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            // Turn Off Spinner
            component.set("v.IsSpinner", false);
            this.showToast(component, 'Error', Err, "Error");
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

    dateChangeHelper: function(component, value) {
        var result = component.get("v.apexResult");
        var sWrapperList = result.sWrapperList;
        var optsTime = [];
        optsTime.push({
            label: "-- None --",
            value: ""
        });
        for (var i = 0; i < sWrapperList.length; i=i+1) {
            if (sWrapperList[i].startDate === value) {
                optsTime.push({
                    label: sWrapperList[i].startTime + ' - ' + sWrapperList[i].endTime,
                    value: sWrapperList[i].startDateTime + '|' + sWrapperList[i].endDateTime
                });
            }
        }
        if (!$A.util.isEmpty(optsTime)) {
            component.set("v.timeOptions", optsTime);
        }
    },
    
    handleSaveHelper: function(component) {
        component.set("v.errorMessage", '');
        var sDate = component.get("v.selectedDate");
        var sTime = component.get("v.selectedTime");
        if ($A.util.isEmpty(sDate) || $A.util.isEmpty(sTime)) {
            component.set("v.errorMessage", 'Please Select Valid Date and Time');
        } else {
            this.callApexToSave(component);
        }
    },
    
    callApexToSave : function (component){
        try {
            // Turn On Spinner
            component.set("v.IsSpinner", true);
            var dateTime = component.get("v.selectedTime");
            var arrDateTime = dateTime.split('|');
            var scheduleStartTime = arrDateTime[0];
            var scheduleEndTime = arrDateTime[1];
            var action = component.get('c.saveRescheduledSlot');
            action.setParams({
                woRecordId: component.get("v.recordId"),
                scheduleStartTime:scheduleStartTime ,
                scheduleEndTime:scheduleEndTime
            });
            action.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)) {
                        if (result === 'SUCCESS') {
                            this.closeEditScreen(component);
                        } else {
                            this.showToast(component, 'Error', result, "Error");
                        }
                    } else {
                        this.showToast(component, 'Error', 'Error Occured While Invoking the Service', "Error");
                    }
                } else {
                    this.showToast(component, 'Error', 'Error Occured While Invoking Server Side Controller', "Error");
                }
                // Turn Off Spinner
                component.set("v.IsSpinner", false);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            // Turn Off Spinner
            component.set("v.IsSpinner", false);
            this.showToast(component, 'Error', Err, "Error");
        }
    },
    // fire Event - to open Read View
    closeEditScreen: function(component) {
        try{
            var openReadFormEvent = component.getEvent("openReadFormEvent");
            var setFalse = false;
            openReadFormEvent.setParams({
                "openReadView": setFalse
            });
            openReadFormEvent.fire();
            component.destroy();
        } catch (Err) {
            this.showToast(component, 'Error', Err, "Error");
        }
    },
    handleChangeHelper: function(component,event) {
        try{
            component.set("v.errorMessage", '');
            if (event.getSource().get("v.name") === 'date') {
                if (!$A.util.isEmpty(event.getSource().get("v.value"))) {
                    this.dateChangeHelper(component, event.getSource().get("v.value"));
                } else {
                    component.set("v.errorMessage", 'Please Select Valid Date');
                    var Opts = [];
                    Opts.push({
                        label: "-- None --",
                        value: ""
                    });
                    component.set("v.timeOptions", Opts);
                }
            } else if (event.getSource().get("v.name") === 'time'){
                if ($A.util.isEmpty(event.getSource().get("v.value"))) {
                    component.set("v.errorMessage", 'Please Select Valid Time');   
                }
            }
        } catch (Err) {
            this.showToast(component, 'Error', Err, "Error");
        }
    }
})
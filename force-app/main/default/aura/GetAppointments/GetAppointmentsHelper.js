/**
 * Created by tdavis on 10/23/18.
 */
({
    fetchServiceAppointment: function (component, event, helper) {
        var action = component.get("c.getSA");
        var serviceAppointmentId = component.get("v.recordId");

        action.setParams({
            serviceAppointmentId: serviceAppointmentId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var sa = response.getReturnValue();
                
                //Added by Pawan Kumar
                if(sa.GeocodeAccuracy__c =='NULL' || sa.GeocodeAccuracy__c =='Unknown')
                {
                    var errMessage = 'Address is Not Accurate. Please enter valid location and try again.';
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Failure!",
                        message: errMessage,
                        type: "error"
                    });
                    
                    
                    component.find("viewTimeSlots").set("v.disabled", true);
                    component.find("createAppointmentTask").set("v.disabled", true);
                    component.set("v.error", errMessage);
                    
                    toastEvent.fire();
                }
                
                component.set("v.serviceAppointment", sa);
            } else {
                alert('Error in getting data');
            }
        });

        component.find("chooseSlotButton").set("v.disabled", true);

        $A.enqueueAction(action);
    },

    fetchTimeSlots: function (component, event, helper) {
        component.find("chooseSlotButton").set("v.disabled", true);
        component.set("v.selectedSlot", '');

        var action = component.get("c.getAppointmentsCallout");
        var serviceAppointmentId = component.get("v.recordId");

        action.setParams({
            saId: serviceAppointmentId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");

            if (state === 'SUCCESS') {
                var slots = [];
                var resp = response.getReturnValue();

                for (var key in resp) {
                    slots.push({value: resp[key], key: key});
                }

                component.set("v.slots", slots);

                console.log(slots);

                if (!$A.util.isEmpty(slots)) {
                    toastEvent.setParams({
                        title: "Slots Loaded",
                        message: "Please choose a slot",
                        type: "success"
                    });
                    toastEvent.fire();

                    var div = document.getElementById("availableSlotsDiv");
                    div.style.display = 'block';
                } else {
                    toastEvent.setParams({
                        title: "No Slots Returned",
                        message: "Please choose different dates",
                        type: "info"
                    });
                    toastEvent.fire();
                }
            } else {
                toastEvent.setParams({
                    title: "No Slots Returned",
                    message: "Please contact your System Administrator",
                    type: "error"
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    createClickTask: function (component, event, helper) {
        var action = component.get("c.processTaskExCallout");
        var serviceAppointmentId = component.get("v.recordId");
        var chosenSlot = component.get("v.selectedSlot");
        var isSLA = component.get("v.isSLA");
        var isAppointmentTask = component.get("v.isAppointmentTask");

        //alert(chosenSlot);

        action.setParams({
            saId: serviceAppointmentId,
            slot: chosenSlot,
            isSLA: isSLA,
            isAppointmentTask: isAppointmentTask
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");

            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();

                if (resp === 'Success') {
                    toastEvent.setParams({
                        title: "Task Created & Assigned",
                        message: "FSE task has been assigned from the chosen slot.",
                        type: "success"
                    });
                    toastEvent.fire();
                } else if (resp === 'ScheduleFailed') {
                    toastEvent.setParams({
                        title: "Task Created",
                        message: "No resource was assigned to the task in FSE. Please coordinate with RM",
                        type: "info"
                    });
                    toastEvent.fire();
                } else {
                    toastEvent.setParams({
                        title: "Task Not Created",
                        message: "Please contact your System Administrator",
                        type: "error"
                    });
                    toastEvent.fire();
                }
            } else {
                toastEvent.setParams({
                    title: "Task Not Created",
                    message: "Please contact your System Administrator",
                    type: "error"
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    }
})
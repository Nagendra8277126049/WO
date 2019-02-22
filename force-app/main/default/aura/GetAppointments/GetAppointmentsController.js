/**
 * Created by tdavis on 10/23/18.
 */
({
    getServiceAppointment: function (component, event, helper) {
        helper.fetchServiceAppointment(component, event, helper);
    },

    doCallout: function (component, event, helper) {
        var sa = component.get("v.serviceAppointment");

        if (sa.Work_Order__r.Schedule_Type__c === 'Appointment')
        {
            helper.fetchTimeSlots(component, event, helper);
        }

        if (sa.Work_Order__r.Schedule_Type__c === 'Activity')
        {
            component.set("v.isSLA", true);

            component.set("v.isOpen", false);
            helper.createClickTask(component, event, helper);
        }
    },

    /*viewTimeSlots: function (component, event, helper) {
        helper.fetchTimeSlots(component, event, helper);
    },*/

    chooseSlot: function (component, event, helper) {
        component.set("v.isOpen", false);
        helper.createClickTask(component, event, helper);
    },

    /*createSLATask: function (component, event, helper) {
        component.set("v.isSLA", true);

        component.set("v.isOpen", false);
        helper.createClickTask(component, event, helper);
    },*/

    createAppointmentTask: function (component, event, helper) {
        component.set("v.isAppointmentTask", true);

        component.set("v.isOpen", false);
        helper.createClickTask(component, event, helper);
    },

    onSlotSelection: function (component, event, helper) {
        var selectedSlot = component.find("slotSelection").get("v.value");
        var selectedSlotObj = JSON.parse(selectedSlot);
        var startDate = new Date(selectedSlotObj.Start);
        var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

        component.set("v.selectedKey", days[startDate.getDay()] + ', ' + startDate.toLocaleString());

        if (selectedSlot === '') {
            component.find("chooseSlotButton").set("v.disabled", true);
        }
        else {
            component.find("chooseSlotButton").set("v.disabled", false);
        }
    },

    resetSelectedSlot: function (component, event, helper) {
        component.find("chooseSlotButton").set("v.disabled", true);
        component.set("v.selectedSlot", '');
        component.set("v.slotSelection", '');
        component.set("v.slots", null);

        var div = document.getElementById("availableSlotsDiv");
        div.style.display = 'none';
    },

    onIsSLAChange: function (component, event, helper) {
        var isSLA = component.find("isSLA").get("v.value");
        var div = document.getElementById("availableSlotsDiv");

        if (isSLA) {
            component.find("viewTimeSlots").set("v.disabled", true);
            component.find("createSLATask").set("v.disabled", false);
            div.style.display = 'none';

        } else {
            component.find("viewTimeSlots").set("v.disabled", false);
            component.find("createSLATask").set("v.disabled", true);
            div.style.display = 'block';
        }
    },

    openModel: function (component, event, helper) {
        component.set("v.isOpen", true);
    },

    closeModel: function (component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    // this function automatic call by aura:waiting event  
    runSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
   	},
    
 	// this function automatic call by aura:doneWaiting event 
    stopSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.spinner", false);
    }
})
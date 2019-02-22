({
	doInit:function(component,event,helper) {
		//helper.getSlots(component);
	},
    gotoKBURL : function (component, event, helper) {
        helper.gotoKBURLHelper();
    },
    saveRecord:function(component,event,helper){
        helper.saveRecordHelper(component);
    },
    closeEditForm:function(component,event,helper){
        helper.closeMe(component);
    },
    dateValueChange:function(component,event,helper){
        helper.pullDatesHelper(component);
    },
    timeValueChange:function(component,event,helper){
        helper.changeTimeSlotHelper(component);
    },
    recordUpdated:function(component,event,helper){
        helper.recordUpdatedHelper(component,event);
    },
    popupButtonClicked:function(component,event,helper){
        helper.popupButtonClickedHelper(component,event);
    },
})
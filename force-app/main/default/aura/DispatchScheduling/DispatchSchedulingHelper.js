({
	getSlots : function(component, event) {
        try{
            //call apex class method    
            //var sWorkOrderNo = '00000006'; 
            var sWorkOrderNo = component.get("v.cWorkOrderNum");
            var recID = component.get("v.recordId");
            //    alert('ScheduleSlotComp' + recID);
            //var action = component.get('c.FetchSlotInfo');
            var action = component.get('c.getScheduleSlots');
            action.setParams({  workOrderNo : recID  });
            action.setCallback(this,function(response){
                //store state of response
                var state = response.getState();
                console.log('state - ' + state);
                if (state === "SUCCESS") {
                    //set response value in objClassController attribute on component
                    console.log('response.getReturnValue() - ' + JSON.stringify(response.getReturnValue()));
                    component.set('v.objClassController', response.getReturnValue());
                    
                    //component.set('v.isDeferral', component.get('v.objClassController.isDeferral'));
                    
                    //alert('return response is --->'+response.getReturnValue());
                    //alert('v.objClassController --->'+component.get('v.objClassController'));
                    //alert('v.objClassController --->'+JSON.stringify(component.get('v.objClassController.scheduleWrapList')));
                	//alert('v.objClassController --->'+JSON.stringify(component.get('v.objClassController.isDeferral')));
                }
            });
            $A.enqueueAction(action);
		}
		catch(Err){
           console.log(Err);
           //Toast Error Message to User
           this.showToast(component,'Error', "Error Occured While Loading the Slots", "Error");
        } 
	},
    setCFSAttribute : function(component, event) {
        try{
            alert(2);
            var cmpTarget = event.getSource();
            var buttonName = event.getSource().get("v.name");
            var buttonValue = event.getSource().get("v.value");
            var buttonLabel = event.getSource().get("v.label");
            
            //var buttonId = event.getSource().get("v.id");
            console.log(buttonValue);
            component.set("v.whichButton", buttonLabel);
            component.set("v.cConcatenatedDateTime", buttonValue);
            var currSlot = component.get("v.cCurrSelectSlot"); 
            var concatenatedDateTime = buttonValue.split('|');
            var startEntitledDate = concatenatedDateTime[0];
            var endEntitleDate = concatenatedDateTime[1];
            console.log('current slot : ' + currSlot);
            alert(3);
            if (currSlot=='') {
                alert(4);
                component.set("v.cCurrSelectSlot", buttonName);
                $A.util.addClass(cmpTarget, 'selectedbutton');  
                this.setDeferralDates(component, startEntitledDate, endEntitleDate);
            }
            else {
                if (buttonName == currSlot) 
                {
                    alert(5);
                    
                    component.set("v.cCurrSelectSlot", "");
                    $A.util.removeClass(cmpTarget, 'selectedbutton');  
                    $A.util.addClass(cmpTarget, 'unselectedbutton'); 
                    this.setDeferralDates(component, '', '');
                }
                else {
                    
                    alert(6);
                    
                    var cmpSlotInstance = component.find("btnSlotId");
                    var cmpCurrSlot;
                    for(var i = 0; cmpSlotInstance.length; i++) {
                        var tmpButtonName = cmpSlotInstance[i].get("v.name");
                        if (tmpButtonName == currSlot) {
                            cmpCurrSlot = cmpSlotInstance[i];
                            console.log(tmpButtonName);
                            break;
                        }
                    }  
                    
                    alert(7);
                    
                    this.setDeferralDates(cmp, startEntitledDate, endEntitleDate);
                    $A.util.removeClass(cmpCurrSlot, 'selectedbutton');  
                    $A.util.addClass(cmpCurrSlot, 'unselectedbutton');  
                    cmp.set("v.cCurrSelectSlot", buttonName);
                    $A.util.addClass(cmpTarget, 'selectedbutton');  
                    $A.util.removeClass(cmpTarget, 'unselectedbutton');
                    
                    alert(8);
                }                
            }
		}
		catch(Err){
           console.log(Err);
           //Toast Error Message to User
           this.showToast(component,'Error', "Error Occured While Loading the Slots", "Error");
        } 
        
    },
    
    setDeferralDates : function(component, startEntitledDate, endEntitleDate) {
        try{
            alert(9);
            
            var recID = component.get("v.recordId");
            var isDefer = component.get("v.isDeferral");
            var currSlotsObject = component.get('v.objClassController');
            if (isDefer==true)
            {
                alert(10);
                
                var action = component.get('c.setDeferralDate');
                action.setParams({woRecordId : recID,
                                  entitlementStartDate : startEntitledDate,
                                  entitlementEndDate : endEntitleDate});
                action.setCallback(this,function(response){
                    //store state of response
                    var state = response.getState();
                    console.log('state - ' + state);
                    if (state === "SUCCESS") {
                        //set response value in objClassController attribute on component
                        console.log('response.getReturnValue() - ' + JSON.stringify(response.getReturnValue()));
                        alert(13);
                        
                        //component.set('v.objClassController', response.getReturnValue());
                        
                        alert(12);
                        
                        //alert('return response is --->'+response.getReturnValue());
                        //alert('v.objClassController --->'+component.get('v.objClassController'));
                        //alert('v.objClassController --->'+JSON.stringify(component.get('v.objClassController.scheduleWrapList')));
                        //alert('v.objClassController --->'+JSON.stringify(component.get('v.objClassController.scheduleSlotListHeader')));
                    }
                });
                $A.enqueueAction(action); 
                alert(11);
                //alert('v.objClassController --->'+JSON.stringify(component.get('v.objClassController.scheduleWrapList')));
                //        alert('v.objClassController --->'+JSON.stringify(currSlotsObject));
                //component.get('v.objClassController', currSlotsObject);
            }
		}
		catch(Err){
           console.log(Err);
           //Toast Error Message to User
           this.showToast(component,'Error', "Error Occured While Saving the Deferral Slots", "Error");
        } 
        
    },
    
    showToast : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message, 
            "type": type,
            //"mode": "sticky",
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
})
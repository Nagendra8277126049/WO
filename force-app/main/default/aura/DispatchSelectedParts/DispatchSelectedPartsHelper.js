({
	//To toast 
    showToast: function(component, title, message, type) {
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
   	doInitHelper: function(component) {
        try {
            // Record Id
            var recId = component.get("v.recordId");
            
            var action = component.get("c.getSelectedParts");
            action.setParams({
                //set RecordId
                workOrderId: recId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result !== null && result !== undefined) {
                        component.set("v.SelectedPartItems", result);
                    } 
                    
                    /* Added by Divyansh */
                    var custs = [];// or var map = {};
                    for(var i=0; i < result.length; i++) {
                        
                        var res = result[i].woLineItem;
                        custs.push({value: res, key:res['Id']}); // to add values in map
                    }
                    
                    component.set("v.mapOfWOL", custs);
                    /* Added by Divyansh */
                } 
            });
            $A.enqueueAction(action);
            
        } catch (Err) {
            this.showToast(component, 'ERROR', $A.get("Error occured in loading selected parts."), "Error");
        }
    },
    getAllSelectedParts : function(component) {
        try {
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__DispatchSelectedpartsAll"
                },
                "state": {
                    "workOrderId": component.get("v.recordId")
                }
            };
            navService.navigate(pageReference);
        } catch(Err){
            console.log(Err);
           	this.showToast(component,'ERROR',"Error occured in loading service events.","Error");
        }    
	},
    showDetailsPopupWindow : function(component, event) {
        
        /* Added by Divyansh */
        var targetHoverId = event.currentTarget.id;
        var targetKey = event.currentTarget.title;
        var mapVal = component.get("v.mapOfWOL");
        
        var woLineInfo;
        
        for(var i = 0; i< mapVal.length; i ++) {
            
            var arrElemWOL = mapVal[i];
            
            if(arrElemWOL.key == targetHoverId) {
                
                woLineInfo = arrElemWOL.value;
                break;
            }
        }
        
        var cmpTarget = component.find('popOverSectionId');
        if(event.type == 'mouseover') {
            
            component.set("v.ISPOCBBacklogETA", woLineInfo.ISPOCBBacklogETA__c);
            component.set("v.ISPOCBMessage", woLineInfo.ISPOCBMessage__c);
            component.set("v.partNumberVal", woLineInfo.PartNumber__c);
            
            $A.util.removeClass(cmpTarget, 'slds-hide');
        	$A.util.addClass(cmpTarget, 'slds-show');
        }
        else if(event.type == 'mouseout') {
            
            $A.util.addClass(cmpTarget, 'slds-hide');
        	$A.util.removeClass(cmpTarget, 'slds-show');
        }
        
    }
})
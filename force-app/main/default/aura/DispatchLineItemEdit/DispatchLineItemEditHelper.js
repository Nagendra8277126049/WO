({
    populateLineItemDetails : function(component, event, helper) {
        try{
            helper.turnOnSpinner(component);
            var lineItemId=component.get("v.recordId");
            var quantityList = [];
            for(var i = 1; i<=50; i++){
                quantityList.push({value:i.toString(), label:i.toString()});
            }
            component.set('v.quantityList',quantityList);
            
            var action = component.get("c.fetchworkOrderLineItem");
            action.setParams({lineItemId : lineItemId});
            action.setCallback(this, function(response){
                component.set('v.part',response.getReturnValue());
                console.log('part is @@@>>>'+JSON.stringify(response.getReturnValue()));
                var quantity=response.getReturnValue().Part_Quantity__c;
                var returnQuantityVal=parseInt(response.getReturnValue().Return_Qty__c);
                if(returnQuantityVal==1){
                    //component.set("v.returnQuantityCheck",true);
                }
                component.set("v.quantityObject",quantity);
                component.set('v.oldQuantityValue',quantity);
                helper.turnOffSpinner(component);
                //component.find('quantity').set('v.value',component.get('v.part.Part_Quantity__c'));
                //component.set('v.oldQuantityValue',component.find('quantity').get('v.value'));
                
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            helper.turnOffSpinner(component);
            console.log("Error Message controller 1 "+Err);
            helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForDisplayingAutoParts"), "Error");            
        }
    },
    // turn off Spinner  
    turnOffSpinner: function (component) {
        try{
            console.log('Inside the turn off spinner');
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            $A.util.removeClass(spinner, 'slds-show');
            $A.util.addClass(spinner,'slds-hide');
        }catch(Err){
            console.log("Error While Turning on the Spinner ==>  "+Err);
        }
    },
    // turn on spinner
    turnOnSpinner: function (component) {
        try{
            console.log('Inside the turner on');
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        }catch(Err){
            console.log("Error While Turning off the Spinner ==>  "+Err);
        }
    },
    saveRecordHelper : function(component, event, helper) {
        console.log("%%%%Himani%%%%");
        helper.saveWorkorderLineItem(component, event, helper);
        
    },
    /*closeCurrentTabEvent : function(component, event, helper) {
        var closeEvent = $A.get("e.c:closeCurrentTab");
        closeEvent.fire();
    },*/
    validateQuantityChange : function(component, event, helper){
        try{ 
            helper.turnOnSpinner(component);
            var quantityObject=component.get('v.quantityObject');
            component.set('v.part.Part_Quantity__c',quantityObject);
            var oldPartQuantity = component.get('v.oldQuantityValue');
            console.log('oldPartQuantity @@@'+oldPartQuantity);
            var newquantityObject = component.get('v.quantityObject');
            
            if(oldPartQuantity != newquantityObject){
                
                var part = component.get("v.part");
                var action = component.get("c.validateWorkOrderLineItem");
                action.setParams({ lineItem  : part});
                action.setCallback(this, $A.getCallback(function (response) {
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        component.set("v.part", response.getReturnValue().WorkOrderLineItemVal);
                    }
                    else{
                        component.set('v.showErrorOnValidation', true);
                        component.set('v.errorToDisplay',response.getReturnValue().responseMessage);
                        //helper.saveRecordHelper(component, event, helper);
                    }
                    helper.turnOffSpinner(component);
                }));
                $A.enqueueAction(action);
            }
        }
        catch(Err){
            helper.turnOffSpinner(component);
            console.log("Error Message controller 1 "+Err);
            helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForDisplayingAutoParts"), "Error");            
        }
    },
    saveWorkorderLineItem : function(component, event, helper){
        try{
            helper.turnOnSpinner(component);
            var partDetails=component.get("v.part");
            console.log("partDetails.Do_not_Sub__c"+partDetails.Do_not_Sub__c);
            component.set("v.simpleRecord.Part_Quantity__c", component.get("v.quantityObject"));
            component.set("v.simpleRecord.Warning_Message__c", partDetails.Warning_Message__c);
            component.set("v.simpleRecord.Do_not_Sub__c", partDetails.Do_not_Sub__c);  
            component.find("LineItemRecord").saveRecord($A.getCallback(function(saveResult) {
                
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Success");
                    console.log(saveResult);
                    helper.turnOffSpinner(component);
                    helper.closeFocusedTabHelper(component, event, helper);
                    
                }
                else if (saveResult.state === "INCOMPLETE") {
                    console.log("INCOMPLETE"+partDetails.Do_not_Sub__c);
                    helper.turnOffSpinner(component);
                    helper.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
                } else if (saveResult.state === "ERROR") {
                    console.log("Error"+partDetails.Do_not_Sub__c);
                    helper.turnOffSpinner(component);
                    helper.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
                }
            }));
        }
        catch(Err){
            helper.turnOffSpinner(component);
            console.log("Error Message controller 1 "+Err);
            helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForDisplayingAutoParts"), "Error");            
        }
    },
    /*saveWorkorderLineItem : function(component, event, helper){
    	
        var action = component.get('c.saveLineItem');
        action.setParams({lineItem : component.get('v.part')});
        action.setCallback(this, function(response){
        	if(response.getReturnValue() === 'SUCCESS')
            	helper.showToast("",'SUCCESS','Line Item saved successfully', 'Confirm'); 
            else 
                helper.showToast("",'ERROR','Error while saving the Line Item', 'Error'); 
        });
        $A.enqueueAction(action); 
	},*/
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
    closeFocusedTabHelper: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        if(workspaceAPI){    
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
    },
    saveDoNotSub:function(component, event,ischecked){
        component.set("v.part.Do_not_Sub__c",ischecked);   
    }
})
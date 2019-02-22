({
    loadManualSelectionReason: function(component) {
        try {
            var recId = component.get("v.recordId");
            var selAction = component.get("c.getManualSelectionReason");
            selAction.setParams({
                WorkOrderId: recId
            });
            selAction.setCallback(this, $A.getCallback(function(response) {
                var state = response.getState();
                if (state === "SUCCESS" && response.getReturnValue() && response.getReturnValue().selectedManualReasonList !== null && response.getReturnValue().selectedManualReasonList !== undefined) {
                    var manualSelectOptionList = [];
                    for (var i = 0; i < response.getReturnValue().selectedManualReasonList.length; i = i + 1) {
                        manualSelectOptionList.push({
                            value: response.getReturnValue().selectedManualReasonList[i],
                            label: response.getReturnValue().selectedManualReasonList[i]
                        });
                    }
                    component.set('v.manualSelectOption', manualSelectOptionList);
                }
            }));
            $A.enqueueAction(selAction);
        } catch (Err) {
            this.showToast("", 'ERROR', 'Error Occured While Loading Manual Part  Selection : ' + Err, "Error");
        }
    },
    manualSelectChangeHandler: function(component, event, helper) {
        try {
        } catch (Err) {
        }
    },
    loadCommodityParts: function(component, event, helper) {
        try {
            helper.turnOnSpinner(component);
            var spmdLink = $A.get("$Label.c.SPMD_URL");
            spmdLink += component.get("v.serviceTag");

            component.set("v.spmdLink", spmdLink);
            var action = component.get("c.getReplacementParts");
            var commodityValue = [];
            commodityValue = component.get("v.commodityArray");
            var quantityList = [];
            for (var i = 1; i <= 50; i = i + 1) {
                quantityList.push({
                    value: i.toString(),
                    label: i.toString()
                });
            }
            component.set('v.quantityList', quantityList);
            var recId = component.get("v.recordId");
            action.setParams({
                WorkOrderId: recId,
                assetId: '02im0000002DbTvAAK',
                serviceTag: component.get("v.serviceTag"),
                addressBUID: component.get("v.addressBUID"),
                listCommodities: commodityValue,
                searchText: component.get("v.searchText")
            });

            action.setCallback(this,
                $A.getCallback(
                    function(response) {
                        helper.turnOffSpinner(component);
                        var state = response.getState();

                        if (state === "SUCCESS") {
                            
                            if (response.getReturnValue()[0].MessageBody === 'success') {
                                var selectedPartsMap = component.get("v.selectedPartsMap");
                                if (commodityValue.length < 1) {
                                    commodityValue[0] = response.getReturnValue()[0].WorkOrderLineItemVal.PartCommodity__c;
                                    component.set("v.commodityArray", commodityValue);
                                }
                                var selPartsGrouped = helper.selPartsGroupBuilder(response.getReturnValue(), commodityValue);
                                component.set("v.PartList", selPartsGrouped); //updating for grouping of defective component
                                for (var key = 0; key < response.getReturnValue().length;) {
                                    if (response.getReturnValue()[key].WorkOrderLineItemVal.Selected_By_user__c) {
                                        var LineItemId = response.getReturnValue()[key].WorkOrderLineItemVal.Id;
                                        var LineItemValues = response.getReturnValue()[key].WorkOrderLineItemVal;
                                        selectedPartsMap[LineItemId] = LineItemValues;
                                    }
                                    key = key + 1;
                                }
                                component.set("v.selectedPartsMap", selectedPartsMap);
                                var cmpTarget = component.find('c-container');
                                $A.util.removeClass(cmpTarget, 'c-container_hide');
                                $A.util.addClass(cmpTarget, 'c-container_show');
                            } else {
                                helper.showToast("", 'ERROR', response.getReturnValue()[0].MessageBody, "Error");
                            }
                        }
                    }));
            $A.enqueueAction(action);
            //helper.turnOffSpinner(component);
        } catch (Err) {
            helper.showToast("", 'ERROR',Err, "Error");
        }
    },
    //This Function will build the wrapper that will be displayed in the UI.
    selPartsGroupBuilder: function(listval, commodityValue) {
        var ListValInput = listval;
        var topLevelObject = [];

        if (ListValInput) {
            for (var cm = 0; cm < commodityValue.length;) {
                var belowLevelObject = [];
                for (var key = 0; key < ListValInput.length;) {
                    if (commodityValue[cm] === ListValInput[key].WorkOrderLineItemVal.PartCommodity__c) {
                        belowLevelObject.push(ListValInput[key]);
                    }
                    key = key + 1;
                }
                var topLevelObjectval = {};
                topLevelObjectval.key = commodityValue[cm];
                topLevelObjectval.Listval = belowLevelObject;
                topLevelObject.push(topLevelObjectval);
                cm = cm + 1;
            }
        }
        return topLevelObject;
    },
    showToast: function(component, title, message, type) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type,
                "mode": "pester",
                "duration": "3000"
            });
            toastEvent.fire();
        } catch (Err) {
            console.log(Err);
        }
    },
    // turn off Spinner  
    turnOffSpinner: function(component) {
        try {
            component.set("v.shouldDisplaySpinner",false);
            var spinner = component.find("mySpinnerMpsScreen");
            $A.util.toggleClass(spinner, "slds-hide");
            $A.util.removeClass(spinner, 'slds-show');
            $A.util.addClass(spinner, 'slds-hide');
        } catch (Err) {
            console.log("Error While Turning on the Spinner ==>  " + Err);
        }
    },

    // turn on spinner
    turnOnSpinner: function(component) {
        try {
            component.set("v.shouldDisplaySpinner",true);
            console.log("Inside Turn On Spinner ==> " );
                var spinner = component.find("mySpinnerMpsScreen");
                console.log("spinner>>>"+spinner);
                $A.util.removeClass(spinner, 'slds-hide');
            	$A.util.addClass(spinner, 'slds-show');
            //$A.util.toggleClass(spinner, "slds-hide");
        } catch (Err) {
            console.log("Error While Turning on the Spinner ==>  " + Err);
        }
    },
    /* --- Commented By Harsha  - 2 different methods exists with Same Name
    handleClearHelper : function (component, event, helper){
        try{
            
            component.set("v.partsList", []);
            component.set("v.commodityArray", []);
            var flow = component.find("flowOnClick");
            var workOrderId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : 'WorkOrderRecordId',
                    type : 'String',
                    value : workOrderId
                    //value : component.get("v.recordId")
                }
            ];
            flow.startFlow("Work_Order_Manual_Part_Selection", inputVariables);
        } catch(Err){
            console.log("Error Message controller 1 "+Err);
            helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageCancellingParts"), "Error");            
        }
    },
    */

    checkboxChangeHandler: function(component, event) {
        var cboxRowInput = event.getSource();
        var selectedCheckRow = cboxRowInput.get("v.value");
        if (selectedCheckRow) {
            var partNumber = cboxRowInput.get("v.name");
            var selectedChkBoxElementsArr = [];
            selectedChkBoxElementsArr.push(partNumber);
        }
    },

    handleSelectPart: function(component, event, helper) {
        try {
            var totalPartList = component.get("v.PartList");
            var selectedPartsMap = component.get("v.selectedPartsMap");
            //var selectedPartslist = component.get("v.selectedPartslist");
            var validatedParts = component.get("v.validatedParts");
            var selectedParts = [];
            var displayValidateParts = false;
            var displayAddParts = false;
            var selectedPart = event.getSource();
            var slctCheckRow = selectedPart.get("v.value");
            if (slctCheckRow === true) {
                component.set("v.enableQuantity", true);
            } else {
                component.set("v.enableQuantity", false);
            }
            //var indexNum = selectedPart.get("v.text");
            var LineItemId = selectedPart.get("v.text");
            for (var k = 0; k < totalPartList.length;) {
                var partlistdef = [];
                partlistdef = totalPartList[k].Listval;

                if (partlistdef) {
                    for (var j = 0; j < partlistdef.length;) {
                        if (partlistdef[j].WorkOrderLineItemVal.Id === LineItemId) {
                            selectedPartsMap[LineItemId] = partlistdef[j].WorkOrderLineItemVal;
                        }
                        j = j + 1;
                    }
                }
                k = k + 1;
            }

            var counter = 0;
            component.set("v.selectedPartsMap", selectedPartsMap);
            Object.keys(selectedPartsMap).forEach(function(key) {
                if (selectedPartsMap[key].Selected_By_user__c && !validatedParts && !selectedPartsMap[key].Selected_Work_Order__c) {
                    displayValidateParts = true;
                    counter=counter+1;
                }
                if (selectedPartsMap[key].Selected_By_user__c && validatedParts && !selectedPartsMap[key].Selected_Work_Order__c) {
                    displayAddParts = true;
                    counter=counter+1;
                }
                if (!selectedPartsMap[key].Selected_Work_Order__c) {
                    selectedParts.push(selectedPartsMap[key]);
                }
            });
            if (counter >= 50) {
                component.set("v.disablePartSelection", true);
            } else {
                component.set("v.disablePartSelection", false);
            }
            component.set("v.selectedPartslist", selectedParts);
            component.set("v.displayValidateParts", displayValidateParts);
            component.set("v.displayAddParts", displayAddParts);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForSelectingParts"), "Error");
        }
    },
    //
    /*  DEFECT 5462004 - Harsha -08/21/2018  - Commented
    handleValidatePartsHelper : function (component, event, helper){
        try{
            helper.turnOnSpinner(component);
            var selectedPartslist = component.get("v.selectedPartslist");
            var action = component.get("c.validateSelectedParts");
            action.setParams({ selectedParts : selectedPartslist});
            action.setCallback(this, $A.getCallback(function (response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    helper.turnOffSpinner(component);
                    var commodityValue = component.get("v.commodityArray");
                    var selPartsGrouped=helper.selPartsGroupBuilder(response.getReturnValue(),commodityValue);
                    var selectedPartslist=[];
                    for(var key=0;key<response.getReturnValue().length;){
                        if(response.getReturnValue()[key].WorkOrderLineItemVal && response.getReturnValue()[key].WorkOrderLineItemVal.Selected_By_user__c){                        
                            var LineItemValue=response.getReturnValue()[key].WorkOrderLineItemVal;
                            selectedPartslist.push(LineItemValue);
                        }
                        key++;
                    }
                    component.set("v.selectedPartslist",selectedPartslist);
                    component.set("v.PartList", selPartsGrouped);
                    component.set("v.displayValidateParts", false);
                    component.set("v.displayAddParts", true);
                    component.set("v.disablePartSelection", true);
                    component.set("v.validatedParts", true);
                    $A.get('e.force:refreshView').fire();
                    //helper.handleClearHelper(component, event, helper);
                }
                else{
                    //helper.turnOffSpinner(cmp);
                    helper.turnOffSpinner(component);
                    helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");            
                }
            }));
            $A.enqueueAction(action);
        } catch(Err){
            helper.turnOffSpinner(component);
            helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");            
        }
    },
    */

    // Added Newly - DEFECT 5462004 - Harsha -08/21/2018  - Commented
    handleValidatePartsHelper: function(component, event, helper) {
        try {
            helper.turnOnSpinner(component);
            var selectedPartslist = component.get("v.selectedPartslist");
            var manualSelectVal = component.get("v.manualSelectVal");
            var selectedPartslist = component.get("v.selectedPartslist");
            var source = event.getSource().getLocalId();
            for(var i = 0; i< selectedPartslist.length; i++){
                console.log('part commodity ###'+selectedPartslist[i].PartCommodity__c);
                console.log('selectedPartslist[i].CFI_on_Work_Order__c ###'+selectedPartslist[i].CFI_on_Work_Order__c);
                if(selectedPartslist[i].PartCommodity__c != null && selectedPartslist[i].PartCommodity__c != '' && 
                  (selectedPartslist[i].PartCommodity__c.indexOf("HARD DRIVE") >= 0 || selectedPartslist[i].PartCommodity__c.indexOf("SOLID STATE DRIVE") >= 0)
                  && !component.get('v.showAutoAddPopUp') && selectedPartslist[i].CFI_on_Work_Order__c){
                	component.set('v.showAutoAddPopUp', true);  
                    this.closeModalPopUpHandler(component);
                    return;
                }
            }
            console.log('source ### '+source);
            
            if(source == 'addCFIPartButton'){
                
                component.set("v.addCFIAutoPart",true); 
                component.set("v.showAutoAddPopUp",false);
                this.closeModalPopUpHandler(component);
            }
            if(source == 'dontAddCFIPartButton'){
                 component.set("v.showAutoAddPopUp",false); 
                 this.closeModalPopUpHandler(component);
            }
            var action = component.get("c.validateSelectedParts");
            action.setParams({
                selectedParts: selectedPartslist,
                manualSelectReason: manualSelectVal,
                autoAddCFIPartForHardDrive: component.get("v.addCFIAutoPart")
            });
            action.setCallback(this, $A.getCallback(function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.turnOffSpinner(component);
                    if (!$A.util.isUndefinedOrNull(response.getReturnValue()) && !$A.util.isEmpty(response.getReturnValue())) {
                        if (!$A.util.isUndefinedOrNull(response.getReturnValue()[0].MessageBody) && !$A.util.isEmpty(response.getReturnValue()[0].MessageBody)) {
                            if (response.getReturnValue()[0].MessageBody.toUpperCase() === 'SUCCESS') {
                                var commodityValue = component.get("v.commodityArray");
                                var selPartsGrouped = helper.selPartsGroupBuilder(response.getReturnValue(), commodityValue);
                                var selectedPartslist = [];
                                for (var key = 0; key < response.getReturnValue().length;) {
                                    if (response.getReturnValue()[key].WorkOrderLineItemVal && response.getReturnValue()[key].WorkOrderLineItemVal.Selected_By_user__c) {
                                        var LineItemValue = response.getReturnValue()[key].WorkOrderLineItemVal;
                                        selectedPartslist.push(LineItemValue);
                                    }
                                    key=key+1;
                                }
                                component.set("v.selectedPartslist", selectedPartslist);
                                component.set("v.PartList", selPartsGrouped);
                                component.set("v.displayValidateParts", false);
                                component.set("v.displayAddParts", true);
                                component.set("v.disablePartSelection", true);
                                component.set("v.validatedParts", true);
                                $A.get('e.force:refreshView').fire();
                            } else {
                                helper.showToast("", 'ERROR', response.getReturnValue()[0].MessageBody, "Error");
                            }
                        } else {
                            helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");
                        }
                    } else {
                        helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");
                    }
                } else {
                    helper.turnOffSpinner(component);
                    helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");
                }
            }));
            $A.enqueueAction(action);
            if(selectedPartslist!=null && selectedPartslist!=undefined){
                var totalParts = selectedPartslist.length;
                var partCounter=1;
                var CountdownTimer = setInterval(function(){
                    if(partCounter <= totalParts){
                        var spinnerMessage= component.get("v.spinnerMessage");
                        if(spinnerMessage!=null && spinnerMessage.indexOf("Loading")==-1 && spinnerMessage.indexOf("Added")==-1 ){
                        	component.set("v.spinnerMessage", "Parts Added:-"+partCounter);
                            partCounter++;
                        }
                        else {
                            component.set("v.spinnerMessage", "Parts validated:-"+partCounter);
                        }
                    }
                    if (partCounter === totalParts) {
                        component.set("v.spinnerMessage", "Still Working...");
                        partCounter++;
                        //console.log("HAPPY NEW YEAR!!");
                        //clearInterval(CountdownTimer);
                    }
                    if (partCounter > totalParts) {
                        component.set("v.spinnerMessage", "Still Working... Hold On...");
                        partCounter++;
                        //console.log("HAPPY NEW YEAR!!");
                        //clearInterval(CountdownTimer);
                    }
                    
                }, 4000);
            }
        } catch (Err) {
            helper.turnOffSpinner(component);
            helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts") + ' : '+Err, "Error");
        }
    },
	/*  DEFECT 5462004 - Harsha -08/21/2018  - Commented
    handleSavePartsHelper: function(component, event, helper) {
        try {
            helper.turnOnSpinner(component);
            var selectedPartslist = component.get("v.selectedPartslist");
            var manualSelectVal = component.get("v.manualSelectVal");
            var action = component.get("c.saveSelectedParts");
            action.setParams({
                selectedParts: selectedPartslist,
                callType: 'MPS',
                manualSelectReason: manualSelectVal
            });
            action.setCallback(this, $A.getCallback(function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    helper.handleClearHelper(component, event, helper);
                } else {
                    helper.turnOffSpinner(component);
                    //console.log("Error from server");
                    helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageSavingParts"), "Error");
                }
            }));
            $A.enqueueAction(action);
        } catch (Err) {
            //console.log("Error Message controller 1 " + Err);
            helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageAddingParts"), "Error");
        }
    },
    */
    /*handleClearHelper : function (component, event, helper){
        try{
            helper.turnOffSpinner(component);
            component.set("v.displayAddParts", false);
            component.set("v.PartList", []);
            var buttonSectionNext = component.find("buttonSectionNext");
            $A.util.addClass(buttonSectionNext,'slds-hide');
            var flow = component.find("flowOnClick");
            var recordId = component.get("v.recordId");
            var addressBUID = component.get("v.addressBUID");
            var serviceTag = component.get("v.serviceTag");
            var inputVariables = [
                {
                    name : 'WorkOrderRecordId',
                    type : 'String',
                    value : recordId
                },
                {
                    name : 'addressBUID',
                    type : 'String',
                    value :  addressBUID           
                },
                {
                    name : 'serviceTag',
                    type : 'String',
                    value :  serviceTag           
                }
            ];
            flow.startFlow("Work_Order_Manual_Part_Selection", inputVariables);
        } catch(Err){
            console.log("Error Message controller 1 "+Err);
           	helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageCancellingParts"), "Error");            
        }
    },*/
    handleClearHelper: function(component, event, helper) {
        helper.turnOffSpinner(component);
        component.set("v.displayAddParts", false);
        component.set("v.PartList", []);
        component.set("v.commodityArray", []);
        component.set("v.searchText", null);
        var buttonSectionNext = component.find("buttonSectionNext");
        $A.util.addClass(buttonSectionNext, 'slds-hide');

        //slds-hidden
        var flow = component.find("flowOnClick");
        var workOrderId = component.get("v.recordId");
        var inputVariables = [{
            name: 'recordId',
            type: 'String',
            value: workOrderId
            //value : component.get("v.recordId")
        }];
        flow.startFlow("Dispatch_APS", inputVariables);
    },
    handleQuantityHelper: function(component, event, helper) {
        try {
            var totalPartList = component.get("v.PartList");
            var selectedPartsMap = component.get("v.selectedPartsMap");
            //var selectedPartslist = component.get("v.selectedPartslist");
            var selectedParts = [];
            var displayAddParts = false;
            var displayValidateParts = false;
            var selectedPart = event.getSource().get("v.name");

            for (var k = 0; k < totalPartList.length;) {
                var partlistdef = [];
                partlistdef = totalPartList[k].Listval;
                if (partlistdef) {
                    for (var j = 0; j < partlistdef.length;) {
                        if (partlistdef[j].WorkOrderLineItemVal.Id === selectedPart) {
                            selectedPartsMap[selectedPart] = partlistdef[j].WorkOrderLineItemVal;
                        }
                        j = j + 1;
                    }
                }
                k = k + 1;
            }
            Object.keys(selectedPartsMap).forEach(function(key) {
                if (selectedPartsMap[key].Selected_By_user__c) {
                    displayValidateParts = true;
                }
                selectedParts.push(selectedPartsMap[key]);
            });
            component.set("v.selectedPartslist", selectedParts);
            component.set("v.displayValidateParts", displayValidateParts);
            component.set("v.displayAddParts", displayAddParts);
            component.set("v.validatedParts", false);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageAddingParts") + ' : ' +Err, "Error");
        }
    },
    OpenModalPopUpHandler: function(component) {
        component.set('v.showModal', true);
    },
    closeModalPopUpHandler: function(component) {
        component.set('v.showModal', false);
    }
})
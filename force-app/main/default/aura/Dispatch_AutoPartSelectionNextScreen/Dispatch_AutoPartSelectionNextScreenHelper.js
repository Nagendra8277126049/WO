({
    doInitHelper: function(component) {
        try {
            this.turnOnSpinner(component);
            var selectedstringswithcomma = component.get('v.selectedString');
            var selectedstring = selectedstringswithcomma.split(',');
            var spmdLink = $A.get("$Label.c.SPMD_URL_LINK");
            spmdLink += component.get("v.serviceTag");
            //alert("spmdLink>>>"+spmdLink);
            component.set("v.spmdLink", spmdLink);
            var partslist = [];
            for (var a in selectedstring) {
                partslist.push(selectedstring[a]);
            }
            var quantityList = [];
            for (var i = 1; i <= 50; i = i + 1) {
                quantityList.push({
                    value: i.toString(),
                    label: i.toString()
                });
            }
            component.set('v.quantityList', quantityList);
            component.set('v.selectedStrings', partslist);
            this.handleSearchHelper(component);
            
        } catch (Err) {
            this.turnOffSpinner(component);
            this.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForFetchingAutoParts"), "Error");
        }
        //helper.doInitHelperCont(component, event, helper); //added for continuation POC
    },
    // turn off Spinner  
    turnOffSpinner: function(component) {
        try {
            component.set("v.shouldDisplaySpinner",false);
            //var spinner = component.find("mySpinnerApsScreen");
            //$A.util.toggleClass(spinner, "slds-hide");
            //$A.util.removeClass(spinner, 'slds-show');
            //$A.util.addClass(spinner, 'slds-hide');
        } catch (Err) {}
    },
    
    // turn on spinner
    turnOnSpinner: function(component) {
        try {
            //console.log("Inside turn On Spinner");
            component.set("v.shouldDisplaySpinner",true);
            //var spinner = component.find("mySpinnerApsScreen");
            //$A.util.toggleClass(spinner, "slds-hide");
        } catch (Err) {}
    },
    
    //added for continuation POC. WIll not be called anytime
    /*
    doInitHelperCont : function (component, event, helper){
        try{
            var vfBaseURL = "https://" + component.get("v.vfHost");
            // Listen for messages posted by the iframed VF page
            window.addEventListener("message", function (event) {
                if (event.origin !== vfBaseURL) {
                    // Not the expected origin: reject message
                    return;
                }
                // Only handle messages we are interested in
                //alert("event.data.topic>>>"+JSON.stringify(event.data));
                if (event.data.topic === "com.mycompany.message") {
                    helper.turnOffSpinner(component);
                    var result = event.data.result;
                    var plainText = result.replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/\n/g,' ').replace('"[',"[").replace(']"',"]");
                    var plainTextobj=JSON.parse(plainText);
                    component.set("v.result", plainTextobj);
                    component.set("v.PartList", plainTextobj);
             		$A.get('e.force:refreshView').fire();
                    //alert('v.PartList selectedParts--->'+JSON.stringify(component.get("v.PartList")));
                   if(result.length && result[0].responseMessage=="success"){                    
                        helper.turnOffSpinner(component);
                        component.set("v.PartList", result.getReturnValue());
                        component.set("v.selectedPartslist", []);
                        component.set("v.displayValidateParts", false);
                        component.set("v.disablePartSelection", true);
                        component.set("v.validatedParts", true);
                        $A.get('e.force:refreshView').fire();
                        //helper.handleClearHelper(component, event, helper);
                    }
                    else{
                        helper.turnOffSpinner(component);
                        component.set("v.displayValidateParts", false);
                        //helper.showToast("",'ERROR', response.getReturnValue()[0].responseMessage, "Error");
                    }
                }
            }, false);
        }
        catch(Err){
            
        }
    },
    */
    /*
    	This method will post the message to the VF page.
        This Method will not be called for now
    */
    /*
    getPartLineItems: function (component, event, helper) {
        var selectedPartslist = JSON.parse(JSON.stringify(component.get("v.selectedPartslist")));
        var message = {
            topic: "com.dellservices.message",
            //productId: component.get("v.message"),
            //latency: "500",
            selectedParts : selectedPartslist,
        };
        //var selectedPartslist = component.get("v.selectedPartslist");
        var vfOrigin = "https://" + component.get("v.vfHost");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, vfOrigin );
    },
    */
    handleSelectPart: function(component, event) {
        try {
            var totalPartList = component.get("v.PartList");
            var selectedPartsMap = component.get("v.selectedPartsMap");
            //var selectedPartslist = component.get("v.selectedPartslist");
            //var displayAddParts = component.get("v.displayAddParts");
            var validatedParts = component.get("v.validatedParts");
            var selectedParts = [];
            var displayValidateParts = false;
            var displayAddParts = false;
            var selectedPart = event.getSource();
            //var slctCheckRow = selectedPart.get("v.value");
            var indexNum = selectedPart.get("v.text");
            //var LineItemId=totalPartList[indexNum].WorkOrderLineItemVal.Id;
            //var LineItemValues=totalPartList[indexNum].WorkOrderLineItemVal;
            for (var k = 0; k < totalPartList.length;) {
                var partlistdef = [];
                partlistdef = totalPartList[k].Listval;
                
                if (partlistdef) {
                    for (var j = 0; j < partlistdef.length;) {
                        if (partlistdef[j].WorkOrderLineItemVal.Id === indexNum) {
                            selectedPartsMap[indexNum] = partlistdef[j].WorkOrderLineItemVal;
                        }
                        j = j + 1;
                    }
                }
                k = k + 1;
            }
            //selectedPartsMap[LineItemId]=LineItemValues;
            var counter = 0;
            component.set("v.selectedPartsMap", selectedPartsMap);
            Object.keys(selectedPartsMap).forEach(function(key) {
                if (selectedPartsMap[key].Selected_By_user__c && !validatedParts && !selectedPartsMap[key].Selected_Work_Order__c) {
                    displayValidateParts = true;
                    counter = counter + 1;
                } else
                    if (selectedPartsMap[key].Selected_By_user__c && validatedParts && !selectedPartsMap[key].Selected_Work_Order__c) {
                        displayAddParts = true;
                        counter = counter + 1;
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
            this.showToast(component, 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForSelectingParts"), "Error");
        }
    },
    removeA: function(arr) {
        var what, a = arguments,
            L = a.length,
            ax;
        while (L > 1 && arr.length) {
            what = a[--L];
            while ((ax = arr.indexOf(what)) !== -1) {
                arr.splice(ax, 1);
            }
        }
        return arr;
    },
    handleValidatePartsHelper: function(component, event, helper) {
        try {
            
            this.turnOnSpinner(component);
            //helper.getPartLineItems(component, event, helper); //added by Dattaa1 for continuation POC
            var selectedPartslist = component.get("v.selectedPartslist");
            var source = event.getSource().getLocalId();
            for(var i = 0; i< selectedPartslist.length; i++){
                console.log('part commodity ###'+selectedPartslist[i].PartCommodity__c);
                console.log('selectedPartslist[i] workorder CFI_Exists__c ###'+selectedPartslist[i].CFI_on_Work_Order__c);
                
                if(selectedPartslist[i].PartCommodity__c != null && selectedPartslist[i].PartCommodity__c != '' && 
                   (selectedPartslist[i].PartCommodity__c.indexOf("HARD DRIVE") >= 0 || selectedPartslist[i].PartCommodity__c.indexOf("SOLID STATE DRIVE") >= 0)
                   && !component.get('v.showAutoAddPopUp') && selectedPartslist[i].CFI_on_Work_Order__c){
                	
                    component.set('v.showAutoAddPopUp', true);  
                    return;
                }
            }
            if(source == 'addCFIPartButton'){
                component.set("v.addCFIAutoPart",true); 
                component.set("v.showAutoAddPopUp",false);
            }
            if(source == 'dontAddCFIPartButton'){
                 component.set("v.showAutoAddPopUp",false); 
            }
            var action = component.get("c.validateSelectedParts");
            action.setParams({
                selectedParts: selectedPartslist,
                EditRec: true,
                callType: 'APS',
                addCFIAutoPart: component.get("v.addCFIAutoPart")
            });
            action.setCallback(this, $A.getCallback(function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(!$A.util.isEmpty(result)){
                    //if (response.getReturnValue().length && response.getReturnValue()[0].responseMessage === "success") {
                        if(!$A.util.isEmpty(result[0].responseMessage)){
                            if(result[0].responseMessage === 'success'){
                                this.turnOffSpinner(component);
                                clearInterval(CountdownTimer);
                                var SelectedValue = component.get("v.selectedStrings");
                                var selectedPartslist = [];
                                for (var key = 0; key < response.getReturnValue().length;) {
                                    if (SelectedValue && !SelectedValue.includes(response.getReturnValue()[key].WorkOrderLineItemVal.DefectiveComponent__c)) {
                                        SelectedValue.push(response.getReturnValue()[key].WorkOrderLineItemVal.DefectiveComponent__c);
                                    }
                                    if (response.getReturnValue()[key].WorkOrderLineItemVal && response.getReturnValue()[key].WorkOrderLineItemVal.Selected_By_user__c) {
                                        var LineItemValue = response.getReturnValue()[key].WorkOrderLineItemVal;
                                        selectedPartslist.push(LineItemValue);
                                    }
                                    key = key + 1;
                                }
                                SelectedValue = SelectedValue.sort();
                                var selPartsGrouped = this.selPartsGroupBuilder(response.getReturnValue(), SelectedValue);
                                component.set("v.selectedPartslist", selectedPartslist);
                                component.set("v.PartList", selPartsGrouped);
                                //component.set("v.selectedPartslist", []);
                                component.set("v.displayValidateParts", false);
                                component.set("v.displayAddParts", true);
                                component.set("v.disablePartSelection", true);
                                component.set("v.validatedParts", true);
                                //  Added Newly
                                $A.get('e.force:refreshView').fire();
                                // Added Newly
                            } else {
                                this.turnOffSpinner(component);
                                clearInterval(CountdownTimer);
                                component.set("v.displayValidateParts", false);
                                this.showToast(component, 'ERROR', response.getReturnValue()[0].responseMessage, "Error");
                            }
                        } else {
                            this.turnOffSpinner(component);
                            clearInterval(CountdownTimer);
                            this.showToast(component,'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");
                        }
                    } else {
                        this.turnOffSpinner(component);
                        clearInterval(CountdownTimer);
                        this.showToast(component,'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");
                    }
                } else {
                    this.turnOffSpinner(component);
                    clearInterval(CountdownTimer);
                    this.showToast(component,'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");
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
            this.turnOffSpinner(component);
            this.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageValidatingParts"), "Error");
        }
    },
    
    handleQuantitychangeHelper: function(component, event) {
        try {
            var totalPartList = component.get("v.PartList");
            var selectedPartsMap = component.get("v.selectedPartsMap");
            //var selectedPartslist = component.get("v.selectedPartslist");
            var selectedParts = [];
            var displayValidateParts = false;
            var displayAddParts = false;
            var selectedPart = event.getSource().get("v.name");
            //var LineItemId=totalPartList[selectedPart].WorkOrderLineItemVal.Id;
            //var LineItemValues=totalPartList[selectedPart].WorkOrderLineItemVal;
            
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
            //selectedPartsMap[LineItemId]=LineItemValues;
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
            this.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageAddingParts"), "Error");
        }
    },
    /* // COmmented By Harsha - DEFECT 5462004
    handleAddPartsHelper: function (component){
        try{
            this.turnOnSpinner(component);
            var totalPartList = component.get("v.selectedPartslist");
            var action = component.get("c.saveSelectedParts");
            action.setParams({ selectedParts : totalPartList, callType : 'APS'});
            action.setCallback(this, $A.getCallback(function (response) {
                this.turnOffSpinner(component);
                var state = response.getState();
                if(state === "SUCCESS"){
                    if(response.getReturnValue() && response.getReturnValue().toUpperCase().includes("SUCCESS")){
                        this.showToast(component,'SUCCESS', $A.get("$Label.c.Dispatch_WorkOrderSaved"), "SUCCESS");
                    }
                    else{
                        //helper.showToast("",'ERROR', response.getReturnValue(), "Error");
                    }
                    $A.get('e.force:refreshView').fire();
                    this.handleClearHelper(component);
                }
                else{
                    this.turnOffSpinner(component);
                    this.showToast(component,'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageSavingParts"), "Error");            
                }
            }));
            $A.enqueueAction(action);
    	} catch(Err){
           	this.showToast(component,'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageAddingParts"), "Error");            
        }
    },
    */
    handleSearchHelper: function(component) {
        try {
            this.turnOnSpinner(component);
            //var selectedlength	=	component.get("v.SelectedDC.length");
            var action = component.get("c.FindSelectedParts");
            var recId = component.get("v.workOrderId");
            var SelectedValue = component.get("v.selectedStrings");
            action.setParams({
                WorkOrderId: recId,
                //selectedList :component.get("v.selectedStrings")
                selectedList: SelectedValue
            });
            action.setCallback(this, $A.getCallback(function(response) {
                this.turnOffSpinner(component);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var selectedPartsMap = component.get("v.selectedPartsMap");
                    //component.set("v.PartList", response.getReturnValue());
                    var selPartsGrouped = this.selPartsGroupBuilder(response.getReturnValue(), SelectedValue);
                    component.set("v.PartList", selPartsGrouped);
                    for (var key = 0; key < response.getReturnValue().length;) {
                        
                        if (response.getReturnValue()[key].WorkOrderLineItemVal.Selected_By_user__c) {
                            var LineItemId = response.getReturnValue()[key].WorkOrderLineItemVal.Id;
                            var LineItemValues = response.getReturnValue()[key].WorkOrderLineItemVal;
                            selectedPartsMap[LineItemId] = LineItemValues;
                        }
                        key = key + 1;
                    }
                    component.set("v.selectedPartsMap", selectedPartsMap);
                    var cmpTarget1 = component.find('c-PartContainer');
                    $A.util.removeClass(cmpTarget1, 'slds-hide');
                    //var PartList= component.get("v.PartList");
                    this.turnOffSpinner(component);
                } else {
                    this.turnOffSpinner(component);
                    this.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageSearchingParts"), "Error");
                }
            }));
            $A.enqueueAction(action);
        } catch (Err) {
            this.turnOffSpinner(component);
            this.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageSearchingParts"), "Error");
        }
    },
    handleClearHelper: function(component) {
        try {
            component.set("v.renderComponent", false);
            //component.set("v.displayAddParts", false);
            component.set("v.PartList", []);
            var flow = component.find("flowOnClick");
            var workOrderId = component.get("v.workOrderId");
            var inputVariables = [{
                name: 'recordId',
                type: 'String',
                value: workOrderId
                //value : component.get("v.recordId")
            }];
            flow.startFlow("Dispatch_APS", inputVariables);
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageCancellingParts"), "Error");
        }
    },
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
    //this will build the wrapper for the commodity list
    selPartsGroupBuilder: function(selectedparts, SelectedCommodities) {
        var selectedpartsList = selectedparts;
        var topLevelObject = [];
        
        if (selectedpartsList) {
            for (var cm = 0; cm < SelectedCommodities.length;) {
                var belowLevelObject = [];
                for (var key = 0; key < selectedpartsList.length;) {
                    if (SelectedCommodities[cm] === selectedpartsList[key].WorkOrderLineItemVal.DefectiveComponent__c) {
                        belowLevelObject.push(selectedpartsList[key]);
                    }
                    key = key + 1;
                }
                var topLevelObjectval = {};
                topLevelObjectval.key = SelectedCommodities[cm];
                topLevelObjectval.Listval = belowLevelObject;
                topLevelObject.push(topLevelObjectval);
                cm = cm + 1;
            }
        }
        return topLevelObject;
    },
    handleAdvanceSearchHelper: function(component) {
        component.set("v.renderComponent", false);
        component.set("v.renderSearchBox", false);
        component.set("v.SelectedDC", []);
        //var toggleText = component.find("text");
        //$A.util.toggleClass(toggleText, "toggle");
        //$A.util.addClass(toggleText,"displayNone");
        //slds-hidden
        var flow = component.find("flowOnClick");
        var workOrderId = component.get("v.workOrderId");
        //var serviceTag = component.get("v.serviceTag");
        var inputVariables = [{
            name: 'WorkOrderRecordId',
            type: 'String',
            value: workOrderId
            //value : component.get("v.recordId")
        }];
        flow.startFlow("Work_Order_Manual_Part_Selection", inputVariables);
    },
    handleChangeHelper: function(component) {
        var searchText = component.get("v.searchText");
        searchText = searchText.toLowerCase();
        var DefCmpCopy = component.get("v.DefCmpCopy");
        var DefCmp = component.get("v.DefCmp");
        //var PofCmpCopy = component.get("v.PofCmpCopy");
        //var PofCmp = component.get("v.PofCmp");
        var sDarray = [];
        //var sDarrayPof			=	[];
        if (!searchText) {
            component.set("v.DefCmp", DefCmpCopy);
            //component.set("v.PofCmp",PofCmpCopy);
        } else {
            for (var keyval = 0; keyval < DefCmp.length;) {
                if (DefCmp[keyval].value === true) {
                    sDarray.push(DefCmp[keyval]);
                }
                keyval = keyval + 1;
            }
            for (var key = 0; key < DefCmpCopy.length;) {
                if (DefCmpCopy[key].label.toLowerCase().indexOf(searchText) >= 0 && !sDarray.includes(DefCmpCopy[key])) {
                    sDarray.push(DefCmpCopy[key]);
                }
                key = key + 1;
            }
            sDarray = sDarray.sort(function(a, b) {
                if (a.label < b.label) return -1;
                if (a.label > b.label) return 1;
                return 0;
            });
            component.set("v.DefCmp", sDarray);
            
        }
        setTimeout(function() {
            var inputText = document.getElementsByClassName("commodity");
            for (var i = 0; i < inputText.length;) {
                var innerHTML = inputText[i].innerHTML.replace("<span><strong>", "").replace("</strong></span>", "");
                var index = innerHTML.toLowerCase().indexOf(searchText);
                if (index >= 0) {
                    innerHTML = innerHTML.substring(0, index) + "<span><strong>" + innerHTML.substring(index, index + searchText.length) + "</strong></span>" + innerHTML.substring(index + searchText.length);
                }
                inputText[i].innerHTML = innerHTML;
                i = i + 1;
            }
        }, 100);
    }
})
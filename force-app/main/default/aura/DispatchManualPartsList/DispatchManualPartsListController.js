({
    doInit: function(component, event, helper) {
        try {
            helper.loadManualSelectionReason(component);
            helper.loadCommodityParts(component, event, helper);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    SelectPart: function(component, event, helper) {
        try {
            helper.handleSelectPart(component, event);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    checkboxChangeHandler: function(component, event, helper) {
        var selectedPartslist = component.get("v.selectedPartslist");
        var cboxRowInput = event.getSource();
        //var selectedCheckRow = cboxRowInput.get("v.value");
        var partNumber = cboxRowInput.get("v.name");
        var selectedParts = selectedPartslist;
        selectedParts.push(partNumber);
        component.set("v.selectedPartslist", selectedParts);
    },
    /*handleOnClick: function (cmp, evt,helper) {        
        helper.handleOnClickHelper(cmp, evt,helper);    
    },*/
    handleClear: function(component, event, helper) {
        helper.handleClearHelper(component, event, helper);
    },
    handleValidateParts: function(component, event, helper) {
        try {
            // Commented //helper.handleValidatePartsHelper(component, event,helper);
            helper.OpenModalPopUpHandler(component); // Added Newly
            //helper.handleClearHelper(component, event,helper);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    closeAutoPartsPopUp: function(component, event, helper) {
		component.set('v.showAutoAddPopUp', false);
    },
    // DEFECT 5462004 - Harsha -08/21/2018 // Commented
    /*
    handleAddParts: function(component, event, helper) {
        try {
            //helper.handleAddPartsHelper(component, event,helper);
            helper.OpenModalPopUpHandler(component);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    */
    handleSaveParts: function(component, event, helper) {
        try {
            helper.closeModalPopUpHandler(component);
            //helper.handleSavePartsHelper(component, event,helper); // DEFECT 5462004 - Harsha -08/21/2018 // Commented
            helper.handleValidatePartsHelper(component, event, helper); //DEFECT 5462004 - Harsha -08/21/2018 // Added Newly         
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    /*afterRender : function(cmp,helper){
        this.superAfterRender();
        var elements = document.getElementsByClassName("validatePartsChkBox");
        console.log("elements.length: " + elements.length);
        for (var i=0; i<elements.length; i++) {
            console.log(elements[i].innerHTML);
        }
    },*/
    handleQuantity: function(component, event, helper) {
        helper.handleQuantityHelper(component, event, helper);
    },
    closeModalPopUp: function(component, event, helper) {
        try {
            helper.closeModalPopUpHandler(component);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
    manualSelectChange: function(component, event, helper) {
        try {
            helper.manualSelectChangeHandler(component, event, helper);
        } catch (Err) {
            helper.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },
})
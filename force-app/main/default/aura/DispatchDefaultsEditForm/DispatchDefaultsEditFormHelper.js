({
    // destroy Component from memory
    closeMe: function(component) {
        try {
            this.closeEditForm(component);
            component.destroy();
        } catch (Err) {
            this.showToast(component, 'Error', "Error Occured While Closing The Form : "+Err, "Error");
        }
    },
    
    // Toast message
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
    
    // Create Picklist Values
    createPicklist: function(component, inputvalue) {
        var opts = [];
        if (inputvalue !== undefined && inputvalue.length > 0) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for (var i = 0; i < inputvalue.length; i = i + 1) {
                if (!$A.util.isEmpty(inputvalue[i])) {
                    opts.push({
                        class: "optionClass",
                        label: inputvalue[i],
                        value: inputvalue[i]
                    });
                }
            }
        } else
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
        return opts;
    },
    
    // Fire Component Event
    fireEvent: function(component) {
        // Get the component event by using the
        // name value from aura:registerEvent
        try {
            var updateDisDefaultEvent = component.getEvent("updateDisDefaultEvent");
            updateDisDefaultEvent.setParams({
                "changedServiceOptionValue": component.get("v.serviceOptionValue"),
                "changedServiceTypeValue": component.get("v.serviceTypeValue"),
                "changedOrderNumber": component.get("v.OrderNumber"),
                "changedSpecialOptionValue": component.get("v.specialOptionValue"),
                "changedProductClassValue": component.get("v.prodClassValue"),
                "changedKeepYComp": component.get("v.kYComp"),
                "changedDSPOverideReq": component.get("v.DSPOverReq"),
                "ADoverrideReq": component.get("v.AccDamageVal"),
                "changedBillToValue": component.get("v.billToValue"),
                "changedADOverrideReason": component.get("v.ADOverValue"),
                "changedAccidentalDamage": component.get("v.AccDamageVal"),
                "changedServiceOptions": component.get("v.holdserviceoptions"),
                "changedServiceTypeOptions": component.get("v.holdServiceTypeOptions"),
                "changedSpecialOptions": component.get("v.holdSpecialOptions"),
                "changedBillToOptions": component.get("v.holdbillToOptions"),
                "changedADOverOptions": component.get("v.holdADOverride"),
                "changedProductClassOptions": component.get("v.holdprodClassOptions"),
                "changedInstructionValue": component.get("v.Instructions"),
                "changedoverrideValue": component.get("v.overrides"),
                "changedInstructionRecordId": component.get("v.InstructRecId"),
                "changedKYHDFlag": component.get("v.KYHDFlag"),
                "changedAltReturnAddressFlagValue": component.get("v.altReturnAddressChkBoxValue"),
                "changedAltReturnAddStreetValue": component.get("v.altReturnStreetValue"),
                "changedAltReturnAddPostalCodeValue": component.get("v.altReturnPostalCodeValue"),
                "changedAltReturnAddCityValue": component.get("v.altReturnCityValue"),
                "changedAltReturnAddStatusValue": component.get("v.altReturnStateValue"),
                "changedAltReturnAddCountryValue": component.get("v.altReturnCountryValue"),
                "reasonForDamage": component.get("v.reasonForDamage"),
                "changedDASPEnable": component.get("v.DASPEnable"),
                "changedDASPValue" : component.get("v.DASPValue")
            });
            updateDisDefaultEvent.fire();
        } catch (Err) {
            this.showToast(component, 'ERROR', "Error Occured While saving the data : "+Err, "Error");
        }
    },
    
    // Update dispatch Default Record
    updateRecord: function(component) {
        try {
            //turn on Spinner
            this.showSpinner(component);
            var DSPSelected;
            if(component.get("v.DASPEnable") == true)
            {    
                var DASPSel			=	component.get("v.DASPValue");
                var DASPOptions		=	component.get("v.DASPValues");
                var DASPIndx		=	DASPOptions.findIndex(item => item.value.PartnerName__c == DASPSel);
                DSPSelected			=   DASPIndx >= 0? DASPOptions[DASPIndx].value.PartnerCode__c: null;
            }    
            var action = component.get("c.updateDefaultsRecord");
            action.setParams({
                recordId: component.get("v.recordId"),
                defaultRecId: component.get("v.dispDefaultsRecId"),
                serTypeValue: component.get("v.serviceTypeValue"),
                serOptionValue: component.get("v.serviceOptionValue"),
                speOptionvalue: component.get("v.specialOptionValue"),
                prodClassValue: component.get("v.prodClassValue"),
                kYcompvalue: component.get("v.kYComp"),
                accDamageValue: component.get("v.AccDamageVal"),
                dSPOverideValue: component.get("v.DSPOverReq"),
                billToValue: component.get("v.billToValue"),
                ADOverValue: component.get("v.ADOverValue"),
                OrderNumber: component.get("v.OrderNumber"),
                servOptionPicklist: component.get("v.holdserviceoptions"),
                instructions: component.get("v.Instructions"),
                overrides: component.get("v.overrides"),
                dspInstrnRecId: component.get("v.InstructRecId"),
                kyhdFlag: component.get("v.KYHDFlag"),
                KYHDFlagChangedTrue: component.get("v.KYHDFlagChangedTrue"),
                ADOverrideReason: component.get("v.ADOverValue"),
                accDamageFlag: component.get("v.AccDamageVal"),
                altReturnAddressFlag: component.get("v.altReturnAddressChkBoxValue"),
                altReturnAddressStreet: component.get("v.altReturnStreetValue"),
                altReturnAddressPostalCode: component.get("v.altReturnPostalCodeValue"),
                altReturnAddressCity: component.get("v.altReturnCityValue"),
                altReturnAddressState: component.get("v.altReturnStateValue"),
                altReturnAddressCountry: component.get("v.altReturnCountryValue"),
                reasonForDamage: component.get("v.reasonForDamage"),
                DASPValue: component.get("v.DASPValue"),
                DSPSelectedfromDASP : DSPSelected
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseResult = response.getReturnValue();
                    if (response.getReturnValue() !== null && response.getReturnValue() !== undefined) {
                        if (responseResult.errorMessage === null || responseResult.errorMessage === undefined || responseResult.errorMessage === '') {
                            if (responseResult.instructRecid !== null && responseResult.instructRecid !== undefined) {
                                // update InstructRecId attribute
                                component.set("v.InstructRecId", responseResult.instructRecid);
                            }
                            this.showToast(component, 'SUCCESS', "Record Updated", "SUCCESS");
                            // Send Values to Read Component
                            this.fireEvent(component);
                            // Close the modal
                            this.closeMe(component);
                            // turn Off Spinner
                            this.hideSpinner(component);
                        } else {
                            this.showToast(component, 'Error', responseResult.errorMessage, "Error");
                            this.hideSpinner(component);
                        }
                    } else {
                        //turn Off Spinner
                        this.hideSpinner(component);
                        // Toast Error Users
                        this.showToast(component, 'ERROR', "Error Occured While saving the data", "Error");
                    }
                } else {
                    //turn Off Spinner
                    this.hideSpinner(component);
                    // Toast Error to Users
                    this.showToast(component, 'ERROR', "Error Occured While saving the data", "Error");
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            //turn Off Spinner
            this.hideSpinner(component);
            this.showToast(component, 'ERROR', "Error Occured While Loading The Form : "+Err, "Error");
        }
    },
    
    // turn on spinner
    showSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    // turn off Spinner
    hideSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    // Call Apex Controller to get Picklist Values for Service Options
    onChangeBillTo: function(component, serviceType, billToFlag, oldServiceOption) {
        try {
            console.log('inside onchangebillto');
            //turn on Spinner
            this.showSpinner(component);
            var oldSpecialOptionValue = component.get("v.specialOptionValue");
            //var opts = [];
            var specialOpts = [];
            var DASP = '';
            if(component.get("v.DASPEnable")) {
            //DASP = $A.util.isEmpty(component.find('DASPId').get("v.value"));
            DASP = component.find('DASPId').get("v.value");
            }
             var sRegion = component.get("v.Region");
            /*console.log('sRegion'+sRegion)
            var sDASPFlg ='N';        
            if((sRegion == '1' ||sRegion == '2')&& DASP == false)
                      sDASPFlg = 'Y';       */


            var action = component.get("c.getBillToAvailableOptions");
            action.setParams({
                recordId: component.get("v.recordId"),
                billToFlag: billToFlag,
                serviceType: serviceType,
                selectedServiceOption: oldServiceOption,
                DASP: DASP
            });
            action.setCallback(this, function(response) {
                console.log('onChangeBillTo response', response);
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('onChangeBillTo response MSG2', result);
                    if (result !== null && result !== undefined) {
                        console.log('onChangeBillTo result is defined');
                        if (result.responseCode === '100' || result.responseCode === '-103') {//changed by dattaa1 5594679
                            if (!$A.util.isEmpty(result.categoryOptions) && result.categoryOptions.length > 0) {
                                specialOpts.push({
                                    label: "--- None ---",
                                    value: ""
                                });
                                for (var i = 0; i < result.categoryOptions.length; i = i + 1) {
                                    if (!$A.util.isEmpty(result.categoryOptions[i])) {
                                        if (result.categoryOptions[i] === oldSpecialOptionValue && !$A.util.isEmpty(oldSpecialOptionValue)) {
                                            specialOpts.push({
                                                label: result.categoryOptions[i],
                                                value: result.categoryOptions[i],
                                                selected: true
                                            });
                                        } else {
                                            specialOpts.push({
                                                label: result.categoryOptions[i],
                                                value: result.categoryOptions[i],
                                                selected: false
                                            });
                                        }
                                    }
                                }
                                //var specialOptionsListObj = this.setServiceOptions(component, result.categoryOptions,oldSpecialOptionValue);
                                component.set("v.specialOptions", specialOpts);
                                component.set("v.holdSpecialOptions", result.categoryOptions);
                                if (result.categoryOptions.includes(oldSpecialOptionValue)) {
                                    component.set("v.specialOptionValue", oldSpecialOptionValue);
                                } else {
                                    component.set("v.specialOptionValue", null);
                                }
                            } else {
                                specialOpts.push({
                                    label: "--- None ---",
                                    value: ""
                                });
                                component.set("v.specialOptions", specialOpts);
                                component.set("v.holdSpecialOptions", '');
                                component.set("v.specialOptionValue", null);
                            }
                            //changed by dattaa1 5594679
                            console.log("responseMessage  ===>  "+result.responseMessage);
                            if(result.responseMessage!==null && result.responseMessage !=='' && result.responseMessage!==undefined && result.responseMessage.toLowerCase().indexOf("success")===-1){
                                this.showToast(component, 'WARNING', result.responseMessage, "Warning");                                    
                            }                
                            //console.log("defaultOption  ===>  "+result.defaultOption);
                            //console.log("responseResult  ===>  "+result.availableOptions);
                            var responseResult = result.availableOptions;
                            /*
                            if (result.defaultOption !== null && result.defaultOption !== undefined) {
                                component.set("v.serviceOptionValue", result.defaultOption);
                                component.find("serviceOptionId").set("v.value", result.defaultOption);
                            }
                            */
                            if (responseResult !== undefined && responseResult.length > 0 && responseResult !== null) {
                                //var SerOptions = this.setServiceOptions(component, responseResult, result.defaultOption);
                                /*
                                var SerOptions = [];
								SerOptions.push({
									label: "--- None ---",
									value: ""
								});
								var resOpt = this.setServiceOptions(component, responseResult, oldServiceOption);
                                
                                */
                                var SerOptions = [];
                                var containsFlag = false;
                                
                                if(!$A.util.isEmpty(oldServiceOption)){
                                    oldServiceOption = oldServiceOption.trim();
                                }
                                SerOptions.push({
                                    label: "--- None ---",
                                    value: ""
                                });
                                for (var i = 0; i < responseResult.length; i = i + 1) {
                                    if (!$A.util.isEmpty(responseResult[i])) {
                                        if (responseResult[i].trim() === oldServiceOption && !$A.util.isEmpty(oldServiceOption)) {
                                            SerOptions.push({
                                                label: responseResult[i].trim(),
                                                value: responseResult[i].trim(),
                                                selected: true
                                            });
                                            containsFlag = true;
                                        } else {
                                            SerOptions.push({
                                                label: responseResult[i].trim(),
                                                value: responseResult[i].trim(),
                                                selected: false
                                            });
                                        }
                                    }
                                }
                                
								//if(!$A.util.isEmpty(resOpt)){
								if(!$A.util.isEmpty(SerOptions)){
									//SerOptions = SerOptions.concat(resOpt);
									component.set("v.serviceoptions", SerOptions);
									component.set("v.holdserviceoptions", responseResult);
									if(!$A.util.isEmpty(oldServiceOption)){
										//if(responseResult.includes(oldServiceOption)){
										if(containsFlag){
											component.set("v.serviceOptionValue",oldServiceOption);
											component.find("serviceOptionId").set("v.value", oldServiceOption);
										} else {
											component.set("v.serviceOptionValue",'');
											component.find("serviceOptionId").set("v.value", '');
										}
									} else {
										component.set("v.serviceOptionValue",'');
										component.find("serviceOptionId").set("v.value", '');
									}
                                } else {
									this.setServiceOptionsToNull(component);
								}
								
								/*
                                if($A.util.isEmpty(component.get("v.serviceOptionValue")) && !$A.util.isUndefinedOrNull(SerOptions)){
                                    component.set("v.serviceOptionValue",SerOptions[0].value);
                                    component.find("serviceOptionId").set("v.value", SerOptions[0].value);
                                }
								*/
                                //turn Off Spinner
                                this.hideSpinner(component);
                            } else {
                                this.setServiceOptionsToNull(component);
                                //turn offSpinner
                                this.hideSpinner(component);
                                console.log('Dev1');
                                this.showToast(component, 'ERROR', "Error Occured While Fetching Service Options onChangeBillTo", "Error");
                            }
                        } else {
                            this.setServiceOptionsToNull(component);
                            //turn offSpinner
                            this.hideSpinner(component);
                            this.showToast(component, 'ERROR', result.responseMessage, "Error");
                        }
                    } else {
                        this.setServiceOptionsToNull(component);
                        //turnOffSpinner
                        this.hideSpinner(component);
                        console.log('Dev2');
                        this.showToast(component, 'ERROR', "Error Occured While Fetching Service Options", "Error");
                    }
                } else {
                    this.setServiceOptionsToNull(component);
                    //turn Off Spinner
                    this.hideSpinner(component);
                    
                    this.showToast(component, 'ERROR', "Error Occured While Loading The Form - callApex", "Error");
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            //turn Off Spinner
            this.hideSpinner(component);
            // Toast Error to User
            this.showToast(component, 'ERROR', "Error Occured While Loading The Form : "+Err, "Error");
        }
    },
    
    setServiceOptionsToNull: function(component) {
        try {
            var opts = [];
            opts.push({
                label: "--- None ---",
                value: ""
            });
            component.set("v.serviceoptions", opts);
            component.set("v.holdserviceoptions", '');
            component.set("v.serviceOptionValue", '');
        } catch (Err) {
            this.showToast(component, 'ERROR', "Error Occured Refreshing the Form : "+Err, "Error");
        }
    },
    
    validateSave: function(component) {
        try {
            var validate = true;
            component.set("v.validationError", false);
            component.set("v.errorMessage", '');
            if ($A.util.isEmpty(component.find('serviceTypeId').get("v.value"))) {
                component.set("v.validationError", true);
                component.set("v.errorMessage", 'Service Type cannot be Empty');
                return false;
            }
            if ($A.util.isEmpty(component.find('serviceOptionId').get("v.value"))) {
                component.set("v.validationError", true);
                component.set("v.errorMessage", 'Service Option Field Cannot be Empty');
                return false;
            }
            if (component.get('v.billToHasValue')) {
                var billTo = component.find('billToId').get("v.value");
                var ordNum;
                if (billTo === "Customer") {
                    ordNum = component.find('billToOrderNumId').get("v.value");
                }
                if ($A.util.isEmpty(ordNum) && billTo === "Customer") {
                    component.set("v.validationError", true);
                    component.set("v.errorMessage", '"The Bill To Customer Order Number is required because Bill To Customer is selected.');
                    return false;
                }
                if (isNaN(ordNum) && billTo === "Customer") {
                    component.set("v.validationError", true);
                    component.set("v.errorMessage", '"Bill To Customer Order Number" is Numeric field. Please enter valid number');
                    return false;
                }
            }
            
            //no need to display the error message for Override reason. so commenting the errormessageset--dattaa1 Defect:-5359660
            if (component.get("v.DSPOverReq")) {
                if ($A.util.isEmpty(component.find('instructionId').get("v.value"))) {
                    component.set("v.validationError", true);
                    component.set("v.DSPOverReqerrorMessage", 'Please provide an override reason and the preferred service provider.');
                    return false;
                } else {
                    if ($A.util.isEmpty(component.find('instructionId').get("v.value").trim())) {
                        component.set("v.validationError", true);
                        component.set("v.DSPOverReqerrorMessage", 'Please provide an override reason and the preferred service provider.');
                        return false;
                    }
                }
            }
            
            // Added by Harsha - Starts Here
            if (component.get("v.altReturnAddressChkBoxValue")) {
                
                var errorMessage = ' ';
                var hasErrorCheck = false;
                var pattern = ' ';
                
                if ($A.util.isEmpty(component.get("v.altReturnStreetValue")) || $A.util.isEmpty(component.get("v.altReturnCityValue")) ||
                    $A.util.isEmpty(component.get("v.altReturnPostalCodeValue")) || $A.util.isEmpty(component.get("v.altReturnStateValue")) ||
                    $A.util.isUndefinedOrNull(component.get("v.altReturnStreetValue")) || $A.util.isUndefinedOrNull(component.get("v.altReturnCityValue")) ||
                    $A.util.isUndefinedOrNull(component.get("v.altReturnCountryValue")) || $A.util.isEmpty(component.get("v.altReturnCountryValue")) ||
                    $A.util.isUndefinedOrNull(component.get("v.altReturnPostalCodeValue")) || $A.util.isUndefinedOrNull(component.get("v.altReturnStateValue"))) {
                    component.set("v.validationError", true);
                    component.set("v.errorMessage", 'Please enter an address for the work order. If the address is outside of the United States or Canada, please create the work order in Delta.');
                    return false;
                }
                var selectedCity = component.get('v.altReturnCityValue');
                if (selectedCity !== undefined && selectedCity !== '') {
                    pattern = /^[a-zA-Z  ]*$/;
                    if (!selectedCity.replace(/\s/g, '').length) {
                        //alert('entered space check city');
                        hasErrorCheck = true;
                        errorMessage = $A.get("$Label.c.DispatchCityError");
                    } else if (pattern.test(selectedCity) === false) {
                        //alert('Name does not contain illegal characters.');
                        hasErrorCheck = true;
                        //component.set("v.validationError", true);
                        errorMessage = $A.get("$Label.c.DispatchCityError");
                        //component.set("v.errorMessage", $A.get("$Label.c.DispatchCityError"));
                        //return false;
                    }
                }
                var selectedZipCode = component.get('v.altReturnPostalCodeValue');
                if (selectedZipCode !== undefined && selectedZipCode !== '') {
                    pattern = /^[a-zA-Z0-9 ]*$/;
                    if (pattern.test(selectedZipCode) === false) {
                        //alert('Name does not contain illegal characters.');
                        hasErrorCheck = true;
                        //component.set("v.validationError", true);
                        errorMessage = errorMessage + '\n' + $A.get("$Label.c.DispatchZipCodeError");
                        //component.set("v.errorMessage", $A.get("$Label.c.DispatchZipCodeError"));
                        //return false;
                    }
                }
                var selectedStreet = component.get('v.altReturnStreetValue');
                if (selectedStreet !== undefined && selectedStreet !== '') {
                    pattern = /^[a-zA-Z0-9,/\-  ]*$/;
                    if (!selectedStreet.replace(/\s/g, '').length) {
                        //alert('entered space check street');
                        hasErrorCheck = true;
                        errorMessage = errorMessage + '\n' + $A.get("$Label.c.DispatchStreetError");
                    } else if (pattern.test(selectedStreet) === false) {
                        //alert('Name does not contain illegal characters.');
                        hasErrorCheck = true;
                        //component.set("v.validationError", true);
                        errorMessage = errorMessage + '\n' + $A.get("$Label.c.DispatchStreetError");
                        //component.set("v.errorMessage", $A.get("$Label.c.DispatchZipCodeError"));
                        //return false;
                    }
                }
                if (hasErrorCheck) {
                    component.set("v.validationError", true);
                    component.set("v.errorMessage", errorMessage);
                    return false;
                }
            }
            // Added by Harsha - Ends Here
            
            //uncommented this block for AD
            if (component.get("v.AccDamageVal") && component.get("v.ADCoverageFlag")) {
                if (component.get("v.isCountrySpain") == false && $A.util.isEmpty(component.find('OverrideId').get("v.value"))) {
                    component.set("v.validationError", true);
                    component.set("v.errorMessage", 'AD Override Reason is required field');
                    return false;
                }
            }
            if ( component.get("v.AccDamageVal") && $A.util.isEmpty(component.find('reasonForDamageId').get("v.value"))  ) {
                component.set("v.validationError", true);
                component.set("v.errorMessage", 'Reason For Damage is required field');
                return false;
            }
            
            if(component.get("v.Region") == '2' && component.get("v.DASPEnable") == true && component.find('serviceTypeId').get("v.value") != "Parts Only" && ($A.util.isEmpty(component.find('DASPId').get("v.value")) || component.find('DASPId').get("v.value")==='--None--'))
            {
              	component.set("v.validationError", true);
                component.set("v.errorMessage", 'DASP Field cannot be empty');
                return false;  
            }    


            return validate;
        } catch (Err) {
            
            this.showToast(component, 'ERROR', "Error Occured While Saving Record to Database : "+Err, "Error");
            return false;
        }
    },
    
    // Fire Component Event
    closeEditForm: function(component) {
        try {
            var openReadFormEvent = component.getEvent("openReadFormEvent");
            var setTrue = true;
            openReadFormEvent.setParams({
                "openReadForm": setTrue
            });
            openReadFormEvent.fire();
        } catch (Err) {
            this.showToast(component, 'ERROR', "Internal Occured While Close the Form : "+Err, "Error");
        }
    },
    
    // Save Record Helper to Database
    saveRecordHelper: function(component) {
        component.set("v.validationError", false);
        component.set("v.errorMessage", '');
        try {
            var SerOption = component.find('serviceOptionId').get("v.value");
            //console.log(" Service Option ===>  " + SerOption);
            // Check if Asset is Out of Warranty or not
            if (component.get("v.OutOfWarranty")) {
                if ($A.util.isEmpty(component.find('billToId').get("v.value"))) {
                    component.set("v.validationError", true);
                    component.set("v.errorMessage", 'A Bill To option is required because this system is out of warranty.');
                } else {
                    if (this.validateSave(component)) {
                        component.set("v.serviceOptionValue", SerOption);
                        this.updateRecord(component);
                    }
                }
            } else {
                if (this.validateSave(component)) {
                    component.set("v.serviceOptionValue", SerOption);
                    //update Record
                    this.updateRecord(component);
                    
                }
            }
        } catch (Err) {
            //show Toast on Error
            this.showToast(component, 'Error', "Error Occured While Closing The Form : "+Err, "Error");
        }
    },
    
    // Invokes On load of component 
    doInitHelper: function(component) {
        try {
            this.hideSpinner(component);
            component.set("v.billToOldValue", component.get("v.billToValue"));
             var woCountry = component.get("v.workOrderCountry");
             if(woCountry !== null && woCountry !== undefined && woCountry.indexOf('Spain') !== -1){
            	 component.set("v.isCountrySpain", true);
            }
            var entitlementDetail = component.get("v.EntitlementDetailsValue");
            if (undefined !== entitlementDetail && entitlementDetail!=null && entitlementDetail.indexOf('KYHD') !== -1 && !component.get("v.kYComp")) {
                component.set("v.KYHDChkBoxDisability", false);
            }
            // Picklist Values for Service Type
            if (component.get("v.holdServiceTypeOptions") !== null && component.get("v.holdServiceTypeOptions") !== undefined) {
                var servTypeOp1 = this.createPicklist(component, component.get("v.holdServiceTypeOptions"));
                component.set("v.serviceTypeOptions", servTypeOp1);
            }
            // Picklist Values for Special Options
            if (!$A.util.isEmpty(component.get("v.holdSpecialOptions")) && component.get("v.holdSpecialOptions") !== undefined && component.get("v.holdSpecialOptions") !==null) {
                var servTypeOp2 = this.createPicklist(component, component.get("v.holdSpecialOptions"));
                component.set("v.specialOptions", servTypeOp2);
            } else {
                var opts = [];
                opts.push({
                    label: "--- None ---",
                    value: ""
                });
                component.set("v.specialOptions", opts);
            }
            // Picklist Values for Product Classification
            if (component.get("v.holdprodClassOptions") !== null && component.get("v.holdprodClassOptions") !== undefined) {
                var servTypeOp3 = this.createPicklist(component, component.get("v.holdprodClassOptions"));
                component.set("v.prodClassOptions", servTypeOp3);
            }
            // Picklist Values for Bill To
            if (component.get("v.holdbillToOptions") !== null && component.get("v.holdbillToOptions") !== undefined) {
                var servTypeOp4 = this.createPicklist(component, component.get("v.holdbillToOptions"));
                component.set("v.billToOptions", servTypeOp4);
            }
            // Picklist Values for ADOverRide
            if (component.get("v.holdADOverride") !== null && component.get("v.holdADOverride") !== undefined) {
                var servTypeOp7 = this.createPicklist(component, component.get("v.holdADOverride"));
                component.set("v.ADOverrideOptions", servTypeOp7);
            }
            //<!--5615509-->
            // Picklist Values for Reason For Damage
            if (component.get("v.reasonForDamageOptionsHold") !== null && component.get("v.reasonForDamageOptionsHold") !== undefined) {
                //var reasonForDamageOptions = this.createPicklist(component, component.get("v.reasonForDamageOptionsHold"));
                var reasonForDamageOptions=[];
                var reason= component.get("v.reasonForDamage");
                console.log('The reson for damage'+JSON.stringify(reason));
                var inputListreason= component.get("v.reasonForDamageOptionsHold");
                reasonForDamageOptions.push({
                    label: "--- None ---",
                    value: ""
                });
                for(var i=0;i<inputListreason.length;i++)
                {
                    if(reason!==undefined && reason!==null)
                    {
                        if(inputListreason[i] === reason)  
                        {
                            reasonForDamageOptions.push({
                                label: inputListreason[i],
                                value: inputListreason[i] ,
                                selected: true     
                            }); 
                        }
                        else{
                            reasonForDamageOptions.push({
                                label: inputListreason[i],
                                value: inputListreason[i] ,
                                selected: false    
                            }); 
                        }                          
                    }
                    else
                    {
                        
                        if(inputListreason[i] ==='System Fell or has Fallen')  
                        {
                            reasonForDamageOptions.push({
                                label: inputListreason[i],
                                value: inputListreason[i] ,
                                selected: true     
                            }); 
                        }
                        else{
                            reasonForDamageOptions.push({
                                label: inputListreason[i],
                                value: inputListreason[i] ,
                                selected: false    
                            }); 
                        }
                        
                    }
                    
                }
                component.set("v.reasonForDamageOptions", reasonForDamageOptions);
            }
            // Picklist Values for Service Options
            if (component.get("v.holdserviceoptions") !== null && component.get("v.holdserviceoptions") !== undefined) {
                var servTypeOp5 = this.setServiceOptions(component, component.get("v.holdserviceoptions"), component.get("v.serviceOptionValue"));
                component.set("v.serviceoptions", servTypeOp5);
            } else {
                this.setServiceOptionsToNull(component);
            }
            // if Bill To has Value --> Display Bill To Order Field on Load of Page
            if (!$A.util.isEmpty(component.get("v.billToValue"))) {
                component.set("v.billToHasValue", true);
            }
            // fetch Country & State Picklist Values.
            this.fetchCountryAndStatePicklists(component);
            
            //Picklist Values for DASP
            if("v.DASPEnable") {
               
                           console.log("!!!!!"+component.get("v.DASPValues"));
                        

            }
            
        } catch (Err) {
            this.hideSpinner(component);
            console.log("Err>>>"+Err);
            this.showToast(component, 'ERROR', "Error Occured While Loading Component", "Error");
        }
    },
    
    onCountryChangedHelper: function(component) {
        var selectedCountry = component.get('v.altReturnCountryValue');
        var arrayOfDependentStates = [];
        if (selectedCountry !== undefined && selectedCountry !== '') {
            var countryStateMap = component.get('v.countryStateMap');
            var states = countryStateMap[selectedCountry];
            var i;
            for (i = 0; i < states.length; i = i + 1) {
                arrayOfDependentStates.push(states[i]);
            }
            arrayOfDependentStates = arrayOfDependentStates.sort();
            var stateOptions = this.setServiceOptions(component, arrayOfDependentStates);
            component.set('v.altReturnStateOptions', stateOptions);
        } else {
            component.set('v.altReturnStateOptions', arrayOfDependentStates);
        }
    },
    
    ADOverrideHelper: function() {
        // Do Nothing
    },
    
    // on chnage of Service Type
    billToChangeHelper: function(component) {
        var oldValue = component.get("v.billToOldValue");
        var oldServiceOption = component.get("v.serviceOptionValue");
		component.set("v.validationError", false);
        component.set("v.errorMessage", '');
        try {
            // Clear DSP Overrride Flag - If Service Type is Changed to Parts Only
            if (component.find('serviceTypeId').get("v.value") === 'Parts Only') {
                component.set("v.DSPOverReq", false);
                component.set("v.Instructions", null);
            }
            
            if ((component.find('billToId').get("v.value")) !== 'Customer') {
                component.set("v.OrderNumber", null);
            }
			 
            
            
            if (component.get("v.OutOfWarranty")) {
                if ($A.util.isEmpty(component.find('billToId').get("v.value"))) {
                    component.set("v.OrderNumber", null);
                    component.set("v.billToHasValue", false);
                    component.set("v.errorMessage", 'A Bill To option is required because this system is out of warranty.');
                    component.set("v.validationError", true);
                    this.setServiceOptionsToNull(component);
                } else {
                    component.set("v.billToHasValue", true);
                    if (oldValue === null || oldValue === undefined || $A.util.isEmpty(oldValue)) {
                        this.getServiceTypeOptions(component, 'Y');
                        this.setServiceOptionsToNull(component);
                    } else {
                        if ($A.util.isEmpty(component.find('serviceTypeId').get("v.value"))) {
                            component.set("v.errorMessage", 'Please select a service type.');
                            component.set("v.validationError", true);
                            this.setServiceOptionsToNull(component);
                        } else {
                            this.onChangeBillTo(component, component.get("v.serviceTypeValue"), 'Y',oldServiceOption);
                        }
                    }
                }
            } else {
                if ($A.util.isEmpty(component.find('billToId').get("v.value"))) {
                    component.set("v.billToHasValue", false);
                    this.getServiceTypeOptions(component, 'N');
                    this.setServiceOptionsToNull(component);
                } else {
                    component.set("v.billToHasValue", true);
                    if (oldValue === null || oldValue === undefined || $A.util.isEmpty(oldValue)) {
                        this.getServiceTypeOptions(component, 'Y');
                        this.setServiceOptionsToNull(component);
                    } else {
                        if ($A.util.isEmpty(component.find('serviceTypeId').get("v.value"))) {
                            component.set("v.errorMessage", 'Please select a service type.');
                            component.set("v.validationError", true);
                            this.setServiceOptionsToNull(component);
                        } else {
                            this.onChangeBillTo(component, component.get("v.serviceTypeValue"), 'Y',oldServiceOption);
                        }
                    }
                }
            }
            component.set("v.billToOldValue", component.find('billToId').get("v.value"));
        } catch (Err) {
            this.showToast(component, 'Error', "Error Occured while loading component - serviceType : "+Err, "Error");
        }
    },
    // on chnage of Service Type
    serviceTypeHelper: function(component) {
		var defaultSOption = component.get("v.serviceOptionValue");
        component.set("v.validationError", false);
        component.set("v.errorMessage", '');
        try {
            if ($A.util.isEmpty(component.find('serviceTypeId').get("v.value"))) {
                component.set("v.errorMessage", 'Please select a service type.');
                component.set("v.validationError", true);
                this.setServiceOptionsToNull(component);
            } else {
                // Clear DSP Overrride Flag - If Service Type is Changed to Parts Only
                if (component.find('serviceTypeId').get("v.value") === 'Parts Only') {
                    component.set("v.DSPOverReq", false);
                    component.set("v.Instructions", null);
                }
                
                if (component.get("v.OutOfWarranty")) {
                    if ($A.util.isEmpty(component.find('billToId').get("v.value"))) {
                        component.set("v.errorMessage", 'A Bill To option is required because this system is out of warranty.');
                        component.set("v.validationError", true);
                        this.setServiceOptionsToNull(component);
                    } else {
                        this.onChangeBillTo(component, component.get("v.serviceTypeValue"), 'Y',defaultSOption);
                    }
                } else {
                    if ($A.util.isEmpty(component.find('billToId').get("v.value"))) {
                        this.setServiceOptionsToNull(component);
                        this.onChangeBillTo(component, component.get("v.serviceTypeValue"), 'N',defaultSOption);
                    } else {
                        this.setServiceOptionsToNull(component);
                        this.onChangeBillTo(component, component.get("v.serviceTypeValue"), 'Y',defaultSOption);
                    }
                }
            }
        } catch (Err) {
            this.showToast(component, 'Error', "Error Occured while loading component - serviceType : "+Err, "Error");
        }
    },
    
    // Create Picklist Values - Service Options
    setServiceOptions: function(component, inputvalue, defaultvalue) {
        var opts = [];
        if (inputvalue !== undefined && inputvalue.length > 0) {
            for (var i = 0; i < inputvalue.length; i = i + 1) {
                if (!$A.util.isEmpty(inputvalue[i])) {
                    if ((inputvalue[i] === defaultvalue && !$A.util.isEmpty(defaultvalue)) || (!$A.util.isEmpty(defaultvalue) && i === 0)) {
                        opts.push({
                            label: inputvalue[i],
                            value: inputvalue[i],
                            selected: true
                        });
                    } else {
                        opts.push({
                            label: inputvalue[i],
                            value: inputvalue[i],
                            selected: false
                        });
                    }
                }
            }
        }
        return opts;
    },
    
    // Get Service Type Picklist values
    getServiceTypeOptions: function(component, billToFlag) {
        try {
			var defaultSOption = component.get("v.serviceOptionValue");
            var serviceTypeVal_BeforeChange = component.get("v.serviceTypeValue");
            component.set("v.serviceTypeValue", null);
            //turn on Spinner
            this.showSpinner(component);
            var opts = [];
            var action = component.get("c.getServiceTypesBasedBillTo");
            action.setParams({
                dDRecId: component.get("v.dispDefaultsRecId"),
                billToFlag: billToFlag
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result !== null && result !== undefined && result.length > 0) {
                        opts.push({
                            label: "--- None ---",
                            value: ""
                        });
                        for (var i = 0; i < result.length; i = i + 1) {
                            if (!$A.util.isEmpty(result[i])) {
                                if (result[i] === serviceTypeVal_BeforeChange && !$A.util.isEmpty(serviceTypeVal_BeforeChange)) {
                                    opts.push({
                                        label: result[i],
                                        value: result[i],
                                        selected: true
                                    });
                                } else {
                                    opts.push({
                                        label: result[i],
                                        value: result[i],
                                        selected: false
                                    });
                                }
                            }
                        }
                        
                        // If list Includes - Service Type - Selected Earlier - it will be defaulted and fetches - new Service Options
                        if (result.includes(serviceTypeVal_BeforeChange)) {
                            component.set("v.serviceTypeValue", serviceTypeVal_BeforeChange);
                            this.onChangeBillTo(component, serviceTypeVal_BeforeChange, billToFlag,defaultSOption);
                        } else {
                            // Need to re-select the service type 
                            this.hideSpinner(component);
                        }
                        component.set("v.holdServiceTypeOptions", result);
                        component.set("v.serviceTypeOptions", opts);
                        
                        // Clear DSP Overrride Flag - If Service Type is Changed to Parts Only
                        if (component.find('serviceTypeId').get("v.value") === 'Parts Only') {
                            component.set("v.DSPOverReq", false);
                            component.set("v.Instructions", null);
                        }
                    }
                } else {
                    opts.push({
                        label: "--- None ---",
                        value: ""
                    });
                    component.set("v.holdServiceTypeOptions", opts);
                    Component.set("v.serviceTypeOptions", opts);
                    // Toast Error Message to User
                    this.showToast(component, 'ERROR', 'Error Occured While Fetching Service Types ', "Error");
                    // turn Off Spinner
                    this.hideSpinner(component);
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            opts.push({
                label: "--- None ---",
                value: ""
            });
            component.set("v.serviceTypeValue", null);
            component.set("v.holdServiceTypeOptions", opts);
            Component.set("v.serviceTypeOptions", opts);
            this.showToast(component, 'ERROR', 'Error Occured While Fetching Service Types :'+Err, "Error");
            // turn Off Spinner
            this.hideSpinner(component);
        }
    },
    
    fetchCountryAndStatePicklists: function(component) {
        try {
            var action = component.get("c.fetchCountryAndStateMap");
            action.setCallback(this, function(response) {
                component.set('v.countryStateMap', response.getReturnValue());
                var countryStateMap = component.get('v.countryStateMap');
                var arrayOfMapKeys = [];
                for (var singlekey in countryStateMap) {
                    if(!$A.util.isEmpty(singlekey)){
                        arrayOfMapKeys.push(singlekey);
                    }
                }
                var countryOptions = [];
                var stateOptions = [];
                var stateValues = [];
                
                if (undefined !== component.get('v.altReturnCountryValue') && component.get('v.altReturnCountryValue') !== '--- None ---') {
                    countryOptions = this.setServiceOptions(component, arrayOfMapKeys, component.get('v.altReturnCountryValue'));
                    stateValues = component.get('v.countryStateMap')[component.get('v.altReturnCountryValue')];
                    
                    if (undefined !== stateValues && null !== stateValues) {
                        stateValues = stateValues.sort();
                        if (undefined !== component.get('v.altReturnStateValue')) {
                            stateOptions = this.setServiceOptions(component, stateValues, component.get('v.altReturnStateValue'));
                        } else {
                            stateOptions = this.createPicklist(component, stateValues);
                        }
                    }
                    //countryOptions.unshift({label:"--- None ---",value:"",selected:false});
                    //stateOptions.unshift({label:"--- None ---",value:"",selected:false});
                } else {
                    countryOptions = this.createPicklist(component, arrayOfMapKeys);
                    if (undefined !== countryOptions && null !== countryOptions && countryOptions[0].label.includes("None")) {
                        countryOptions.shift();
                    }
                    stateOptions = this.createPicklist(component, stateValues);
                }
                component.set('v.altReturnCountryOptions', countryOptions);
                component.set('v.altReturnStateOptions', stateOptions);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component, 'ERROR', 'Error Occured While Fetching Country Picklist Values : '+Err, "Error");
        }
    },
    KYHDChkBoxChangeAction: function(component) {
        var KYHDFlag = component.get('v.KYHDFlag');
        if (KYHDFlag) {
            component.set("v.KYHDFlagChangedTrue", true);
        } else {
            component.set("v.KYHDFlagChangedTrue", false);
        }
    },
    
    //Archana Giliyar added for the US 5509615     
    onChangeServiceOptions: function(component) {
        try {
            this.showSpinner(component);
            var specialOpts 		= 	[];
            var recordId 			= 	component.get("v.recordId");
            var oldSpclOptionValue 	= 	component.get("v.specialOptionValue");
            var SvcType 			= 	component.get("v.serviceTypeValue");
            var SvcOption 			= 	component.get("v.serviceOptionValue");
            var DASP                =   '';           
            var action 				= 	component.get("c.getWOdata");
            if(component.get("v.DASPEnable")) {
                DASP = component.find('DASPId').get("v.value");
            }              
            action.setParams({
                WorkOrderId: recordId,
                ServiceType: SvcType,
                SvcOptions: SvcOption,
                DASPVal:  DASP 
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (!$A.util.isEmpty(result)) {
                        if (result.responseCode === '100') {
                            if (!$A.util.isEmpty(result.categoryOptions) && result.categoryOptions.length > 0) {
                                specialOpts.push({
                                    label: "--- None ---",
                                    value: ""
                                });
                                for (var i = 0; i < result.categoryOptions.length; i = i + 1) {
                                    if (!$A.util.isEmpty(result.categoryOptions[i])) {
                                        if (result.categoryOptions[i] === oldSpclOptionValue && !$A.util.isEmpty(oldSpclOptionValue)) {
                                            specialOpts.push({
                                                label: result.categoryOptions[i],
                                                value: result.categoryOptions[i],
                                                selected: true
                                            });
                                        } else {
                                            specialOpts.push({
                                                label: result.categoryOptions[i],
                                                value: result.categoryOptions[i],
                                                selected: false
                                            });
                                        }
                                    }
                                }
                                
                                component.set("v.specialOptions", specialOpts);
                                component.set("v.holdSpecialOptions", result.categoryOptions);
                                if (result.categoryOptions.includes(oldSpclOptionValue)) {
                                    component.set("v.specialOptionValue", oldSpclOptionValue);
                                } else {
                                    component.set("v.specialOptionValue", null);
                                }
                            } else {
                                this.setSpclOptionsToNull(component);
                            }
                            this.hideSpinner(component);
                        } else {
                            this.setSpclOptionsToNull(component);
                            this.hideSpinner(component);
                            //this.showToast(component, 'ERROR', 'Category List from External Source is blank', "Error"); - Commented By Harsha - DEFECT 5610374
                        }
                    } else {
                        this.setSpclOptionsToNull(component);
                        this.hideSpinner(component);
                        this.showToast(component, 'ERROR', "Error Occured While Fetching Spcl Options", "Error");
                    }
                } else {
                    this.setSpclOptionsToNull(component);
                    //turn Off Spinner
                    this.hideSpinner(component);
                    this.showToast(component, 'ERROR', "Error Occured While Loading The Form - callApex", "Error");
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            //turn Off Spinner
            this.hideSpinner(component);
            // Toast Error to User
            this.showToast(component, 'ERROR', "Error Occured While Loading The Form : "+Err, "Error");
        }
        
    },
    
    setSpclOptionsToNull: function(component) {
        try {
            var opts = [];
            opts.push({
                label: "--- None ---",
                value: ""
            });
            component.set("v.specialOptions", opts);
            component.set("v.holdSpecialOptions", '');
            component.set("v.specialOptionValue", null);
        } catch (Err) {
            this.showToast(component, 'ERROR', "Error Occured Refreshing the Form: "+Err, "Error");
        }
    },
    // added function By Harsha - 09/25/2018 - Defect #865002590
    // OR condition added by Megha - 01/11/2019 - Defect #6002888
    handleADchangeHelper : function (component){
        try{
            if(!component.get("v.AccDamageVal") || component.get("v.isCountrySpain")){
                component.set("v.ADOverValue","");
            }
        } catch(Err){
            this.showToast(component, 'ERROR', "Error Occured Refreshing the Form: "+Err, "Error");
        }
    },
    DASPHelper : function (component) {
     try{
          //Latam De-Scoped
        }
        catch(Err){
            this.showToast(component, 'ERROR', "Error Occured Refreshing the Form: "+Err, "Error");
        }
    }
})
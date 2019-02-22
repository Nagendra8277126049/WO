({
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

    // Call Apex Controller
    CheckRepeatDispatchInAsset: function(component) {
        try {
            component.set("v.Spinner", true);
            component.set("v.isRepeatDispatch", false);
                                           //console.log('Akhil++ countryCode in Repeat Dispatch'+component.get("v.addressCountry"));
            var action = component.get("c.checkRepeatDispatchInAsset");
            action.setParams({
                caseId: component.get("v.caseId"),
                                                          countryCode: component.get("v.addressCountry")
                                                          
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseResult = response.getReturnValue();
                    if (!$A.util.isEmpty(responseResult)) {
                        component.set("v.isAssetPurchasedRecently", responseResult.ifAssetPurchasedRecently);
                        component.set("v.isRepeatDispatch", responseResult.ifAssetHasRepeatDispatch);
                        //component.set("v.isAssetPurchasedRecently",true);
                        component.set("v.ServiceBUID", responseResult.ServiceBUID);
                        component.set("v.rowCount", responseResult.recordsCount);
                    } else {
                        this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
                    }
                    component.set("v.Spinner", false);
                } else {
                    component.set("v.Spinner", false);
                    this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            component.set("v.Spinner", false);
            this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },

    createLDSFrameWork: function(component) {
        try {
            component.find("workOrderRecordCreator").getNewRecord(
                "WorkOrder", // objectApiName
                null, // recordTypeId
                false, // skip cache?
                $A.getCallback(function() {
                    var rec = component.get("v.newWorkOrder");
                    var error = component.get("v.newWorkOrderError");
                    if (error || (rec === null)) {
                        this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
                    }
                })
            );
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },

    navigateWorkOrderTab: function(component, workOrderId) {
        try {
            if (!$A.util.isEmpty(workOrderId)) {
                // Commented by Harsha - DEFECT 5443199 - 08/07/2018
                /*
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": workOrderId,
                    "slideDevName": "related"
                });
                navEvt.fire();
                */
                // Added by Harsha - DEFECT 5443199 - 08/07/2018
                var navService = component.find("navService");
                var pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": workOrderId,
                        "objectApiName": "WorkOrder",
                        "actionName": "view"
                    },
                    "state": {}
                };
                navService.navigate(pageReference);
            }
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },

    createWorkOrderLDS: function(component) {
        try {
            component.set("v.Spinner", true);
            var thisObj = this;
                                           //component.set("v.addressCountry",'BR');
            component.set("v.simpleNewWorkOrder.OperationType__c", "DPS");
                                           //console.log('The asset value'+component.get("v.isAssetPurchasedRecently"));
            //component.set("v.simpleNewWorkOrder.Is_Asset_within_Invoice_Period__c", false);
                                           if(component.get("v.isAssetPurchasedRecently")===true){
            component.set("v.simpleNewWorkOrder.Is_Asset_within_Invoice_Period__c", true);    
                                           } 
            else{
                component.set("v.simpleNewWorkOrder.Is_Asset_within_Invoice_Period__c", false);
            }
            component.set("v.simpleNewWorkOrder.CaseId", component.get("v.caseId"));
            component.set("v.simpleNewWorkOrder.Subject", component.get("v.caseSubject"));
            component.set("v.simpleNewWorkOrder.Description", component.get("v.caseDescription"));
            component.set("v.simpleNewWorkOrder.AccountId", component.get("v.caseAccountId"));
            component.set("v.simpleNewWorkOrder.AssetId", component.get("v.caseAssetId"));
            component.set("v.simpleNewWorkOrder.ContactId", component.get("v.casePrimaryContactId"));
            component.set("v.simpleNewWorkOrder.ContactRole__c", component.get("v.casePrimaryContactRole"));
            component.set("v.simpleNewWorkOrder.AdditionalContactId__c", component.get("v.caseSecondaryContactId"));
            component.set("v.simpleNewWorkOrder.AdditionContactRole__c", component.get("v.caseSecondaryContactRole"));
            component.set("v.simpleNewWorkOrder.Additional_Notes__c", component.get("v.AdditionalNotes"));
            component.set("v.simpleNewWorkOrder.City", component.get("v.addressCity"));
            if (component.get("v.CountryCode") === 'US' || component.get("v.CountryCode") === 'CA' || component.get("v.CountryCode") === 'AU' || component.get("v.CountryCode") === 'NL' || component.get("v.CountryCode") === 'IN')
            component.set("v.simpleNewWorkOrder.StateCode", component.get("v.addressState"));
            //else
                                           //console.log('Inside Create Work Order : State is :'+ component.get("v.addressState"));
                                           //console.log('Inside Create Work Order : Country is :'+ component.get("v.CountryCode"));            
            //component.set("v.simpleNewWorkOrder.State", component.get("v.addressState"));
            component.set("v.simpleNewWorkOrder.PostalCode", component.get("v.addressPostalCode"));
            component.set("v.simpleNewWorkOrder.CountryCode", component.get("v.addressCountry"));
            component.set("v.simpleNewWorkOrder.Street", component.get("v.addressStreet"));
            component.set("v.simpleNewWorkOrder.AssetPartyLocationId__c", component.get("v.assetPartyLocationId"));
            component.set("v.simpleNewWorkOrder.PartyLocationId__c", component.get("v.partyLocationId"));
            component.set("v.simpleNewWorkOrder.Region__c", component.get("v.Region"));
            component.set("v.simpleNewWorkOrder.CustomerRegion__c", component.get("v.Region"))
            
            component.set("v.simpleNewWorkOrder.CountryCode__c", component.get("v.CountryCode"));
            component.set("v.simpleNewWorkOrder.DPS_BUID__c", component.get("v.CountryBUID"));
            component.set("v.simpleNewWorkOrder.DPS_Region__c", component.get("v.RegionName"));
            component.set("v.simpleNewWorkOrder.DPS_Sub_Region__c", component.get("v.SubRegionName"));
            component.set("v.simpleNewWorkOrder.Environment__c", component.get("v.Environment"));
            component.set("v.simpleNewWorkOrder.SubEnvironment__c", component.get("v.SubEnvironment"));
            component.set("v.simpleNewWorkOrder.DispatchEvent__c", 'DISPATCH_CREATE');
            component.set("v.simpleNewWorkOrder.FSD_Worked_By_Flg__c", 'N');
            component.set("v.simpleNewWorkOrder.IsDeferralAllowed__c", true);
            component.set("v.simpleNewWorkOrder.WO_Type__c", 'Break Fix');
            // Commented By Harsha - 09/28/2019 - DEFECT 5666418
            //component.set("v.simpleNewWorkOrder.ISPDispatchReasonCode__c", 'GCAE1');
            component.set("v.simpleNewWorkOrder.Status", 'Open');
            component.set("v.simpleNewWorkOrder.FSD_System_Model__c", component.get("v.assetModel"));
            component.set("v.simpleNewWorkOrder.ISPBillingAddressLine1__c", component.get("v.addressStreetBilling"));
            component.set("v.simpleNewWorkOrder.ISPBillingAddressLine2__c", component.get("v.addressStreetBilling2"));
            component.set("v.simpleNewWorkOrder.ISPBillingCity__c", component.get("v.addressCityBilling"));
            component.set("v.simpleNewWorkOrder.ISPBillingCountry__c", component.get("v.addressCountryBilling"));
            component.set("v.simpleNewWorkOrder.ISPBillingCountryCode__c", component.get("v.addressCountryBilling"));
            component.set("v.simpleNewWorkOrder.ISPBillingState__c", component.get("v.addressStateBilling"));
            component.set("v.simpleNewWorkOrder.ISPBillingZipCode__c", component.get("v.addressPostalCodeBilling"));
            component.set("v.simpleNewWorkOrder.Repeat_Dispatch_Count__c", component.get("v.rowCount"));
            component.set("v.simpleNewWorkOrder.RecordTypeId", $A.get("$Label.c.Dispatch_Record_Type_Create"));
            //MB: added below line to save CFI Number on work order as part of Nov Story: 5417023
            component.set("v.simpleNewWorkOrder.CFINumber__c",component.get("v.customFactoryIntNum"));
                                           
                                           //Akhil : Setting Dispatch Country 
                                           //var addr = 'Line1'+'\n\r'+'Line2'+'\n\r'+'Line3';
                                           //component.set("v.addressStreet",addr);
                                           //console.log('Before Setting Dispatch Country - Country Code:'+ component.get("v.addressCountry"));
                                           //console.log('The Dispatch Country on Create:'+component.get("v.addressCountry"));
           // console.log('brazil addreslline1'+component.get("v.brazilAddressLine1"));
            //console.log('brazil addreslline2'+component.get("v.brazilAddressLine2"));
            //console.log('brazil addreslline3'+component.get("v.brazilAddressLine3"));
            //console.log('brazil addreslline4'+component.get("v.brazilAddressLine4"));
            
                                           if(!$A.util.isEmpty(component.get("v.addressCountry"))&& $A.get("$Label.c.LatamCountries").includes(component.get("v.addressCountry")) && component.get("v.addressCountry")!==null  ){
                //console.log('Inside Brazil Check')
                //console.log('Brazil Address Street from BI:'+ component.get("v.addressStreet"));
								               var address = component.get("v.addressStreet");
                                               if(address.length >=255)
                                                   component.set("v.simpleNewWorkOrder.Street",  address.substring(0,254));
                                                          /*var address = component.get("v.addressStreet").split('\n\r');
                                                          if(!$A.util.isEmpty(address[0])){
                                                                        component.set("v.simpleNewWorkOrder.Address_Line_1__c", address[0]);
                }
                                                          if(!$A.util.isEmpty(address[1])) {
                                                                        component.set("v.simpleNewWorkOrder.Address_Line_2__c", address[1]);
                }
                                                          if(!$A.util.isEmpty(address[2])) {
                                                                        component.set("v.simpleNewWorkOrder.Address_Line_3__c", address[2]);
                }
                                                          if(!$A.util.isEmpty(address[3])) {
                                                                        component.set("v.simpleNewWorkOrder.Address_Line_4__c", address[3]);
                }*/
                                                         component.set("v.simpleNewWorkOrder.StateCode", component.get("v.addressState"));
                                                         component.set("v.simpleNewWorkOrder.Address_Line_1__c", component.get("v.brazilAddressLine1"));
                                                         component.set("v.simpleNewWorkOrder.Address_Line_2__c", component.get("v.brazilAddressLine2"));
                                                         component.set("v.simpleNewWorkOrder.Address_Line_3__c", component.get("v.brazilAddressLine3"));
                                                         component.set("v.simpleNewWorkOrder.Address_Line_4__c", component.get("v.brazilAddressLine4"));
                                               component.set("v.simpleNewWorkOrder.Dispatch_Country__c",'LATAM');
                                             //component.set("v.simpleNewWorkOrder.Country__c",'Brazil');
                                           component.set("v.simpleNewWorkOrder.Zip_Code__c",component.get("v.addressPostalCode"));
                                           component.set("v.simpleNewWorkOrder.City__c",component.get("v.addressCity"));
                                           }else{
                //console.log('Inside Global Check')
                                                        component.set("v.simpleNewWorkOrder.Dispatch_Country__c",'Global except LATAM');
                                           }
            
            if (!$A.util.isEmpty(component.get("v.ReasonRepeatWorkOrder"))) {
                component.set("v.simpleNewWorkOrder.Reason_for_repeat_Work_Order__c", component.get("v.ReasonRepeatWorkOrder"));
            }
            // Added By Harsha - STORY 5240855 - Starts Here
            var tObj = component.get("v.tireObject");
            if(component.get("v.requireMWDDiagnostic") === true && !$A.util.isEmpty(tObj)){
            	component.set("v.simpleNewWorkOrder.Diagnostic_Tier_Type__c",'MWD');
                component.set("v.simpleNewWorkOrder.ISPDiagnosticTier1__c",tObj.teir1);
                component.set("v.simpleNewWorkOrder.ISPDiagnosticTier2__c",tObj.teir2);
                component.set("v.simpleNewWorkOrder.ISPDiagnosticTier3__c",tObj.teir3);
                component.set("v.simpleNewWorkOrder.ISPDispatchReasonCode__c",tObj.reasonCode);
            } else if(component.get("v.safetyIssueFlag")){
             	// Added By Harsha - DEFECT 5670951 - 10/01/2018 - Starts Here
                component.set("v.simpleNewWorkOrder.Diagnostic_Tier_Type__c",'Safety');
                component.set("v.simpleNewWorkOrder.ISPDiagnosticTier1__c",'Safety Hazard');
                component.set("v.simpleNewWorkOrder.ISPDiagnosticTier2__c",component.get("v.typeOfSafetyIssue"));
                component.set("v.simpleNewWorkOrder.ISPDiagnosticTier3__c",'');
                component.set("v.simpleNewWorkOrder.ISPDispatchReasonCode__c",'');
                // Added By Harsha - DEFECT 5670951 - 10/01/2018 - Ends Here   
            }
             // Added By Harsha - STORY 5240855 - Ends Here
          
            component.set("v.simpleNewWorkOrder.ISPDispatchPPID__c", component.get("v.PPID")); //Prakhar needs to update it
            component.find("workOrderRecordCreator").saveRecord(function(saveResult) {

                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    component.set("v.showValidationErrorMsg", false);
                    component.set("v.errorMessageArray", null);
                    var workOrderId = saveResult.recordId;
                    component.set("v.workOrderId", workOrderId);
                    // Update the UI: close panel,refresh case page
                    thisObj.navigateWorkOrderTab(component, workOrderId);
                    component.set("v.Spinner", false);
                    $A.get("e.force:refreshView").fire();
                } else if (saveResult.state === "ERROR") {
                    component.set("v.simpleNewWorkOrder.StateCode", null);
                    //console.log('Trying to Save Record without StateCode');
                    component.find("workOrderRecordCreator").saveRecord(function(saveResult) {
                                  if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                                component.set("v.showValidationErrorMsg", false);
                                                component.set("v.errorMessageArray", null);
                                                 var workOrderId = saveResult.recordId;
                                                component.set("v.workOrderId", workOrderId);
                                                 // Update the UI: close panel,refresh case page
                                                thisObj.navigateWorkOrderTab(component, workOrderId);
                                                component.set("v.Spinner", false);
                                                $A.get("e.force:refreshView").fire();
                                  } else if (saveResult.state === "ERROR") {
                                                 //console.log('Erorr during creation'+JSON.stringify(saveResult.error));
                                                component.set("v.Spinner", false);
                                                component.set("v.showValidationErrorMsg", true);
                                                 var errorMessagesArray = [];
                                                 //below nested loop is iterating over the page messages of saveresult's error
                                                 for (var i = 0; i < saveResult.error.length; i = i + 1) {
                                                               var pageErrorMessage = saveResult.error[i];
                                                               for (var j = 0; j < pageErrorMessage.pageErrors.length; j = j + 1) {
                                                                             errorMessagesArray.push(pageErrorMessage.pageErrors[j].message);
                                                               }

                                                               component.set("v.errorMessageArray", errorMessagesArray);
                                                 }
                                  }
                    });

                }
            });
        } catch (Err) {
            component.set("v.Spinner", false);
            this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },

    createPPIDData: function(component) {
        var RowItemList = component.get("v.PPIDList");
        var rowcount = component.get("v.rowCount");
        rowcount = rowcount + 1;
        component.set("v.rowCount", rowcount);
        RowItemList.push({
            'key': rowcount,
            'PPIDText__c': '',
            'ErrorMessageforPPID__c': 'false',
            'ErrorMessageforLength': 'false',
            'ErrorMessageforDuplicatePPId': 'false',
            'ErrorDuplicateCheck': 'false'
        });
        component.set("v.PPIDList", RowItemList);
    },
    
    removePPIDData: function (component, event) {
        var index = event.target.dataset.index;
        var PPIDList = component.get("v.PPIDList");
        PPIDList.splice(index, 1);
        component.set("v.PPIDList", PPIDList);
    },    
    
    validatePPID: function(component) {
        component.set("v.Spinner", true);

        var PPIDValueList = [];
        var PPIDHyphenList = [];
        var PPIDBoolean = false;
        var duplicateBoolean;        
        var RowItemList = component.get("v.PPIDList");
        for (var i = 0; i < RowItemList.length; i = i + 1) {
            
             var PPIDstring = RowItemList[i].PPIDText__c.replace(/-/g, '');
           
            if (PPIDstring.length < 20) {                
                RowItemList[i].ErrorMessageforLength = true;
                RowItemList[i].ErrorMessageforPPID__c = false;
                RowItemList[i].ErrorMessageforDuplicatePPId = false;
                PPIDBoolean = true;
            }
            else{
                //PPIDBoolean = false;
                RowItemList[i].ErrorMessageforLength = false;
                RowItemList[i].ErrorMessageforPPID__c = false;
                RowItemList[i].ErrorMessageforDuplicatePPId = false;
                PPIDValueList.push(PPIDstring);
            }
        }

        duplicateBoolean = this.duplicatePPIDcheck(RowItemList, component);
        //alert('the value of duplicateBoolean'+duplicateBoolean);
        //alert('the value of PPIDBoolean'+PPIDBoolean);
        if (duplicateBoolean === true) {
            //alert('Inside DuplicateBoolean value'+duplicateBoolean);
            PPIDBoolean = true;
        }
        component.set("v.PPIDList", RowItemList);
        if (PPIDBoolean === false) {
            try {
                var action = component.get("c.validatePPID");
                action.setParams({
                    PPIDList: PPIDValueList,
                    ServiceBUID: component.get("v.ServiceBUID")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var responseResult = response.getReturnValue();
                        var PPIDreturnList = JSON.stringify(responseResult);
                        if (responseResult !== null || responseResult !== undefined) {
                            if (PPIDreturnList.includes('Success')) {
                                for (var x = 0; x < RowItemList.length; x=x+1) {
                                    PPIDHyphenList.push(RowItemList[x].PPIDText__c);
                                }
                                var PPIDConcatenated = PPIDHyphenList.join(",");

                                component.set("v.PPID", PPIDConcatenated);

                                this.createWorkOrderLDS(component);
                           } else {
                                for (var y = 0; y < RowItemList.length; y=y+1) {
                                    var PPIDstringVal = RowItemList[y].PPIDText__c.replace(/-/g, '');
                                    if (responseResult.includes(PPIDstringVal)) {
                                        RowItemList[y].ErrorMessageforPPID__c = true;
                                    }
                                }
                                component.set("v.PPIDList", RowItemList);
                            }
                        }
                    } else {
                        this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
                    }
                });
                $A.enqueueAction(action);
            } catch (Err) {
                component.set("v.Spinner", false);
            }
        }
        component.set("v.Spinner", false);
    },
    keyCheckGeneric: function(messageText,component) {
        var finalMessage = '';
        var messagereplaced ='';
        var message = messageText.replace(/[^a-zA-Z0-9]/g, '');
        if(message.length >27)
        {
            messagereplaced= message.substring(0,27);
        }
        else
        {
            messagereplaced= message;
        }
        for (var i = 0; i < messagereplaced.length; i = i + 1) {              
            if (i === 8 || i === 2 || i === 13) {
                finalMessage = finalMessage + '-';
                finalMessage = finalMessage + messagereplaced.charAt(i);
            } else {
                finalMessage = finalMessage + messagereplaced.charAt(i);
            }
        }
       /* var count=0;
        var RowItemList = component.get("v.PPIDList");
        for(var i=0;i<RowItemList.length;i++)
        {
            if($A.util.isEmpty(RowItemList[i].PPIDText__c))
            {
                count=count+1;
                break;
            }
        }
        if(count>0)
        {
            component.set("v.DisabledPPIDLink",false);
        }
        else{
            component.set("v.DisabledPPIDLink",true);
        }*/
        return finalMessage;
    },

    handleSaveWorkOrderHelper: function(component) {
        try {
            var isRepeatDispatch = component.get("v.isRepeatDispatch");
            var repeatReason = '';
            var RowItemList = component.get("v.PPIDList");

            if (isRepeatDispatch) {
                repeatReason = component.find("ReasonRepeatWorkOrderId").get("v.value");
            }
            if (isRepeatDispatch) {
                if ($A.util.isEmpty(repeatReason)) {
                    this.showToast("", 'ERROR', "Provide reason for repeat work order to proceed further.", "Error"); //move to a custom label
                    return;
                } else {
                    //Defect - 5257488
                    // Added by Harsha - Starts Here
                    if (repeatReason === 'DOA Service Part') {
                        if (RowItemList.length > 0) {
                            component.set('v.showValidationErrorMsg', false);

                            if (RowItemList[0].PPIDText__c === '') {
                                component.set('v.showValidationErrorMsg', true);
                                var errormessage = [];
                                errormessage.push('PPID is a required field for the selected repeat work order reason');
                                component.set('v.errorMessageArray', errormessage);
                                return;
                            }
                            this.validatePPID(component);
                        }
                    // Added By Harsha - STORY 5240855 - Starts Here
                    } else if(component.get("v.requireMWDDiagnostic")===true && $A.util.isEmpty(component.get("v.tireObject"))){
    	                this.showToast("", 'ERROR', "Provide select special issue to proceed further.", "Error"); 
        	            return;
 	                // Added By Harsha - STORY 5240855 - Ends Here
                    } else {
                        this.createWorkOrderLDS(component);
                    }
                }

            } else {
                this.createWorkOrderLDS(component);
            }
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }

    },

    handleRepeatReasonHelper: function(component) {
        try {
            /*//
             * Commented Below for this STORY 5240855
            var getRepeatReasonVal = component.find("ReasonRepeatWorkOrderId").get("v.value");
            if (component.find("ReasonRepeatWorkOrderId").get("v.value") === 'DOA Service Part') {
                component.set("{!v.isPPID}", true);
            } else {
                component.set("{!v.isPPID}", false);
            }
            if (!$A.util.isEmpty(getRepeatReasonVal)) {
                component.set("v.ReasonRepeatWorkOrder", getRepeatReasonVal);
            }
            */
            //Added below for this Story 5240855 - Starts Here
            var getRepeatReasonVal = component.find("ReasonRepeatWorkOrderId").get("v.value");
            if (!$A.util.isEmpty(getRepeatReasonVal)) {
                component.set("v.ReasonRepeatWorkOrder", getRepeatReasonVal);
                component.set("{!v.isPPID}", false);
                component.set("{!v.requireMWDDiagnostic}",false);
                if (getRepeatReasonVal.toLowerCase()=== 'doa service part') {
                    component.set("{!v.isPPID}", true);
                } else if (getRepeatReasonVal.toLowerCase()=== 'product quality issue' || getRepeatReasonVal.toLowerCase()=== 'logistics - mwd'){
                    component.set("{!v.requireMWDDiagnostic}",true);
                }
                
                if(component.get("v.requireMWDDiagnostic") === false && !$A.util.isEmpty(component.get("v.tireObject"))){
                    // do something
                    component.set("{!v.tireObject}",null);
                }
            }
            //Added below for this Story 5240855 - Ends Here
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.CreateDispatchErrorMessage"), "Error");
        }
    },

    duplicatePPIDcheck: function(RowItemList, component) {
        var count = 0;
        //alert(JSON.stringify(RowItemList));
        for (var i = 0; i < RowItemList.length; i=i+1) {
            for (var j = i + 1; j < RowItemList.length; j=j+1) {
                if (!$A.util.isEmpty(RowItemList[i].PPIDText__c) && !$A.util.isEmpty(RowItemList[j].PPIDText__c)) { // Added by Harsha - DEFECT 5599859
                    if (RowItemList[i].PPIDText__c !== 'XX-XXXXXX-XXXXX-XXXXXXXXXXXXXX' && RowItemList[i].PPIDText__c !== 'xx-xxxxxx-xxxxx-xxxxxxxxxxxxxx') {
                        if (RowItemList[i].PPIDText__c === RowItemList[j].PPIDText__c) {
                            RowItemList[j].ErrorDuplicateCheck = true;
                            RowItemList[j].ErrorMessageforDuplicatePPId = true;
                            count = count + 1;
                        } else if (RowItemList[j].ErrorDuplicateCheck !== true) {
                            RowItemList[j].ErrorMessageforDuplicatePPId = false;
                        }
                    }
                }
            }
        }
        //alert("Inside Duplicate check function"+JSON.stringify(RowItemList));
        component.set("v.PPIDList", RowItemList);
        if (count > 0) {
            return true;
        }
        return false;
    },
    
     // Added By Harsha - STORY 5240855 - Starts Here
    handleMWDDiagnosticTeirHelper:function(component,event){
        var msg = event.getParam('filters') || '';
        if(!$A.util.isEmpty(msg)){
            component.set("{!v.tireObject}",msg);
        } else {
            component.set("{!v.tireObject}",null);
        }
    }
     // Added By Harsha - STORY 5240855 - Ends Here
})
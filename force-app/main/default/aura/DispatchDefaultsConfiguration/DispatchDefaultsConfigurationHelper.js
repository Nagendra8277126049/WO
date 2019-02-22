({
    // Get Response Calling Apex Controller
    getResponse: function(component, recId) {
        try {
			console.log('Inside getresponse');            
            if(component.get("v.isTriggerFlag")){
                return;
            }
            
            component.set("v.isTriggerFlag",true);
            component.set("v.Spinner", true);
            var action = component.get("c.getDispatchDefaults");
            action.setParams({
                //set RecordId
                workOrderId: recId
            });
            action.setCallback(this, function(response) {
                //console.log("v.response>>>"+JSON.stringify(response.getReturnValue()));
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //response from Apex Controller
                    if (result !== null && result !== undefined) {
                       	component.set("v.response", response.getReturnValue());
                        
                        if(result.DASPValues != undefined && result.DASPValues != null && result.DASPValues != '')
                        {
                            var arr 	= 	[];
                            arr.push({value:"", label:"--None--"});
                            Object.keys(result.DASPValues).forEach(function(key) {
                            arr.push({label:result.DASPValues[key].PartnerName__c, value:result.DASPValues[key]});
							});
                            console.log(arr);
                            component.set("v.DASPEnable", true);
                            component.set("v.DASPValues",arr);
                            
                        } 
                        component.set("v.Spinner", false);
                        
                        if (result.outOfWarranty) {
                            // if asset is Out of Warranty - Show Warning to Agent
                            this.showToast(component, 'Warning',$A.get("$Label.c.Dispatch_WarningMessageAssetOutOfWarranty"), "Warning");
                        }
                        if (!$A.util.isUndefinedOrNull(result.ErrorCode) && !$A.util.isUndefinedOrNull(result.WarningMessage)) {
                            if(result.ErrorCode !=100000 && result.WarningMessage!="Operation successful."){
                            	this.showToast(component, 'Warning',result.WarningMessage, "Warning");
                            }
                        }
                    } else {
                        component.set("v.response", null);
                        component.set("v.Spinner", false);
                        // Toast Error Message to User
                        this.showToast(component, 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageComponent"), "Error");
                    }
                } else {
                    //Show Error to user - Error Occured While Loading Component.
                    this.showToast(component, 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageComponent"), "Error");
                    component.set("v.Spinner", false);
                }
                
            });
            $A.enqueueAction(action);
            component.set("v.isTriggerFlag",false);
        } catch (Err) {
            component.set("v.isTriggerFlag",false);
            component.set("v.Spinner", false);
            this.showToast(component, 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"), "Error");
        }
    },

    //To toast 
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

    //Create Dynamic Edit Component Asynchronosuly
    openWindow: function(component) {
        try {
            component.set("v.openReadForm", false);
            component.get("v.response.ADOverrideReason");
                          
		    $A.createComponent(
                "c:DispatchDefaultsEditForm", {
                    // Aura Id 
                    "aura:id" : "dispatchDeftEditCmpId",
                    //Work Order Record Id
                    "recordId": component.get("v.recordId"),
                    //Component Name
                    "ComponentLabel": component.get("v.ComponentLabel"),
                    //Dispatch Default Record Id
                    "dispDefaultsRecId": component.get("v.response.defaultRecordId"),
                    //Picklist Values for Service Type
                    "holdServiceTypeOptions": component.get("v.response.serviceTypeOptions"),
                    //ServiceType Value
                    "serviceTypeValue": component.get("v.response.serviceType"),
                    //Picklist Values for Bill To Options
                    "holdbillToOptions": component.get("v.response.billToOptions"),
                    //Bill To Value
                    "billToValue": component.get("v.response.billTo"),
                    //product Classification Picklist Values
                    "holdprodClassOptions": component.get("v.response.productClassOptions"),
                    //Product Classification Value
                    "prodClassValue": component.get("v.response.productClassification"),
                    //Special Options - Picklist Values
                    "holdSpecialOptions": component.get("v.response.specialOptions"),
                    //Special Option Value
                    "specialOptionValue": component.get("v.response.specialOpnsValue"),
                    //Accidental Damage Value from maestro
                    "AccDamage": component.get("v.response.accidentalDamage"),
                    //Accidental Damage Value in SFDC
                    "AccDamageVal": component.get("v.response.accidentalDamage1"),
                    //Accidental Damage override attribute
                    "ADCoverageFlag": component.get("v.response.ADCoverageFlag"),
                    //Accidental Damage Option Values
                    "holdADOverride": component.get("v.response.ADOverrideOptions"),
                    //Accidental Damage OverRide Reason Value //added by dattaa1
                    "ADOverValue": component.get("v.response.ADOverrideReason"),
                    //Order Number
                    "OrderNumber": component.get("v.response.orderNumber"),
                    //Keep Your Components
                    "kYComp": component.get("v.response.keepYComp"),
                    //DSP Override Request
                    "DSPOverReq": component.get("v.response.dSPOverideReq"),
                    //Picklist Values for Service Options
                    "holdserviceoptions": component.get("v.response.serviceOptions"),
                    //Service Option Value
                    "serviceOptionValue": component.get("v.response.selectedServiceOpt"),
                    //Service Type Field Label
                    "ServiceTypeLabel": component.get("v.ServiceTypeLabel"),
                    //Service Option Field Label
                    "ServiceOptionsLabel": component.get("v.ServiceOptionsLabel"),
                    //Service Classification Field Label
                    "SystemClassificationLabel": component.get("v.SystemClassificationLabel"),
                    //Category Label
                    "CategoryLabel": component.get("v.CategoryLabel"),
                    //KYC Field Label
                    "KeepYourComponentsLabel": component.get("v.KeepYourComponentsLabel"),
                    //DSP Override Request Field Label
                    "DSPOverideRequestLabel": component.get("v.DSPOverideRequestLabel"),
                    //Accidental Damage Field Label
                    "AccidentalDamageLabel": component.get("v.AccidentalDamageLabel"),
                    //Bill To Field Label
                    "BillToLabel": component.get("v.BillToLabel"),
                    //Order Number Field Label
                    "OrderNumberLabel": component.get("v.OrderNumberLabel"),
                    //Out of Warrant - Boolean value
                    "OutOfWarranty": component.get("v.response.outOfWarranty"),
                    //Instructions
                    "Instructions": component.get("v.response.Instructions"),
                    //Instruction RecordId
                    "InstructRecId": component.get("v.response.InstructRecordId"),
                    //Instruction Field Label
                    "InstructionLabel": component.get("v.InstructionLabel"),
                    //KYHDFlag
                    "KYHDFlag": component.get("v.response.KYHDFlag"),
                    //KYHD Flag Label
                    "KYHDFlagLabel": component.get("v.KYHDLabel"),
                    //Reason For Damage Label
                    "reasonForDamageLabel": component.get("v.reasonForDamageLabel"),
                    //Reason For Damage Value
                    "reasonForDamage": component.get("v.response.reasonForDamage"),
                    //Reason For Damage Options
                    "reasonForDamageOptionsHold": component.get("v.response.reasonForDamageOptions"),
                    "EntitlementDetailsValue": component.get("v.response.entitlementDetails"),
                    "ADOverrideReasonLabel": component.get("v.ADOverrideReasonPicklistLabel"),
                    "entitledServiceValue": component.get("v.response.entitledServiceType"),
                    "altReturnAddressChkBoxValue": component.get("v.response.alternateReturnAddressChkBx"),
                    "altReturnPostalCodeValue": component.get("v.response.alternateReturnPostalCode"),
                    "altReturnStreetValue": component.get("v.response.alternateReturnStreet"),
                    "altReturnCityValue": component.get("v.response.alternateReturnCity"),
                    "altReturnStateValue": component.get("v.response.alternateReturnState"),
                    "altReturnCountryValue": component.get("v.response.alternateReturnCountry"),
                    
                    //locationCoverageLevel
                    "locationCoverageLevel": component.get("v.response.locationCoverageLevel"),
                    //DASP
                    "DASPEnable": component.get("v.DASPEnable"),
                    "DASPValues" : component.get("v.DASPValues"),
                    "DASPValue" : component.get("v.response.DASPValue"),
                    "Region": component.get("v.response.Region"),
                    "workOrderCountry": component.get("v.response.workOrderCountry")
                },

                function(newcomponent) {
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(newcomponent);
                        component.set("v.body", body);
                    }
                }
            );

        } catch (Err) {
            //Toast Error Message to User
            this.showToast(component, 'Error', $A.get("$Label.c.Dispatch_ErrorMessageOpenEditForm"),"Error");
        }
    },
	 createPicklist: function(component, inputvalue) {
        var opts = [];
        if (inputvalue !== undefined && inputvalue.length > 0) {
            
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
    recordUpdatedHelper: function(component, event) {
        try {
            var eventParams = event.getParams();
            //alert('eventParams.changeType ###'+eventParams.changeType);
			//console.log('Inside Event Listener. preventRecursion:' +component.get("v.preventRecursionAddressUpdate"));
            if (eventParams.changeType === "CHANGED") {
                
                // get the fields that changed for this record
                var changedFields = eventParams.changedFields;
				                //alert('reached update helper');
                var fieldsChanged = JSON.stringify(changedFields);
                console.log('the fields changed are:::'+fieldsChanged); 
                var parsedFields = JSON.parse(fieldsChanged);
                console.log('parsedFields #####'+parsedFields);
                console.log('includesssssssssssss::::::'+fieldsChanged.includes("Postal_Code_Changed__c"));
             
            	
                if(null != parsedFields.Available_Cities__c && parsedFields.Available_Cities__c != undefined){
                    
                    component.set("v.changedFieldsMap",parsedFields);
                    if(fieldsChanged.includes("Available_Cities__c") && parsedFields.Available_Cities__c.value!=null){
                        //component.set("v.showChooseCityPopUp",true);
                        console.log('valueeeeeeeeeee::::'+parsedFields.Available_Cities__c.value);
                        var availableCities = parsedFields.Available_Cities__c.value;
                        console.log('availableCities Text Value: '+availableCities);
                        var availableCitiesList = [];
                        if(null != availableCities && availableCities.includes("||")){
                            availableCitiesList = availableCities.split("||");
							component.set("v.availableCitiesList",this.createPicklist(component,availableCitiesList));
							component.set("v.showChooseCityPopUp",true);
						}
                        else if (null != availableCities && !availableCities.includes("||")){	
							
                            availableCitiesList[0] = availableCities;
						}
                        console.log('availableCitiesList ###'+availableCitiesList);
                        console.log('options@@@@'+component.get("v.availableCitiesList"));
                    }
                }
                if(fieldsChanged.includes('Override_Ground_Shipment__c')||fieldsChanged.includes('Ground_Shipment_Flag__c')){
                //console.log('Ground shipment fields are changed: ' + fieldsChanged);
                	this.calculateServiceOptionHelper(component);
                	return;
                }
                /*if(stringChangedFields.includes("Postal_Code_Changed__c") && component.get("v.simpleRecord.Postal_Code_Changed__c")){
            		component.set("v.showChooseCityPopUp",true);
                    return;
                }*/
                // record is changed, so refresh the component (or other component logic)
                this.handleUpdate(component, changedFields);
            } else if (eventParams.changeType === "LOADED") {
                // record is loaded in the cache
                this.handleOnPageLoad(component);
                
       
                if(!$A.util.isEmpty(component.find("dispatchDeftEditCmpId"))){
                    component.find("dispatchDeftEditCmpId").destroy();
                    component.set("v.openReadForm", true);
                }
                
            } else if (eventParams.changeType === "REMOVED") {
                // record is deleted and removed from the cache
            } else if (eventParams.changeType === "ERROR") {
                // there’s an error while loading, saving or deleting the record
            }
        } catch (Err) {
            this.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
            console.log('Error is:'+Err);
        }
    },

    handleUpdate: function(component, changedFields) {
        try {
            var stringChangedFields = JSON.stringify(changedFields);
            var city = stringChangedFields.includes("City");
            var state = stringChangedFields.includes("State");
            var country = stringChangedFields.includes("Country");
            var countryCode = stringChangedFields.includes("CountryCode");
            var stateCode = stringChangedFields.includes("StateCode");
            var street = stringChangedFields.includes("Street");
            var psCode = stringChangedFields.includes("PostalCode");
            //var citynew =stringChnagedFields.include("City_new__c");
			
			var latamCountry = stringChangedFields.includes("Country__c");
            var latamCity = stringChangedFields.includes("City_new__c");
            var latamPostalCode = stringChangedFields.includes("Zip_Code__c");
            var latamState = stringChangedFields.includes("State__c");
            var latamAddressLine1 = stringChangedFields.includes("Address_Line_1__c");
            var latamAddressLine2 = stringChangedFields.includes("Address_Line_2__c");
            var latamAddressLine3 = stringChangedFields.includes("Address_Line_3__c");
            var latamAddressLine4 = stringChangedFields.includes("Address_Line_4__c");
			/*if(stringChangedFields.includes("Dispatch_Country__c")){
                
				console.log('Calling DispatchDefault Inside DispatchCountryChange');
				var recId = component.get("v.recordId");
				this.getResponse(component, recId);
			}*/
            
            if(stringChangedFields.includes("Dispatch_Country__c")){
              	if(!$A.util.isEmpty(component.find("dispatchDeftEditCmpId"))){
                    component.find("dispatchDeftEditCmpId").destroy();
                    component.set("v.openReadForm", true);
                }
            }
            
			console.log('Inside modal box decision method. preventRecursion:' +component.get("v.preventRecursionAddressUpdate"));
			var parsedFields = JSON.parse(stringChangedFields);
			if(city || state || country || countryCode || stateCode || street || psCode || latamCountry || latamCity || latamPostalCode || latamState || latamAddressLine1 || latamAddressLine2 || latamAddressLine3 || latamAddressLine4 ){
				
                if(!$A.util.isEmpty(component.find("dispatchDeftEditCmpId"))){
                    component.find("dispatchDeftEditCmpId").destroy();
                    component.set("v.openReadForm", true);
                }
                
				if(stringChangedFields.includes("StateCode")&& component.get("v.preventRecursionAddressUpdate")==false){
				console.log('Inside StateCode update');
				component.set("v.simpleRecord.StateCode",parsedFields.StateCode.value);
				
				}
				if(stringChangedFields.includes("CountryCode")&& component.get("v.preventRecursionAddressUpdate")==false){
				console.log('Inside CountryCode update');
				component.set("v.simpleRecord.CountryCode",parsedFields.CountryCode.value);
				
				}
			 	
				console.log('Parsed fields value:'+stringChangedFields);
				if (component.get("v.preventRecursionAddressUpdate")){
					
					component.set("v.changedFieldsMap",parsedFields);
					console.log('Map:'+component.get("v.changedFieldsMap"));
					console.log('Initial status of Simple Record Values when there is a change in Address field:');
					 console.log('--------------------------`---------------------');
					console.log('Street Simple Value:'+ component.get("v.simpleRecord.Street"));
					console.log('City Simple Value:'+ component.get("v.simpleRecord.City"));
					console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country"));
					console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
					console.log('State Simple Value:'+ component.get("v.simpleRecord.State"));
					console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
					console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.PostalCode"));
				 
					console.log('-----Latam Simple record values:------');
					console.log('Street Simple Value:'+ component.get("v.simpleRecord.Address_Line_1__c"));
					console.log('Street Simple Value:'+ component.get("v.simpleRecord.Address_Line_2__c"));
					console.log('Street Simple Value:'+ component.get("v.simpleRecord.Address_Line_3__c"));
					console.log('Street Simple Value:'+ component.get("v.simpleRecord.Address_Line_4__c"));
					console.log('City Simple Value:'+ component.get("v.simpleRecord.City__c"));
					console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country__c"));
					console.log('State Simple Value:'+ component.get("v.simpleRecord.State__c"));
					console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.Zip_Code__c"));
					console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
					//console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));					
					if(component.get("v.hasNoAddress")){
						console.log('Address is not present');
						
						if(latamCountry||latamCity||latamPostalCode||latamState||latamAddressLine1||latamAddressLine2||latamAddressLine3){
							
							console.log('Address Is not present: Change in Latam Addresss Fields');											
							//component.set("v.simpleRecord.CountryCode",parsedFields.CountryCode.value);	
							//component.set("v.simpleRecord.StateCode",parsedFields.StateCode.value);		
							if(parsedFields.Address_Line_1__c!=undefined)
							component.set("v.simpleRecord.Address_Line_1__c",parsedFields.Address_Line_1__c.value);
							if(parsedFields.Address_Line_2__c!=undefined)
							component.set("v.simpleRecord.Address_Line_2__c",parsedFields.Address_Line_2__c.value);
							if(parsedFields.Address_Line_3__c!=undefined)
							component.set("v.simpleRecord.Address_Line_3__c",parsedFields.Address_Line_3__c.value);
							if(parsedFields.Address_Line_4__c!=undefined)
							component.set("v.simpleRecord.Address_Line_4__c",parsedFields.Address_Line_4__c.value);
							if(parsedFields.City_new__c!=undefined){
                                component.set("v.simpleRecord.City_new__c",parsedFields.City_new__c.value);
							//component.set("v.simpleRecord.City__c",parsedFields.City__c.value);
							//component.set("v.simpleRecord.City",parsedFields.City__c.value);
							}
							if(parsedFields.Country__c!=undefined){
							component.set("v.simpleRecord.Country__c",parsedFields.Country__c.value);
							component.set("v.simpleRecord.Country",parsedFields.Country__c.value);
							}
							//component.set("v.simpleRecord.CountryCode",parsedFields.CountryCode.value);
							if(parsedFields.State__c!=undefined){
							component.set("v.simpleRecord.State__c",parsedFields.State__c.value);
							component.set("v.simpleRecord.State",parsedFields.State__c.value);
							}
							//component.set("v.simpleRecord.StateCode",parsedFields.StateCode.value);
							if(parsedFields.Zip_Code__c!=undefined){
							component.set("v.simpleRecord.Zip_Code__c",parsedFields.Zip_Code__c.value);
							component.set("v.simpleRecord.PostalCode",parsedFields.Zip_Code__c.value);
							}
						}
						else{
						if(parsedFields.Street!=undefined)	
						component.set("v.simpleRecord.Street",parsedFields.Street.value);
						if(parsedFields.City!=undefined)	
						component.set("v.simpleRecord.City",parsedFields.City.value);
						if(parsedFields.Country!=undefined)
						component.set("v.simpleRecord.Country",parsedFields.Country.value);
						if(parsedFields.CountryCode!=undefined)
						component.set("v.simpleRecord.CountryCode",parsedFields.CountryCode.value);
						if(parsedFields.State!=undefined)
						component.set("v.simpleRecord.State",parsedFields.State.value);
						if(parsedFields.StateCode!=undefined)
						component.set("v.simpleRecord.StateCode",parsedFields.StateCode.value);
						if(parsedFields.PostalCode!=undefined)
						component.set("v.simpleRecord.PostalCode",parsedFields.PostalCode.value);
						}
						component.set("v.hasNoAddress",false);
						if(component.get("v.showChooseCityPopUp")!=true){
							if(!$A.util.isEmpty(component.get("v.response.defaultRecordId"))){
								console.log('Calling updateDispatchDefault');
								this.updateDispConfig(component);
							}else{
								console.log('Calling DispatchDefault');
								var recId = component.get("v.recordId");
								this.getResponse(component, recId);
							}
						}
						if(latamCountry||latamCity||latamPostalCode||latamState||latamAddressLine1||latamAddressLine2||latamAddressLine3){
							console.log('Inside Latam Country : Before initial Address update ');
							var streetUpdate='';
							if(component.get("v.simpleRecord.Address_Line_1__c")!=null)
								streetUpdate=component.get("v.simpleRecord.Address_Line_1__c")
							if(component.get("v.simpleRecord.Address_Line_2__c")!=null)
								streetUpdate=streetUpdate+" "+component.get("v.simpleRecord.Address_Line_2__c")
							if(component.get("v.simpleRecord.Address_Line_3__c")!=null)
								streetUpdate=streetUpdate+" "+component.get("v.simpleRecord.Address_Line_3__c")
							if(component.get("v.simpleRecord.Address_Line_4__c")!=null)
								streetUpdate=streetUpdate+" "+component.get("v.simpleRecord.Address_Line_4__c")
							component.set("v.simpleRecord.Street",streetUpdate.substring(0,255));
							component.set("v.preventRecursionAddressUpdate",false);
							console.log('Calling Method : handleUpdate');
							//this.handleSaveRecord(component,event);
						}
					}
					else{
						console.log('Address is present');
						console.log('Modal Box to be displayed. preventRecursion:' +component.get("v.preventRecursionAddressUpdate"));
						//console.log('The old City value from Map:'+component.get("v.changedFieldsMap").City__c.oldValue);
						/*if(city === true && parsedFields.City!=undefined){
							console.log('Inside City check');
							component.set("v.simpleRecord.City",parsedFields.City.value);
							component.set("v.cityOldValue", parsedFields.City.oldValue);
						}				
						if(state === true){
							console.log('Inside state check');
							component.set("v.simpleRecord.State",parsedFields.State.value);
							component.set("v.stateOldValue", parsedFields.State.oldValue);
						}
						if(country===true){
							console.log('Inside country check');
							component.set("v.simpleRecord.Country",parsedFields.Country.value);
							component.set("v.countryOldValue", parsedFields.Country.oldValue);
						}
						if(countryCode===true){
							console.log('Inside countrycode check');
							component.set("v.simpleRecord.CountryCode",parsedFields.CountryCode.value);
							component.set("v.countryCodeOldValue", parsedFields.CountryCode.oldValue);
						}
						if(stateCode===true){
							console.log('Inside stateCode check');
							component.set("v.simpleRecord.StateCode",parsedFields.StateCode.value);
							component.set("v.stateCodeOldValue", parsedFields.StateCode.oldValue);
						}
						if(street=== true){
							console.log('Inside Street Check'+parsedFields.Street.oldValue);
							component.set("v.simpleRecord.Street",parsedFields.Street.value);
							component.set("v.streetOldValue", parsedFields.Street.oldValue);
						}
						if(psCode===true){
							console.log('Inside postalCode check');
							component.set("v.simpleRecord.PostalCode",parsedFields.PostalCode.value);
							component.set("v.postalCodeOldValue", parsedFields.PostalCode.oldValue);
						}*/
                        console.log('parsedFields.CountryCode @@@'+parsedFields.CountryCode);
                        if(parsedFields.CountryCode != undefined)
                            console.log('parsedFields.CountryCode value @@@'+parsedFields.CountryCode.value);
						
                        /*if((parsedFields.CountryCode!=undefined && parsedFields.CountryCode != null && 
                           (parsedFields.CountryCode.value!='AU' && parsedFields.CountryCode.value!='NZ')) ||
                           
                           (parsedFields.CountryCode==undefined && component.get("v.simpleRecord").CountryCode != undefined 
                           && (component.get("v.simpleRecord").CountryCode!='AU' && component.get("v.simpleRecord").CountryCode.value!='NZ')))*/
						 if(parsedFields.Available_Cities__c != undefined && parsedFields.Available_Cities__c.value!=null && parsedFields.Available_Cities__c.value.includes("||"))
                        {
							component.set("v.showAddressUpdateModalBox", false);
                            console.log('I am inside AU woohooo');
                        }
                        else
                           component.set("v.showAddressUpdateModalBox", true);
						component.set("v.hasNoAddress",false);
					}
                /* Akhil--Commenting as the same logic is moved to function: updateAddressHelper
				if(!$A.util.isEmpty(component.get("v.response.defaultRecordId"))){
                    //this.updateDispConfig(component);
                }else{
                    var recId = component.get("v.recordId");
                    this.getResponse(component, recId);
                }*/
				
				console.log('Simple Record Values after update dispatch call');
				console.log('-----------------------------------------------');
				console.log('Street Simple Value:'+ component.get("v.simpleRecord.Street"));
				console.log('City Simple Value:'+ component.get("v.simpleRecord.City"));
				console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country"));
				console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
				console.log('State Simple Value:'+ component.get("v.simpleRecord.State"));
				console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
				console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.PostalCode"));
			 
				console.log('After update dispatch call : Latam Simple record values:');
				console.log('Street Simple Value:'+ component.get("v.simpleRecord.Address_Line_1__c"));
				console.log('City Simple Value:'+ component.get("v.simpleRecord.City__c"));
				console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country__c"));
				//console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
				console.log('State Simple Value:'+ component.get("v.simpleRecord.State__c"));
				//console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
				console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.Zip_Code__c"));
				}
				else{
				
					component.set("v.preventRecursionAddressUpdate",true);
					console.log('Setting Recursion to True. preventRecursion:' +component.get("v.preventRecursionAddressUpdate"));
				}
			}
		}catch (Err) {
			console.log('Error:'+ Err);
            this.showToast(component, 'Error',"Error Occured While Refreshing Component", "Error");
        }
    },

    updateDispConfig: function(component) {
        try {
			
            component.set("v.Spinner", true);
            var action = component.get("c.updateDispatchDefaults");
            action.setParams({
                //set RecordId
                workOrderId: component.get("v.recordId"),
                //set dispatchDefaultId
                dDefaultRecId: component.get("v.response.defaultRecordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //response from Apex Controller
                    if (!$A.util.isEmpty(result)) {

                        component.set("v.response.serviceType",result.serviceType);
                        component.set("v.response.serviceOptions",result.serviceOptions);
                        component.set("v.response.specialOpnsValue",result.specialOpnsValue);
                        component.set("v.response.productClassification",result.productClassification);
                        component.set("v.response.selectedServiceOpt",result.selectedServiceOpt);
                        component.set("v.response.billTo",result.billTo);
                        component.set("v.response.orderNumber",result.orderNumber);
                        component.set("v.response.accidentalDamage",result.accidentalDamage);
                        component.set("v.response.keepYComp",result.keepYComp);
                        component.set("v.response.dSPOverideReq",result.dSPOverideReq);
                        component.set("v.response.outOfWarranty",result.outOfWarranty);
                        component.set("v.response.KYHDFlag",result.KYHDFlag);
                        component.set("v.response.locationCoverageLevel",result.locationCoverageLevel);
                        component.set("v.response.serviceTypeOptions",result.serviceTypeOptions);
                        component.set("v.response.selectedServiceOpt",'');
                        component.set("v.response.billTo",'');
                        component.set("v.Spinner", false);
                        component.set("v.Region",result.region);
                        component.set("v.DASPEnable",result.DASPFlag);
                        if(result.DASPValues != undefined && result.DASPValues !=null && result.DASPValues!= '')
                        {
                            var arr 	= 	[];
                            arr.push({value:"", label:"--None--"});
                            Object.keys(result.DASPValues).forEach(function(key) {
                            arr.push({label:result.DASPValues[key].PartnerName__c, value:result.DASPValues[key]});
							});
                            component.set("v.DASPEnable", true);
                            component.set("v.DASPValues",arr);
                        } 
                        
                        if (result.outOfWarranty) {
                            // if asset is Out of Warranty - Show Warning to Agent
                            this.showToast(component,'Warning',$A.get("$Label.c.Dispatch_WarningMessageAssetOutOfWarranty"), "Warning");
                        }
                        if (!$A.util.isUndefinedOrNull(result.ErrorCode) && !$A.util.isUndefinedOrNull(result.WarningMessage)) {
                            if(result.ErrorCode !=100000 && result.WarningMessage!="Operation successful."){
                            	this.showToast(component, 'Warning',result.WarningMessage, "Warning");
                            }
                        }
                    } else {
                        component.set("v.Spinner", false);
                        // Toast Error Message to User
                        this.showToast(component,'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageComponent"), "Error");
                    }
                } else {
                    //Show Error to user - Error Occured While Loading Component.
                    this.showToast(component, 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageComponent"),"Error");
                    component.set("v.Spinner", false);
                }
            });
            $A.enqueueAction(action);
        } catch (Err) {
            component.set("v.Spinner", false);
            console.log("Err  ====> "+Err);
            this.showToast(component, 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"), "Error");
        }
    },

    // handle Updated Values from Component Event
    handleEventUpdate: function(component, event) {
        try {
            component.set("v.Spinner", true);
            // set the handler attributes based on event data
            // Selected Service Option Value
            component.set("v.response.selectedServiceOpt", event.getParam("changedServiceOptionValue"));
            //Selected Service Type Value
            component.set("v.response.serviceType", event.getParam("changedServiceTypeValue"));
            //Order Number
            component.set("v.response.orderNumber", event.getParam("changedOrderNumber"));
            //Special Options Value
            component.set("v.response.specialOpnsValue", event.getParam("changedSpecialOptionValue"));
            //Product Classification Value
            component.set("v.response.productClassification", event.getParam("changedProductClassValue"));
            //Keep Your Components Value
            component.set("v.response.keepYComp", event.getParam("changedKeepYComp"));
            //DSP Override Request Value
            component.set("v.response.dSPOverideReq", event.getParam("changedDSPOverideReq"));
            //Bill To Value
            component.set("v.response.billTo", event.getParam("changedBillToValue"));
            //Accidental Damage Value
            component.set("v.response.accidentalDamage1", event.getParam("changedAccidentalDamage"));
            // Service Options - Picklist Values
            component.set("v.response.ADOverrideReason", event.getParam("changedADOverrideReason"));
            component.set("v.response.serviceOptions", event.getParam("changedServiceOptions"));
            // Service Type - Picklist Values
            component.set("v.response.serviceTypeOptions", event.getParam("changedServiceTypeOptions"));
            // Special Options - Picklist Values
            component.set("v.response.specialOptions", event.getParam("changedSpecialOptions"));
            // Bill To - Picklist Values
            component.set("v.response.billToOptions", event.getParam("changedBillToOptions"));
            // Product Classification - Picklist Values
            component.set("v.response.productClassOptions", event.getParam("changedProductClassOptions"));
            //Instruction Value
            component.set("v.response.Instructions", event.getParam("changedInstructionValue"));
            //Instruction Record Id
            component.set("v.response.InstructRecordId", event.getParam("changedInstructionRecordId"));
            //KYHDFlag Value
            component.set("v.response.KYHDFlag", event.getParam("changedKYHDFlag"));
          	//Megha: code changes starts below regarding Aug Story-Mail in 
            component.set("v.response.alternateReturnAddressChkBx", event.getParam("changedAltReturnAddressFlagValue"));
            component.set("v.response.alternateReturnPostalCode", event.getParam("changedAltReturnAddPostalCodeValue"));
            component.set("v.response.alternateReturnStreet", event.getParam("changedAltReturnAddStreetValue"));
            component.set("v.response.alternateReturnCity", event.getParam("changedAltReturnAddCityValue"));
            component.set("v.response.alternateReturnState", event.getParam("changedAltReturnAddStatusValue"));
            component.set("v.response.alternateReturnCountry", event.getParam("changedAltReturnAddCountryValue"));
            //Megha: code changes end here
            //5615509
            component.set("v.response.reasonForDamage", event.getParam("reasonForDamage"));
            component.set("v.Spinner", false);
            //component.set("v.response.DASPEnable", event.getParam("changedDASPEnable"));
            component.set("v.response.DASPValue", event.getParam("changedDASPValue"));
            // Refresh View
            $A.get("e.force:refreshView").fire();

        } catch (Err) {
            component.set("v.Spinner",false);
            this.showToast(component,'ERROR',"Error Happened While Refreshing The View", "Error");
        }
    },

     handleOnPageLoad: function(component) {
		 console.log('inside handleOnPageLoad');
        var city = component.get("v.simpleRecord.City");
        var countryCode = component.get("v.simpleRecord.CountryCode");
        var stateCode = component.get("v.simpleRecord.StateCode");
        var street = component.get("v.simpleRecord.Street");
        var postCode = component.get("v.simpleRecord.PostalCode");
		var brazilAddressLine1 = component.get("v.simpleRecord.Address_Line_1__c");
		var brazilAddressLine2 = component.get("v.simpleRecord.Address_Line_2__c");
		var brazilAddressLine4 = component.get("v.simpleRecord.Address_Line_4__c");
        var postalCodeChangedFlag = component.get("v.simpleRecord.Postal_Code_Changed__c");
        var availableCities = component.get("v.simpleRecord.Available_Cities__c");
        var DPSregion = component.get("v.simpleRecord.DPS_Region__c");
        console.log('postalCodeChangedFlag Value: '+postalCodeChangedFlag);
        console.log('availableCities Text Value: '+availableCities);
        console.log('Region'+ component.get("v.simpleRecord.DPS_Region__c"));
        var availableCitiesList;
        if(null != availableCities && availableCities.includes("||"))
        	availableCitiesList = availableCities.split("||");
        console.log('availableCitiesList ###'+availableCitiesList);
        component.set("v.availableCitiesList",availableCitiesList);
		console.log('Country Code in Page Load'+countryCode);
       	
        var countriesCodeToExcludeZipCode = ["PE","AI","AG","AW","BS","BR","BB","BZ","BM","MX","BO","VG","KY","DM","DO","EC","SV","GF","JM","MQ","MS","NI","PA","PY","KN","LC","VC","SR","TT","TC","VE","GD","GP","GT","GY","HT","HN","UY","BQ","CW","SX"];
               var skipZipCode = false;
        if(!$A.util.isEmpty(countryCode)) {
            skipZipCode =  countriesCodeToExcludeZipCode.includes(countryCode);                              
        } 
		if(!$A.util.isEmpty(countryCode) && $A.get("$Label.c.LatamCountries").includes(countryCode)){
			skipZipCode=true;
		}
		if ((!$A.util.isEmpty(city)) && (!$A.util.isEmpty(countryCode)) && (!$A.util.isEmpty(stateCode)) && (!$A.util.isEmpty(street)) && ((!$A.util.isEmpty(postCode) && !skipZipCode) || skipZipCode)) {
				if (countryCode==='BR'&& (($A.util.isEmpty(brazilAddressLine1))||($A.util.isEmpty(brazilAddressLine2))||($A.util.isEmpty(brazilAddressLine4)))){
					component.set("v.hasNoAddress",true);
				}else if(countryCode!='BR'&& $A.get("$Label.c.LatamCountries").includes(countryCode)&& ($A.util.isEmpty(brazilAddressLine1))){
					component.set("v.hasNoAddress",true);
				}
				else{
					console.log('In global page load');
					component.set("v.hasNoAddress",false);        
					// Record Id
					var recId = component.get("v.recordId");
					this.getResponse(component, recId);
				}
            
        } else {
			if(!$A.util.isEmpty(component.get("v.simpleRecord.DPS_Region__c")) && component.get("v.simpleRecord.DPS_Region__c")==='EMEA' && $A.util.isEmpty(stateCode)){
				component.set("v.hasNoAddress",false);
			}else{
            component.set("v.hasNoAddress",true);
			}
        }
        if ((!$A.util.isEmpty(city)) && DPSregion === 'EMEA' &&(!$A.util.isEmpty(street)) && ((!$A.util.isEmpty(postCode) && !skipZipCode) || skipZipCode)) {
        	component.set("v.hasNoAddress",false);  
			var recId = component.get("v.recordId");
			this.getResponse(component, recId);
        }

    },
    calculateServiceOptionHelper : function(component){
        //console.log('reached calculate');
        //console.log(JSON.stringify(changedFields));
        var action = component.get("c.calculateServiceOption");
        action.setParams({workOrderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();            
                    var defaultVal = component.get("v.response");
                    if (result !== null && result !== undefined) {
                        if (result.responseCode === '100') {
                            //var responseResult = result.availableOptions;
                            if (result.defaultOption!==null && result.defaultOption!==undefined) {
                                defaultVal.selectedServiceOpt = result.defaultOption;
                            }
                            if (result.availableOptions!==null && result.availableOptions!==undefined) {
                                defaultVal.serviceOptions = result.availableOptions;
                            }
                            component.set("v.response",defaultVal);
                        }
                    }
                }
        });
        $A.enqueueAction(action);
   },
    closeAddressUpdateModelHelper : function(component,event){
	 try{
	 
	 console.log('Inside Cancel method');
	 
	 console.log('-------Before to update upon Cancel---------');
	 console.log('Street Old Value:'+ component.get("v.streetOldValue"));
	 console.log('City Old Value:'+ component.get("v.cityOldValue"));
	 console.log('Country Old Value:'+ component.get("v.countryOldValue"));
	 console.log('CountryCode Old Value:'+ component.get("v.countryOldValue"));
	 console.log('State Old Value:'+ component.get("v.stateOldValue"));
	 console.log('StateCode Old Value:'+ component.get("v.stateCodeOldValue"));
	 console.log('Zip code Old Value:'+ component.get("v.postalCodeOldValue"));
	 
	 
	 component.set("v.showAddressUpdateModalBox", false);
	 component.set("v.preventRecursionAddressUpdate",false);
	 /*if(component.get("v.streetOldValue")!==undefined)
	 component.set("v.simpleRecord.Street",component.get("v.streetOldValue"));
	 if(component.get("v.cityOldValue")!==undefined){
	 console.log('****Should not come inside City***');	 
	 component.set("v.simpleRecord.City",component.get("v.cityOldValue"));
	 }
	 if(component.get("v.countryOldValue")!==undefined)
	 component.set("v.simpleRecord.Country",component.get("v.countryOldValue"));
	 if(component.get("v.countryCodeOldValue")!==undefined)
	 component.set("v.simpleRecord.CountryCode",component.get("v.countryCodeOldValue"));
	 if(component.get("v.stateOldValue")!==undefined)
	 component.set("v.simpleRecord.State",component.get("v.stateOldValue"));
	 if(component.get("v.stateCodeOldValue")!==undefined)
     component.set("v.simpleRecord.StateCode",component.get("v.stateCodeOldValue"));
	 if(component.get("v.postalCodeOldValue")!==undefined)
	 component.set("v.simpleRecord.PostalCode",component.get("v.postalCodeOldValue"));*/
 
	
		console.log('Inside Cancel method. preventRecursion:' +component.get("v.preventRecursionAddressUpdate"));	 
		console.log('-------About to update upon Cancel---------');
		console.log('Street Simple Value:'+ component.get("v.simpleRecord.Street"));
		console.log('City Simple Value:'+ component.get("v.simpleRecord.City"));
		console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country"));
		console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
		console.log('State Simple Value:'+ component.get("v.simpleRecord.State"));
		console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
		console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.PostalCode"))
		console.log('Inside Cancel Method : Latam Simple record values:');
		console.log('Street Simple Value:'+ component.get("v.simpleRecord.Address_Line_1__c"));
		console.log('City Simple Value:'+ component.get("v.simpleRecord.City__c"));
		console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country__c"));
		//console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
		console.log('State Simple Value:'+ component.get("v.simpleRecord.State__c"));
		//console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
		console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.Zip_Code__c"));
		console.log('-------After transfer of old values, the Old Values are cleared---------');
		component.set("v.streetOldValue",undefined);
		component.set("v.cityOldValue",undefined);
		component.set("v.countryOldValue",undefined);
		component.set("v.countryCodeOldValue",undefined);
		component.set("v.stateOldValue",undefined);
		component.set("v.stateCodeOldValue",undefined);
		component.set("v.postalCodeOldValue",undefined);
		component.set("v.changedFieldsMap",undefined);
			 
	  console.log('Calling Method : Cancel');
	  
	 this.handleSaveRecord(component,event);
	 }catch(Err) {
			//console.log('Error:'+ Err);
            this.showToast(component, 'Error',"Error Occured While Refreshing Component", "Error");
        }
	 
   },
    updateAddressHelper : function(component,event){
	 try{
						console.log('Clicked on Update Button');
						console.log('----Changed fields Map----');
						console.log('Map:'+JSON.stringify(component.get("v.changedFieldsMap")));
						//console.log('new value of Street is:'+component.get("v.changedFieldsMap").Street.value);
						component.set("v.showAddressUpdateModalBox", false);
						var isLatamChange = false;
         				
						if(component.get("v.changedFieldsMap").City!=undefined){
							console.log('Inside City check');
                            component.set("v.simpleRecord.City",component.get("v.changedFieldsMap").City.value);
                            //component.set("v.cityOldValue", parsedFields.City.oldValue);
						}				
						if(component.get("v.changedFieldsMap").State!=undefined){
							console.log('Inside global state check');
							component.set("v.simpleRecord.State",component.get("v.changedFieldsMap").State.value);
							component.set("v.simpleRecord.StateCode",component.get("v.changedFieldsMap").StateCode.value);
							//component.set("v.stateOldValue", parsedFields.State.oldValue);
						}
						if(component.get("v.changedFieldsMap").Country!=undefined){
							console.log('Inside country check');
							component.set("v.simpleRecord.Country",component.get("v.changedFieldsMap").Country.value);
							component.set("v.simpleRecord.CountryCode",component.get("v.changedFieldsMap").CountryCode.value);
							//component.set("v.countryOldValue", parsedFields.Country.oldValue);
						}
						/*if(countryCode===true){
							console.log('Inside countrycode check');
							component.set("v.simpleRecord.CountryCode",parsedFields.CountryCode.value);
							component.set("v.countryCodeOldValue", parsedFields.CountryCode.oldValue);
						}*/
						/*if(stateCode===true){
							console.log('Inside stateCode check');
							component.set("v.simpleRecord.StateCode",parsedFields.StateCode.value);
							component.set("v.stateCodeOldValue", parsedFields.StateCode.oldValue);
						}*/
						if(component.get("v.changedFieldsMap").Street!=undefined){
							console.log('Inside Street Check');
							component.set("v.simpleRecord.Street",component.get("v.changedFieldsMap").Street.value);
							//component.set("v.streetOldValue", parsedFields.Street.oldValue);
						}
						if(component.get("v.changedFieldsMap").PostalCode!=undefined){
							console.log('Inside postalCode check');
							component.set("v.simpleRecord.PostalCode",component.get("v.changedFieldsMap").PostalCode.value);
							//component.set("v.postalCodeOldValue", parsedFields.PostalCode.oldValue);
						}
						if(component.get("v.changedFieldsMap").Address_Line_1__c!=undefined){
							console.log('Inside Address Line 1 check');
							component.set("v.simpleRecord.Address_Line_1__c",component.get("v.changedFieldsMap").Address_Line_1__c.value);
							component.set("v.simpleRecord.Street",component.get("v.changedFieldsMap").Address_Line_1__c.value);
							isLatamChange = true; 
						}
						if(component.get("v.changedFieldsMap").Address_Line_2__c!=undefined){
							console.log('Inside Address Line 2 check');
							component.set("v.simpleRecord.Address_Line_2__c",component.get("v.changedFieldsMap").Address_Line_2__c.value);
							component.set("v.simpleRecord.Street",component.get("v.changedFieldsMap").Address_Line_2__c.value);
							isLatamChange = true; 
						}
						if(component.get("v.changedFieldsMap").Address_Line_3__c!=undefined){
							console.log('Inside Address Line 3 check');
							component.set("v.simpleRecord.Address_Line_3__c",component.get("v.changedFieldsMap").Address_Line_3__c.value);
							component.set("v.simpleRecord.Street",component.get("v.changedFieldsMap").Address_Line_3__c.value);
							isLatamChange = true; 
						}
						if(component.get("v.changedFieldsMap").Address_Line_4__c!=undefined){
							console.log('Inside Address Line 4 check');
							component.set("v.simpleRecord.Address_Line_4__c",component.get("v.changedFieldsMap").Address_Line_4__c.value);
							component.set("v.simpleRecord.Street",component.get("v.changedFieldsMap").Address_Line_4__c.value);
							isLatamChange = true; 
						}
						if(component.get("v.changedFieldsMap").City_new__c!=undefined){
							console.log('Inside City check');
							component.set("v.simpleRecord.City_new__c",component.get("v.changedFieldsMap").City_new__c.value);
						    //component.set("v.simpleRecord.City",component.get("v.changedFieldsMap").City__c.value);
							//isLatamChange = true; 
							//component.set("v.cityOldValue", parsedFields.City.oldValue);
						}				
						if(component.get("v.changedFieldsMap").State__c!=undefined){
							console.log('Inside latam state check');
							component.set("v.simpleRecord.State__c",component.get("v.changedFieldsMap").State__c.value);
							component.set("v.simpleRecord.State",component.get("v.changedFieldsMap").State__c.value);
							isLatamChange = true; 
							//component.set("v.stateOldValue", parsedFields.State.oldValue);
						}
						if(component.get("v.changedFieldsMap").Country__c!=undefined){
							console.log('Inside country check');
							component.set("v.simpleRecord.Country__c",component.get("v.changedFieldsMap").Country__c.value);
							component.set("v.simpleRecord.Country",component.get("v.changedFieldsMap").Country__c.value);
							isLatamChange = true; 
							//component.set("v.countryOldValue", parsedFields.Country.oldValue);
						}
						if(component.get("v.changedFieldsMap").Street__c!=undefined){
							console.log('Inside Street Check');
							component.set("v.simpleRecord.Street__c",component.get("v.changedFieldsMap").Street__c.value);
							component.set("v.simpleRecord.Street",component.get("v.changedFieldsMap").Street__c.value);
							isLatamChange = true; 
							//component.set("v.streetOldValue", parsedFields.Street.oldValue);
						}
						if(component.get("v.changedFieldsMap").Zip_Code__c!=undefined){
							console.log('Inside postalCode check');
							component.set("v.simpleRecord.Zip_Code__c",component.get("v.changedFieldsMap").Zip_Code__c.value);
							component.set("v.simpleRecord.PostalCode",component.get("v.changedFieldsMap").Zip_Code__c.value);
							isLatamChange = true; 
							//component.set("v.postalCodeOldValue", parsedFields.PostalCode.oldValue);
						}
         
             /* if(component.get("v.changedFieldsMap").City_new__c!=undefined)
              {
                  component.set("v.simpleRecord.City_new__c",component.get("v.changedFieldsMap").City_new__c.value);
              }*/
	 
			 console.log('Inside Update Address Helper Method:Will call the updateDispConfig');
			 console.log('Street Simple Value:'+ component.get("v.simpleRecord.Street"));
			 console.log('City Simple Value:'+ component.get("v.simpleRecord.City"));
			 console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country"));
			 console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
			 console.log('State Simple Value:'+ component.get("v.simpleRecord.State"));
			 console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
			 console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.PostalCode"));
			 
			 console.log('Inside Update Address : Latam Simple record values:');
			 console.log('Street Simple Value:'+ component.get("v.simpleRecord.Address_Line_1__c"));
			 console.log('City Simple Value:'+ component.get("v.simpleRecord.City__c"));
			 console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country__c"));
			 //console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
			 console.log('State Simple Value:'+ component.get("v.simpleRecord.State__c"));
			 //console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
			 console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.Zip_Code__c"));
			 
			 console.log('-------After update of Address Old Values are cleared---------');
			 component.set("v.streetOldValue",undefined);
			 component.set("v.cityOldValue",undefined);
			 component.set("v.countryOldValue",undefined);
			 component.set("v.countryCodeOldValue",undefined);
			 component.set("v.stateOldValue",undefined);
			 component.set("v.stateCodeOldValue",undefined);
			 component.set("v.postalCodeOldValue",undefined);
             //component.set("v.CitynewOldvalue",undefined);
			 
			 
			 console.log('Street Old Value:'+ component.get("v.streetOldValue"));
			 console.log('City Old Value:'+ component.get("v.cityOldValue"));
			 console.log('Country Old Value:'+ component.get("v.countryOldValue"));
			 console.log('CountryCode Old Value:'+ component.get("v.countryOldValue"));
			 console.log('State Old Value:'+ component.get("v.stateOldValue"));
			 console.log('StateCode Old Value:'+ component.get("v.stateCodeOldValue"));
			 console.log('Zip code Old Value:'+ component.get("v.postalCodeOldValue"));
			 
		component.set("v.preventRecursionAddressUpdate",true);
		if(isLatamChange==true){
			console.log('There is a latam address change : On Address Update ');
            component.set("v.preventRecursionAddressUpdate",true);
            var streetUpdate='';
            //var streetUpdate = component.get("v.simpleRecord.Address_Line_1__c")+' '+component.get("v.simpleRecord.Address_Line_2__c")+' '+component.get("v.simpleRecord.Address_Line_3__c");
            var streetUpdate = component.get("v.simpleRecord.Address_Line_1__c"); //+' '+component.get("v.simpleRecord.Address_Line_2__c")+' '+component.get("v.simpleRecord.Address_Line_3__c");
            if (component.get("v.simpleRecord.Address_Line_2__c") != null)
                streetUpdate = streetUpdate +'\r\n'+component.get("v.simpleRecord.Address_Line_2__c");
            else
                streetUpdate = streetUpdate +'\r\n ';
            
            if (component.get("v.simpleRecord.Address_Line_3__c") != null)
                streetUpdate = streetUpdate +'\r\n'+component.get("v.simpleRecord.Address_Line_3__c");
            else
                streetUpdate = streetUpdate +'\r\n ';            
            
            if(component.get("v.simpleRecord.Address_Line_4__c")!=null)
                streetUpdate=streetUpdate+' '+component.get("v.simpleRecord.Address_Line_4__c");
            //streetUpdate=streetUpdate+' '+component.get("v.simpleRecord.Address_Line_4__c");*/
            component.set("v.simpleRecord.Street",streetUpdate.substring(0,255));
            //component.set("v.simpleRecord.City",component.get("v.simpleRecord.City__c"));
            component.set("v.simpleRecord.State",component.get("v.simpleRecord.State__c"));
            component.set("v.simpleRecord.Country",component.get("v.simpleRecord.Country__c"));
            component.set("v.simpleRecord.PostalCode",component.get("v.simpleRecord.Zip_Code__c"));							
           
		    console.log('Calling Method : updateAddressHelper');
            //this.handleSaveRecord(component,event);
		}
            if(!$A.util.isEmpty(component.get("v.response.defaultRecordId"))){
                console.log('On Address update : calling updateDispatchDefault');
                component.set("v.hasNoAddress",false);
                this.updateDispConfig(component);
            }else{
                console.log('On Address update : calling DispatchDefault');
                var recId = component.get("v.recordId");
                component.set("v.hasNoAddress",false);
                this.getResponse(component, recId);
            }
	 }catch(Err){
		 this.showToast(component, 'Error',"Error Occured While Refreshing Component", "Error");
		 console.log('Error in update method is :'+ Err);
	 }		 
   },
   handleSaveRecord: function(component, event) {
	   try{
		    
			 console.log('Inside Save Method');
			 console.log('Inside Save method. preventRecursion before save:' +component.get("v.preventRecursionAddressUpdate"));	   
		   	 console.log('Street Simple Value:'+ component.get("v.simpleRecord.Street"));
			 console.log('City Simple Value in handlesaverecord method :'+ component.get("v.simpleRecord.City"));
			 console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country"));
			 console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
			 console.log('State Simple Value:'+ component.get("v.simpleRecord.State"));
			 console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
			 console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.PostalCode"));
		     
			component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // handle component related logic in event handler
				//component.set("v.preventRecursionAddressUpdate",false);
				//console.log('Akhil : Successfully Saved');
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
				component.set("v.preventRecursionAddressUpdate",true);
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }
		));
		//console.log('Inside Save method. preventRecursion after Save:' +component.get("v.preventRecursionAddressUpdate"));
	}catch(Err){
		 component.set("v.preventRecursionAddressUpdate",true);
		 this.showToast(component, 'Error',"Error Occured While Updating Address", "Error");
		 console.log('Error while saving record is:'+Err);
	 }	
	
    },
    updateCityOnWorkOrderHelper: function(component, event) {
        console.log('chosen city ### : '+component.get("v.chosenCity"));
        
        if(component.get("v.chosenCity") != null && component.get("v.chosenCity").length > 0){
            if(component.get("v.chosenCity").includes('--'))
            {
                var splitted= component.get("v.chosenCity").split('--');
                component.set("v.simpleRecord.City_APJ__c", splitted[1]);
                component.set("v.simpleRecord.State_APJ__c",splitted[0]);
            }
            else
            {
                component.set("v.simpleRecord.City_APJ__c", component.get("v.chosenCity"));
            }
    	
            component.set("v.simpleRecord.Available_Cities__c", "");
            //component.set("v.simpleRecord.Postal_Code_Changed__c", false);
			if(component.get("v.changedFieldsMap").Country!=undefined){
				console.log('Inside country check');
				component.set("v.simpleRecord.Country",component.get("v.changedFieldsMap").Country.value);
				component.set("v.simpleRecord.CountryCode",component.get("v.changedFieldsMap").CountryCode.value);
							//component.set("v.countryOldValue", parsedFields.Country.oldValue);
			}
			
			 console.log('Inside updateCityOnWorkOrderHelper Method');
			 console.log('Inside updateCityOnWorkOrderHelper method. preventRecursion before save:' +component.get("v.preventRecursionAddressUpdate"));	   
		   	 console.log('Street Simple Value:'+ component.get("v.simpleRecord.Street"));
			 console.log('City Simple Value in handlesaverecord method :'+ component.get("v.simpleRecord.City"));
			 console.log('Country Simple Value:'+ component.get("v.simpleRecord.Country"));
			 console.log('CountryCode Simple Value:'+ component.get("v.simpleRecord.CountryCode"));
			 console.log('State Simple Value:'+ component.get("v.simpleRecord.State"));
			 console.log('StateCode Simple Value:'+ component.get("v.simpleRecord.StateCode"));
			 console.log('Zip code Simple Value:'+ component.get("v.simpleRecord.PostalCode"));
        //	if((component.get("v.simpleRecord.CountryCode") =='AU' ||  component.get("v.simpleRecord.CountryCode") =='NZ' || component.get("v.simpleRecord.CountryCode") =='IN')){
                //component.set("v.simpleRecord.City",component.get("v.chosenCity"));
                console.log('I AM HEREEEEEEEEEEEEEEEEEEE');
                //this.handleSaveRecord(component,event);
				
						if(component.get("v.changedFieldsMap").State!=undefined){
							console.log('Inside global state check');
							component.set("v.simpleRecord.State",component.get("v.changedFieldsMap").State.value);
							component.set("v.simpleRecord.StateCode",component.get("v.changedFieldsMap").StateCode.value);
							//component.set("v.stateOldValue", parsedFields.State.oldValue);
						}
						
						if(component.get("v.changedFieldsMap").Street!=undefined){
							console.log('Inside Street Check');
							component.set("v.simpleRecord.Street",component.get("v.changedFieldsMap").Street.value);
							//component.set("v.streetOldValue", parsedFields.Street.oldValue);
						}
						if(component.get("v.changedFieldsMap").PostalCode!=undefined){
							console.log('Inside postalCode check');
							component.set("v.simpleRecord.PostalCode",component.get("v.changedFieldsMap").PostalCode.value);
							//component.set("v.postalCodeOldValue", parsedFields.PostalCode.oldValue);
						}
						if(component.get("v.changedFieldsMap").City!=undefined){
							console.log('Inside postalCode check');
							component.set("v.simpleRecord.City",component.get("v.changedFieldsMap").City.value);
							//component.set("v.postalCodeOldValue", parsedFields.PostalCode.oldValue);
						}							
				
     		//}  
			console.log('Calling Method : updateCityOnWorkOrderHelper');
            this.handleSaveRecord(component,event);
			component.set("v.hasNoAddress",false);
			if(!$A.util.isEmpty(component.get("v.response.defaultRecordId"))){
				console.log('On Address update : calling updateDispatchDefault');           
				this.updateDispConfig(component);
			}else{
            console.log('On Address update : calling DispatchDefault');
			var recId = component.get("v.recordId");
			this.getResponse(component, recId);
			}
        }
        component.set("v.showChooseCityPopUp",false);
    }
    
   
})
({
    // Invoke Server Side Code
    callApex: function(component, event, getValue, contType) {
        try{
            var checkBoolean;
            var errMessage;
            var errtitle;
            if (contType === 'primaryContact'){
                checkBoolean = true;
            } else{
                checkBoolean = false;
            }	
            var action = component.get("c.validateForMessaging");
            action.setParams({
                recordId: component.get("v.recordId"),
                isPrimaryContact: checkBoolean,
                selectedContactType: getValue,
            });  
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result!==null && result!==undefined){
                        // check whether contact has Phone Number
                        if(result.hasPhoneNumber && result.hasPrimaryPhoneTypeInfo){
                            // check whether Contact has Phone Number in USA(or) Canada
                            if(result.belongsToUs){
                                //check 100 Response from Service
                                if(result.ErrorCode === '100'){		
                                    if(result.isEligible){
                                        
                                        // Avoid calling server side to get current value
                                        if(checkBoolean) {
                                            
                                            component.set('v.savedAlertForThisContact', component.find("contactValue").get("v.value"));
                                            component.find("contactValue").set("v.value", component.get("v.savedAlertForThisContact"));
                                        }
                                        else{
                                            
                                            component.set('v.savedAlertForAddContact',	component.find("addContactValue").get("v.value"));	
											component.find("addContactValue").set("v.value", component.get("v.savedAlertForAddContact"));
                                        }
                                           
                                        if(result.ErrorMessage==="email success"){
                                            this.showToast(component,'Email address updated',"Tracking notifications will be sent to this email address", "Success");
                                        }
                                        else{
                                         if(result.botheligible)
                                         {
                                             this.showToast(component,"Phone number and Email address updated","Tracking notifications will be sent to this phone number and Email address", "Success");
                                         }
                                          else
                                           {
                                             this.showToast(component,'Phone number updated',"Tracking notifications will be sent to this phone number", "Success");
                                           }
                                            
                                        }
                                        // Save Record
                                        //this.handleSaveRecord(component);
                                        
                                    }else{
                                        //ToastUser
                                        errMessage = 'Contact Phone Number is not Eligible for SMS';
                                        this.showToast(component,'Failed To Update',errMessage, "warning");
                                        $A.get('e.force:refreshView').fire();
                                    }
                                }else{
                                    
                                    errMessage = result.ErrorMessage;
                                    
                                    if(errMessage.indexOf('.') > -1)
                                        errMessage = errMessage.substr(0, errMessage.indexOf('.')); 
                                    this.showToast(component,'Error From Service', errMessage, "Error");
                                    
                                    this.refreshPrimaryAndAdditionalContact(component, errMessage, contType);
                                }
                            }
                            else{
                                if(getValue==='SMS & Email')
                                {
                                	this.showToast(component,"Phone number and Email address updated","Tracking notifications will be sent to this phone number and Email address", "Success");
                                } else if (getValue==='Email'){
                                 	this.showToast(component,'Email address updated',"Tracking notifications will be sent to this email address", "Success");   
                                } else if (getValue==='SMS'){
                                 	this.showToast(component,'Phone number updated',"Tracking notifications will be sent to this phone number", "Success");   
                                }
                                
                                //update Rcord
                                //alert('no validation hence I am updating the record');
                                //this.handleSaveRecord(component);   
                            }
                        }
                        else{
                            
                            //UpdateWorkOrder
                            errMessage = result.ErrorMessage;
                            errtitle =result.Errortitle;
                            //console.log('before toast'+errMessage+'error title'+errtitle);
                            if(result.Errortitle!==null && result.Errortitle!=='')
                            {
                                this.showToast(component,errtitle,errMessage, "Error");
                            }
                            else{
                                 this.showToast(component,'Error',errMessage, "Error");
                                }
                            //alert(component.get("v.savedAlertForThisContact"));
                           	
                            this.refreshPrimaryAndAdditionalContact(component, errMessage, contType);
                            
                        }   
                    }else{
                        //ToastUser
                        errMessage = result.ErrorMessage;
                        //console.log('for example timeout error '+errMessage);
                        this.showToast(component,'Error',errMessage, "Error");
                    }        
                }else{
                    //ToastUser
                    this.showToast(component,'Error',"Failed to Connect with backend System", "Error");
                    
                }
            });
            $A.enqueueAction(action);
        }catch(Err){
            //console.log(Err);
            this.showToast(component,'Error',"Failed to Load Lightning Component", "Error");
        }
    },
    
    // to toast Error messages
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
    handleSaveRecord: function(component) {
        try{
            var contAlert = component.get("v.contactAlertType");
            if(contAlert!==null && contAlert!==undefined && contAlert !== "" && contAlert.length !== 0){
                component.set("v.simpleRecord.ContactAlertUpdates__c", component.get("v.contactAlertType"));
            }
            var addContAlert = component.get("v.addContactAlertType");
            if(addContAlert!==null && addContAlert!==undefined && addContAlert !== "" && addContAlert.length !== 0){
                component.set("v.simpleRecord.AdditionalContactAlertUpdates__c", component.get("v.addContactAlertType"));
            }
            if(component.find('contactValue').get('v.value') === '--None--'){
                component.set("v.simpleRecord.ContactAlertUpdates__c", null);
            }
            if(undefined !== component.find('addContactValue') && component.find('addContactValue').get('v.value') === '--None--'){
                component.set("v.simpleRecord.AdditionalContactAlertUpdates__c", null);
            }
            component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
                // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
                // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    var contactValue = component.find("contactValue").get("v.value");
                    component.set('v.savedAlertForThisContact',contactValue);
                    if(undefined !== component.find("addContactValue")){
                        var addContactValue = component.find("addContactValue").get("v.value");
                        component.set('v.savedAlertForAddContact',addContactValue);
                    }
                    // handle component related logic in event handler
                } else if (saveResult.state === "INCOMPLETE") {
                    this.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
                } else if (saveResult.state === "ERROR") {
                    
                    var errorMessagesArray = [];
                    for (var i=0;i<saveResult.error.length;i=i+1)
                    {
                        var pageErrorMessage = saveResult.error[i];
                        for(var j=0;j<pageErrorMessage.pageErrors.length;j=j+1){
                            errorMessagesArray.push(pageErrorMessage.pageErrors[j].message);
                        }
                    } 
                    this.showToast(component,'Error',errorMessagesArray,"Error");
                } else {
                    this.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
                }
            }));
        }catch(Err){
            this.showToast(component,'Error',"Error Occured While Updating the Record", "Error");
        }
    },
    getWorkOrderAndPicklistValHelper : function(component){
        var action = component.get("c.fetchWorkOrderAndPicklistValues");
        action.setParams({ recordId : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();        
            if (state === "SUCCESS") {
	            //var jsonResponse = JSON.stringify(response.getReturnValue());
                component.set('v.recordAlertWrapperObject', response.getReturnValue());
                component.set('v.listOfContactAlerts', component.get('v.recordAlertWrapperObject.allContactAlertPicklistValues'));
                component.set('v.savedAlertForThisContact',component.get('v.recordAlertWrapperObject.savedContactAlert'));
                component.find("contactValue").set("v.value", component.get("v.recordAlertWrapperObject.savedContactAlert"));
                if(undefined !== component.get("v.savedAlertForThisContact")){
                    component.find("contactValue").set("v.value", component.get("v.savedAlertForThisContact"));
                } else {
                    component.find("contactValue").set("v.value", '--None--');
                }
                
                if(component.get('v.recordAlertWrapperObject.hasAdditionalContacts')){
                    component.set("v.showAdditionalcontactAlerts",true);
                    component.set('v.savedAlertForAddContact',component.get('v.recordAlertWrapperObject.additionalContactAlertValue'));
                    if(undefined !== component.get("v.savedAlertForAddContact"))
                        component.find("addContactValue").set("v.value", component.get("v.savedAlertForAddContact"));
                    else
                        component.find("addContactValue").set("v.value", '--None--');
                } else{
                    component.set("v.showAdditionalcontactAlerts",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    CheckforAdditionalContacts : function(component)
    {
        //console.log('Inside helper');
        var action=component.get("c.checkforAdditionalContacts");
        action.setParams({ recordId : component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            //console.log('The state of the response'+response.getState());
            if (state === "SUCCESS") {
                var responseResult = response.getReturnValue();
                //console.log('this-----    '+JSON.stringify(response.getReturnValue()));
                //console.log('Inside if statement at js'+response.getReturnValue().length);
                if(response.getReturnValue().length){
                    //console.log('Inside if statement at js'+response.getReturnValue().length);
                    component.set("v.hideAdditionalcontactAlerts",responseResult[0].hasAdditionalContacts);
                }
            }
            if(state === 'Error')
            {
                //console.log('Inside the error'+response.getState());
            }
        })
        $A.enqueueAction(action);
    },
    refresh :function(component,previousvalue)
    {
        //console.log('inside refresh function');
        this.CheckforAdditionalContacts(component);
        // component.set("v.contactAlertType",previousvalue)
        //location.reload();
        /* var workOrderId = component.get("v.recordId");
        if (workOrderId!=null && workOrderId!=undefined) {
            //alert('inside workorderid'+workOrderId);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": workOrderId
                    
                });
            navEvt.fire();
        
        }*/
    },
    checkContactChange : function(component,changedFields){
        try{
            //// Added by Harsha - DEFECT 5446043
            var stringChangedFields = JSON.stringify(changedFields);
            if(stringChangedFields.includes("AdditionalContactId__c") || stringChangedFields.includes("ContactId")) {
           		this.getWorkOrderAndPicklistValHelper(component);
            }
        } catch (Err) {
            this.showToast(component,'Error',"Failed to Load Lightning Component : "+Err, "Error");
        }
    },
    
    callApexToSavePMContact : function (component){
        try{
            var action=component.get("c.updatePrimaryContactAlertToNull");
            action.setParams({ recordId : component.get("v.recordId")});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result  = response.getReturnValue();
                    if(!$A.util.isEmpty(result)){
                        if(!result==='SUCCESS'){
                            this.showToast(component,'Error',"Error Occured While Update Record to Database : "+result, "Error");
                        }
                    } else {
                        this.showToast(component,'Error',"Error Occured While Update Record to Database", "Error");
                    }
                } else {
                    this.showToast(component,'Error',"Error Occured While Update Record to Database", "Error");
                }
            })
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component,'Error',"Failed to Load Lightning Component : "+Err, "Error");
        }
    },
    
    callApexToSaveADContact : function (component){
        try{
            var action=component.get("c.updateAdditContactAlertToNull");
            action.setParams({ recordId : component.get("v.recordId")});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result  = response.getReturnValue();
                    if(!$A.util.isEmpty(result)){
                        if(!result==='SUCCESS'){
                            this.showToast(component,'Error',"Error Occured While Update Record to Database : "+result, "Error");
                        }
                    } else {
                        this.showToast(component,'Error',"Error Occured While Update Record to Database", "Error");
                    }
                } else {
                    this.showToast(component,'Error',"Error Occured While Update Record to Database", "Error");
                }
            })
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component,'Error',"Failed to Load Lightning Component : "+Err, "Error");
        }
    },
    refreshPrimaryAndAdditionalContact : function (component, errMessage, contType) {
    	
    	if(errMessage !== '') {
                                            
                if(contType == 'primaryContact') { 
                if(undefined !== component.get("v.savedAlertForThisContact"))
                	component.find("contactValue").set("v.value", component.get("v.savedAlertForThisContact"));
                else
                	component.find("contactValue").set("v.value", '--None--'); 
                    
        		}
        		else {
                 //alert(component.get("v.savedAlertForAddContact"));
                 if(undefined !== component.get("v.savedAlertForAddContact"))
                    component.find("addContactValue").set("v.value", component.get("v.savedAlertForAddContact"))
                 else if(undefined === component.get("v.savedAlertForAddContact") && component.get("v.showAdditionalcontactAlerts"))
                    component.find("addContactValue").set("v.value", '--None--'); 
        		}
       }
	}
})
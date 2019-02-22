({
	init : function(component, event, helper) {
        let loadServiceTypesAction = component.get("c.getServiceTypes");
        loadServiceTypesAction.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") {
                component.set("v.serviceTypeOptions", response.getReturnValue().map(x => { return {Label: x.MasterLabel, Value: x.DeveloperName }} )); 
            } else {
                helper.showErrorMessage(component, null, "Ohh, an error occured on loading service types information. Please, try again later.");
            }
        });
        $A.enqueueAction(loadServiceTypesAction); 
        
        let loadCountriesAction = component.get("c.getCountries");
        loadCountriesAction.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") {
                component.set("v.countryOptions", response.getReturnValue().map(x => { return {Label: x.MasterLabel, Value: x.BUID__c }} )); 
            } else {
                helper.showErrorMessage(component, null, "Ohh, an error occured on loading countries information. Please, try again later.");
            }
            
            if (component.get('v.recordId') == undefined)
                helper.showLoadingSpinner(false);
        });
        $A.enqueueAction(loadCountriesAction); 
    },
    updateEditValues : function(component, event, helper) {
        setTimeout(() => { 
            const serviceSku = component.get('v.serviceSku');
            
            component.set('v.skuNumber', serviceSku.SkuNumber__c);
            component.set('v.serviceType', serviceSku.ServiceType__c);
            component.set('v.country', serviceSku.Buid__c);
            component.set('v.serviceSkuID', serviceSku.ExternalId);
            
            helper.showLoadingSpinner(false);    
        }, 1000);
    },
    post : function(component, event, helper) {
        let validForm = component.find('create-form').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if (validForm){  
            helper.showLoadingSpinner(true);
            
            const request = {
                Buid: component.get("v.country"),
                ServiceType: component.get("v.serviceType"),
                SkuNumber: component.get("v.skuNumber"),
                ServiceSkuId: component.get('v.serviceSkuID')
            }
            
            let action = component.get("c.newServiceSku");
            action.setParams({"body": JSON.stringify(request)});
            action.setCallback(this, function(response, component){
                if (response.getState() === "SUCCESS") {
                    try {
                        var result = response.getReturnValue();
                        
                        if (result.Status != 201 && result.Status != 200 && result.Status != 204) {
                            const msg = JSON.parse(result.Body)[0].value[0];
                            helper.showErrorMessage(component, null, helper.formatErrorMessageType(msg));
                        } else {
                            const isUpdate = component.get('v.serviceSkuID') != null;
                            
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": `The record has been ${isUpdate ? 'updated' : 'created'} successfully.`
                            });
                            toastEvent.fire();
                            
                            setTimeout(() => { 
                                window.location.pathname = "lightning/o/ServiceSku__x/list"; 
                                //component.destroy(); window.history.back() 
                                }, 1500);
                        }
                    }
                    catch (e) {
                        helper.showErrorMessage(component, null);
                    }
                    finally {
                        helper.showLoadingSpinner(false);
                    }
                } else {
                    let errors = response.getError();
                    
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                    
                    helper.showErrorMessage(component); 
                    helper.showLoadingSpinner(false);
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    back : function(component, event, helper) {
        component.destroy();
        window.location.pathname = "lightning/o/ServiceSku__x/list";
        //window.history.back();
    }
})
({
    // Destroy the Modal Component
    closeModal: function(component, event, helper) {
        try {
            // call helper to destroy component
            helper.closeMe(component);
        } catch (Err) {
            // show toast on Error
            helper.showToast(component,'Error',"Error Occured While Closing The Form : "+Err, "Error");
        }
    },

    // on chnage of Service Type
    serviceType: function(component, event, helper) {
        try {
            helper.serviceTypeHelper(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured while loading component - serviceType : "+Err,"Error");
        }
    },

    // on chnage of Service Type
    
   serviceOptions: function(component, event, helper) {
        try {
            helper.onChangeServiceOptions(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured while loading component - serviceOption :"+Err,"Error");
        }
    }, 
    billToChange: function(component, event, helper) {
        try {
            helper.billToChangeHelper(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured while loading component - serviceType : "+Err,"Error");
        }
    },
    
	OnCountryChanged: function(component, event, helper) {
        try {
            helper.onCountryChangedHelper(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured while loading component - Country Change : "+Err,"Error");
        }
    },

    // on change of ADOverride
    ADOverrideChange: function(component, event, helper) {
        try {
            helper.ADOverrideHelper();
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured while loading component - AD Override : "+Err,"Error");
        }
    },
    
    // Invokes On load of component 
    doInit: function(component, event, helper) {
        try {
            helper.doInitHelper(component);
        } catch (Err) {
            helper.showToast(component,'ERROR',"Error Occured While Loading Component : "+Err, "Error");
        }
    },

    // Save Record to Database
    saveRecord: function(component, event, helper) {
        try {
            helper.saveRecordHelper(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured While Closing The Form : "+Err, "Error");
        }
    },
    // This will set the flag KYHDFlagChangedTrue to true and used to add info parts in server side
    KYHDChkBoxChangeAction :function(component, event, helper) {
        try {
            helper.KYHDChkBoxChangeAction(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured While Closing The Form : "+Err, "Error");
        }
    },
    // added function By Harsha - 09/25/2018 - Defect #865002590
    handleADCheckChange : function(component, event, helper){
        try{
            helper.handleADchangeHelper(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured in the component: "+Err, "Error");
        }
    },
    //on change of DASP
    DASP: function(component, event, helper) {
        try {
            helper.DASPHelper(component);
        } catch (Err) {
            helper.showToast(component,'Error',"Error Occured while loading component - DASP : "+Err,"Error");
        }
    }
})
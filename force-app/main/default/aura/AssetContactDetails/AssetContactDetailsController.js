({
    /* ceHandlerController.js */
	 handleComponentEvent : function(component, event, helper) {
         try{
             helper.handleComponentEvent(component, event);
         }catch(Err){
            helper.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }   
    },
    
    openModalWindow: function(component,event,helper) {
        try{
            helper.openWindow(component, event);
        }catch(Err){
           	//console.log(Err);
            helper.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }        
    },
    doInit: function(component, event, helper) {
        try {
            var recID = component.get("v.recordId"); 
            if (recID!==null && recID !==undefined)
                helper.getResponse(component, recID); 
            else
                helper.showToast("",'ERROR', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
        catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
        
    },
    /*
    closeModal:function(component,event,helper){    
        try {
            var cmpTarget = component.find('Modalbox');
            var cmpBack = component.find('Modalbackdrop');        
            var cmpEvent = event.getSource();
            var whichContact = component.get("v.editWhichContact");
            if (cmpEvent != null && cmpEvent !=undefined){
                if(cmpEvent.getLocalId() == "mainConSaveBtn") {
                    helper.postUpdateRequest(component, event, whichContact);
                }
                else{
                    $A.util.removeClass(cmpBack,'slds-backdrop--open');
                    $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
                }
            }
        }
        catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },
    openModal: function(component,event,helper) {
        try {
            var cmpTarget = component.find('Modalbox');
            var cmpBack = component.find('Modalbackdrop');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
            
            var cmpEvent = event.getSource();                
            if (cmpEvent != null && cmpEvent !=undefined)
            {
                component.set("v.editWhichContact", cmpEvent.getLocalId());
                if(cmpEvent.getLocalId() == "priConEditBtn")
                {
                    component.find("mainFirstName").set("v.value", component.get("v.contacts.firstName"));
                    component.find("mainLastName").set("v.value", component.get("v.contacts.lastName"));
                    component.find("mainCountryCode").set("v.value", component.get("v.contacts.countryCode"));
                    component.find("mainAreaCode").set("v.value", component.get("v.contacts.areaCode"));
                    component.find("mainPhone").set("v.value", component.get("v.contacts.phoneNumber"));
                    component.find("mainEmail").set("v.value", component.get("v.contacts.email"));
                }
                if(cmpEvent.getLocalId() == "secConEditBtn")
                {
                    component.find("mainFirstName").set("v.value", component.get("v.contacts.secondaryFirstName"));
                    component.find("mainLastName").set("v.value", component.get("v.contacts.secondaryLastName"));
                    component.find("mainCountryCode").set("v.value", component.get("v.contacts.secondaryCountryCode"));
                    component.find("mainAreaCode").set("v.value", component.get("v.contacts.secondaryAreaCode"));
                    component.find("mainPhone").set("v.value", component.get("v.contacts.secondaryPhoneNumber"));
                    component.find("mainEmail").set("v.value", component.get("v.contacts.secondaryEmail"));            
                }
                
                if(cmpEvent.getLocalId() == "triConEditBtn")
                {
                    component.find("mainFirstName").set("v.value", component.get("v.contacts.tertiaryFirstName"));
                    component.find("mainLastName").set("v.value", component.get("v.contacts.tertiaryLastName"));
                    component.find("mainCountryCode").set("v.value", component.get("v.contacts.tertiaryCountryCode"));
                    component.find("mainAreaCode").set("v.value", component.get("v.contacts.tertiaryAreaCode"));
                    component.find("mainPhone").set("v.value", component.get("v.contacts.tertiaryPhoneNumber"));
                    component.find("mainEmail").set("v.value", component.get("v.contacts.tertiaryEmail"));
                }
            }
        }
        catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },*/    
})
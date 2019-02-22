({  
    validContactDetails: function(component, event)
    {
        try{
            var cmpEvent = event.getSource();
            var isValid = true;
            if(cmpEvent.getLocalId() == "mainConSaveBtn") 
            {
                var sFirstName = component.find("mainFirstName").get("v.value");
                var sLastName = component.find("mainLastName").get("v.value");
                var sCountryCode = component.find("mainCountryCode").get("v.value");
             //   var sAreaCode = component.find("mainAreaCode").get("v.value");
                var sPhoneNumber = component.find("mainPhone").get("v.value");
                var sEmail = component.find("mainEmail").get("v.value");
                 
                if ((sFirstName == null) || (sFirstName == "") || (sFirstName == " ")){
                    isValid = false;
                    this.showToast("",'Error', $A.get("$Label.c.ContactFirstNameValidation"), "Error"); 
                }
                if ((sLastName == null) || (sLastName == "") || (sLastName == " ")){
                    isValid = false;
                    this.showToast("",'Error', $A.get("$Label.c.ContactLastNameValidation"), "Error"); 
                } 
                if ((sCountryCode == null) || (sCountryCode == "") || (sCountryCode == " ")){
                    isValid = false;
                    this.showToast("",'Error', $A.get("$Label.c.ContactCountryCodeValidation"), "Error"); 
                }
                else{
                    //[Defect : 4992956]
                    //Modified by Sri Harsha G - Date: 04/21/2018
                    //if (isNaN(sCountryCode) || sCountryCode != 1) {
                    if (isNaN(sCountryCode)) {
                        isValid = false;
                        this.showToast("",'Error', $A.get("$Label.c.ContactCountryCodeValidation2"), "Error"); 
                    }
                    
                }
           /*      if ((sAreaCode == null) || (sAreaCode == "") || (sAreaCode == " ")){
                    isValid = false;
                    this.showToast("",'Error', $A.get("$Label.c.ContactAreaCodeValidation"), "Error"); 
                }
                else{
                    //if (isNaN(sAreaCode) || sAreaCode.length<3)  {
                    if (isNaN(sAreaCode))  {
                        isValid = false;
                        this.showToast("",'Error', $A.get("$Label.c.ContactAreaCodeValidation2"), "Error"); 
                    }
                    
                } */
                if ((sPhoneNumber == null) || (sPhoneNumber == "") || (sPhoneNumber == " ")){
                    isValid = false;
                    this.showToast("",'Error', $A.get("$Label.c.ContactPhoneValidation"), "Error"); 
                }
                else{
                    //[Defect : 4992956]
                    //Modified by Sri Harsha G - Date: 04/21/2018
                    //Updated the PhoneNumber Length condition from 7 to 6
                    if (isNaN(sPhoneNumber)) {
                        isValid = false;
                        this.showToast("",'Error', $A.get("$Label.c.ContactPhoneValidation2"), "Error"); 
                    }                
                }
                if ((sEmail == null) || (sEmail == "") || (sEmail == " ")){
                    isValid = false;
                    this.showToast("",'Error', $A.get("$Label.c.ContactEmailValidation"), "Error"); 
                }
                else
                {
                    if(!this.isValidEmail(component)) {
                        isValid = false;
                        this.showToast("",'Error', $A.get("$Label.c.ContactEmailValidation2"), "Error"); 
                    }
                    
                }
                
            }
            return isValid;
        }catch(Err){      
            this.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
        
    },
    isValidEmail : function(component) {
        try {
            var email = component.find("mainEmail").get("v.value");
            var atpos=email.indexOf("@");
            var dotpos=email.lastIndexOf(".");
            var isValid = true;
            if ((atpos<1 || dotpos<atpos+2 || dotpos+2>=email.length))
            {
                isValid = false;
            }
            return isValid;
        }
        catch(Err){      
            this.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },  
    postUpdateRequest: function(component, event, helper) {
        try {
            var action = component.get("c.updateAssetContact");
            var cmpTarget = component.find('Modalbox');
            var cmpBack = component.find('Modalbackdrop');
            var sContactCode = "";
        //    var sPhoneAreaCode = "";//component.get("v.AreaCode"); 
            var sAddressType = component.get("v.addressType");
            var sCountryCode = ""; //component.get("v.CountryCode");
            var cAssetPartyLocationId="";
            var cPartyLocationId="";
            var cPartyId="";
            var cMiddleName="";
            var cTitle="";
            var cDepartment="";
            var cOrganizationName="";
            var cLanguage="";
            var cAlternateContactName="";
            var cAlternateGivenName="";
            var cAlternateMiddleName="";
            var cAlternateLastName="";
            var cPartyContactMethodIdEmail="";
            var cPartyContactMethodIdPhone="";
            
            if (action!=null && action !=undefined)
            {
                if(this.validContactDetails(component, event))
                {                 
                    var editWhichContactStr = component.get("v.editWhichContact");
                    var sServiceTag = component.get("v.serviceTag");
                    var sFirstName = component.find("mainFirstName").get("v.value");
                    var sLastName= component.find("mainLastName").get("v.value");        
                    var sPhoneNumber = component.find("mainPhone").get("v.value");        
                    var sEmailAddress = component.find("mainEmail").get("v.value");
                //    sPhoneAreaCode = component.find("mainAreaCode").get("v.value");        
                    sCountryCode = component.find("mainCountryCode").get("v.value");
                    
                    if (sAddressType == "" || sAddressType == null)
                        sAddressType = "CP";
                    //#5174955 starts
                    if(editWhichContactStr == "priConEditBtn") {
                        sContactCode = "Primary";
                    }
                    // #5174955 ends 
                    if(editWhichContactStr == "secConEditBtn") {
                        sContactCode = "Secondary";
                    }
                    if(editWhichContactStr == "triConEditBtn") {
                        sContactCode = "Tertiary";
                    }  
                    
                    action.setParams({
                        ContactCode: sContactCode,
                        sServiceTag: sServiceTag,
                        sFirstName: sFirstName,
                        sLastName: sLastName,
                      //  sPhoneAreaCode: sPhoneAreaCode,
                        sPhoneNumber: sPhoneNumber,
                        sAddressType: sAddressType,
                        sEmailAddress: sEmailAddress,
                        sCountryCode : sCountryCode
                    });   
                    
                    action.setCallback(this, function(response) 
                                       {
                                           var state = response.getState();
                                           if (state === "SUCCESS") 
                                           {
                                               if (response.getReturnValue() == 200) 
                                               {
                                                   this.showToast("",'SUCCESS', $A.get("$Label.c.AssetContactSaved"), "success");                            
                                               }
                                               else {
                                                   this.showToast("",'Error', $A.get("$Label.c.AssetContactSaveErrorMessage"), "Error");            
                                               }               
                                           }
                                           else if (state === "INCOMPLETE") {
                                               this.showToast("",'INCOMPLETE', $A.get("$Label.c.AssetContactSaveErrorMessage"), "Error");
                                           }
                                               else if (state === "ERROR") {
                                                   var errMessage="";
                                                   var errors = response.getError();
                                                   if (errors) {
                                                       if (errors[0] && errors[0].message) {
                                                           errMessage = $A.get("$Label.c.AssetContactSaveErrorMessage") + " : " + errors[0].message;
                                                       }
                                                   }
                                                   else {
                                                       errMessage = $A.get("$Label.c.AssetContactSaveErrorMessage") + " : Unknown error"; 
                                                   }                
                                                   this.showToast("",'ERROR', errMessage, "Error");                    
                                               }
                                           
                                           var cmpEvent = component.getEvent("cmpContactUpdateEvent");                                           
                                           cmpEvent.setParams({
                                               "firstName" : sFirstName,
                                               "lastName" : sLastName,
                                               "countryCode" : sCountryCode,
                                             //  "areaCode" : sPhoneAreaCode,
                                               "phoneNumber" : sPhoneNumber,
                                               "emailAddress" : sEmailAddress,
                                               "updateStatus" : state,
                                               "editWhichContact" : editWhichContactStr
    
                                           });
                                           
                                           cmpEvent.fire();    
                                           
                                           this.closeMe(component, event, null);
                                       });
                    $A.enqueueAction(action);
                    
                }     
                //else
                //    this.showToast("",'ERROR', $A.get("$Label.c.AssetContactSaveErrorMessage"), "Error");
            }
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
        
    },
    
    closeMe : function(component, event, helper)  { 
        try{
            component.destroy();            
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },
    
    applycss:function(component){
        try{
            //initialize  
            var cmpTarget = component.find('Modalbox');
            var cmpBack = component.find('MB-Back');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
            
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },
    
    
    showToast : function(component, title, message, type) {
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message, 
                "type": type,
                "mode": "pester",
                "duration": "3000"
            });
            toastEvent.fire();
        }catch(Err){
            console.log(Err);
        }
    },
})
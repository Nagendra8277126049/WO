({
    handleComponentEvent: function(component, event) {
        try {
            //  helper.handleComponentEvent(component, event, helper)
            var statusStr = event.getParam("updateStatus");
            var firstNameStr = event.getParam("firstName");
            var lastNameStr = event.getParam("lastName");
            var countryCodeStr = event.getParam("countryCode");
          //  var areaCodeStr = event.getParam("areaCode");
            var phoneNumberStr = event.getParam("phoneNumber");
            var emailAddressStr = event.getParam("emailAddress");
            var editWhichContactStr = event.getParam("editWhichContact");
           
            if (statusStr === "SUCCESS") {
                if (editWhichContactStr === "priConEditBtn") {
                    component.set("v.contacts.firstName", firstNameStr);
                    component.set("v.contacts.lastName", lastNameStr);
                    component.set("v.contacts.phoneNumber", phoneNumberStr);
                    component.set("v.contacts.email", emailAddressStr);

                    component.set("v.contacts.fullName", firstNameStr + " " + lastNameStr);
                    component.set("v.contacts.fullPhone","+" + countryCodeStr + "-" + phoneNumberStr); 
                    window.alert(v.contacts.fullPhone);

                  //  component.set("v.contacts.areaCode", areaCodeStr);
                    component.set("v.contacts.countryCode", countryCodeStr);

                }
                if (editWhichContactStr === "secConEditBtn") {
                    component.set("v.contacts.secondaryFirstName", firstNameStr);
                    component.set("v.contacts.secondaryLastName", lastNameStr);
                    component.set("v.contacts.secondaryPhoneNumber", phoneNumberStr);
                    component.set("v.contacts.secondaryEmail", emailAddressStr);

                    component.set("v.contacts.secondaryFullName", firstNameStr + " " + lastNameStr);
                    component.set("v.contacts.secondaryFullPhone", "+" + countryCodeStr + "-" + phoneNumberStr);

                 //   component.set("v.contacts.secondaryAreaCode", areaCodeStr);
                    component.set("v.contacts.secondaryCountryCode", countryCodeStr);
                }
                if (editWhichContactStr === "triConEditBtn") {
                    component.set("v.contacts.tertiaryFirstName", firstNameStr);
                    component.set("v.contacts.tertiaryLastName", lastNameStr);
                    component.set("v.contacts.tertiaryPhoneNumber", phoneNumberStr);
                    component.set("v.contacts.tertiaryEmail", emailAddressStr);

                    component.set("v.contacts.tertiaryFullName", firstNameStr + " " + lastNameStr);
                    component.set("v.contacts.tertiaryFullPhone", "+" + countryCodeStr + "-" + phoneNumberStr);

                 //   component.set("v.contacts.tertiaryAreaCode", areaCodeStr);
                    component.set("v.contacts.tertiaryCountryCode", countryCodeStr);
                }
            }
        } catch (Err) {
            //console.log(Err);
            this.showToast(component, 'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },
    openWindow: function(component, event) {
        try {
            var cmpEvent = event.getSource();
            var editWhichContactStr = cmpEvent.getLocalId();
            var serviceTagStr = component.get("v.contacts.serviceTag");
            var firstNameStr = component.get("v.contacts.firstName");
            var lastNameStr = component.get("v.contacts.lastName");
            var countryCodeStr = component.get("v.contacts.countryCode");
         //   var areaCodeStr = component.get("v.contacts.areaCode");
            var phoneNumberStr = component.get("v.contacts.phoneNumber");
            var emailAddressStr = component.get("v.contacts.email");
            var addressTypeStr = component.get("v.contacts.addressType");

            if (editWhichContactStr === "secConEditBtn") {
                firstNameStr = component.get("v.contacts.secondaryFirstName");
                lastNameStr = component.get("v.contacts.secondaryLastName");
                countryCodeStr = component.get("v.contacts.secondaryCountryCode");
               // areaCodeStr = component.get("v.contacts.secondaryAreaCode");
                phoneNumberStr = component.get("v.contacts.secondaryPhoneNumber");
                emailAddressStr = component.get("v.contacts.secondaryEmail");
                addressTypeStr = component.get("v.contacts.secondaryAddressType");
            }
            if (editWhichContactStr === "triConEditBtn") {
                firstNameStr = component.get("v.contacts.tertiaryFirstName");
                lastNameStr = component.get("v.contacts.tertiaryLastName");
                countryCodeStr = component.get("v.contacts.tertiaryCountryCode");
              //  areaCodeStr = component.get("v.contacts.tertiaryAreaCode");
                phoneNumberStr = component.get("v.contacts.tertiaryPhoneNumber");
                emailAddressStr = component.get("v.contacts.tertiaryEmail");
                addressTypeStr = component.get("v.contacts.tertiaryAddressType");
            }

            $A.createComponent(
                "c:AssetContactDetailsUpdate", {
                    "serviceTag": serviceTagStr,
                    "firstName": firstNameStr,
                    "lastName": lastNameStr,
                    "countryCode": countryCodeStr,
                   /* "areaCode": areaCodeStr,*/
                    "phoneNumber": phoneNumberStr,
                    "emailAddress": emailAddressStr,
                    "addressType": addressTypeStr,
                    "editWhichContact": editWhichContactStr,
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
            //console.log(Err);
            this.showToast(component, 'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
        }
    },

    getResponse: function(component, recID) {
        try {
            var action = component.get("c.getAssetContactDetails");
            if (action !== null && action !== undefined) {
                component.set("v.conSpinner1", true);
                action.setParams({
                    recordId: recID
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.contacts", response.getReturnValue());
                        component.set("v.conSpinner1", false);
                        component.set("v.conAlert1", true);
                    } else if (state === "INCOMPLETE") {
                        this.showToast("", 'INCOMPLETE', $A.get("$Label.c.AssetContactGetErrorMessage"), "Warning");
                    } else if (state === "ERROR") {
                        var errMessage = "";
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                errMessage = $A.get("$Label.c.AssetContactGetErrorMessage") + " : " + errors[0].message;
                            }
                        } else {
                            errMessage = $A.get("$Label.c.AssetContactGetErrorMessage") + " : Unknown error";
                        }
                        this.showToast("", 'ERROR', errMessage, "Error");
                    }
                });
                $A.enqueueAction(action);
            } else
                this.showToast("", 'ERROR', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        } catch (Err) {
            this.showToast("", 'ERROR', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
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
})
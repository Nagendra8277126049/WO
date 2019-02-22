/*--------------------------------------------------------------------------------------------------------------------------
Name:         ValidatePhoneNumberController
Description:  To call OBR Service - to check whether Phone Number is eligible for SMS or Not.
- Story #4623476
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author              Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
03/29/2017     1.0         Carpio Rodrigo       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class ValidatePhoneNumberController {

    // Wrapper Class
    public with sharing class phoneWrapper {
        @AuraEnabled public Boolean hasPhoneNumber {
            get;
            set;
        }
        @AuraEnabled public Boolean botheligible {
            get;
            set;
        }
        @AuraEnabled public String phoneNumber {
            get;
            set;
        }
        @AuraEnabled public Boolean isEligible {
            get;
            set;
        }
        @AuraEnabled public string ErrorCode {
            get;
            set;
        }
        @AuraEnabled public string Errortitle {
            get;
            set;
        }
        @AuraEnabled public String ErrorMessage {
            get;
            set;
        }
        @AuraEnabled public Boolean belongsToUs {
            get;
            set;
        }
        @AuraEnabled public Boolean hasPrimaryPhoneTypeInfo {
            get;
            set;
        }
    }
    /*
    @AuraEnabled public RecordAlertWrapper recordAlertWrapperObj {
        get;
        set;
    }
	*/

    /* 
     * Method to Query on PhoneNumberValidation__x External Object and also to collect Response from Service
     */
    @AuraEnabled
    public static phoneWrapper validateForMessaging(Id recordId, Boolean isPrimaryContact, String selectedContactType) {
        system.debug('selectedValue>>>' + selectedContactType);
        phoneWrapper pWrap = new phoneWrapper();
        try {
            //Boolean isEligible;
            string conrecId = '';
            boolean belongsToUs= false;
            string countryCode = '';
            boolean hasPhoneNumber=false;

            List < WorkOrder > wOrderList = new List < WorkOrder > ();
            wOrderList = [SELECT Contact.Primary_Phone__c, Contact.Primary_Phone_Type__c, Contact.Country_Code__c,
                Contact.Email, ContactAlertUpdates__c, AdditionalContactAlertUpdates__c,
                AdditionalContactId__r.Primary_Phone__c, AdditionalContactId__r.Primary_Phone_Type__c,
                AdditionalContactId__r.Country_Code__c, AdditionalContactId__r.Email
                FROM workOrder WHERE id =: recordId LIMIT 1
            ];
            //If it is Primary Contact
            //system.debug('wOrderList[0].Contact.Primary_Phone_Type__c ###'+wOrderList[0].Contact.Primary_Phone_Type__c);

            if (isPrimaryContact) {
                system.debug('Inside Primary contact');
                //can be commented as we have validation rule in Contact.-Prakhar
                if (string.isNotBlank(selectedContactType) && selectedContactType.equalsIgnoreCase('SMS & Email') &&
                    wOrderList[0].Contact.Primary_Phone__c == null &&
                    wOrderList[0].Contact.Primary_Phone_Type__c == null &&
                    wOrderList[0].Contact.Email == null) {
                    pWrap.hasPrimaryPhoneTypeInfo = false;
                    pWrap.ErrorMessage = 'Please enter a phone number along with the country code and Email Address for the Contact';
                    return pWrap;
                }
                if (string.isNotBlank(selectedContactType) && selectedContactType.equalsIgnoreCase('email')) {
                    if (wOrderList[0].Contact.Email != null && wOrderList[0].Contact.Email != '') {
                        //added by dattaa1 to check if the email id is invalid
                        if (String.isNotBlank(wOrderList[0].Contact.Email) && wOrderList[0].Contact.Email.containsignorecase('no-email@dell.com')) {
                            pWrap.hasPrimaryPhoneTypeInfo = false;
                            pWrap.ErrorMessage = 'Please enter valid Email Address for the Contact';
                            return pWrap;
                        }
                        //fooling the system with a valid response from the server.
                        pWrap.hasPhoneNumber = true;
                        pWrap.hasPrimaryPhoneTypeInfo = true;
                        pWrap.belongsToUs = true;
                        pWrap.ErrorCode = '100';
                        pWrap.isEligible = true;
                        pWrap.ErrorMessage = 'email success';
                        // Added Sri1
                        wOrderList[0].ContactAlertUpdates__c = 'email';
                        update wOrderList[0];
                        // Added Sri1
                        return pWrap;
                    } //else part can be commented as there is validation rule in contact.
                    else {
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pWrap.ErrorMessage = 'Please enter Email Address for the Contact';
                        return pWrap;
                    }
                }
                //Added by Prakhar Sinha for SMS & Email
                if (string.isNotBlank(selectedContactType) && selectedContactType.equalsIgnoreCase('SMS & Email')) {
                    if (wOrderList[0].Contact.Email != null && wOrderList[0].Contact.Email != '') {
                        //added by dattaa1 to check if the email id is invalid
                        if (!String.isempty(wOrderList[0].Contact.Email) && wOrderList[0].Contact.Email.containsignorecase('no-email@dell.com')) {
                            pWrap.hasPrimaryPhoneTypeInfo = false;
                            pWrap.ErrorMessage = 'Please enter valid Email Address for the Contact';
                            return pWrap;
                        }
                    } //else part can be commented as there is validation rule in contact.
                    else {
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pWrap.ErrorMessage = 'Please enter Email Address for the Contact';
                        return pWrap;
                    }
                    if (null == wOrderList[0].Contact.Primary_Phone_Type__c || !wOrderList[0].Contact.Primary_Phone_Type__c.equalsIgnoreCase('Mobile')) {
                        //system.debug('inside no phone type');
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    }

                    if (String.isNotBlank(wOrderList[0].Contact.Primary_Phone__c)) {
                        pWrap.hasPhoneNumber = true;
                        pWrap.hasPrimaryPhoneTypeInfo = true;
                        hasPhoneNumber = true;
                        // Contact Phone Number
                        pWrap.phoneNumber = wOrderList[0].Contact.Primary_Phone__c;
                        //pmContact = wOrderList[0].Contact.Primary_Phone__c;
						//Updated by Divyansh for Defect 5999065
                        if (wOrderList[0].Contact.Primary_Phone__c.startsWith(system.label.UsaCanadaPhNumPrefix) || 
							wOrderList[0].Contact.Primary_Phone__c.startsWith(system.label.IndiaPhNumPrefix) || 
							wOrderList[0].Contact.Primary_Phone__c.startsWith(system.label.AusPhNumPrefix)) {
                            // Phone Number belongs to USA
                            // Phone Number has Starts With +1
                            conrecId = wOrderList[0].Contact.Primary_Phone__c;
                            pWrap.belongsToUs = true;
                            belongsToUs = true;
                            pwrap.botheligible = true;
                        } else {
                            if (String.isNotBlank(wOrderList[0].Contact.Country_Code__c)) {
								//Updated by Divyansh for Defect 5999065
                                if (wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode) ||
									wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode) ||
									wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
                                    // Phone Number belongs to USA
                                    // Phone Number does not has Starts With +1
                                    // Add +1 before Phone Number
									
									if(wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode)) {
										countryCode = system.label.UsaCanadaPhNumPrefix;
									}
									else if(wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode)) {
										countryCode = system.label.IndiaPhNumPrefix;
									}
									else if(wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
										countryCode = system.label.AusPhNumPrefix;
									}
									
									conrecId = countryCode + wOrderList[0].Contact.Primary_Phone__c;
                                    pWrap.belongsToUs = true;
                                    belongsToUs = true;
                                    pwrap.botheligible = true;
                                }
							}
                        }

                    } else {

                        // contact has No Phone Number
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    }


                }
                if (selectedContactType != null && selectedContactType.equalsIgnoreCase('SMS')) {
                    if (null == wOrderList[0].Contact.Primary_Phone_Type__c || !wOrderList[0].Contact.Primary_Phone_Type__c.equalsIgnoreCase('Mobile')) {
                        //system.debug('inside no phone type');
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    } else if (null == wOrderList[0].Contact.Country_Code__c || String.isBlank(wOrderList[0].Contact.Country_Code__c)) {

                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pWrap.ErrorMessage = 'Please enter a country code for the phone number.';
                        return pWrap;
                    } else if (null == wOrderList[0].Contact.Primary_Phone__c || String.isBlank(wOrderList[0].Contact.Primary_Phone__c)) {
                        //system.debug('inside no phone');
                        pWrap.hasPhoneNumber = false;
                        pWrap.ErrorMessage = 'Please enter a phone number for the contact';
                        return pWrap;
                    }
                    // Phone Number is Not Blank
                    if (String.isNotBlank(wOrderList[0].Contact.Primary_Phone__c)) {
                        pWrap.hasPhoneNumber = true;
                        pWrap.hasPrimaryPhoneTypeInfo = true;
                        hasPhoneNumber = true;
                        // Contact Phone Number
                        pWrap.phoneNumber = wOrderList[0].Contact.Primary_Phone__c;
                        //pmContact = wOrderList[0].Contact.Primary_Phone__c;
						
                        //Updated by Divyansh for Defect 5999065
                        if (wOrderList[0].Contact.Primary_Phone__c.startsWith(system.label.UsaCanadaPhNumPrefix) || 
							wOrderList[0].Contact.Primary_Phone__c.startsWith(system.label.IndiaPhNumPrefix) || 
							wOrderList[0].Contact.Primary_Phone__c.startsWith(system.label.AusPhNumPrefix)) {
                            // Phone Number belongs to USA
                            // Phone Number has Starts With +1
                            conrecId = wOrderList[0].Contact.Primary_Phone__c;
                            pWrap.belongsToUs = true;
                            belongsToUs = true;
                        } else {
                            if (String.isNotBlank(wOrderList[0].Contact.Country_Code__c)) {
                                ////Updated by Divyansh for Defect 5999065
                                if (wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode) ||
									wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode) ||
									wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
                                    // Phone Number belongs to USA
                                    // Phone Number does not has Starts With +1
                                    // Add +1 before Phone Number
									if(wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode)) {
										countryCode = system.label.UsaCanadaPhNumPrefix;
									}
									else if(wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode)) {
										countryCode = system.label.IndiaPhNumPrefix;
									}
									else if(wOrderList[0].Contact.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
										countryCode = system.label.AusPhNumPrefix;
									}
                                    conrecId = wOrderList[0].Contact.Primary_Phone__c;
									if(String.isNotBlank(countryCode)){ // Added Blank Check for DEFECT 6062267 - Jan 12th 2019
                                    	conrecId = countryCode + wOrderList[0].Contact.Primary_Phone__c;
                                    }
                                    pWrap.belongsToUs = true;

                                    belongsToUs = true;
                                }

                            }
                        }
                        //system.Debug('belongsToUs ###'+belongsToUs);
                    } else {
                        // contact has No Phone Number
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    }
                }
                if (selectedContactType != null && selectedContactType.containsIgnoreCase('email') && (wOrderList[0].Contact.Email == null || wOrderList[0].Contact.Email == '')) {
                    pWrap.hasPrimaryPhoneTypeInfo = false;
                    pWrap.ErrorMessage = 'Please enter Email Address for the Contact';
                    return pWrap;
                }
                //added by dattaa1 to check if the email id is invalid
                else if (selectedContactType != null && selectedContactType.containsIgnoreCase('email') && !String.isempty(wOrderList[0].Contact.Email) && wOrderList[0].Contact.Email.containsignorecase('no-email@dell.com')) {

                    pWrap.hasPrimaryPhoneTypeInfo = false;
                    pWrap.ErrorMessage = 'Please enter valid Email Address for the Contact';
                    return pWrap;
                }

            }
            //If it is Additional Contact
            else {
                if (selectedContactType != null && selectedContactType.equalsIgnoreCase('SMS & Email') && wOrderList[0].AdditionalContactId__r.Primary_Phone__c == null && wOrderList[0].AdditionalContactId__r.Primary_Phone_Type__c == null && wOrderList[0].AdditionalContactId__r.Email == null) {
                    pWrap.hasPrimaryPhoneTypeInfo = false;
                    pWrap.ErrorMessage = 'Please enter a phone number along with the country code and Email Address for the Contact';
                    return pWrap;
                }
                if (selectedContactType != null && selectedContactType.equalsIgnoreCase('email')) {
                    if (wOrderList[0].AdditionalContactId__r.Email != null && wOrderList[0].AdditionalContactId__r.Email != '') {
                        //added by dattaa1 to check if the email id is invalid
                        if (!String.isempty(wOrderList[0].AdditionalContactId__r.Email) && wOrderList[0].AdditionalContactId__r.Email.containsignorecase('no-email@dell.com')) {
                            pWrap.hasPrimaryPhoneTypeInfo = false;
                            pWrap.ErrorMessage = 'Please enter valid Email Address for the Contact';
                            return pWrap;
                        }
                        //fooling the system with a valid response from the server.
                        pWrap.hasPhoneNumber = true;
                        pWrap.hasPrimaryPhoneTypeInfo = true;
                        pWrap.belongsToUs = true;
                        pWrap.ErrorCode = '100';
                        pWrap.isEligible = true;
                        pWrap.ErrorMessage = 'email success';
                        // Added Sri1
                        wOrderList[0].AdditionalContactAlertUpdates__c = 'email';
                        update wOrderList[0];
                        // Added Sri1
                        return pWrap;
                    } //else part can be commented as there is validation rule in contact.
                    else {
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pWrap.ErrorMessage = 'Please enter Email Address for the Contact';
                        return pWrap;
                    }
                }
                //Added by Prakhar Sinha for SMS & Email
                if (selectedContactType != null && selectedContactType.equalsIgnoreCase('SMS & Email')) {
                    if (wOrderList[0].AdditionalContactId__r.Email != null && wOrderList[0].AdditionalContactId__r.Email != '') {
                        //added by dattaa1 to check if the email id is invalid
                        if (!String.isempty(wOrderList[0].AdditionalContactId__r.Email) && wOrderList[0].AdditionalContactId__r.Email.containsignorecase('no-email@dell.com')) {
                            pWrap.hasPrimaryPhoneTypeInfo = false;
                            pWrap.ErrorMessage = 'Please enter valid Email Address for the Contact';
                            return pWrap;
                        }
                    } //else part can be commented as there is validation rule in contact.
                    else {
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pWrap.ErrorMessage = 'Please enter Email Address for the Contact';
                        return pWrap;
                    }
                    if (null == wOrderList[0].AdditionalContactId__r.Primary_Phone_Type__c || !wOrderList[0].AdditionalContactId__r.Primary_Phone_Type__c.equalsIgnoreCase('Mobile')) {
                        //system.debug('inside no phone type');
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    }

                    if (String.isNotBlank(wOrderList[0].AdditionalContactId__r.Primary_Phone__c)) {
                        pWrap.hasPhoneNumber = true;
                        pWrap.hasPrimaryPhoneTypeInfo = true;
                        hasPhoneNumber = true;
                        // Contact Phone Number
                        pWrap.phoneNumber = wOrderList[0].AdditionalContactId__r.Primary_Phone__c;
                        //pmContact = wOrderList[0].Contact.Primary_Phone__c;
						
                        //Updated by Divyansh for Defect 5999065
                        if (wOrderList[0].AdditionalContactId__r.Primary_Phone__c.startsWith(system.label.UsaCanadaPhNumPrefix) || 
							wOrderList[0].AdditionalContactId__r.Primary_Phone__c.startsWith(system.label.IndiaPhNumPrefix) || 
							wOrderList[0].AdditionalContactId__r.Primary_Phone__c.startsWith(system.label.AusPhNumPrefix)) {
                            // Phone Number belongs to USA
                            // Phone Number has Starts With +1
                            conrecId = wOrderList[0].AdditionalContactId__r.Primary_Phone__c;
                            pWrap.belongsToUs = true;
                            belongsToUs = true;

                        } else {
                            if (String.isNotBlank(wOrderList[0].AdditionalContactId__r.Country_Code__c)) {
								//Updated by Divyansh for Defect 5999065
                                if (wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode) ||
									wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode) ||
									wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)
									) {
                                    // Phone Number belongs to USA
                                    // Phone Number does not has Starts With +1
                                    // Add +1 before Phone Number
									/*
									 * Commented for DEFECT 6062267  - Jan 12th 2019
									if(wOrderList[0].AdditionalContactId__r.Primary_Phone__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode)) {
										countryCode = system.label.UsaCanadaPhNumPrefix;
									}
									else if(wOrderList[0].AdditionalContactId__r.Primary_Phone__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode)) {
										countryCode = system.label.IndiaPhNumPrefix;
									}
									else if(wOrderList[0].AdditionalContactId__r.Primary_Phone__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
										countryCode = system.label.AusPhNumPrefix;
									}
									conrecId = countryCode + wOrderList[0].AdditionalContactId__r.Primary_Phone__c;
									*/
                                     // DEFECT 6062267 - Starts Here - Jan 12th 2019
                                  	if(wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode)) {
										countryCode = system.label.UsaCanadaPhNumPrefix;
									}
									else if(wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode)) {
										countryCode = system.label.IndiaPhNumPrefix;
									}
									else if(wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
										countryCode = system.label.AusPhNumPrefix;
									}
                                    
                                    conrecId = wOrderList[0].AdditionalContactId__r.Primary_Phone__c;
                                    
                                    if(String.isNotBlank(countryCode)){
                                    	conrecId = countryCode + wOrderList[0].AdditionalContactId__r.Primary_Phone__c;
                                    }
                                    //DEFECT 6062267 - Ends Here - Jan 12th 2019
                                    
                                    pWrap.belongsToUs = true;
                                    belongsToUs = true;
                                    pwrap.botheligible = true;
                                }

                            }
                        }

                    } else {

                        // contact has No Phone Number
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    }


                }
                if (selectedContactType != null && selectedContactType.equalsIgnoreCase('SMS')) {
                    if (null == wOrderList[0].AdditionalContactId__r.Primary_Phone_Type__c || !wOrderList[0].AdditionalContactId__r.Primary_Phone_Type__c.equalsIgnoreCase('Mobile')) {
                        //system.debug('inside no phone type');
                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    } else if (null == wOrderList[0].AdditionalContactId__r.Country_Code__c || String.isBlank(wOrderList[0].AdditionalContactId__r.Country_Code__c)) {

                        pWrap.hasPrimaryPhoneTypeInfo = false;
                        pWrap.ErrorMessage = 'Please enter a country code for the phone number.';
                        return pWrap;
                    } else if (null == wOrderList[0].AdditionalContactId__r.Primary_Phone__c || String.isBlank(wOrderList[0].AdditionalContactId__r.Primary_Phone__c)) {
                        //system.debug('inside no phone');
                        pWrap.hasPhoneNumber = false;
                        pWrap.ErrorMessage = 'Please enter a phone number for the contact';
                        return pWrap;
                    }
                    // Phone Number is Not Blank
                    if (String.isNotBlank(wOrderList[0].AdditionalContactId__r.Primary_Phone__c)) {
                        pWrap.hasPhoneNumber = true;
                        pWrap.hasPrimaryPhoneTypeInfo = true;
                        hasPhoneNumber = true;
                        // Contact Phone Number
                        pWrap.phoneNumber = wOrderList[0].Contact.Primary_Phone__c;
                        //pmContact = wOrderList[0].Contact.Primary_Phone__c;
						//Updated by Divyansh for Defect 5999065
                        if (wOrderList[0].AdditionalContactId__r.Primary_Phone__c.startsWith(system.label.UsaCanadaPhNumPrefix) || 
							wOrderList[0].AdditionalContactId__r.Primary_Phone__c.startsWith(system.label.IndiaPhNumPrefix) || 
							wOrderList[0].AdditionalContactId__r.Primary_Phone__c.startsWith(system.label.AusPhNumPrefix)) {
                            // Phone Number belongs to USA
                            // Phone Number has Starts With +1
                            conrecId = wOrderList[0].Contact.Primary_Phone__c;
                            pWrap.belongsToUs = true;
                            belongsToUs = true;
                        } else {
                            if (String.isNotBlank(wOrderList[0].AdditionalContactId__r.Country_Code__c)) {
								//Updated by Divyansh for Defect 5999065
                                if (wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode) ||
									wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode) ||
									wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
                                    // Phone Number belongs to USA
                                    // Phone Number does not has Starts With +1
                                    // Add +1 before Phone Number
									//if(wOrderList[0].AdditionalContactId__r.Primary_Phone__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode)) {
									if(wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.UsaCanadaPhNumCountryCode)) {	
                                        countryCode = system.label.UsaCanadaPhNumPrefix;
									}
									//else if(wOrderList[0].AdditionalContactId__r.Primary_Phone__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode)) {
									else if(wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.IndiaPhNumCountryCode)) {
                                        countryCode = system.label.IndiaPhNumPrefix;
									}
									//else if(wOrderList[0].AdditionalContactId__r.Primary_Phone__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
									else if(wOrderList[0].AdditionalContactId__r.Country_Code__c.equalsIgnoreCase(system.label.AusPhNumCountryCode)) {
                                        countryCode = system.label.AusPhNumPrefix;
									}
									
                                    conrecId = countryCode + wOrderList[0].Contact.Primary_Phone__c;
                                    pWrap.belongsToUs = true;

                                    belongsToUs = true;
                                }

                            }
                        }
                        //system.Debug('belongsToUs ###'+belongsToUs);
                    } else {
                        // contact has No Phone Number
                        pwrap.Errortitle = 'Phone Type does not match';
                        pWrap.ErrorMessage = 'For contact by SMS, the phone type should be mobile.';
                        return pWrap;
                    }
                }
                if (selectedContactType != null && selectedContactType.containsIgnoreCase('email') && (wOrderList[0].AdditionalContactId__r.Email == null || wOrderList[0].AdditionalContactId__r.Email == '')) {
                    pWrap.hasPrimaryPhoneTypeInfo = false;
                    pWrap.ErrorMessage = 'Please enter Email Address for the Contact';
                    return pWrap;
                }
                //added by dattaa1 to check if the email id is invalid
                else if (selectedContactType != null && selectedContactType.containsIgnoreCase('email') && !String.isempty(wOrderList[0].AdditionalContactId__r.Email) && wOrderList[0].AdditionalContactId__r.Email.containsignorecase('no-email@dell.com')) {

                    pWrap.hasPrimaryPhoneTypeInfo = false;
                    pWrap.ErrorMessage = 'Please enter valid Email Address for the Contact';
                    return pWrap;
                }

            }

            List < PhoneNumberValidation__x > phNumList = new List < PhoneNumberValidation__x > ();
            system.debug('belongsToUs $$$' + belongsToUs);
            if (String.isNotBlank(conrecId) && belongsToUs && hasPhoneNumber) {
                String numericString = '';
                if (conrecId != null && conrecId != '') {
                    for (integer i = 0; i < conrecId.length(); i++) {
                        String s = conrecId.mid(i, 1);
                        if (s.isNumeric()) {
                            numericString += s;
                        }
                    }
                    conrecId = numericString;
                }
                system.debug('conrecId >>>' + conrecId);
                if (!Test.isRunningTest()) {
                    // SOQL Query on External Object - PhoneNumberValidation__x
                    // Call OBS Service to validate Phone Number
                    phNumList = [SELECT ErrorCode__c, SmsCapable__c, ErrorMessage__c FROM PhoneNumberValidation__x WHERE PhoneNumber__c =: conrecId LIMIT 1];
                } else {
                    //for Test Coverage
                    phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
                    phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
                    phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
                    phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
                    phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
                }

                //check if returned List from query on ExternalObject - size greater than zero.
                if (phNumList.size() > 0) {
                    // Error Message From Service
                    pWrap.ErrorMessage = phNumList[0].ErrorMessage__c;
                    // Error Code From Service
                    pWrap.ErrorCode = phNumList[0].ErrorCode__c;
                    // check if Response Code equals to 100
                    if (phNumList[0].ErrorCode__c.equals('100')) {
                        //is Phone Number Eligible for SMS
                        pWrap.isEligible = Boolean.valueOf(phNumList[0].SmsCapable__c);
                        // Added By Sri1 - Starts Here
                        if (Boolean.valueOf(phNumList[0].SmsCapable__c)) {
                            if (isPrimaryContact) {
                                if (selectedContactType.equalsIgnoreCase('SMS')) {
                                    wOrderList[0].ContactAlertUpdates__c = selectedContactType;
                                    update wOrderList[0];
                                } else if (selectedContactType.equalsIgnoreCase('SMS & Email')) {
                                    wOrderList[0].ContactAlertUpdates__c = selectedContactType;
                                    update wOrderList[0];
                                }
                            } else {
                                if (selectedContactType.equalsIgnoreCase('SMS')) {
                                    wOrderList[0].AdditionalContactAlertUpdates__c = selectedContactType;
                                    update wOrderList[0];
                                } else if (selectedContactType.equalsIgnoreCase('SMS & Email')) {
                                    wOrderList[0].AdditionalContactAlertUpdates__c = selectedContactType;
                                    update wOrderList[0];
                                }
                            }
                        }
                        // Added By Sri1 - Ends Here
                    }
                }
            }
            // Added By Sri1 - Starts Here
            if (!belongsToUs & String.isNotBlank(selectedContactType)) {
                if (isPrimaryContact) {
                    wOrderList[0].ContactAlertUpdates__c = selectedContactType;
                	update wOrderList[0];
          		} else {
                    wOrderList[0].AdditionalContactAlertUpdates__c = selectedContactType;
                	update wOrderList[0];
            	}
            }
            //// Added By Sri1 - Ends Here
            return pWrap;
        } catch (exception e) {
            // Log Exception Record on Exception Logger Object
            ExceptionHandler.logHandledExceptions(e, 'ValidatePhoneNumberController', 'validateForMessaging', 'Dispatch Management');
            //Megha changed this return statement on 19-04-2018 to show the actual error message on screen toast
            //return null;
            pWrap.ErrorMessage = e.getMessage();
            return pWrap;
        }
    }
    /*@AuraEnabled
public static list<phoneWrapper> checkforAdditionalContacts(Id recordId)
{

System.debug('>>>>Inside method>>>');
phoneWrapper phnwrap = new phoneWrapper();
Boolean hasAdditionalContacts= false;
String contactAlert='';
List<WorkOrder> wOrderList = new List<WorkOrder>();
wOrderList = [SELECT Id,AdditionalContactId__c,ContactAlertUpdates__c FROM workOrder WHERE id=:recordId LIMIT 1];
if(wOrderList[0].AdditionalContactId__c!=null)
{
hasAdditionalContacts=true;
phnwrap.hasAdditionalContacts=hasAdditionalContacts;

}
else{
phnwrap.hasAdditionalContacts=false;
}


system.debug('phnwrap>>>>'+phnwrap);
list<phoneWrapper> phnwrplist = new List<phoneWrapper>();
phnwrplist.add(phnwrap);
return  phnwrplist;     
}*/

    /*
Method to Fetch Work Order Details and PicklistValues(ContactAlertUpdates__c Field) 
*/
    @AuraEnabled
    public static recordAlertwrapper fetchWorkOrderAndPicklistValues(string recordId) {
        try {
            List < String > lstPickvals = new List < String > ();
            RecordAlertWrapper alertWrapper = new RecordAlertWrapper();

            Schema.DescribeFieldResult fieldResult = workOrder.ContactAlertUpdates__c.getDescribe();
            List < Schema.PicklistEntry > pick_list_values = fieldResult.getPicklistValues();
            lstPickvals.add('--None--');
            
            for (Schema.PicklistEntry pe: pick_list_values) {
                lstPickvals.add(pe.getValue());
            }

            List < workOrder > workOrderList = [SELECT Id, ContactAlertUpdates__c, AdditionalContactId__c,
                AdditionalContactAlertUpdates__c FROM WorkOrder WHERE Id =: recordId LIMIT 1
            ];

            if (null != workOrderList && workOrderList.size() > 0) {

                alertWrapper.savedContactAlert = workOrderList[0].ContactAlertUpdates__c;
                alertWrapper.allContactAlertPicklistValues = lstPickvals;

                if (workOrderList[0].AdditionalContactId__c != null) {
                    alertWrapper.hasAdditionalContacts = true;
                    alertwrapper.additionalContactAlertValue = workOrderList[0].AdditionalContactAlertUpdates__c;

                }
            }
            //system.debug('alertWrapper ---'+alertWrapper);
            return alertWrapper;
        } catch (exception e) { ExceptionHandler.logHandledExceptions(e, 'ValidatePhoneNumberController', 'fetchWorkOrderAndPicklistValues', 'Dispatch Management');
            return null;
        }
    }

    public with sharing class RecordAlertWrapper {
        @AuraEnabled public string savedContactAlert {
            get;
            set;
        }
        @AuraEnabled public List < string > allContactAlertPicklistValues {
            get;
            set;
        }
        @AuraEnabled public Boolean hasAdditionalContacts {
            get;
            set;
        }
        @AuraEnabled public String additionalContactAlertValue {
            get;
            set;
        }

        public RecordAlertWrapper() {
            savedContactAlert = '';
            allContactAlertPicklistValues = new List < string > ();
            hasAdditionalContacts = false;
        }
    }
       @AuraEnabled
    public static string updatePrimaryContactAlertToNull (Id recordId){
        try{
            WorkOrder wo = new WorkOrder(Id =recordId);
            wo.ContactAlertUpdates__c = null;
            update wo;
	        return 'SUCCESS';
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e, 'ValidatePhoneNumberController', 'updatePrimaryContactAlertToNull', 'Dispatch Management');
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string updateAdditContactAlertToNull (Id recordId){
        try{
            WorkOrder wo = new WorkOrder(Id =recordId);
            wo.AdditionalContactAlertUpdates__c = null;
            update wo;   
	        return 'SUCCESS';
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e, 'ValidatePhoneNumberController', 'updateAdditContactAlertToNull', 'Dispatch Management');
            return e.getMessage();
        }
    }
}
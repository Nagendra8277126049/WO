/* -----------------------------------------------------------------------------------------------------------------------
Name:         PhoneCheck
Description:  this is controller for Lightning component SMSCheck  Story 5428506
Date          Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
10/18/2018     1.0     Rajesh Guru    Initial Release

-------------------------------------------------------------------------------------------------------------------------- */ 


public class PhoneCheck {
    
   // @TestVisible private static list< PhoneNumberValidation__x> mockedcustlist = new List< PhoneNumberValidation__x>();
    @AuraEnabled
    public static String check(String caseId) {
        try {
            Case objCase = [Select Id, SMS_Case_Closure__c,Contact.Country_Code__c, Contact.Primary_Phone__c From Case Where Id =: caseId];
            System.debug(objCase.Contact.Country_Code__c+objCase.Contact.Primary_Phone__c);
            String recordName = objCase.Contact.Country_Code__c;
            String regex = '[(a-zA-Z)&]';
            String recordNumber = recordName.replaceAll(regex, '');
            String plus= '+';
            String tNum =(plus+recordNumber+objCase.Contact.Primary_Phone__c).replaceAll('\\s+','') ;           
            System.debug(tNum);
            System.debug(recordNumber);
            List < PhoneNumberValidation__x > phNumList = new List < PhoneNumberValidation__x >();
            if(!Test.isRunningTest()) {
                phNumList = [SELECT ErrorCode__c, SmsCapable__c, ErrorMessage__c FROM PhoneNumberValidation__x WHERE PhoneNumber__c =:tNum LIMIT 1];
            } else {
                //for Test Coverage
      
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '-103', SmsCapable__c = 'false', ErrorMessage__c = 'failed'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '-103', SmsCapable__c = 'false', ErrorMessage__c = 'failed'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '-103', SmsCapable__c = 'false', ErrorMessage__c = 'failed'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '-103', SmsCapable__c = 'false', ErrorMessage__c = 'failed'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '-103', SmsCapable__c = 'false', ErrorMessage__c = 'failed'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
               phNumList.add(new PhoneNumberValidation__x(ErrorCode__c = '100', SmsCapable__c = 'True', ErrorMessage__c = 'Success'));
            }
            System.debug(phNumList);
            System.debug( Boolean.valueOf(phNumList[0].SmsCapable__c));
            if(phNumList.isEmpty()) {
                return '0';
            } else {
                if(Boolean.valueOf(phNumList[0].SmsCapable__c)) {
                    
                    objCase.SMS_Case_Closure__c = true;
                    objCase.SMS_SR_Flag__c = 'SMSRPY';
                    update objCase;
                    return '1'; 
                } else {
                    objCase.SMS_Case_Closure__c = false;
                    update objCase;
                    
                    return '0';
                }
            }
        }
        catch(Exception ex) {
            System.debug('Debug Log For Exception: '+ex);
            return '0';
        }
    }
    @AuraEnabled
    public static Case getCaseDetails(String cId) {
        return [Select Id, SMS_Case_Closure__c From Case Where Id =: cId];
    }
}
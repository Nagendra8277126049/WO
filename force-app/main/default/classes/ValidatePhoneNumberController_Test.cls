/*--------------------------------------------------------------------------------------------------------------------------
Name:         ValidatePhoneNumberController_Test
Description:  Test Class for ValidatePhoneNumberController Class - Story #4623476
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author              Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
03/29/2017     1.0         Carpio Rodrigo       Initial Release
03/29/2017     1.0         Harsha Reddy         Initial Release
05/24/2018     1.1         Bikram Bebarta       
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class ValidatePhoneNumberController_Test {

    @testSetup static void setup() 
    {
        List < Account > accListList = DispatchTestSetupData.createAccountList();
        List < Asset > assetList = DispatchTestSetupData.createAssetList(accListList[0].id);
        List < Contact > conlist = DispatchTestSetupData.createContactList(accListList[0].id);
        List < Case > caselist = DispatchTestSetupData.createCaseList(accListList[0].id, assetList[0].id, conlist[0].id);
        List < WorkOrder > workOrderList = DispatchTestSetupData.createworkorderList(accListList[0].id, assetList[0].id, conlist[0].id, caselist[0].id);
        List < WorkOrderLineItem > workorderItemList = DispatchTestSetupData.createworkorderListItem(workOrderList[0].id, 'APS');    
    }
    
    public static  testMethod void validateForMessagingTestMethod()
    {
    Contact c=[Select Id,Primary_Phone__c from Contact where Country_Code__c ='Bermuda (441)' limit 1];
    c.Primary_Phone__c='9148043976';
    c.Primary_Phone_Type__c='Mobile';
    c.Country_Code__c ='USA & Canada (1)';
    update c;
   WorkOrder w =  [Select Id from WorkOrder where  ContactId=:c.id limit 1];
   
   WorkOrder w1 =[Select Id from WorkOrder where AddressBUID__c ='3696' limit 1];
     w1.AdditionalContactId__c= c.id;
     update w1;
    test.starttest();
    
   ValidatePhoneNumberController.validateForMessaging(w.id,true,'SMS & Email');
    ValidatePhoneNumberController.validateForMessaging(w.id,true,'email');
     ValidatePhoneNumberController.validateForMessaging(w1.id,false,'SMS & Email');
      ValidatePhoneNumberController.validateForMessaging(w1.id,false,'email');
      validatePhoneNUmberController.validateForMessaging(w.id,true,'SMS');
      validatePhoneNUmberController.validateForMessaging(w1.id,false,'SMS');
      
      validatePhoneNUmberController.fetchWorkOrderAndPicklistValues(w.id);
      validatePhoneNumberController.updatePrimaryContactAlertToNull (w.id);
      validatePhoneNUmberController.updateAdditContactAlertToNull (w.id);
   
    }
    
    public static  testMethod void validateForMessagingTestMethodfornull()
    {
    Contact c=[Select Id,Primary_Phone__c from Contact where Country_Code__c ='Bermuda (441)' limit 1];
    c.email='no-email@dell.com';
    update c;
   WorkOrder w =  [Select Id from WorkOrder where  ContactId=:c.id limit 1];
   
   WorkOrder w1 =[Select Id from WorkOrder where AddressBUID__c ='3696' limit 1];
     w1.AdditionalContactId__c= c.id;
     update w1;
    test.starttest();
    
   ValidatePhoneNumberController.validateForMessaging(w.id,true,'SMS & Email');
    ValidatePhoneNumberController.validateForMessaging(w.id,true,'email');
     ValidatePhoneNumberController.validateForMessaging(w1.id,false,'SMS & Email');
      ValidatePhoneNumberController.validateForMessaging(w1.id,false,'email');
     
   
    }
    
    public static  testMethod void validateForMessagingTestMethodforPrimaryPhone()
    {
    Contact c=[Select Id,Primary_Phone__c from Contact where Country_Code__c ='Bermuda (441)' limit 1];
    
    
   WorkOrder w =  [Select Id from WorkOrder where  ContactId=:c.id limit 1];
   
   WorkOrder w1 =[Select Id from WorkOrder where AddressBUID__c ='3696' limit 1];
     w1.AdditionalContactId__c= c.id;
     update w1;
    test.starttest();
    
   ValidatePhoneNumberController.validateForMessaging(w.id,true,'SMS & Email');
    ValidatePhoneNumberController.validateForMessaging(w.id,true,'SMS');
     ValidatePhoneNumberController.validateForMessaging(w1.id,false,'SMS & Email');
      ValidatePhoneNumberController.validateForMessaging(w1.id,false,'SMS');
     
   
    }
    
    public static  testMethod void validateForMessagingTestMethod1()
    {
    Contact c=[Select Id,Primary_Phone__c from Contact where Country_Code__c ='Bermuda (441)' limit 1];
    c.Primary_Phone__c='9148043976';
    c.Primary_Phone_Type__c='Mobile';
    c.Country_Code__c ='Australia (61)';
    update c;
   WorkOrder w =  [Select Id from WorkOrder where  ContactId=:c.id limit 1];
   
   WorkOrder w1 =[Select Id from WorkOrder where AddressBUID__c ='3696' limit 1];
     w1.AdditionalContactId__c= c.id;
     update w1;
    test.starttest();
    
   ValidatePhoneNumberController.validateForMessaging(w.id,true,'SMS & Email');
    ValidatePhoneNumberController.validateForMessaging(w.id,true,'email');
     ValidatePhoneNumberController.validateForMessaging(w1.id,false,'SMS & Email');
      ValidatePhoneNumberController.validateForMessaging(w1.id,false,'email');
      validatePhoneNUmberController.validateForMessaging(w.id,true,'SMS');
      validatePhoneNUmberController.validateForMessaging(w1.id,false,'SMS');
      
      validatePhoneNUmberController.fetchWorkOrderAndPicklistValues(w.id);
      validatePhoneNumberController.updatePrimaryContactAlertToNull (w.id);
      validatePhoneNUmberController.updateAdditContactAlertToNull (w.id);
   
    }
    
    public static  testMethod void validateForMessagingTestMethod2()
    {
    Contact c=[Select Id,Primary_Phone__c from Contact where Country_Code__c ='Bermuda (441)' limit 1];
    c.Primary_Phone__c='9148043976';
    c.Primary_Phone_Type__c='Mobile';
    c.Country_Code__c ='India (91)';
    update c;
   WorkOrder w =  [Select Id from WorkOrder where  ContactId=:c.id limit 1];
   
   WorkOrder w1 =[Select Id from WorkOrder where AddressBUID__c ='3696' limit 1];
     w1.AdditionalContactId__c= c.id;
     update w1;
    test.starttest();
    
   ValidatePhoneNumberController.validateForMessaging(w.id,true,'SMS & Email');
    ValidatePhoneNumberController.validateForMessaging(w.id,true,'email');
     ValidatePhoneNumberController.validateForMessaging(w1.id,false,'SMS & Email');
      ValidatePhoneNumberController.validateForMessaging(w1.id,false,'email');
      validatePhoneNUmberController.validateForMessaging(w.id,true,'SMS');
      validatePhoneNUmberController.validateForMessaging(w1.id,false,'SMS');
      
      validatePhoneNUmberController.fetchWorkOrderAndPicklistValues(w.id);
      validatePhoneNumberController.updatePrimaryContactAlertToNull (w.id);
      validatePhoneNUmberController.updateAdditContactAlertToNull (w.id);
   
    }
    
    
}
/* -----------------------------------------------------------------------------------------------------------------------
Name:         Service1CommonUlitity_Test.apx
Description:  Test Call for Service1CommonUlitity.apx 
      
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author                 Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/03/2017     1.0        Farhan Yakkalur        Initial Release
01/09/2018     1.1        Surya Subramanian      Changes are based on Code Review Defect 4378242
01/17/2018     1.2     	  Surya Subramanian   	 Changes are based on Code Review Defect 4561213
01/22/2018     1.3     	  Surya Subramanian   	 Changes are based on SRVS_CreateTestDataFactory Class
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class Service1CommonUlitity_Test {
    
    private static User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
    
    @isTest
    private static void Service1CommunityUtility(){
        System.RunAs(u){
            Test.StartTest();
            Service1CommonUlitity scu=new Service1CommonUlitity();
            sObject sobj = new Lead();
        
            Service1CommonUlitity.getSelectOptions(sobj,'LeadSource');
            Service1CommonUlitity.getSelectOptions(sobj,'Test_Field__c');   
            scu.getSelectOptionValues(Lead.LeadSource.getDescribe());
            Test.StopTest();
            System.AssertEquals(null, Service1CommonUlitity.getSelectOptions(sobj,'Test_Field__c'));
            
        }
        
    }
    
    @isTest
    private static void sendApiRequestException(){
        System.RunAs(u){
            Test.StartTest();
           
            //Test.setMock(HttpCalloutMock.class,new Service1CommunityUlitityMock());
            Service1CommonUlitity scu = new Service1CommonUlitity();
            string res='{"serviceTag":"MyAsset","firstName":"John","lastName":"Smith","email":"John@sm.com","areaCode":"CA","countryCode":"12234","extension":"9089898765","phoneNumber":"9090909090","addressType":"CA","secondaryFirstName":"Micheal","secondaryLastName":"Steve","secondaryEmail":"Steve@oc.com","secondaryAreaCode":"CAS","secondaryCountryCode":"DAD","secondaryExtension":"123456789","secondaryPhoneNumber":"9898989898","secondaryAddressType":"Current","tertiaryFirstName":"Bob","tertiaryLastName":"Steve","tertiaryEmail":"bob@re.com","tertiaryAreaCode":"78788","tertiaryCountryCode":"87877","tertiaryExtension":"8989898989","tertiaryPhoneNumber":"7898990871","tertiaryAddressType":"Current"}';
            scu.sendAPIRequest('callout:AssetContactDetails',res,'POST', assetContactDetailsJSON.class); 
            Test.StopTest();
            System.AssertEquals(null, scu.sendAPIRequest('callout:AssetContactDetails',res,'POST', assetContactDetailsJSON.class)); 
        }
    }
    
    @isTest
    private static void sendApiRequest(){
        System.RunAs(u){
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class,new Service1CommunityUlitityMock());
            Service1CommonUlitity scu = new Service1CommonUlitity();
            string res='{"serviceTag":"MyAsset","firstName":"John","lastName":"Smith","email":"John@sm.com","areaCode":"CA","countryCode":"12234","extension":"9089898765","phoneNumber":"9090909090","addressType":"CA","secondaryFirstName":"Micheal","secondaryLastName":"Steve","secondaryEmail":"Steve@oc.com","secondaryAreaCode":"CAS","secondaryCountryCode":"DAD","secondaryExtension":"123456789","secondaryPhoneNumber":"9898989898","secondaryAddressType":"Current","tertiaryFirstName":"Bob","tertiaryLastName":"Steve","tertiaryEmail":"bob@re.com","tertiaryAreaCode":"78788","tertiaryCountryCode":"87877","tertiaryExtension":"8989898989","tertiaryPhoneNumber":"7898990871","tertiaryAddressType":"Current"}';
            scu.sendAPIRequest('callout:AssetContactDetails',res,'POST', assetContactDetailsJSON.class); 
            Test.StopTest();
           // System.AssertNotEquals(null, scu.sendAPIRequest('callout:AssetContactDetails',res,'POST', assetContactDetailsJSON.class)); 
        }
    }
   
   
    //negative testing
    @isTest
    private static void sendApiRequestNegative(){
        
        System.RunAs(u){
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class,new Service1CommunityUlitityNegativeMock());
            Service1CommonUlitity scu = new Service1CommonUlitity();
            string res='{"serviceTag":"MyAsset","firstName":"John","lastName":"Smith","email":"John@sm.com","areaCode":"CA","countryCode":"12234","extension":"9089898765","phoneNumber":"9090909090","addressType":"CA","secondaryFirstName":"Micheal","secondaryLastName":"Steve","secondaryEmail":"Steve@oc.com","secondaryAreaCode":"CAS","secondaryCountryCode":"DAD","secondaryExtension":"123456789","secondaryPhoneNumber":"9898989898","secondaryAddressType":"Current","tertiaryFirstName":"Bob","tertiaryLastName":"Steve","tertiaryEmail":"bob@re.com","tertiaryAreaCode":"78788","tertiaryCountryCode":"87877","tertiaryExtension":"8989898989","tertiaryPhoneNumber":"7898990871","tertiaryAddressType":"Current"}';
            scu.sendAPIRequest('callout:AssetContactDetails',res,'POST', assetContactDetailsJSON.class); 
            Test.StopTest();    
            System.AssertEquals(null, scu.sendAPIRequest('callout:AssetContactDetails',res,'POST', assetContactDetailsJSON.class)); 
        
        }
    }    
    
    //for negative testing
    public class Service1CommunityUlitityNegativeMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            
            System.assertEquals('callout:AssetContactDetails', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
        
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string res2='{"serviceTag":"MyAsset","firstName":"John","lastName":"Smith","email":"John@sm.com","areaCode":"CA","countryCode":"12234","extension":"9089898765","phoneNumber":"9090909090","addressType":"CA","secondaryFirstName":"Micheal","secondaryLastName":"Steve","secondaryEmail":"Steve@oc.com","secondaryAreaCode":"CAS","secondaryCountryCode":"DAD","secondaryExtension":"123456789","secondaryPhoneNumber":"9898989898","secondaryAddressType":"Current","tertiaryFirstName":"Bob","tertiaryLastName":"Steve","tertiaryEmail":"bob@re.com","tertiaryAreaCode":"78788","tertiaryCountryCode":"87877","tertiaryExtension":"8989898989","tertiaryPhoneNumber":"7898990871","tertiaryAddressType":"Current"}';
            res.setBody(res2);
            res.setStatusCode(400);
            return res;
        }
    }
   
    public class Service1CommunityUlitityMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            System.assertEquals('callout:AssetContactDetails', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
        
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string res2='{"serviceTag":"MyAsset","firstName":"John","lastName":"Smith","email":"John@sm.com","areaCode":"CA","countryCode":"12234","extension":"9089898765","phoneNumber":"9090909090","addressType":"CA","secondaryFirstName":"Micheal","secondaryLastName":"Steve","secondaryEmail":"Steve@oc.com","secondaryAreaCode":"CAS","secondaryCountryCode":"DAD","secondaryExtension":"123456789","secondaryPhoneNumber":"9898989898","secondaryAddressType":"Current","tertiaryFirstName":"Bob","tertiaryLastName":"Steve","tertiaryEmail":"bob@re.com","tertiaryAreaCode":"78788","tertiaryCountryCode":"87877","tertiaryExtension":"8989898989","tertiaryPhoneNumber":"7898990871","tertiaryAddressType":"Current"}';
            res.setBody(res2);
            res.setStatusCode(200);
            return res;
        }
    }
    
    
}
/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetContactDetailsJSON_Test
Description:  Test class for AssetContactDetails_JSON class - Story #4150193
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author             		Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/17/2017     1.0         Mohammed Farhan          Initial Release
01/17/2018     1.1     	   Surya Subramanian    	Changes are based on Code Review Defect 4561213
01/22/2018     1.2     	   Surya Subramanian   	 	Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018     1.3     	   Sonia Sharaff	        Changes are based on defect 4561229
30/04/2018     1.1         Srikanth Parvathareddy   Story #4918471 - Contact Field Addition Due to BIL PCF Changes
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class AssetContactDetailsJSON_Test {
    
    private static User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
    
    @isTest
    private static void AssetContactDetailsJSON(){
        System.runAs(u) {
            Test.startTest();
            AssetContactDetailsJSON asssetContact=new AssetContactDetailsJSON();
            
            AssetContactDetailsJSON.AssetContactDetailsResponse assetConResp=new AssetContactDetailsJSON.AssetContactDetailsResponse();
            Test.stopTest();
            
            /******** Negative Case ***************/
            System.assertEquals(null,assetConResp.serviceTag);
            System.assertEquals(null,assetConResp.primaryfirstName);
            System.assertEquals(null,assetConResp.primarylastName);
            System.assertEquals(null,assetConResp.primaryemail);
        //    System.assertEquals(null,assetConResp.primaryareaCode);
            System.assertEquals(null,assetConResp.primarycountryCode);
            System.assertEquals(null,assetConResp.primaryextension);
            System.assertEquals(null,assetConResp.primaryphoneNumber);
            System.assertEquals(null,assetConResp.primaryaddressType);
            System.assertEquals(null,assetConResp.secondaryFirstName);
            System.assertEquals(null,assetConResp.secondaryLastName);
            System.assertEquals(null,assetConResp.secondaryEmail);
         //   System.assertEquals(null,assetConResp.secondaryAreaCode);
            System.assertEquals(null,assetConResp.secondaryCountryCode);
            System.assertEquals(null,assetConResp.secondaryExtension);
            System.assertEquals(null,assetConResp.secondaryPhoneNumber);
            System.assertEquals(null,assetConResp.secondaryAddressType);
            System.assertEquals(null,assetConResp.tertiaryFirstName);
            System.assertEquals(null,assetConResp.tertiaryLastName);
            System.assertEquals(null,assetConResp.tertiaryEmail);
       //     System.assertEquals(null,assetConResp.tertiaryAreaCode);
            System.assertEquals(null,assetConResp.tertiaryCountryCode);
            System.assertEquals(null,assetConResp.tertiaryExtension);
            System.assertEquals(null,assetConResp.tertiaryPhoneNumber);
            System.assertEquals(null,assetConResp.tertiaryAddressType);
            
            /********** Positive Case **********************/
            assetConResp.serviceTag = 'Service tag 1';
            assetConResp.primaryfirstName = 'Sample name';
            assetConResp.primarylastName = 'Sample last name';
            assetConResp.primaryemail = 'test@gmail.com';
         //   assetConResp.primaryareaCode = '1234';
            assetConResp.primarycountryCode = '1234';
            assetConResp.primaryextension = '0987';
            assetConResp.primaryphoneNumber = '1234567890';
            assetConResp.primaryaddressType = 'Permenent';
            assetConResp.secondaryFirstName = 'Sec first name';
            assetConResp.secondaryLastName = 'Sec Last Name';
            assetConResp.secondaryEmail = 'secTestmail@gmail.com';
          //  assetConResp.secondaryAreaCode = 's1234';
            assetConResp.secondaryCountryCode = 's12345';
            assetConResp.secondaryExtension = 'sExtn1234';
            assetConResp.secondaryPhoneNumber = '9087654321';
            assetConResp.secondaryAddressType = 'Present';
            assetConResp.tertiaryFirstName = 'T Frist Name';
            assetConResp.tertiaryLastName = 'T Last Name';
            assetConResp.tertiaryEmail = 'testMail 1';
         //   assetConResp.tertiaryAreaCode = 'territory1234';
            assetConResp.tertiaryCountryCode = 't1234';
            assetConResp.tertiaryExtension = 'tExt1234';
            assetConResp.tertiaryPhoneNumber = '8907654321';
            
            System.assertEquals('Service tag 1',assetConResp.serviceTag);
            System.assertEquals('Sample name',assetConResp.primaryfirstName);
            System.assertEquals('Sample last name',assetConResp.primarylastName);
            System.assertEquals('test@gmail.com',assetConResp.primaryemail);
         //   System.assertEquals('1234',assetConResp.primaryareaCode);
            System.assertEquals('1234',assetConResp.primarycountryCode);
            System.assertEquals('0987',assetConResp.primaryextension);
            System.assertEquals('1234567890',assetConResp.primaryphoneNumber);
            System.assertEquals('Permenent',assetConResp.primaryaddressType);
            System.assertEquals('Sec first name',assetConResp.secondaryFirstName);
            System.assertEquals('Sec Last Name',assetConResp.secondaryLastName);
            System.assertEquals('secTestmail@gmail.com',assetConResp.secondaryEmail);
         //   System.assertEquals('s1234',assetConResp.secondaryAreaCode);
            System.assertEquals('s12345',assetConResp.secondaryCountryCode);
            System.assertEquals('sExtn1234',assetConResp.secondaryExtension);
            System.assertEquals('9087654321',assetConResp.secondaryPhoneNumber);
            System.assertEquals('Present',assetConResp.secondaryAddressType);
            System.assertEquals('T Frist Name',assetConResp.tertiaryFirstName);
            System.assertEquals('T Last Name',assetConResp.tertiaryLastName);
            System.assertEquals('testMail 1',assetConResp.tertiaryEmail);
         //   System.assertEquals('territory1234',assetConResp.tertiaryAreaCode);
            System.assertEquals('t1234',assetConResp.tertiaryCountryCode);
            System.assertEquals('tExt1234',assetConResp.tertiaryExtension);
            System.assertEquals('8907654321',assetConResp.tertiaryPhoneNumber);
            System.assertEquals(null,assetConResp.tertiaryAddressType);
        }
    }    
}
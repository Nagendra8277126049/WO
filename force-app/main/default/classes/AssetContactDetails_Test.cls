/* -----------------------------------------------------------------------------------------------------------------------
Name:         AssetContactDetails_Test.apx
Description:  Unit Test Class for AssetContactDetails Class
      
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author                 Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/30/2017     1.0        Farhan Yakkalur          Initial Release
01/09/2018     1.1        Surya Subramanian        Changes are based on Code Review Defect 4378242
01/22/2018     1.2     	  Sonia Sharaff   	       Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018     1.2     	  Sonia Sharaff	           Changes are based on defect 4561229
30/04/2018     1.3        Srikanth Parvathareddy   Story #4918471 - Contact Field Addition Due to BIL PCF Changes
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class AssetContactDetails_Test{
    private static Integer i;
    
    @testSetup
    private static void setupTestData() {
        Account acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert acnt;
        Contact c = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        c.Email='smith@jo.com';
        c.Phone='9090909090';
        c.Primary_Phone_Ext__c='9089898765';
        c.Primary_Phone__c = '9123456789';
        c.FirstName='Smith';
        insert c;
        Contact con = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email='rr@jo.com';
        con.Phone='97954909090';
        con.Primary_Phone__c = '9123456789';
        insert con;
        Asset ast = SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        insert ast;   
    }
    
    @isTest
    private static void getAssetContactDetailsFail_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.startTest();
            contact co=[select id from contact limit 1];
            AssetContactDetails.AssetContactDetailsWrapper details = AssetContactDetails.getAssetContactDetails(null);
			Test.stopTest();   
            system.assertEquals(details, null);            
        }
    } 
    
    @isTest
    private static void formatContactDetails_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.startTest();
            contact co=[select id from contact limit 1];
            assetContactDetailsJSON.AssetContactDetailsResponse assetConResp=new assetContactDetailsJSON.AssetContactDetailsResponse();
            
            assetConResp.serviceTag = 'Service tag 1';
            assetConResp.primaryfirstName = 'Sample name';
            assetConResp.primarylastName = 'Sample last name';
            assetConResp.primaryemail = 'test@gmail.com';
            //assetConResp.primaryareaCode = '1234';
            assetConResp.primarycountryCode = '1234';
            assetConResp.primaryextension = '0987';
            assetConResp.primaryphoneNumber = '1234567890';
            assetConResp.primaryaddressType = 'Permenent';
            assetConResp.secondaryFirstName = 'Sec first name';
            assetConResp.secondaryLastName = 'Sec Last Name';
            assetConResp.secondaryEmail = 'secTestmail@gmail.com';
            //assetConResp.secondaryAreaCode = 's1234';
            assetConResp.secondaryCountryCode = 's12345';
            assetConResp.secondaryExtension = 'sExtn1234';
            assetConResp.secondaryPhoneNumber = '9087654321';
            assetConResp.secondaryAddressType = 'Present';
            assetConResp.tertiaryFirstName = 'T Frist Name';
            assetConResp.tertiaryLastName = 'T Last Name';
            assetConResp.tertiaryEmail = 'testMail 1';
            //assetConResp.tertiaryAreaCode = 'territory1234';
            assetConResp.tertiaryCountryCode = 't1234';
            assetConResp.tertiaryExtension = 'tExt1234';
            assetConResp.tertiaryPhoneNumber = '8907654321';
            /*Defect #5174955
            assetConResp.PrimaryAssetPartyLocationId='4008039';
            assetConResp.PrimaryPartyLocationId='5492080';
            assetConResp.PrimaryPartyId='549208';
            assetConResp.PrimaryMiddleName='Test1';
            assetConResp.secondaryAssetPartyLocationId='629534288';
            assetConResp.secondaryPartyLocationId='629534';
            assetConResp.secondaryPartyId='6295';
            assetConResp.secondaryMiddleName='Test2';
            assetConResp.tertiaryAssetPartyLocationId='629534289';
            assetConResp.tertiaryPartyLocationId='629534';
            assetConResp.tertiaryPartyId='629';
            assetConResp.tertiaryMiddleName='Test3';
            assetConResp.PrimaryTitle='Title1';
            assetConResp.PrimaryDepartment='OLM';
            assetConResp.PrimaryOrganizationName='DELL';
            assetConResp.PrimaryLanguage='ENG';
            assetConResp.PrimaryAlternateContactName='CON1';
            assetConResp.PrimaryAlternateGivenName='NAME1';
            assetConResp.PrimaryAlternateMiddleName='MNAME1';
            assetConResp.PrimaryAlternateLastName='LNAME1';
            assetConResp.PrimaryPartyContactMethodIdEmail='TEST1@SFDC.COM';
            assetConResp.PrimaryPartyContactMethodIdPhone='678983939';
            assetConResp.secondaryTitle='Title2';
            assetConResp.secondaryDepartment='SRO';
            assetConResp.secondaryOrganizationName='DELL';
            assetConResp.secondaryLanguage='ENG';
            assetConResp.secondaryAlternateContactName='CON2';
            assetConResp.secondaryAlternateGivenName='NAME2';
            assetConResp.secondaryAlternateMiddleName='MNAME2';
            assetConResp.secondaryAlternateLastName='LNAME2';
            assetConResp.secondaryPartyContactMethodIdEmail='TEST2@SFDC.COM';
            assetConResp.secondaryPartyContactMethodIdPhone='67890202';
            assetConResp.tertiaryTitle='Title3';
            assetConResp.tertiaryDepartment='DRM';
            assetConResp.tertiaryOrganizationName='DELL';
            assetConResp.tertiaryLanguage='ENG';
            assetConResp.tertiaryAlternateContactName='CON3';
            assetConResp.tertiaryAlternateGivenName='NAME3';
            assetConResp.tertiaryAlternateMiddleName='MNAME2';
            assetConResp.tertiaryAlternateLastName='LNAME3';
            assetConResp.tertiaryPartyContactMethodIdEmail='TEST3@SFDC.COM';
            assetConResp.tertiaryPartyContactMethodIdPhone='77636373';
*/
            AssetContactDetails.AssetContactDetailsWrapper details = AssetContactDetails.formatContactDetails(assetConResp);
            AssetContactDetails.AssetContactDetailsWrapper detailsNull = AssetContactDetails.formatContactDetails(null);
			Test.stopTest();   
           system.assertNotEquals(details,null);            
        }
    } 
    
    private static testMethod void updateAssetContact_test(){
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u) {
            Test.startTest();
            Contact c1=[select FirstName from Contact where FirstName='Smith'];
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
            calloutFromTest();
            Test.stopTest(); 
            System.AssertEquals(c1.FirstName, 'Smith');    
            
        }
    }
    
    //end of update contact test method.
    
    @isTest
    private static void blankConditions_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
                Contact c3=[select FirstName,LastNAme,Primary_Phone_Ext__c,Phone,Email from Contact where Phone='97954909090'];

        system.runAs(u7){
            Test.startTest();
            string phone = AssetContactDetails.formatPhoneNumber('US', /*null,*/ null);
            string request = AssetContactDetails.formatRequest('+1', 'TESTTAG', 'test', 'test',/*'512',*/ '1234567', null, 'test@test.com', null,'6789054','65400','654','TestName',
                                                                'Title1','SRO','DELL','ENG','CON1','name1','mname1','lname1','null','null');
            string request2 = AssetContactDetails.formatRequest(null, null, null, null,/*'512',*/ '1234567', null, 'test@test.com', null ,'679034','78906','5678','TestMname',
                                                                'null','null','DELL','null','null','name1','mname1','lname1','null','null');
			string request3=AssetContactDetails.formatRequest('Primary','myAsset',c3.FirstNAme,c3.LastNAme, /*'469',*/'7835672','IN','hk@sfdc.com','IN','67899','546788','3456','tname2',
                                                    'Title2','OIM','DELL','RUS','CON2','name2','mname2','lname2','Test2@sfdc.com','736378404'); 
            string request4=AssetContactDetails.formatRequest('Primary','Service Tag','sFirstName','sLastName',/*null,*/ null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
            Test.stopTest();   
            System.AssertNotEquals(phone, ''); 
        }
    }
    
    @future (Callout = true)
    Private Static void calloutFromTest(){
        
        Id ast_Id=[select Id from Asset Limit 1].ID;
        Contact c2=[select FirstName,LastNAme,Primary_Phone_Ext__c,Phone,Email from Contact where FirstName='Smith'];
        Contact c3=[select FirstName,LastNAme,Primary_Phone_Ext__c,Phone,Email from Contact where Phone='97954909090'];
        
        
        AssetContactDetails.getAssetContactDetails(ast_Id);        
        AssetContactDetails.formatPhoneNumber('IN',/* '+91',*/ '9098908990');
     
        
        i = AssetContactDetails.updateAssetContact('1234','myAsset',c2.FirstNAme,c2.LastNAme,/*c2.Primary_Phone_Ext__c,*/c2.Phone,'Primary',c2.Email,'IN','789045','23456','123','Tname',
                                                    'Title1','SRO','DELL','ENG','CON1','name1','mname1','lname1','TEST@SFDC.COM','977633383');
       
        i = AssetContactDetails.updateAssetContact('1234','myAsset',c3.FirstNAme,c3.LastNAme,/* c3.Primary_Phone_Ext__c,*/c3.Phone,'Primary',null,'IN','67899','546788','3456','tname2',
                                                    'Title2','OIM','DELL','RUS','CON2','name2','mname2','lname2','Test2@sfdc.com','736378404');  
   		i = AssetContactDetails.updateAssetContact('Primary','myAsset',c3.FirstNAme,c3.LastNAme, /*'469',*/'7835672','IN','hk@sfdc.com','IN','67899','546788','3456','tname2',
                                                    'Title2','OIM','DELL','RUS','CON2','name2','mname2','lname2','Test2@sfdc.com','736378404'); 
   		i = AssetContactDetails.updateAssetContact('Primary','myAsset',c3.FirstNAme,c3.LastNAme, /*null,*/'6789765',null,null,null,null,null,null,null,
                                                    null,null,null,null,null,null,null,null,null,null);
   
    }
    
    Public class Service1CommonAPIUlitityMock implements HttpCalloutMock{        
        Public HttpResponse respond(HttpRequest req){
            //System.debug('Calling the fake response------------>'+req);
                        
            System.assertEquals((req.getEndpoint() == 'callout:AssetContactDetails' || req.getEndpoint() == 'callout:AssetContactUpdate'), true);
            System.assertEquals('POST', req.getMethod());
        
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //string res2='{"MessageHeader":  {"ReturnMessaging":  {"Code":  "100","Message":  "Operation completed successfully","Type": "SUCCESS","Details": "Operation successful."}}"PrimaryAssetPartyLocationId": "29150694","PrimaryPartyLocationId": "2918062","PrimaryPartyId": "2918062","PrimaryPartyContactMethodIdEmail": "2918062","PrimaryPartyContactMethodIdPhone": "2918062","SecondaryAssetPartyLocationId": "2918062","SecondaryPartyId": "2918062","SecondaryPartyContactMethodIdEmail": "2918062","SecondaryPartyContactMethodIdPhone": "2918062","TertiaryAssetPartyLocationId": "2918062","TertiaryPartyLocationId": "2918062","TertiaryPartyId": "2918062","TertiaryPartyContactMethodIdEmail": "2918062","TertiaryPartyContactMethodIdPhone": "2918062"}';
            string res2='{"MessageHeader":{"ReturnMessaging":{"Code":"100","Message":"OperationCompletedSuccessfully","Type":"SUCCESS","Details":null}},"AssetContactDetails":{"ServiceTag":"R31V015","PrimaryFirstName":"Sunil","PrimaryLastName":"神奈川県神奈川県","PrimaryEmail":"noemail@noemail.com","PrimaryCountryCode":"001","PrimaryExtension":null,"PrimaryPhoneNumber":"1111111","PrimaryAddressType":"InstallAt","SecondaryFirstName":"神奈川県川崎市幸区","SecondaryLastName":"神奈川県川崎市幸区","SecondaryEmail":"no-email@dell.com","SecondaryCountryCode":"811","SecondaryExtension":null,"SecondaryPhoneNumber":"3884000","SecondaryAddressType":"InstallAt","TertiaryFirstName":"神奈川県川崎市幸","TertiaryLastName":"神奈川県川崎市幸区","TertiaryEmail":"no-email@dell.com","TertiaryCountryCode":"816","TertiaryExtension":null,"TertiaryPhoneNumber":"1234567","TertiaryAddressType":"InstallAt"}}';
            //string res2='AssetContactDetailsJSON:{assetContactDetails=AssetContactDetailsResponse:{primaryaddressType=InstallAt,primarycountryCode=001,primaryemail=noemail@noemail.com,primaryextension=null,primaryfirstName=Sunil,primarylastName=神奈川県神奈川県,primaryphoneNumber=1111111,secondaryAddressType=InstallAt,secondaryCountryCode=811,secondaryEmail=no-email@dell.com,secondaryExtension=null,secondaryFirstName=神奈川県川崎市幸区,secondaryLastName=神奈川県川崎市幸区,secondaryPhoneNumber=3884000,serviceTag=R31V015,tertiaryAddressType=InstallAt,tertiaryCountryCode=816,tertiaryEmail=no-email@dell.com,tertiaryExtension=null,tertiaryFirstName=神奈川県川崎市幸,tertiaryLastName=神奈川県川崎市幸区,tertiaryPhoneNumber=1234567},messageHeader=CommonMessageHeader:{ReturnMessaging=CommonReturnMessaging:{code=100,details=null,message=OperationCompletedSuccessfully,type=SUCCESS}}}';
            res.setBody(res2);
            res.setStatusCode(200);
            return res;
        } 
    }
    
  

}//end of test class.
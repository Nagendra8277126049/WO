/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetAddressLocationUpdate_Test
Description:  This class contain the test method for AssetAddressLocationUpdate to validate coverage - story #4316381
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/30/2018     1.0    Rodrigo Carpio       Initial Release
06/11/2018     1.1    Sri Harsha G         DEFECT 5149770
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class AssetAddressLocationUpdate_Test {
    
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static User u;
    private static Contact con;
    private static WorkOrder wo;
    private static WorkOrder wo2;
    private static Product2 prd;
    
    private static void setupTestData() {
        
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        /*u = new User(Alias = 'auser', Email='adminuser@dell.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='44550977', External_ID__c='44550977',
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName, OSP__c='No');
        insert u; */
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
     
        //create a test account
        acnt= new Account(Name = 'Test Company',Industry='Fashion',Type='Customer',AccountNumber='1234567890',BUID__c='99');
        insert acnt;
        
        //create a new product
        prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV',LOB_Description__c='AH129');
        insert prd;
        
        //create a test asset
        ast = new Asset(Name='Test Asset',Status='Installed',AccountId=acnt.Id,Product2Id=prd.Id,InstallDate = System.Today(),UsageEndDate = System.Today());
        insert ast;
        
        //create a test contact
        con = new Contact(Email='testtag@test.com',firstname='firstname',LastName='testtag',Accountid=acnt.id, country_code__c= 'USA & Canada (1)', Primary_Phone__c='1234567890');
        insert con;
        
        //create a test case
        cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id,ContactId=con.Id,NonAgentContactEmail__c='testtag@test.com',
                        NonAgentContactFirstName__c='firstname',NonAgentContactLastName__c='testtag',NonAgentContactPhone__c='800-123-4567');
        insert cse;
        
        string lineAddress = '';
        lineAddress = lineAddress + 'line 1\n\r';
        lineAddress = lineAddress + 'line 2\n\r';
        lineAddress = lineAddress + 'line 3\n\r';
        lineAddress = lineAddress + 'line 4';
        
        //create a test work Order
        wo = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=con.id,caseId=cse.id,AdditionalContactId__c=con.id,subject='test',Street=lineAddress,city='Round Rock',
                            StateCode='TX',PostalCode='78664',CountryCode='US',AssetPartyLocationId__c='partyid',PartyLocationId__c='locationid');
        insert wo;
        
        wo2 = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=con.id,caseId=cse.id,AdditionalContactId__c=con.id,subject='test',
                             Street=lineAddress,city='Porto Alegre',Address_Line_1__c = 'line 1', Address_Line_2__c = 'line 2', Address_Line_3__c = 'line 3 ', Address_Line_4__c='line 4',
                            StateCode='RS',PostalCode='910000',CountryCode='BR',AssetPartyLocationId__c='partyid',PartyLocationId__c='locationid');
        insert wo2;
    }
    @isTest
    private static void updateAssetAddressLocation_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list <string> idWO = new list<string>();
            idWO.add(wo.id);
            List<string> assetId = new List<string>();
            assetId = AssetAddressLocationUpdate.updateAssetAddressLocation(idWO);
            Test.stopTest();   
            system.assertEquals(assetId, null);            
        }
    } 
    @isTest
    private static void updateAssetAddressLocation2_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            list <string> idWO = new list<string>();
            idWO.add(wo2.id);
            List<string> assetId = new List<string>();
            assetId = AssetAddressLocationUpdate.updateAssetAddressLocation(idWO);
            Test.stopTest();   
            system.assertEquals(assetId, null);            
        }
    }
    @isTest
    private static void updateAssetAddressLocationFails_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<string> assetId = new List<string>();
            assetId = AssetAddressLocationUpdate.updateAssetAddressLocation(null);    
            Test.stopTest();   
            if(assetId != null && assetId.size()>0)
            	system.assertEquals(null,assetId);            
        }
    } 
}
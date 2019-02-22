/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetAddressLocation_Test
Description:  This class contain the test method for AssetAddressLocation to validate coverage - story #4316381
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/29/2018     1.0    Rodrigo Carpio       Initial Release
08/21/2018     1.1    Harsha Reddy         Updated Test Class - DEFECT 5503837
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class AssetAddressLocation_Test {
    private static AssetLocationResponse__x addrAsset;
    @testSetup
    private static void setupTestData() {

        //create a test account
        Account acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry = 'Fashion';
        acnt.Type = 'Customer';
        acnt.AccountNumber = '1234567890';
        acnt.BUID__c = '99';
        insert acnt;

        //create a test asset
        Asset ast = SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name = 'APNONT11';
        ast.UsageEndDate = System.Today();
        insert ast;

        //create a test contact
        contact con = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';
        con.Country_Code__c = 'USA & Canada (1)';
        con.Primary_Phone__c = '1234567890';
        con.accountid = acnt.id;
        insert con;

        //create a test LiveChatVisitor
        LiveChatVisitor visitor = SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;

        // create a LiveChatTranscript
        LiveChatTranscript lct = SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor, ast);
        insert lct;

        //create a test case
        Case cse = SRVS_CreateTestDataFactory.createSingleCase(ast.id, acnt.id, con.id);
        cse.subject = 'Test Controller Acct Case';
        cse.Service_Tag__c = 'APNONT11';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        cse.TranscriptId__c = lct.Id;
        insert cse;

        //create a test Product
        Product2 prd = new Product2();
        prd.ProductCode = 'AH129';
        prd.Name = 'AH129';
        prd.LOB_Code__c = 'AH129';
        prd.LOB_Description__c = 'AH129';
        prd.Description = 'AH129 TEST Product';

        insert prd;

        // create work Order
        WorkOrder wo = new WorkOrder();
        wo.AssetId = ast.id;
        wo.AccountId = acnt.id;
        wo.ContactId = con.id;
        wo.CaseId = cse.id;
        wo.Subject = 'test work order';

        insert wo;
        
        
    }

    @isTest
    private static void getAssetAddressLocation_Test() {
        User u7 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7) {
            Test.startTest();
            workorder wo = [select id from workorder limit 1];
            list < string > idWO = new list < string > ();
            idWO.add(wo.id);

            addrAsset = new AssetLocationResponse__x(
            AddressLine1__c = 'TESTTAG',
            AddressLine2__c = 'TESTTAG',
            AddressLine3__c = 'TESTTAG',
            AddressLine4__c = 'TESTTAG',
            City__c = 'TESTTAG',
            State__c = 'TESTTAG',
            Country__c = 'TESTTAG',
            PostalCode__c = 'TESTTAG',
            ResponseCode__c = '100',
            AssetPartyLocationId__c = 'TESTTAG',
            PartyLocationId__c = 'TESTTAG',
            BillingAddressLine1__c = 'TESTTAG',
            BillingAddressLine2__c = 'TESTTAG',
            BillingAddressLine3__c = 'TESTTAG',
            BillingAddressLine4__c = 'TESTTAG',
            BillingCity__c = 'TESTTAG',
            BillingState__c = 'TESTTAG',
            BillingCountry__c = 'TESTTAG',
            BillingPostalCode__c = 'TESTTAG');
             
            AssetAddressLocation.mockedAssetLocationRespnse.add(addrAsset);
            List < AssetAddressLocation.AssetAddressWrapper > assetId = AssetAddressLocation.getAssetAddressLocation(idWO);
            Test.stopTest();
            system.assertNotEquals(assetId, null);
        }
    }
    
     @isTest
    private static void getAssetAddressLocation2_Test() {
        User u7 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7) {
            Test.startTest();
            workorder wo = [select id from workorder limit 1];
            list < string > idWO = new list < string > ();
            idWO.add(wo.id);

            addrAsset = new AssetLocationResponse__x(
            AddressLine1__c = 'TESTTAG',
            AddressLine2__c = 'TESTTAG',
            AddressLine3__c = 'TESTTAG',
            AddressLine4__c = 'TESTTAG',
            City__c = 'TESTTAG',
            State__c = 'TESTTAG',
            Country__c = 'BR',
            PostalCode__c = 'TESTTAG',
            ResponseCode__c = '100',
            AssetPartyLocationId__c = 'TESTTAG',
            PartyLocationId__c = 'TESTTAG',
            BillingAddressLine1__c = 'TESTTAG',
            BillingAddressLine2__c = 'TESTTAG',
            BillingAddressLine3__c = 'TESTTAG',
            BillingAddressLine4__c = 'TESTTAG',
            BillingCity__c = 'TESTTAG',
            BillingState__c = 'TESTTAG',
            BillingCountry__c = 'TESTTAG',
            BillingPostalCode__c = 'TESTTAG');
             
            AssetAddressLocation.mockedAssetLocationRespnse.add(addrAsset);
            List < AssetAddressLocation.AssetAddressWrapper > assetId = AssetAddressLocation.getAssetAddressLocation(idWO);
            Test.stopTest();
            system.assertNotEquals(assetId, null);
        }
    }

    @isTest
    private static void assetAddressLocationFails_Test() {
        User u7 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7) {
            Test.startTest();
            workorder wo = [select id from workorder limit 1];
            List < AssetAddressLocation.AssetAddressWrapper > assetId = AssetAddressLocation.getAssetAddressLocation(null);
            Test.stopTest();
            system.assertEquals(null, assetId);
        }
    }

    @isTest
    private static void assetAddressLocation1_Test() {
        User u7 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7) {
            Test.startTest();
            workorder wo = [select id from workorder limit 1];
            list < string > idWO = new list < string > ();
            idWO.add(wo.id);
            List < AssetAddressLocation.AssetAddressWrapper > assetId = AssetAddressLocation.getAssetAddressLocation(idWO);
            Test.stopTest();
           // system.assert(assetId.isEmpty());
        }
    }
}
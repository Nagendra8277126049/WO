/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssociateServiceTagHandler_Test
Description:  This test class for AssociateServiceTagHandler #4640778
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/08/2018     1.0     Rodrigo Carpio      Initial Release
03/14/2018     1.1     Roselin Hephzibah   Updated to cover populateAssetNumber methods
05/14/2018     1.2     Surya               Updated to cover assetUpdatePB method
05/24/2018     1.3     Surya               Changes are based on Defect 5113822
07/27/2018	   1.4	   Surya			   Added MapAssetToCase_Test method to increase the code coverage - Defect : 5374440
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class AssociateServiceTagHandler_Test {
    // This method creates the test data 
    @testSetup
    private static void setupTestData() {
     
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test Product
        Product2 p=SRVS_CreateTestDataFactory.createProduct2();
        p.Product_Identifier__c='S360';
        p.External_Id__c = 'AH129';
        insert p;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.Product2Id=p.Id;
        ast.UsageEndDate = System.Today();
        insert ast;       
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        con.Primary_Phone__c = '800-123-4567';
        insert con;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;
        
        LiveChatTranscript lct123=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        lct123.Asset__c=null;
        insert lct123;
        
        // create a LiveChatTranscript without Asset
        LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorId=visitor.Id);
        lct1.Asset__c=null;
        insert lct1;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.AssetId=ast.id;
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        cse.TranscriptId__c = lct.Id;
        insert cse; 
        
        Case cse123=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse123.subject='Test Controller Acct Case';
        cse123.Service_Tag__c = 'TestCase123';
        cse123.AssetId=ast.id;
        cse123.NonAgentContactEmail__c = 'testtag@test.com';
        cse123.NonAgentContactFirstName__c = 'firstname';
        cse123.NonAgentContactLastName__c = 'testtag';
        cse123.NonAgentContactPhone__c = '800-123-4567';
        cse123.TranscriptId__c = lct123.Id;
        insert cse123; 
        
        Case cse1=SRVS_CreateTestDataFactory.createSingleCase(null,acnt.id,con.id);
        cse1.subject='Test Controller Acct Case';
        cse1.Service_Tag__c = 'Test Asset';
        cse1.AssetId=ast.id;
        cse1.NonAgentContactEmail__c = 'testtag@test.com';
        cse1.NonAgentContactFirstName__c = 'firstname';
        cse1.NonAgentContactLastName__c = 'testtag';
        cse1.NonAgentContactPhone__c = '800-123-4567';
        cse1.TranscriptId__c = lct.Id;
        insert cse1; 
            
        Case cse2=SRVS_CreateTestDataFactory.createSingleCase(null,acnt.id,con.id);
        cse2.subject='Test Case without Service Tag';
		cse2.Service_Tag__c = 'Test Asset';
        cse2.NonAgentContactEmail__c = 'testtag@test.com';
        cse2.NonAgentContactFirstName__c = 'firstname';
        cse2.NonAgentContactLastName__c = 'testtag';
        cse2.NonAgentContactPhone__c = '800-123-4567';
        cse2.TranscriptId__c = lct1.Id;
        insert cse2; 
        
       
    }
    
    /* This method tests service tag association to case */
    
    @isTest
    private static void associateServiceTagByCase_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
            Test.startTest();
            List<case> ce=[select id, AssetId, AccountId, ContactId from case limit 2];
            account ac=[select id from account limit 1];
            Product2 pr=[select id from Product2 limit 1];
            string assetId = AssociateServiceTagHandler.associateServiceTag(ce[0].Id);
            string assetId1 = AssociateServiceTagHandler.associateServiceTag(ce[1].Id);
            Test.stopTest();   
            system.assertNotEquals(assetId, null);
            
        }
    }   
    @isTest
    private static void associateServiceTagByCaseFails_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
            Test.startTest();
            case ce=[select id, AssetId, AccountId, ContactId from case limit 1];
            account ac=[select id from account limit 1];
            string assetId = AssociateServiceTagHandler.associateServiceTag(null);    
            Test.stopTest();   
            system.assertEquals(assetId, null);            
        }
    } 

    @isTest
    private static void performAPICall_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
            Test.startTest();
            case ce=[select id, Service_Tag__c, AssetId, AccountId, ContactId, NonAgentContactEmail__c, NonAgentContactFirstName__c, NonAgentContactLastName__c, NonAgentContactPhone__c, TranscriptId__c from case limit 1];
            BILAssetInformation bilAssetInfo = AssociateServiceTagHandler.performAPICall(ce.Service_Tag__c);     
            Test.stopTest();   
            system.assertNotEquals(bilAssetInfo, null);            
        }
    }
   @isTest
    private static void performAssetAssociation_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
            Test.startTest();
            case ce=[select id, Service_Tag__c, AssetId, AccountId, ContactId, NonAgentContactEmail__c, NonAgentContactFirstName__c, NonAgentContactLastName__c, NonAgentContactPhone__c, TranscriptId__c from case where Service_Tag__c='Test Asset' limit 1];
            //account ac=[select id from account limit 1];
            string res2='{    "asset": {"id": 1817040673,        "serviceTag": "80YJ0Z13",        "serialNumber": "CN0P19MV282984BF0066","manufacturerId": 1,        "manufacturerDescription": "DELL",        "expressServiceCode": "17472253357","customerBuid": 99,        "customerNumber": 1234567890,        "orderBuid": 11,"orderNumber": "771620347",        "tieNumber": 1,        "sourceSiteId": 1,"shipDate": "2015-02-13T00:00:00",        "productCode": "AH129",        "productDescription": "S SERIES,S6000,32PRT,AC,IO/PSU","productLineCode": "20519",        "productLineDescription": "FORCE 10 S SERIES",        "productLobCode": "4FO","productLobDescription": "Dell Networking",        "localChannel": "01",        "orderCompanyNumber": "01 ","tiedToAssetFlag": "N"    },"identifiers": { "content":[{"identifierTypeId": 92,"identifierTypeName": "EMC PSNT","identifierValue": "EMFVR164512825" }]} }';
            BILAssetInformation bilAssetInfo = (BILAssetInformation)JSON.deserialize(res2, BILAssetInformation.class);
            string assetId = (string) AssociateServiceTagHandler.performAssetAssociation(ce, bilAssetInfo);  
            Test.stopTest();
            system.assertNotEquals(null,assetId);
        }
    }
	
    @isTest
    private static void test_123(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
            Test.startTest();
            case ce=[select id, Service_Tag__c, AssetId, AccountId, ContactId, NonAgentContactEmail__c, NonAgentContactFirstName__c, NonAgentContactLastName__c, NonAgentContactPhone__c, TranscriptId__c from case where Service_Tag__c='TestCase123' limit 1];
            //account ac=[select id from account limit 1];
            string res2='{    "asset": {"id": 1817040673,        "serviceTag": "80YJ0Z13",        "serialNumber": "CN0P19MV282984BF0066","manufacturerId": 1,        "manufacturerDescription": "DELL",        "expressServiceCode": "17472253357","customerBuid": 99,        "customerNumber": 1234567890,        "orderBuid": 11,"orderNumber": "771620347",        "tieNumber": 1,        "sourceSiteId": 1,"shipDate": "2015-02-13T00:00:00",        "productCode": "AH129",        "productDescription": "S SERIES,S6000,32PRT,AC,IO/PSU","productLineCode": "20519",        "productLineDescription": "FORCE 10 S SERIES",        "productLobCode": "4FO","productLobDescription": "Dell Networking",        "localChannel": "01",        "orderCompanyNumber": "01 ","tiedToAssetFlag": "N"    },"identifiers": { "content":[{"identifierTypeId": 92,"identifierTypeName": "EMC PSNT","identifierValue": "EMFVR164512825" }]} }';
            BILAssetInformation bilAssetInfo = (BILAssetInformation)JSON.deserialize(res2, BILAssetInformation.class);
            string assetId = (string) AssociateServiceTagHandler.performAssetAssociation(ce, bilAssetInfo);  
            Test.stopTest();
            //system.assertNotEquals(null,assetId);
        }
    }
    
    @isTest
    private static void assetCreationFail_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.setMock(HttpCalloutMock.class, new Service1CommonAPIUlitityMock());
            Test.startTest();
            string res2='{    "asset": {"id": 1817040673,        "serviceTag": "80YJ0Z13",        "serialNumber": "CN0P19MV282984BF0066","manufacturerId": 1,        "manufacturerDescription": "DELL",        "expressServiceCode": "17472253357","customerBuid": 11,        "customerNumber": 60187476,        "orderBuid": 11,"orderNumber": "771620347",        "tieNumber": 1,        "sourceSiteId": 1,"shipDate": "2015-02-13T00:00:00",        "productCode": "AH129",        "productDescription": "S SERIES,S6000,32PRT,AC,IO/PSU","productLineCode": "20519",        "productLineDescription": "FORCE 10 S SERIES",        "productLobCode": "4FO","productLobDescription": "Dell Networking",        "localChannel": "01",        "orderCompanyNumber": "01 ","tiedToAssetFlag": "N"    },"identifiers": { "content":[{"identifierTypeId": 92,"identifierTypeName": "EMC PSNT","identifierValue": "EMFVR164512825" }]} }';
            BILAssetInformation bilAssetInfo = (BILAssetInformation)JSON.deserialize(res2, BILAssetInformation.class);
            contact co=[select id from contact limit 1];
            string assetId = AssociateServiceTagHandler.createAsset(bilAssetInfo, co.Id);
            Test.stopTest();   
            system.assertEquals(null, assetId);            
        }
    } 
    @isTest
    private static void performAssetAssociationFail_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.startTest();
            case ce=[select id, Service_Tag__c, AssetId, AccountId, ContactId, NonAgentContactEmail__c, NonAgentContactFirstName__c, NonAgentContactLastName__c, NonAgentContactPhone__c, TranscriptId__c from case limit 1];
            contact co=[select id from contact limit 1];
            string res2='{    "asset": {"id": 1817040673,        "serviceTag": "80YJ0Z13",        "serialNumber": "CN0P19MV282984BF0066","manufacturerId": 1,        "manufacturerDescription": "DELL",        "expressServiceCode": "17472253357","customerBuid": 11,        "customerNumber": 60187476,        "orderBuid": 11,"orderNumber": "771620347",        "tieNumber": 1,        "sourceSiteId": 1,"shipDate": "2015-02-13T00:00:00",        "productCode": "AH129",        "productDescription": "S SERIES,S6000,32PRT,AC,IO/PSU","productLineCode": "20519",        "productLineDescription": "FORCE 10 S SERIES",        "productLobCode": "4FO","productLobDescription": "Dell Networking",        "localChannel": "01",        "orderCompanyNumber": "01 ","tiedToAssetFlag": "N"    },"identifiers": { "content":[{"identifierTypeId": 92,"identifierTypeName": "EMC PSNT","identifierValue": "EMFVR164512825" }]} }';
            BILAssetInformation bilAssetInfo = (BILAssetInformation)JSON.deserialize(res2, BILAssetInformation.class);
            string assetId = (string) AssociateServiceTagHandler.performAssetAssociation(null, bilAssetInfo);     
            Test.stopTest();   
            system.assertEquals('AccountNA',assetId);            
        }
    }
    @isTest
    private static void contactCreationFail_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.startTest();
            string contactId = (string) AssociateServiceTagHandler.createContact(null);            
            Test.stopTest();   
            system.assertEquals(null,contactId);            
        }
    }
    @isTest
    private static void updateAssetinCase_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.startTest();
            case ce=[select id, AssetId, AccountId, ContactId, Service_Tag__c from case limit 1];
            AssociateServiceTagHandler.updateAssetinCase('Test Asset', ce.id);
            Test.stopTest();  
            System.assertNotEquals(null, ce.Service_Tag__c);          
        }
    }     
    @isTest
    private static void populateAssetNumber_Test(){
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
            Test.startTest();
            List<case> ce=[select id, AssetId, AccountId, ContactId, Service_Tag__c from case limit 2];
            for(Case c : ce){
                AssociateServiceTagHandler.populateAssetNumber(c.id);
                AssociateServiceTagHandler.populateAssetNumber(c.id);
            }
            Test.stopTest();  
            System.assertNotEquals(null, ce[0].Service_Tag__c);           
        }
    } 
    
    @isTest
    private static void assetUpdatePB_Test(){
        User u8=SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        system.runAs(u8){
            Test.startTest();
            List<case> ce=[select id, AssetId, AccountId, ContactId, Service_Tag__c from case limit 2];            
            AssociateServiceTagHandler.assetUpdatePB(ce);          
            Test.stopTest();  
            System.assertNotEquals(null, ce[0].Service_Tag__c);           
        }
    }
    
    /* To increase the Code coverage */
    @isTest
    private static void MapAssetToCase_Test(){
    	User u9=SRVS_CreateTestDataFactory.createUser('System Administrator');       
        system.runAs(u9){
         	Test.startTest();
            List<case> ce=[select id,subject, AssetId, AccountId, ContactId, Service_Tag__c from case where subject='Test Case without Service Tag' limit 1];     
            AssociateServiceTagHandler.MapAssetToCase(ce[0].id);
            Test.stopTest();
		            
        }
        
    }
    
    /* Generates the mock response */      
    Public class Service1CommonAPIUlitityMock implements HttpCalloutMock{        
        Public HttpResponse respond(HttpRequest req){
            System.assertEquals('GET', req.getMethod());
        
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string res2='{    "asset": {"id": 1817040673,        "serviceTag": "80YJ0Z13",        "serialNumber": "CN0P19MV282984BF0066","manufacturerId": 1,        "manufacturerDescription": "DELL",        "expressServiceCode": "17472253357","customerBuid": 11,        "customerNumber": 60187476,        "orderBuid": 11,"orderNumber": "771620347",        "tieNumber": 1,        "sourceSiteId": 1,"shipDate": "2015-02-13T00:00:00",        "productCode": "AH129",        "productDescription": "S SERIES,S6000,32PRT,AC,IO/PSU","productLineCode": "20519",        "productLineDescription": "FORCE 10 S SERIES",        "productLobCode": "4FO","productLobDescription": "Dell Networking",        "localChannel": "01",        "orderCompanyNumber": "01 ","tiedToAssetFlag": "N"    },"identifiers": { "content":[{"identifierTypeId": 92,"identifierTypeName": "EMC PSNT","identifierValue": "EMFVR164512825" }]} }';
            res.setBody(res2);
            res.setStatusCode(200);
            return res;
        } 
    }
}
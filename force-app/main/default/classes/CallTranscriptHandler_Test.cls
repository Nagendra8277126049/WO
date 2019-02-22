@isTest
public class CallTranscriptHandler_Test {
    
    @isTest
    private static void testCallTranscriptHandlerTest() {
        
        User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(objUser)
        {        
            Test.startTest();
            
            //create a test account
            Account objAccount= new Account(Name = 'Test Company', Industry='Fashion',Type='Customer',AccountNumber = '1234567890', BUID__c = '99',CCN__c='1231');
            insert objAccount;
            
            //create a test contact
            Contact objContact = new Contact(Email='testtag@test.com',firstname='firstname',LastName='testtag',Accountid=objAccount.id, country_code__c= 'USA & Canada (1)', Primary_Phone__c='1234567890');
            insert objContact;
            
             //create a new product
            Product2 objProduct = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV',LOB_Description__c='AH129');
            insert objProduct;
            
            Asset objAsset1 = new Asset(Name = 'Test Asset2',Product2Id = objProduct.Id, AccountId=objAccount.Id);
            insert objAsset1;
            
            Asset objAsset2 = new Asset(Name='Test Asset2',Product2Id = objProduct.Id, AccountId=objAccount.Id);
            insert objAsset2;
            
            //Create a test case
            Case objCase = new Case(Subject = 'Test Case', AccountId = objAccount.Id, AssetId = objAsset1.Id, ContactId = objContact.Id, NonAgentContactEmail__c='testtag@test.com',
                            NonAgentContactFirstName__c='firstname',NonAgentContactLastName__c='testtag',NonAgentContactPhone__c='800-123-4567');
            insert objCase;
            
            //Create a Call Transcript with Asset
            Call_Transcript__c objCallTranscript1 = new Call_Transcript__c(Asset__c=objAsset1.id, Name='Test Call Transript 1',Type__c ='Customer Inbound');
            insert objCallTranscript1;
            
            //Create a Call Transcript without Asset 
            Call_Transcript__c objCallTranscript2 = new Call_Transcript__c(Name='Test Call Transript 2', Type__c ='Customer Inbound');
            insert objCallTranscript2; 
            
            CallTranscriptHandler obj = new CallTranscriptHandler();
            
            List<Call_Transcript__c> lstCallTranscript = new List<Call_Transcript__c>();
            lstCallTranscript.add(objCallTranscript1);
            
            CallTranscriptHandler.handleCTAttrForAssetUpdate(objCallTranscript1.Id);
            
            CallTranscriptHandler.handleCTAttrForAssetUpdate(objCallTranscript2.Id);
            
            CallTranscriptHandler.CreateCTARec(lstCallTranscript);
                        
            Test.stopTest();
        }    
    }
}
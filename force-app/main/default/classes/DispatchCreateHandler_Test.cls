/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchCreateHandler_Test
Description:  This class contain the test method for DispatchCreateHandler to validate coverage - story #4316217
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/29/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private  class DispatchCreateHandler_Test {
    private static User u;
    private static Account acnt;
    private static Asset ast;
    private static contact con;
    private static LiveChatVisitor visitor;
    private static LiveChatTranscript lct;
    private static Case cse;
    private static Product2 prd;
    private static WorkOrder wo;
    private static ValidateReturnParts__x objvalidate;
    
    //@testSetup
    private static testMethod void setupTestData() {
        
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        u = new User(Alias = 'auser', Email='adminuser@dell.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',External_ID__c = '1234526',Organization__c = 'ORGID', File_Source__c = 'AMS - System Admin',Dell_NTUserID__c = 'TEST2019',Service_User_Type__c = 'Admin',
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__C = 'No');
        insert u;
     
        //create a test account
        acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test asset
        ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        ast.Invoice_Date__c= system.today();
        insert ast;
        
        //create a test contact
        con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        insert con;
        
        //create a test LiveChatVisitor
        visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;
        
        //create a test case
        cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        cse.TranscriptId__c = lct.Id;
        cse.assetId= ast.id;
        insert cse;        
        
        //create a test Product
        prd = new Product2();
        prd.ProductCode = 'AH129';
        prd.Name = 'AH129';
        prd.LOB_Code__c = 'AH129';
        prd.LOB_Description__c = 'AH129';
        prd.Description = 'AH129 TEST Product';
        
        insert prd;
        
        // create work Order
        wo = new WorkOrder();
        wo.AssetId = ast.id;
        wo.AccountId = acnt.id;
        wo.ContactId = con.id;
        wo.CaseId = cse.id;
        wo.Subject = 'test work order';
        wo.status = 'Work In Progress';
        
        insert wo;
    }
    
    @isTest
    private static void UnitTestMethod1(){
        setupTestData();
         objvalidate = new ValidateReturnParts__x();
         objValidate.ResponseCode__c='100';
        system.runAs(u){
            Test.startTest();
                DispatchCreateHandler.MockAutovalidateParts.add(objValidate);    
                String countrycode = 'BR';       
                DispatchCreateHandler.checkRepeatDispatchInAsset(cse.id,countrycode);
                //DispatchCreateHandler.createWorkOrder(cse.id,'APS Error','test Add notes');
                //DispatchCreateHandler.createWorkOrder(cse.id,'Test APS Error','test Add notes');
                List<string> AssetHoldStatus = new list<string>();
                //serviceTagList.add('77435435');
                AssetHoldStatus.add('31');
                DispatchCreateHandler.GetAssetHoldValue(AssetHoldStatus);
                DispatchCreateHandler.getselectOptions(cse, 'Origin');
                List<String> PPIDLst = new List<String>();
                PPIDLst.add('12345678');
                DispatchCreateHandler.validatePPID(PPIDLst,'56789');
            Test.stopTest();
       }
               
    }
    
    @isTest
    private static void UnitTestMethod2(){   
        setupTestData();
        objvalidate = new ValidateReturnParts__x();
        objValidate.ResponseCode__c='101';
        system.runAs(u){
            Test.startTest();
                DispatchCreateHandler.MockAutovalidateParts.add(objValidate); 
                List<String> PPIDLst = new List<String>();
                PPIDLst.add('12345678');
                DispatchCreateHandler.validatePPID(PPIDLst,'56789');
            Test.stopTest();
        }
   } 
   
    @isTest
    private static void UnitTestMethod3(){   
        setupTestData();
        system.runAs(u){
            Test.startTest();
                 //List<string> serviceTagList = new list<string>();
                 List<string> AssetHoldStatus = new list<string>();
                 AssetHoldStatus = null;
                 DispatchCreateHandler.GetAssetHoldValue(AssetHoldStatus);
                //DispatchCreateHandler.MockAutovalidateParts.add(objValidate); 
               // List<String> PPIDLst = new List<String>();
               // PPIDLst.add('12345678');
               // DispatchCreateHandler.validatePPID(PPIDLst,null);
            Test.stopTest();
        }
   }
   
    @isTest
    private static void validatePPID(){   
        setupTestData();
        objvalidate = new ValidateReturnParts__x();
        objValidate.ResponseCode__c='100';
        string str = '12345678';
        objValidate.PartNumber__c = str.substring(3,8).toUpperCase();
        
        system.runAs(u){
            Test.startTest();
                DispatchCreateHandler.MockAutovalidateParts.add(objValidate);    
                        
                String countrycode = 'BR';
                DispatchCreateHandler.checkRepeatDispatchInAsset(cse.id,countrycode);
                //DispatchCreateHandler.createWorkOrder(cse.id,'APS Error','test Add notes');
                //DispatchCreateHandler.createWorkOrder(cse.id,'Test APS Error','test Add notes');
                /*List<string> serviceTagList = new list<string>();
                serviceTagList.add('77435435');
                DispatchCreateHandler.checkAssetHoldStatus(serviceTagList);
                DispatchCreateHandler.getselectOptions(cse, 'Origin');*/
                List<String> PPIDLst = new List<String>();
                PPIDLst.add('12345678');
                DispatchCreateHandler.validatePPID(PPIDLst,'56789');
            Test.stopTest();
       }
               
   }
}
@isTest
    public class CallTransferHandler_Test {
        //Call Transfer Attribute record id
        @TestSetup
        static void setup()
        {
                    Account account=SRVS_CreateTestDataFactory.createSingleAccountRecord();
                    insert account;
                    Asset asset=SRVS_CreateTestDataFactory.createSingleAsset(account.id);
                    insert asset;
                    Call_Transcript__c ct=SRVS_CreateTestDataFactory.createcallTranscript();
                    ct.Asset__c=asset.id;
                    insert ct;
                    Call_Transfer_Attributes__c cta=SRVS_CreateTestDataFactory.createcallTransAttr(ct.id);
                    cta.Local_Channel__c='Retail';
                    cta.Product_Line__c='Cloud Servers';
                    cta.Category__c='Software';
                    cta.Detail__c='DSP';
                    cta.Notes__c='notes'; 
                    cta.Product_Shipped_Date__c=date.today();
                    insert cta;
                    Call_Transcript__c ct1=SRVS_CreateTestDataFactory.createcallTranscript();
                    ct1.Asset__c=asset.id;
                    insert ct1;
                    Call_Transfer_Attributes__c cta1=SRVS_CreateTestDataFactory.createcallTransAttr(ct1.id);
                    cta1.Local_Channel__c='Retail';
                    cta1.Product_Line__c='Cloud Servers';
                    cta1.Category__c='Software';
                    cta1.Detail__c='DSP';
                    cta1.Notes__c='notes'; 
                    cta1.Product_Shipped_Date__c=date.today();
                    cta1.Transfer_Count__c='1';
                    cta1.Updated_Transfer_Count__c='3';
                    insert cta1;
                   
                   
        }
        @isTest
        private static void getcallTranscriptIdTest(){
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
            system.runAs(objUser)
            {  
                Call_Transcript__c ct=[Select Id from Call_Transcript__c LIMIT 1];
                Call_Transfer_Attributes__c cta=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
                String csllTransferAttrId = CallTransferHandler.getCallTransferAttrId(ct.Id);
                System.assertEquals(csllTransferAttrId, cta.Id);
                
                //Negiative test scenario to provide the test coverage to Catch block.
                //Calling the createcallTranscript() with the null input which results in exception: "List has no rows for assignment to SObject"
                CallTransferHandler.getCallTransferAttrId(null);
            }
        }
        //Context store get methods for teansfer count
         @isTest 
        static void getTransferCountTest1()
        {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
                system.runAs(objUser)
                {  
                    Call_Transcript__c ct=[Select Agent_ID__c,IVR_Input__c from Call_Transcript__c LIMIT 1];
                    Test.startTest(); 
                    Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorGet('A'));
                    String transferCount = CallTransferHandler.GetTransferCount(ct.id,ct.Agent_ID__c,ct.IVR_Input__c);
                    String expectedValue = '1';
                    System.assertEquals(transferCount, expectedValue);
                    String transferCountnull = CallTransferHandler.GetTransferCount(null,null,null);
                    Test.stopTest();              
                }
              
        }
          @isTest 
        static void getTransferCountTest2()
        {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
                system.runAs(objUser)
                {  
                    Call_Transcript__c ct=[Select Agent_ID__c,IVR_Input__c from Call_Transcript__c LIMIT 1];
                    Test.startTest(); 
                    Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorGet('B'));
                    String transferCount = CallTransferHandler.GetTransferCount(ct.id,ct.Agent_ID__c,ct.IVR_Input__c);
                    Test.stopTest();  
                 
                }
              
        }
        @isTest 
        static void getTransferCountTest3()
        {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
                system.runAs(objUser)
                {  
                    Call_Transcript__c ct=[Select Agent_ID__c,IVR_Input__c from Call_Transcript__c LIMIT 1];
                    Test.startTest(); 
                    Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorGet('C'));
                    String transferCount = CallTransferHandler.GetTransferCount(ct.id,ct.Agent_ID__c,ct.IVR_Input__c);
                    Test.stopTest();              
                }         
        }
        @isTest 
        static void getTransferCountTest4()
        {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;   
                system.runAs(objUser)
                {  
                    Call_Transcript__c ct=[Select Agent_ID__c,IVR_Input__c from Call_Transcript__c LIMIT 1];
                    Test.startTest(); 
                    Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorGet('D'));
                    String transferCount = CallTransferHandler.GetTransferCount(ct.id,ct.Agent_ID__c,ct.IVR_Input__c);
                    Test.stopTest();               
                }
              
        }
        @isTest 
        static void getTransferCountTest5()
        {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;   
                system.runAs(objUser)
                {  
                    Call_Transcript__c ct=[Select Agent_ID__c,IVR_Input__c from Call_Transcript__c LIMIT 1];
                    Test.startTest(); 
                    Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorGet('E'));
                    String transferCount = CallTransferHandler.GetTransferCount(ct.id,ct.Agent_ID__c,ct.IVR_Input__c);
                    Test.stopTest();               
                }
              
        }
         //Context store put methods for transfer count and transfer type
        @isTest static void updateTransferCountTest1()
        {
             User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
            system.runAs(objUser)
            {    
              Call_Transfer_Attributes__c cta1=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
              Test.startTest();            
              Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorPut('A'));        
              CallTransferHandler.UpdateTransferCount(cta1.id);
              CallTransferHandler.UpdateTransferCount(null);
              Test.stopTest();
        
                   
            }
        }
        @isTest static void updateTransferCountTest2()
        {          
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
            system.runAs(objUser)
            {    
               Call_Transfer_Attributes__c cta1=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
               Test.startTest();            
               Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorPut('B'));        
               CallTransferHandler.UpdateTransferCount(cta1.id);
               Test.stopTest();
            }
        }
         @isTest static void updateTransferCountTest3()
         {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
            system.runAs(objUser)
            {           
              Call_Transfer_Attributes__c cta1=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
              Test.startTest();            
              Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorPut('C'));        
              CallTransferHandler.UpdateTransferCount(cta1.id);
              Test.stopTest();
            }
         }
         @isTest static void updateTransferCountTest4()
          {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
            system.runAs(objUser)
            {    
            
              Call_Transfer_Attributes__c cta1=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
              Test.startTest();            
              Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorPut('D'));        
              CallTransferHandler.UpdateTransferCount(cta1.id);
              Test.stopTest();
            }
        }
           @isTest static void updateTransferCountTest5()
          {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
            system.runAs(objUser)
            {    
            
              Call_Transfer_Attributes__c cta1=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
              Test.startTest();            
              Test.setMock(HttpCalloutMock.class, new VoiceMockHttpResponseGeneratorPut('E'));        
              CallTransferHandler.UpdateTransferCount(cta1.id);
              Test.stopTest();
            }
        }
           // BRE TEST METHODS
        @isTest 
        static void BreGetTestMethod1()
        {
           User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
           insert objUser;
                system.runAs(objUser)
                {  
                    Call_Transfer_Attributes__c cta=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
                    Test.startTest(); 
                    Test.setMock(HttpCalloutMock.class, new BREMockHttpResponseGenerator('A'));   
                    String breResp=CallTransferHandler.CallBRE_API(cta.id);                 
                    String expectedValue = '6166002';
                    System.assertEquals(breResp, expectedValue);
                    String breResp1=CallTransferHandler.CallBRE_API(null);  
                    Test.stopTest();  
                }
              
        }
        @isTest 
        static void BreGetTestMethod2()
        {
            User objUser = SRVS_CreateTestDataFactory.createUser('System Administrator');
            insert objUser;
                system.runAs(objUser)
                {  
                    Call_Transfer_Attributes__c cta=[Select Id from Call_Transfer_Attributes__c LIMIT 1];
                    Test.startTest(); 
                    Test.setMock(HttpCalloutMock.class, new BREMockHttpResponseGenerator('B'));                
                    CallTransferHandler.CallBRE_API(cta.id);  
                    CallTransferHandler.CallBRE_API(null);   
                    Test.stopTest();  
                }
              
        }
        
        //mock for BRE
         public class BREMockHttpResponseGenerator implements HttpCalloutMock {
            // Implement this interface method
            public String type;
              public BREMockHttpResponseGenerator(final String type)
                {
                    this.type=type;
                }
            public HTTPResponse respond(HTTPRequest req) {
                    
                System.assertEquals(Label.BRE_CallTransfer + '?apikey=' + Label.BRE_CallTransferAPIKey, req.getEndpoint());
                System.assertEquals('GET', req.getMethod());
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"selectedDestAddress":"6166002"}');
                 if(type == 'A'){
                      res.setStatusCode(200);
                 }
                else if(type == 'B'){
                      res.setStatusCode(500);
                 }
                return res;
            }
        }
        //mock for get
        public class VoiceMockHttpResponseGeneratorGet implements HttpCalloutMock {
            // Implement this interface method
            public String type;
              public VoiceMockHttpResponseGeneratorGet(final String type)
                {
                    this.type=type;
                }
            public HTTPResponse respond(HTTPRequest req) {
                // Optionally, only send a mock response for a specific endpoint
                // and method.           
                String AgentName= UserInfo.getFirstName()+'_'+UserInfo.getLastName();  
                String AgentId='4564553';   
                String aliasId = 'Sample Asset';           
                //System.assertEquals(label.voiceContextStorePath +aliasId +'/answer?touchpoint=VoiceSFDCAgent.' +AgentName +'.' +AgentId + '&apikey='+label.VoiceContextStoreApiKey, req.getEndpoint());
                //System.assertEquals('GET', req.getMethod());
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"data": { "Customer_Number": "7943546","Contact_Method_ID": "18004563355","Transfer_Count": "1","Customer_Name": "","Interaction_Type": "Service_Tag","Product_Line": "DELL LATITUDE 14 RUGGED","Transfer_Reason": "Software - DDPE","Service_Tag": "DYSWSG2"}}');
                 if(type == 'A'){
                res.setStatusCode(200);
                 }
                else if(type == 'B'){
                res.setStatusCode(400);
                 }
                else if(type == 'C'){
                res.setStatusCode(404);
                 }
                else if(type == 'D'){
                res.setStatusCode(500);
                 }
                else if(type == 'E'){
                 }
                return res;
            }
        }
        //mock for put methods
        public class VoiceMockHttpResponseGeneratorPut implements HttpCalloutMock {
            // Implement this interface method
           public String type;
               public VoiceMockHttpResponseGeneratorPut(final String type)
                {
                    this.type=type;
                }
            public  HTTPResponse respond(HTTPRequest req) {
                String url=req.getEndpoint();
                String[] parts = url.split('Service_Tag');
                String endpoint = parts[0]; 
                System.assertEquals(label.voiceContextStorePath, endpoint);
                System.assertEquals('PUT', req.getMethod());
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setBody('{"Transfer_Count":"4","Transfer_Reason":"wrong call"}');
                 if(type == 'A'){
                res.setStatusCode(200);
                 }
                else if(type == 'B'){
                res.setStatusCode(400);
                 }
                else if(type == 'C'){
                res.setStatusCode(404);
                 }
                else if(type == 'D'){
                res.setStatusCode(500);
                 }
                 else if(type == 'E'){
                 }
                return res;
             }
        }
    }
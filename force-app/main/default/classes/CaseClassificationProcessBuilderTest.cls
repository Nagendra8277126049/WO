/* -----------------------------------------------------------------------------------------------------------------------
Name:       CaseClassificationProcessBuilderTest
Description:  Makes an API call to the Intent API and fetches the predictions according to the title and description.
----------------------------------------------------------------------------------------------------------------------------
Date         Version  Author                    Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
10/23/2018     3.0    Shaurya Bajaj             Initial Release
10/23/2018     4.0    Jorge Montalvão           Increase code coverage
01/03/2019     5.0    Jorge Montalvão           Defect 6023261: [QE]FY20_0202_Lightning_Intelligence_CC List and NBA field is blank for cases created for the mentioned performance labels in SIT1
-------------------------------------------------------------------------------------------------------------------------- */


@isTest
private class CaseClassificationProcessBuilderTest {
   
     @testSetup
    static void createCase(){
        
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        
        //Create a test Chat Transcript
        LiveChatTranscript ct =  new LiveChatTranscript();
        ct.body ='<p align="center">Chat Started: Monday, November 26, 2018, 20:51:04 (+0000)</p><p align="center">Chat Origin: AMER.TS.CLI.CHAT.EN.CORE.CA.CON</p><p align="center">Agent Eric L</p>( 4s ) Eric L: Hi . Thank you for contacting Dell Technical Support. My name is Eric. Please allow me a moment to review your case details.<br>( 44s ) Visitor: Hello, I have a problem with my laptop<br>';
        ct.LiveChatVisitorId = lcv.id;
        insert ct;
            
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
        
        //create a test case
        Case cse1=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse1.subject='Mouse not working';
        cse1.Description = 'Mouse not working';
        cse1.Service_Tag__c = '86LKVS1';
        
        //cse.Case_Source__c = 'Delta';
        cse1.AssetId=ast.id;
        cse1.NonAgentContactEmail__c = 'testtag@test.com';
        cse1.NonAgentContactFirstName__c = 'firstname';
        cse1.NonAgentContactLastName__c = 'testtag';
        cse1.NonAgentContactPhone__c = '800-123-4567';
        cse1.TranscriptId__c = ct.id;
        insert cse1;
        ct.caseid = cse1.id;
        update ct;
        
        Case cse2=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse2.subject = null;
        cse2.Description = null;
        cse2.Service_Tag__c = '128K51S';
        //cse.Case_Source__c = 'Delta';
        cse2.AssetId=ast.id;
        cse2.NonAgentContactEmail__c = 'testtag@test.com';
        cse2.NonAgentContactFirstName__c = 'firstname';
        cse2.NonAgentContactLastName__c = 'testtag';
        cse2.NonAgentContactPhone__c = '800-123-4567';
        insert cse2;
    } 
 
   @isTest
    static void test01()
    {   
        system.debug('*****TEST1()*****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest = true;
        List<Id> recId =new List<Id>();
        recId.add([select id from Case where Service_Tag__c ='86LKVS1'].id);
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        CaseClassificationProcessBuilder.doCallout(recId);
        Test.stopTest();
    } 
    
    @isTest
    static void test02()
    {   
        system.debug('***** TEST2: check null pointer exception catch exception error *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest = true;
        List<Id> recId =new List<Id>();
        recId.add([select id from Case where Service_Tag__c ='128K51S'].id);
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        CaseClassificationProcessBuilder.doCallout(recId);
        Test.stopTest();
    } 
    
    @isTest
    static void test03()
    {   
        system.debug('***** TEST3: check Case Classification related Performance *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest = true;
        CaseClassificationProcessBuilder.checkCCPerf   = true;
        List<Id> recId =new List<Id>();
        recId.add([select id from Case where Service_Tag__c ='128K51S'].id);
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        CaseClassificationProcessBuilder.doCallout(recId);
        Test.stopTest();
    } 
    
    @isTest
    static void test04()
    {   
        system.debug('***** TEST4: check GR Login User and Pwd *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest = true;
        CaseClassificationProcessBuilder.checkGRLPwd   = true;
        List<Id> recId =new List<Id>();
        recId.add([select id from Case where Service_Tag__c ='86LKVS1'].id);
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        CaseClassificationProcessBuilder.doCallout(recId);
        Test.stopTest();
    } 
    
    @isTest
    static void test05()
    {   
        system.debug('***** TEST5: check GR Access Token *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest = true;
        CaseClassificationProcessBuilder.checkGRToken  = true;
        List<Id> recId =new List<Id>();
        recId.add([select id from Case where Service_Tag__c ='86LKVS1'].id);
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        CaseClassificationProcessBuilder.doCallout(recId);
        Test.stopTest();
    }
    
    @isTest
    static void test06()
    {   
        system.debug('***** TEST6: check when predicted CC level is lower than 40% *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest  = true;
        CaseClassificationProcessBuilder.checkCCLower = true;
        List<Id> recId =new List<Id>();
        recId.add([select id from Case where Service_Tag__c ='86LKVS1'].id);
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        CaseClassificationProcessBuilder.doCallout(recId);
        Test.stopTest();
    }
    
    @isTest
    static void test07()
    {   
        system.debug('***** TEST7: catch System.NullPointerException when perfor String.toLowerCase() to a given null variable *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest = true;
        String subject = null;
        ID sfdcId = null;
        CaseClassificationProcessBuilder.returnIntent(subject,sfdcId);
        Test.stopTest();
    }
    
    @isTest
    static void test08()
    {   
        system.debug('***** TEST8: Einstein Platform returns Bad Request: Missing document *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest = true;
        CaseClassificationProcessBuilder.checkBadDoc   = true;
        String subject = '';
        ID sfdcId = null;
        CaseClassificationProcessBuilder.returnIntent(subject,sfdcId);
        Test.stopTest();
    }
    
    @isTest
    static void test09()
    {   
        system.debug('***** TEST9: Guided_Resolution 2.1 JSON response code not expected *****');
        Test.startTest();
        CaseClassificationProcessBuilder.checkUnitTest    = true;
        CaseClassificationProcessBuilder.checkGRBadResult = true;
        String serviceTag = '86LKVS1';
        String symptomDescription = 'non';
        ID sfdcId;
        CaseClassificationProcessBuilder.returnNBA(serviceTag, symptomDescription, sfdcId);
        Test.stopTest();
    }
    
    @isTest
    static void test10()
    {   
        system.debug('***** TEST10: check null pointer exception catch exception error *****');
        String key = 'abcd';
        Test.startTest();
        String[] result = EncryptKey.getEncryptedValue(key);
       	System.assertNotEquals(result, null);
        Test.stopTest();
    }
    
	// This test method should give 100% coverage
	// Generated by JSON2Apex http://json2apex.herokuapp.com/
	@IsTest
    static void test11() {
        Test.startTest();
		String json = '{\"probabilities\":[{\"label\":\"Slow performance with 100% Hard Drive activity using Windows 8 /8.1/10\",\"probability\":0.8990304},{\"label\":\"System freezing/locking up\",\"probability\":0.060056917},{\"label\":\"Slow system performance when docked(notebooks only)\",\"probability\":0.014812006}],\"object\":\"predictresponse\", \"message\": \"{\\\"sampleId\\\":\\\"bitlocker encryption\\\",\\\"message\\\":\\\"Bad Request: Missing document\\\"}\"}';
		Einstein_PredictionResult r = Einstein_PredictionResult.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Einstein_PredictionResult objEinstein_PredictionResult = new Einstein_PredictionResult(System.JSON.createParser(json));
		System.assert(objEinstein_PredictionResult != null);
		System.assert(objEinstein_PredictionResult.probabilities == null);
		System.assert(objEinstein_PredictionResult.object_Type == null);
		System.assert(objEinstein_PredictionResult.message == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Einstein_PredictionResult.Probabilities objProbabilities = new Einstein_PredictionResult.Probabilities(System.JSON.createParser(json));
		System.assert(objProbabilities != null);
		System.assert(objProbabilities.label == null);
		System.assert(objProbabilities.probability == null);
        Test.stopTest();
	}

	@IsTest
    static void test12() {
        Test.startTest();
        Einstein_Probability p = new Einstein_Probability();
        p.label = 'test';
        p.probability = 0.9999999;
        Einstein_Probability.BoundingBox b = new Einstein_Probability.BoundingBox();
        b.minX = 0;
        b.maxX = 0;
        b.maxY = 0;
        p.BoundingBox = b;
        system.debug(p);
        System.assert(p.label == 'test');
        System.assert(p.probability == 0.9999999);
        System.assert(p.BoundingBox.minX == 0);
        System.assert(p.BoundingBox.maxX == 0);
        System.assert(p.BoundingBox.maxY == 0);
        Test.stopTest();
    }
    
    //Test method to fix code coverage for Einstein_JWTBearerFlow
    @isTest
     static void test13()
    {   
       
        String endpoint = 'abcd';
        
        Einstein_JWT jwt = new Einstein_JWT(endpoint);
        jwt.iss = 'abc';
        jwt.sub = 'abc';
        jwt.aud = 'abc';
        Test.startTest();
        String result = Einstein_JWTBearerFlow.getAccessToken(endpoint, jwt);
       	System.assertNotEquals(result, null);
        Test.stopTest();
    } 
}
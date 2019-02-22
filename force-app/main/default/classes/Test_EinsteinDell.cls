/* -----------------------------------------------------------------------------------------------------------------------
Name:       Test_EinsteinDell
Description:  Test Einstein classes related to Case Classificaiton, Einstein API and Einstein Playground
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
2018-10-29     1.0         Rodrigo Parizotto          Initial Release
2019-01-03     1.1         Rodrigo Parizotto          Minor change due to build error
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
public with sharing class Test_EinsteinDell {
    
    static testMethod void getAccessToken_failsWithoutEmailSetting() {
        
        TestUtils.enable_isRunningTest = false; 
        
        Test.startTest();
        try {
            Einstein_PredictionService.getAccessToken();
            System.assert(false, 'Expected Einstein_ConfigurationException');
        }
        catch (Exception e) {
            System.assert(e instanceof Einstein_ConfigurationException);
            System.AssertEquals(e.getMessage().contains('email setting'), true);
        }
        Test.stopTest();
    }
    
    static testMethod void playgroundValidation(){
        
        map<string, boolean> result = new map<string, boolean>();
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        
        result = Einstein_PlaygroundController.validateEinsteinPlatformSetup();
        system.assertEquals(result.get('einsteinEmail'), false);
        system.assertEquals(result.get('einsteinCert'), false);
        
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        result = Einstein_PlaygroundController.validateEinsteinPlatformSetup();
        
        system.assertEquals(result.get('einsteinEmail'), true);
        system.assertEquals(result.get('einsteinCert'), false);
        
        settings.CertName__c = 'myCert';
        upsert settings;
        
        result = Einstein_PlaygroundController.validateEinsteinPlatformSetup();
        system.assertEquals(result.get('einsteinEmail'), true);
        system.assertEquals(result.get('einsteinCert'), true);
        
    }
    
    /*static testMethod void getAccessToken_failsWithoutCertificate() {
Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
settings.Einstein_EMail__c = 'test@mail.com';
upsert settings;

TestUtils.enable_isRunningTest = false;

Test.startTest();
try {
Einstein_PredictionService.getAccessToken();
System.assert(false, 'Expected Einstein_ConfigurationException');
}
catch (Exception e) {
System.assert(e instanceof Einstein_ConfigurationException);
System.AssertEquals(e.getMessage().contains('certificate file'), true);
}
Test.stopTest();
}*/
    
    static testMethod void getAccessToken_works() {
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        ContentVersion certificate = new ContentVersion(Title = 'einstein_platform', PathOnClient='.', VersionData=Blob.valueOf('someData'));
        insert certificate;
        
        Test.startTest();
        String token = Einstein_PredictionService.getAccessToken();
        System.assertEquals(token, '');
        Test.stopTest();
    }
    
    static testMethod void createDataset() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Dataset dataset = service.createDatasetFromUrlAsync('https://myurl');
        System.assertEquals('Beach and Mountain', dataset.name);
        System.assertEquals(DateTime.newInstanceGmT(2016,9,15,16,51,41), dataset.updatedAt);
        
        dataset = service.createDatasetFromUrlSync('https://myurl');
        System.assertEquals('Beach and Mountain', dataset.name);
        System.assertEquals(DateTime.newInstanceGmT(2016,9,15,16,51,41), dataset.updatedAt);
        System.assertEquals(611, dataset.labelSummary.labels[0].id);
        System.assertEquals(57, dataset.labelSummary.labels[0].datasetId);
        System.assertEquals('beach', dataset.labelSummary.labels[0].name);
        System.assertEquals(0, dataset.labelSummary.labels[0].numExamples);
        System.assertEquals(2, dataset.totalLabels);
        System.assertEquals(true, dataset.available);
        System.assertEquals('SUCCEEDED', dataset.statusMsg);
        
    }
    
    
    static testMethod void getDataset() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Dataset dataset = service.getDataset(57);
        
        // Test 1: Valid Dataset returned
        System.assertEquals('Beach and Mountain', dataset.name);
        System.assertEquals(DateTime.newInstanceGmT(2016,9,15,16,51,41), dataset.updatedAt);
        
        try
        {
            Einstein_Dataset dataset2 = service.getDataset(0);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NoValuesException);
        }
        
    }
    
    static testMethod void getDatasets() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        List<Einstein_Dataset> datasets = service.getDatasets();
        
        System.assertEquals(2, datasets.size());
        
        for (Einstein_Dataset dataset : datasets) {
            if (dataset.id == 57) {
                System.assertEquals('Beach and Mountain', dataset.name);
            }
        }
        
        datasets = service.getGlobalDatasets();
        System.assertEquals(1, datasets.size());
        
    }
    
    static testMethod void deleteDataset() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Boolean success = service.deleteDataset(108);
        
        System.assertEquals(true, success);
        
    }
    
    
    static testMethod void createExample() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Example example = service.createExample(57, '77880132.jpg', 614, Blob.valueOf('data'));
        
        System.assertEquals(43887, example.id);
        System.assertEquals('77880132.jpg', example.name);
        System.assertEquals('https://jBke4mtMuOjrCK3A04Q79O5TBySI2BC3zqi7...', example.location);
        System.assertEquals(DateTime.newInstanceGmt(2016,9,15,23,18,13), example.createdAt);
        System.assertNotEquals(null, example.label);
        
    }
    
    static testMethod void createExamplesFromUrl() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Dataset dataset = service.createExamplesFromUrl(1000022, 'http://my.image.com/test.png');
        
        System.assertEquals('mountainvsbeach', dataset.name);
        System.assertEquals(DateTime.newInstanceGmt(2017,2,17,0,22,10), dataset.createdAt);
        System.assertEquals(DateTime.newInstanceGmt(2017,2,17,0,22,12), dataset.updatedAt);
        
        try {
            dataset = service.createExamplesFromUrl(1000022, '');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
    }
    
    static testMethod void getExamples() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        List<Einstein_Example> examples = service.getExamples(57);
        
        System.assertEquals(4, examples.size());
        
    }
    
    static testMethod void trainDataset() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Model model = service.trainDataset(57, 'Beach and Mountain Model', 0, 0, null);
        
        System.assertEquals(DateTime.newInstanceGmt(2016,9,16,18,3,21), model.createdAt);
        System.assertEquals(DateTime.newInstanceGmt(2016,9,16,18,3,21), model.updatedAt);
        System.assertEquals(57, model.datasetId);
        System.assertEquals(0, model.datasetVersionId);
        System.assertEquals('Beach and Mountain Model', model.name);
        System.assertEquals('QUEUED', model.status);
        System.assertEquals(0, model.progress);
        System.assertEquals(0.001, model.learningRate);
        System.assertEquals(3, model.epochs);
        System.assertEquals(1, model.queuePosition);
        System.assertEquals('7JXCXTRXTMNLJCEF2DR5CJ46QU', model.modelId);
        System.assertEquals(null, model.trainParams);
        System.assertEquals(null, model.trainStats);
        System.assertEquals('image', model.modelType);
        System.assertEquals(null, model.failureMsg);
        
        try {
            model = service.trainDataset(0, 'Beach and Mountain Model', 0, 0, null);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.debug('Error is: ' + e.getTypeName());
            System.assert(e instanceof Einstein_NoValuesException);
        }
        
        try {
            model = service.trainDataset(57, '', 0, 0, null);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            String nameTooLong = 'AbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefg';
            model = service.trainDataset(57, nameTooLong, 0, 0, null);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringTooLongException);
        }
        
        try {
            model = service.trainDataset(57, 'Beach and Mountain Model', 101, 0, null);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooBigException);
        }
        
        try {
            model = service.trainDataset(57, 'Beach and Mountain Model', 101, 0, null);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooBigException);
        }
        
        try {
            model = service.trainDataset(57, 'Beach and Mountain Model', 0, 0.00001, null);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooSmallException);
        }
        
        try {
            model = service.trainDataset(57, 'Beach and Mountain Model', 0, 0.1, null);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooBigException);
        }
        
    }
    
    static testMethod void getModel() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Model model = service.getModel('7JXCXTRXTMNLJCEF2DR5CJ46QU');
        
        // TODO System.assertEquals(DateTime.newInstance(), model.createdAt);
        // TODO System.assertEquals(DateTime.newInstance(), model.updatedAt);
        System.assertEquals(57, model.datasetId);
        System.assertEquals(0, model.datasetVersionId);
        System.assertEquals('Beach and Mountain Model', model.name);
        System.assertEquals('SUCCEEDED', model.status);
        System.assertEquals(1, model.progress);
        System.assertEquals(0.001, model.learningRate);
        System.assertEquals(3, model.epochs);
        System.assertEquals('7JXCXTRXTMNLJCEF2DR5CJ46QU', model.modelId);
        System.assertEquals(null, model.trainStats);
        System.assertEquals('image', model.modelType);
        
        Einstein_Dataset dataset = new Einstein_Dataset();
        dataset.id = 57;
        
        model = service.getModel('7JXCXTRXTMNLJCEF2DR5CJ46QU');
        System.assertEquals('Beach and Mountain Model', model.name);
        
    }
    
    static testMethod void getModelLearningCurve() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        String learningCurves = service.getModelLearningCurve('7JXCXTRXTMNLJCEF2DR5CJ46QU');
        
        System.assertNotEquals(null, learningCurves);
        
    }
    
    static testMethod void getModelMetrics() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        String metrics = service.getModelMetrics('7JXCXTRXTMNLJCEF2DR5CJ46QU');
        
        System.assertNotEquals(null, metrics);
        
    }
    
    static testMethod void getModels() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        List<Einstein_Model> models = service.getModels(57);
        
        System.assertEquals(2, models.size());
        Einstein_Model model = models.get(0);
        System.assertEquals('To train a dataset and create a model, the dataset must contain at least 100 examples per label for test set', model.failureMsg);
        
    }
    
    static testMethod void predictImages() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_PredictionResult result = service.predictImageBase64('YCQ4ZACEPJFGXZNRA6ERF3GL5E', 'aaabbbccc', 0, '');
        
        System.assertEquals(2, result.probabilities.size());
        System.assertEquals('beach', result.probabilities.get(0).label);
        System.assertEquals(0.039788953959941864, result.probabilities.get(1).probability);        
        
        result = service.predictImageUrl('YCQ4ZACEPJFGXZNRA6ERF3GL5E', 'https://theurl', 0, '');
        result = service.predictImageBlob('modelId', Blob.valueof('somedata'), 0, 'sampleId');
        
        result = service.detectImageBase64('YCQ4ZACEPJFGXZNRA6ERF3GL5E', 'aaabbbccc', 0, '');
        
        /* temporary commented due to Compilation error on boundingBox
        System.assertEquals(100, result.probabilities[0].boundingBox.maxX); 
        System.assertEquals(100, result.probabilities[0].boundingBox.maxY);
        System.assertEquals(100, result.probabilities[0].boundingBox.minX);
        System.assertEquals(100, result.probabilities[0].boundingBox.minX);
        */
        
        result = service.detectImageBlob('YCQ4ZACEPJFGXZNRA6ERF3GL5E', Blob.valueof('somedata'), 0, '');
        result = service.detectImageUrl('YCQ4ZACEPJFGXZNRA6ERF3GL5E', 'aaabbbccc', 0, '');
    }
    
    static testMethod void predictLanguage() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.SENTIMENT);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_PredictionResult result = service.predictSentiment('modelId', 'text', 0, '');
        
        System.assertEquals(3, result.probabilities.size());
        System.assertEquals('positive', result.probabilities.get(0).label);
        
        service.setType(Einstein_PredictionService.Types.INTENT);
        result = service.predictIntent('modelId', 'text', 0, '');
        
        System.assertEquals(5, result.probabilities.size());
        System.assertEquals('Mouse', result.probabilities.get(0).label);
        
    }
    
    
    static testMethod void createFeedback() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.INTENT);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Example example = service.createFeedbackLanguageExample('expectedLabel', 'modelId', 'text');
        System.assertEquals(1048038, example.id);
        System.assertEquals('text-intent', example.name);
        
        Blob theBlob = Blob.valueof('somedata');
        service.setType(Einstein_PredictionService.Types.IMAGE);
        example = service.createFeedbackImageExample('name', 'expectedLabel', 'modelId', theBlob);
        System.assertEquals(618168, example.id);
        System.assertEquals('alps.jpg', example.name);
        
    }
    
    static testMethod void retrainDataset() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        // Valid Values
        Einstein_TrainParams trainParams = new Einstein_TrainParams();
        trainParams.withFeedback = true;
        Einstein_Model model = service.retrainDataset('modelId', 3, 0.001, trainParams);
        System.assertEquals(57, model.datasetId);
        
        // Zero Defaults
        model = service.retrainDataset('modelId', 0, 0, trainParams);
        System.assertEquals(57, model.datasetId);
        
        // Null Defaults
        Integer epochs = null;
        Decimal learningRate = null;
        
        model = service.retrainDataset('modelId', epochs, learningRate, trainParams);
        System.assertEquals(57, model.datasetId);
        
        Einstein_HttpBodyPartRetraining parts = new Einstein_HttpBodyPartRetraining('modelId', epochs, learningRate, trainParams);
        System.assertEquals('modelId', parts.getModelId());
        System.assertEquals(null, parts.getEpochs());
        System.assertEquals(null, parts.getLearningRate());
        
        // Validation
        try {
            model = service.retrainDataset(null, epochs, learningRate, trainParams);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            model = service.retrainDataset('modelId', 101, learningRate, trainParams);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooBigException);
        }
        
        try {
            model = service.retrainDataset('modelId', epochs, 0.00001, trainParams);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooSmallException);
        }
        
        try {
            model = service.retrainDataset('modelId', epochs, 0.1, trainParams);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooBigException);
        }
        
    }
    
    static testMethod void testContentDistributionTrigger() {
        //create a file

        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Description = 'this is a test description';
        cse.origin = 'Email';
        cse.Reason = 'Test';
        insert cse;

        ContentVersion CV = Einstein_PlaygroundController.saveFileToFiles('case', 'Description', 'Reason');
        ContentDistribution CD = Einstein_PlaygroundController.writeCD(CV.ContentDocumentId, 'TestCD');

        ContentDistribution CD2 = [select id, Name, ExpiryDate, ContentDownloadUrl from ContentDistribution where Id =: cd.Id];

        System.assertNotEquals(null, CD2.ContentDownloadUrl, 'The download url did not get created');
        //review assert
        //System.assert(CD2.ExpiryDate > System.now(), 'The content distribution should have not be expired yet.'); 


        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //update the CD just to trigger the trigger
            test.startTest();
            CD2.Name = 'EinsteinTemp' + CD2.Name;
            update CD2;
            test.stopTest();
        }

        ContentDistribution CD3 = [select id, ExpiryDate from ContentDistribution where Id =: cd.Id];
        //review assert
        //System.assert(CD3.ExpiryDate < System.now(), 'The content distribution should have expired.');
        
        //
        list<ID> CDs = new list<ID>();
        Einstein_PlaygroundController.handleCDV(CDs);
    }
    
    static testMethod void Test_Einstein_TrainStats(){
        Einstein_TrainStats stats = new Einstein_TrainStats();
        stats.labels = 1;
        stats.examples = 2;
        stats.totalTime = 'test1';
        stats.transforms = new Einstein_TrainStats.Transforms();
        stats.transforms.toFlip = True;
        stats.transforms.toRotate = True;
        stats.transforms.cropLocation = 'test2';
        stats.trainingTime = 'test3';
        stats.earlyStopping = true;
        stats.lastEpochDone = 3;
        stats.modelSaveTime = 'test4';
        stats.testSplitSize = 4;
        stats.trainSplitSize = 5;
        stats.datasetLoadTime = 'test5';
        stats.preProcessStats = 'test6';
        stats.postProcessStats = 'test7';
        
        System.assertEquals(1,stats.labels);
        System.assertEquals(2,stats.examples); 
        System.assertEquals('test1', stats.totalTime); 
        System.assertEquals(True,stats.transforms.toFlip); 
        System.assertEquals(True,stats.transforms.toRotate); 
        System.assertEquals('test2',stats.transforms.cropLocation); 
        System.assertEquals('test3',stats.trainingTime); 
        System.assertEquals(true,stats.earlyStopping); 
        System.assertEquals(3,stats.lastEpochDone); 
        System.assertEquals('test4',stats.modelSaveTime); 
        System.assertEquals(4,stats.testSplitSize); 
        System.assertEquals(5,stats.trainSplitSize); 
        System.assertEquals('test5',stats.datasetLoadTime); 
        System.assertEquals('test6',stats.preProcessStats); 
        System.assertEquals('test7',stats.postProcessStats); 
        
    } 
    
    
    static testMethod void apiUsage() {
        
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_ApiUsage[] apiUsages = service.getApiUsage();
        
        System.assertEquals(1, apiUsages.size());
        
        Einstein_ApiUsage apiUsage = apiUsages.get(0);
        System.assertEquals('489', apiUsage.id);
        System.assertEquals('108', apiUsage.organizationId);
        System.assertEquals('kJCHtYDCSf', apiUsage.licenseId);
        System.assertEquals(997, apiUsage.predictionsRemaining);
        System.assertEquals(3, apiUsage.predictionsUsed);
        System.assertEquals(1000, apiUsage.predictionsMax);
        System.assertEquals('2017-03-01T00:00:00.000Z', apiUsage.startsAt);
        System.assertEquals('2017-04-01T00:00:00.000Z', apiUsage.endsAt);
        
        Einstein_PlanData planData = apiUsage.planData.get(0);
        System.assertEquals('FREE', planData.plan);
        System.assertEquals('HEROKU', planData.source);
        System.assertEquals(1, planData.amount);
        
    }
    
    
    static testMethod void testOtherMethods() {
        
        System.assertEquals('1ff13444ed8140c7a32fc4e6451aa76d', Einstein_HttpBodyPart.getBoundary());
        
        
        Einstein_HttpBodyPartExample bodyPartExampleInit;
        
        try {
            bodyPartExampleInit = new Einstein_HttpBodyPartExample('', 0, '');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            bodyPartExampleInit = new Einstein_HttpBodyPartExample('123', 0, '');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NullPointerException);
        }
        
        try {
            bodyPartExampleInit = new Einstein_HttpBodyPartExample('123', 1, '');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        Einstein_HttpBodyPartExample bodyPartExample = new Einstein_HttpBodyPartExample('name', 1, 'data');
        System.assertEquals('name', bodyPartExample.getName());
        System.assertEquals(1, bodyPartExample.getLabelId());
        System.assertEquals('data', bodyPartExample.getData());
        
        try {
            bodyPartExample.setName('');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            bodyPartExample.setData('');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.debug(e+' alo');
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        Einstein_HttpBodyPartDatasetUrl bodyPartDatasetUrl = new Einstein_HttpBodyPartDatasetUrl('http://my.test1.com', 'image');
        System.assertEquals('http://my.test1.com', bodyPartDatasetUrl.getUrl());
        System.assertEquals('image', bodyPartDatasetUrl.getType());
        
        bodyPartDatasetUrl.setUrl('http://my.test2.com');
        System.assertEquals('http://my.test2.com', bodyPartDatasetUrl.getUrl());
        
        try {
            bodyPartDatasetUrl.setUrl('');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        Einstein_HttpBodyPartPrediction bodyPartPrediction = new Einstein_HttpBodyPartPrediction('modelId1', 'testData1', 0, '', Einstein_HttpBodyPartPrediction.TYPES.BASE64);
        
        bodyPartPrediction.setModelId('modelId2');
        System.assertEquals('modelId2', bodyPartPrediction.getModelId());
        
        bodyPartPrediction.setData('data2');
        System.assertEquals('data2', bodyPartPrediction.getData());
        
        bodyPartPrediction.setSampleId('sampleId2');
        System.assertEquals('sampleId2', bodyPartPrediction.getSampleId());
        
        bodyPartPrediction.setType(Einstein_HttpBodyPartPrediction.Types.URL);
        System.assertEquals(Einstein_HttpBodyPartPrediction.Types.URL, bodyPartPrediction.getType());
        
        Einstein_HttpBodyPartTraining bodyPartTraining = new Einstein_HttpBodyPartTraining(1, 'Test1', 1, 0, null);
        bodyPartTraining.getTrainParams();
        
        bodyPartTraining.setDatasetId(2);
        System.assertEquals(2, bodyPartTraining.getDatasetId());
        
        try {
            bodyPartTraining.setDatasetId(0);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NoValuesException);
        }
        
        bodyPartTraining.setName('Test2');
        System.assertEquals('Test2', bodyPartTraining.getName());
        
        try {
            bodyPartTraining.setName('');
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            String nameTooLong = 'AbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefgAbcdefg';
            bodyPartTraining.setName(nameTooLong);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {			
            System.assert(e instanceof Einstein_StringTooLongException);
        }
        
        bodyPartTraining.setEpochs(5);
        System.assertEquals(5, bodyPartTraining.getEpochs());
        
        try {
            bodyPartTraining.setEpochs(101);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooBigException);
        }
        
        bodyPartTraining.setLearningRate(0.001);
        System.assertEquals(0.001, bodyPartTraining.getLearningRate());
        
        try {
            bodyPartTraining.setLearningRate(0.1);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooBigException);
        }
        
        try {
            bodyPartTraining.setLearningRate(0.00001);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_NumberTooSmallException);
        }
        
        Einstein_HttpBodyPartFeedbackExample bodyPartFeedbackExample;
        
        bodyPartFeedbackExample = new Einstein_HttpBodyPartFeedbackExample('name', 'expectedLabel', 'modelId', 'data', Einstein_HttpBodyPartFeedbackExample.Types.BASE64);
        System.assertEquals('name', bodyPartFeedbackExample.getName());
        System.assertEquals('expectedLabel', bodyPartFeedbackExample.getExpectedLabel());
        System.assertEquals('modelId', bodyPartFeedbackExample.getModelId());
        System.assertEquals('data', bodyPartFeedbackExample.getData());
        System.assertEquals(Einstein_HttpBodyPartFeedbackExample.Types.BASE64, bodyPartFeedbackExample.getType());
        
        try {
            bodyPartFeedbackExample = new Einstein_HttpBodyPartFeedbackExample('', '', '', '', Einstein_HttpBodyPartFeedbackExample.Types.BASE64);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            bodyPartFeedbackExample = new Einstein_HttpBodyPartFeedbackExample('asdf', '', '', '', Einstein_HttpBodyPartFeedbackExample.Types.BASE64);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            bodyPartFeedbackExample = new Einstein_HttpBodyPartFeedbackExample('asdf', 'asdf', '', '', Einstein_HttpBodyPartFeedbackExample.Types.BASE64);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
        try {
            bodyPartFeedbackExample = new Einstein_HttpBodyPartFeedbackExample('asdf', 'sadf', 'sadf', '', Einstein_HttpBodyPartFeedbackExample.Types.BASE64);
            System.assert(false, 'Exception Expected');
        } catch (Exception e) {
            System.assert(e instanceof Einstein_StringIsEmptyException);
        }
        
    }
    
    static testMethod void testJWT() {
        
        Einstein_JWT jwt = new Einstein_JWT('a');
        jwt.iss = 'b';
        jwt.aud = 'c';
        jwt.sub = 'test';
        jwt.exp = 'd';
        jwt.iat = 'e';
        jwt.claims = new Map<String,String>();
        jwt.claims.put('test','test');
        jwt.validFor = 1;
        jwt.cert = 'f';
        jwt.pkcs8 = 'g';
        jwt.privateKey = 'h';
        String encode = jwt.base64URLencode(Blob.valueOf('QImKMgrxkib9zJxU6d0P'));
        String issue= jwt.issue();
        
        System.assertEquals('a', jwt.alg);
        System.assertEquals('b', jwt.iss);
        System.assertEquals('c', jwt.aud);
        System.assertEquals('test', jwt.sub);
        System.assertEquals('d', jwt.exp);
        System.assertEquals('e', jwt.iat);
        System.assert(!jwt.claims.isEmpty());
        System.assertEquals('f', jwt.cert);
        System.assertEquals('g', jwt.pkcs8);
        System.assertEquals('h', jwt.privateKey);
        System.assertEquals(1, jwt.validFor);
        System.assertEquals('UUltS01ncnhraWI5ekp4VTZkMFA', encode);
        System.assert(!String.isEmpty(issue));
        
        
    }
    
    static testmethod void testPGgetModelMetrics(){
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        test.startTest();
        Einstein_PlaygroundController.getModelMetrics('7JXCXTRXTMNLJCEF2DR5CJ46QU', 'image');
        test.stopTest();
        //already covered in the _service testing--this is just a wrapper
    }
    
    static testmethod void testPGObjectOptions(){
        string objectJSON = Einstein_PlaygroundController.getObjectOptions();
        system.assert(objectJSON.contains('Case'), 'Case should have been included, but wasn\'t');
        
    }
    
    static testmethod void testPGObjectFields(){
        string fieldsJSON = Einstein_PlaygroundController.getObjectFields('Case', 'Source');
        system.assert(fieldsJSON.contains('Description'), 'Case Description should have been included, but wasn\'t');
        
        fieldsJSON = Einstein_PlaygroundController.getObjectFields('Case', 'Label');
        system.assert(fieldsJSON.contains('Reason'), 'Case Reason should have been included, but wasn\'t');
        
    }
    
    static testmethod void testPGOtherMethods(){
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        test.startTest();
        Einstein_PlaygroundController.getDatasets('image');
        Einstein_PlaygroundController.deleteDataset(108, 'image');
        Einstein_PlaygroundController.getDatasets('image-multi-label');
        Einstein_PlaygroundController.getDatasets('image-detection');
        Einstein_PlaygroundController.createDatasetFromUrl('https://www.google.com', 'image');
        Einstein_PlaygroundController.getUsage();
        Einstein_PlaygroundController.getMyUserId();
        Einstein_PlaygroundController.getLearningCurves('7JXCXTRXTMNLJCEF2DR5CJ46QU','image');
        Einstein_PlaygroundController.getModels(57, 'image');
        Einstein_PlaygroundController.trainDataset(57, 'myModel', 'image');
        Einstein_PlaygroundController.retrainDataset('57', 'text-sentiment');
        
        //prediction methods
        Einstein_PlaygroundController.predictImageClassification('123', 'aaabbbccc');
        Einstein_PlaygroundController.predictImageClassificationURL('123', 'https://www.google.com');
        
        Einstein_PlaygroundController.predictImageDetection('123', 'aaabbbccc');
        Einstein_PlaygroundController.predictImageDetectionURL('123', 'https://www.google.com');
        
        Einstein_PlaygroundController.predictIntent('123', 'hello, world');
        Einstein_PlaygroundController.predictSentiment('123', 'hello, world');
        
        
        test.stopTest();
    }
    
    static testmethod void testCaseClassificationProcessBuilderWithoutMock(){
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        insert cse;
    }
    
    // testing invocable methods
    
    static testmethod void testPBLanguage(){
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        TestUtils.enable_isRunningTest = false;
        
        Case c1 = new Case();
        c1.Description = 'this is for standardSentiment';
        c1.origin = 'Email';
        c1.Reason = 'Test';
        c1.SuppliedEmail = 'test@mail.com'; 
        insert c1;
        
        Case c2 = new Case();
        c2.Description = 'this is for customIntent';
        c2.origin = 'Email';
        c2.Reason = 'Test';
        c2.SuppliedEmail = 'test@mail.com';
        insert c2;
        
        Case c3 = new Case();
        c3.Description = 'this is for customSentiment';
        c3.origin = 'Email';
        c3.Reason = 'Test';
        c3.SuppliedEmail = 'test@mail.com'; // SuppliedEmail added to fix null exception on All Cases Process - Jorge Moreira 08/22/2018
        insert c3;
        
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        //settings.Crypto_Key__c = 'abc';
        EinsteinSettings__mdt es;
        upsert settings;        
        
        list<Einstein_Invocable_Language.LanguageRequest> LRs = new list<Einstein_Invocable_Language.LanguageRequest>();
        
        Einstein_Invocable_Language.LanguageRequest LR = new Einstein_Invocable_Language.LanguageRequest();
        LR.recordId = c1.Id;
        LR.FieldToAnalyze = 'Description';
        LR.LabelStoreField = 'Reason';
        
        LRs.add(LR);
        
        Einstein_Invocable_Language.LanguageRequest LR2 = new Einstein_Invocable_Language.LanguageRequest();
        
        LR2.recordId = c3.Id;
        LR2.FieldToAnalyze = 'Description';
        LR2.LabelStoreField = 'Reason';
        LR2.ModelId = '1234';
        LR2.ModelType = 'Sentiment';
        
        list<Einstein_Invocable_Language.LanguageRequest> LRs2 = new list<Einstein_Invocable_Language.LanguageRequest>();
        
        LRs2.add(LR2);
        
        
        Einstein_Invocable_Language.LanguageRequest LR3 = new Einstein_Invocable_Language.LanguageRequest();
        
        LR3.recordId = c2.Id;
        LR3.FieldToAnalyze = 'Description';
        LR3.LabelStoreField = 'Reason';
        LR3.ModelId = '1234';
        LR3.ModelType = 'Intent';
        LR3.ProbabilityStoreField = 'Subject';
        LR3.RawStoreField = 'Description';
        list<Einstein_Invocable_Language.LanguageRequest> LRs3 = new list<Einstein_Invocable_Language.LanguageRequest>();
        
        LRs3.add(LR3);
        
        test.startTest();
        //your code here
        Einstein_Invocable_Language.AnalyzeLanguage(LRs);
        Einstein_Invocable_Language.AnalyzeLanguage(LRs2);
        Einstein_Invocable_Language.AnalyzeLanguage(LRs3);
        
        test.stopTest();
        
        for (case c : [select id, Reason, Description from Case] ){
            if (c.Id == c1.Id){
                //standard sentiment model
                system.assertEquals('Mouse', c.Reason); //changed by Shaurya Bajaj , defect 6112129
            } else if (c.Id == c3.Id){
                //custom sentiment
                system.assertEquals('Mouse', c.Reason); //changed by Shaurya Bajaj , defect 6112129
            } else if (c.Id == c2.Id){
                //custom intent model with probabilities,etc
                system.assertEquals('Mouse', c.Reason);
                //system.assertEquals('{"probabilities":[{"label":"Mouse","probability":0.9917755},{"label":"USB","probability":0.0035287717},{"label":"Slow shutdown","probability":0.0024557777},{"label":"Touchpad","probability":4.2926372E-4},{"label":"Slow boot time","probability":3.1050152E-4}],"object":"predictresponse"}', c.Description);
            }
        }
        
    }
    
    
    static testmethod void testPBLanguageFeedback(){
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        Einstein_Invocable_Language_Feedback.LanguageFeedback LF = new Einstein_Invocable_Language_Feedback.LanguageFeedback();
        LF.ModelId = '1234';
        LF.Label = 'Complaint';
        LF.Text = 'I think this must be the longest apex test class I know';
        
        list<Einstein_Invocable_Language_Feedback.LanguageFeedback> LFs = new list<Einstein_Invocable_Language_Feedback.LanguageFeedback>();
        LFs.add(LF);
        test.startTest();
        //your code here
        Einstein_Invocable_Language_Feedback.AnalyzeLanguage(LFs);
        test.stopTest();
    }
    
    static testmethod void exampleTestMethod(){
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        test.startTest();
        //your code here
        test.stopTest();
    }
    
    static testmethod void testEinstein_NoValuesException(){
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
        test.startTest();
        
        try {
            Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
            service.getDataset(0);
            System.assert(false, 'Expected Einstein_ConfigurationException');
        }
        catch (Exception e) {
            System.assert(e instanceof Einstein_NoValuesException);             
        }
        test.stopTest();
    }
    
    static testmethod void TestHttpError(){
        Test_Einstein_HttpMockResponses httpmock = new Test_Einstein_HttpMockResponses();
        httpmock.forceHttpError = true;
        Test.setMock(HttpCalloutMock.class, httpmock);
        test.startTest();
        Einstein_PredictionService service = new Einstein_PredictionService('123', Einstein_PredictionService.Types.IMAGE);
        Einstein_Dataset dataset = service.createDatasetFromUrlAsync('https://myurl');
        dataset = service.createDatasetFromUrlSync('https://myurl');
        service.getDataset(12);
        service.getDatasets();
        service.deleteDataset(12);
        Einstein_Example example = service.createExample(57, '77880132.jpg', 614, Blob.valueOf('data'));
        Einstein_Dataset dataset2 = service.createExamplesFromUrl(1000022, 'http://my.image.com/test.png');
        service.getExamples(12);
        Einstein_Example example2 = service.createFeedbackLanguageExample('expectedLabel', 'modelId', 'text');
        Einstein_Model model = service.trainDataset(57, 'Beach and Mountain Model', 0, 0, null);
        
        service.getModel('1234');
        service.getModels(12);
        service.getModelLearningCurve('1234');
        service.getModelMetrics('1234');
        service.predictIntent('modelId', 'text', 0, '');
        service.detectImageBase64('YCQ4ZACEPJFGXZNRA6ERF3GL5E', 'aaabbbccc', 0, '');
        service.detectImageBlob('YCQ4ZACEPJFGXZNRA6ERF3GL5E', Blob.valueof('somedata'), 0, '');
        service.predictImageUrl('YCQ4ZACEPJFGXZNRA6ERF3GL5E', 'https://theurl', 0, '');
        
        test.stopTest();        
    }
    
    static testmethod void TestEinstein_GR_Token(){
        Einstein_GR_Token grToken;
        String tokenResp = '{"token_type":"Bearer","access_token":"eyJhbGciOiJSUzUxMiIsImtpZCI6IjNDRjFBNTk1NjQ5MzdFQ0Q0NTE3NDI4QTU3NUU0NUM0OTJBNEFDRTkiLCJ0eXAiOiJKV1QifQ.eyJ1cG4iOiJhZG1pbiIsInVuaXF1ZV9uYW1lIjoiYWRtaW4iLCJlbWFpbCI6IiIsIm5iZiI6MTUzOTg4NDA2MiwiZXhwIjoxNTM5ODg3NjYyLCJpYXQiOjE1Mzk4ODQwNjIsImlzcyI6ImRlcGxveXIubWljcm9zb2Z0LmNvbSIsImF1ZCI6ImRlcGxveXIubWljcm9zb2Z0LmNvbSJ9.IhxLkBGf4J0nfqq_nBsXjZMLYoYjvSIaGSzmIMv8fqpiXNb5f_cDjtSmUGBAkyQX6pAd5ES82mCdFTHJqUqFEtxrt-LCp3L354qWm2s8F2ggz4HQMYYA5KHv-I2xmIsBfkNlAUTSusSBjszn2mp77EAraEXpOy4jw-TKEPpXPGgP9vsFlh2FgOSOOCdInOvvmWo0n0wDhX5rBeeTnY9EtpmO4PUhvw4cQDITdVlddvUnEYh-MhYtJljO8kqEk9njz3eS3aQGmNcPGs12p6xjnIaE3qn4gEpecsvnFLZnIJ5uWDMicld8GFo95zl7pbeK3q5yoMbbi0FvXxx229Fprg","expires_in":3600,"expires_on":1539887662,"refresh_token":"c7AkrokqVJDuaqpFbNtPOOMdfS2+MkwNa0nZu42JTjTYMLdWAIbHXEKfiD8iZbDo2zYoIAzEJaHO5dIFhyTod3K9k724ems7qYvcC2s7Agdxq6x/xAgQnL3JuwTpMzE5woZUPQoRBwAXh/OtoE4aOfEndA2Nfv6zL7G8Yjqabb+d22o/UMlOgFGjgnG/w1mtcjW5Lkb5HPpdWlOtiDgItMNWqqSrYjsZLCJH6iaTeqirfFOomzBpn/vVK73HE68MbKD9z3QVf5IJ1By3w1Jbny/Z8sRE5Z0zUtRiaAElAN5QjQO8z2NllQ4aSDF0l71vH6SZiXSXhXgaLMjvFrCazg=="}';
        String commonResp = '{"success":true,"errorMessage":"","outputParameters":{"nba_output":{"cluster_name":[{"cluster":"mouse - usb - wireless - keyboard"}],"next_best_action":[["Dispatch Part: Mouse"]],"title_pred":[{"issue":"mouse - usb - wireless - keyboard","lob_desc":"Personal Notebooks","top5":[["Mouse Troubleshooting For Windows 7, 8 And 10",0.637970746],["Slow Performance, Lockup And Freeze For Windows 7, 8 And 10",0.07564148],["Touchpad/Trackstick",0.07051654],["Windows 7, 8, 10 Os Installation/Restore",0.0418154672],["Best Effort Software Support",0.0284358561]],"input_text":"mouse not working"}],"next_best_action_link":[["[NA]"]],"tag_info":[{"shipd_dt":"2012-07-06","fmly_desc":"AUDIA5INTELFBTX","lob_desc":"Personal Notebooks","asst_id":"86LKVS1","start_time_utc":"2018-10-23 12:16:41","brand_desc":"INSPIRON 5520"}],"soft_pred":[{"top5":[["Run Supportassist",0.171014667],["Perform Hard Reset",0.120786943],["Perform Clean Boot",0.033226952],["Perform Windows Recovery",0.0325096734],["Perform Operating System Reinstallation",0.03225872]]}],"index":[0],"udt_key_used":[0],"edit_flg":[0],"hard_pred":[{"top5":[["Mouse",0.9632703],["Keyboard, Mouse",0.01724495],["Keyboard",0.00585626345],["Chassis",0.003091401],["Chassis, Keyboard",0.000942832965]],"cost":"low"}]}},"outputFiles":{},"consoleOutput":"","changedFiles":[]}';
		grToken = Einstein_GR_Token.parse(tokenResp);
        grToken = Einstein_GR_Token.parse(commonResp);        
    }
}
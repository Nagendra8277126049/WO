@isTest
public class Test_EinsteinCaseClassifAdmin {
    
    static testmethod void TestController_InitService() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Einstein_CaseClassificAdminController c = new Einstein_CaseClassificAdminController();
        Einstein_CaseClassificAdminController.InitService();
        System.assert(Einstein_CaseClassificAdminController.service != null);
        Test.stopTest();
    }
    
    static testmethod void TestController_getEinsteinApiToken() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        Einstein_CaseClassificAdminController c = new Einstein_CaseClassificAdminController();
        String token = Einstein_CaseClassificAdminController.getEinsteinApiToken();
        System.assert(token == '');
        //System.debug(token + ' / TEST EXECUTION');
        //String sampletoken = 'TFEUJYCKEBL6CMAVB5IMB2NEPHTMP2TU6IHB6N243IMNIV5RGWRCGOKVBEVGZSOQGEPMBTSXW45QNZXMSUXKTTFXFLPIMU4WGCKBFRQ';
        //System.assertEquals(token.length(), sampletoken.length());        
        Test.stopTest();
    }

    static testmethod void TestController_getDatasets() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        Einstein_CaseClassificAdminController c = new Einstein_CaseClassificAdminController();
		List<Einstein_Dataset> datasets = Einstein_CaseClassificAdminController.getDatasets();
        system.debug('datasets size: ' + datasets.size());
        System.assert(datasets.size()>0);        
        Test.stopTest();
    }

    static testmethod void TestController_getModels() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        Einstein_CaseClassificAdminController c = new Einstein_CaseClassificAdminController();
        Long datasetId = 1234;
		List<Einstein_Model> models = Einstein_CaseClassificAdminController.getModels(datasetId);
        System.assert(models.size()>0);           
        Test.stopTest();
    }
    
    static testmethod void TestController_getAdminSettings() {
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.CCModel_ID__c = 'ModelId_123';
        settings.Einstein_EMail__c = 'test@mail.com';
        settings.CCModelLastUpdate__c = Date.today();
        settings.CCModelUpdatedBy__c = 'unit_test_user';
        upsert settings;
        
        Test.startTest();
        Einstein_CaseClassificAdminController c = new Einstein_CaseClassificAdminController();
        Einstein_CaseClassificAdminSettings admsettings = Einstein_CaseClassificAdminController.getAdminSettings();
        System.assert(admsettings.CCModel_ID.length()>0);
        System.assert(admsettings.CCModelLastUpdate == Date.today());
        System.assert(admsettings.CCModelUpdatedBy.length()>0);
        Test.stopTest();
    }    
    
    static testmethod void TestController_updateModelId() {
        String testModelId = 'testModelID';
        Test.startTest();
        Einstein_CaseClassificAdminController c = new Einstein_CaseClassificAdminController();
        String newModelId = Einstein_CaseClassificAdminController.updateModelId(testModelId);
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();                
        System.assertEquals(settings.CCModel_ID__c, testModelId);
        Test.stopTest();
    }     
    
    static testmethod void TestController_getUsage() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        Einstein_CaseClassificAdminController c = new Einstein_CaseClassificAdminController();
        List<Einstein_ApiUsage> usage = Einstein_CaseClassificAdminController.getUsage();
        System.assert(usage.size() > 0);
        Test.stopTest();
    }
    static testmethod void TestController_refreshMetrics() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        System.assertEquals('Confusion Matrix refreshed successfully', Einstein_CaseClassificAdminController.refreshMetrics());
        Test.stopTest();
    }
    
}
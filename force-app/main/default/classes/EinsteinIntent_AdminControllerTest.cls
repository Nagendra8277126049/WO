/**********************************************************************
Name:  EinsteinIntent_AdminControllerTest
======================================================
======================================================
Purpose: Test the class EinsteinIntent_AdminController
-------                                               
This class is an adaptation of the class Test_EinsteinCaseClassifAdmin adding 
methods and configuration related with Accidental Damage
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
1.0   Rayana Alencar   2018-12-10      INITIAL DEVELOPMENT          CSR: 
1.1   Rayana Alencar   2019-02-07	   Update for Code Coverage 
***********************************************************************/

@isTest
public class EinsteinIntent_AdminControllerTest {
    
    static testmethod void TestController_InitService() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        EinsteinIntent_AdminController.InitService();
        System.assert(EinsteinIntent_AdminController.service != null);
        Test.stopTest();
    }
    
    static testmethod void TestController_getEinsteinApiToken() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        String token = EinsteinIntent_AdminController.getEinsteinApiToken();
        System.assert(token == '');       
        //test service error
		EinsteinIntent_AdminController.testServiceError = True;
        try{
            EinsteinIntent_AdminController.getEinsteinApiToken();
        }catch(Exception e){
            System.assertEquals(True, e instanceof AuraHandledException);
        }
        Test.stopTest();
    }
    
    static testmethod void TestController_getDatasets() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        List<Einstein_Dataset> datasets = EinsteinIntent_AdminController.getDatasets();
        system.debug('datasets size: ' + datasets.size());
        System.assert(datasets.size()>0); 
        //test service error
		EinsteinIntent_AdminController.testServiceError = True;
        try{
            EinsteinIntent_AdminController.getDatasets();
        }catch(Exception e){
            System.assertEquals(True, e instanceof AuraHandledException);
        }
        Test.stopTest();
    }
    
    static testmethod void TestController_getModels() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        Long datasetId = 1234;
        List<Einstein_Model> models = EinsteinIntent_AdminController.getModels(datasetId);
        System.assert(models.size()>0); 
        //test service error
		EinsteinIntent_AdminController.testServiceError = True;
        try{
            EinsteinIntent_AdminController.getModels(datasetId);
        }catch(Exception e){
            System.assertEquals(True, e instanceof AuraHandledException);
        }
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
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        EinsteinIntent_AdminSettings admsettings = EinsteinIntent_AdminController.getAdminSettings();
        System.assert(admsettings.CCModel_ID.length()>0);
        System.assert(admsettings.CCModelLastUpdate == Date.today());
        System.assert(admsettings.CCModelUpdatedBy.length()>0);
        Test.stopTest();
    }    
    
    static testmethod void TestController_updateCaseModelId() {
        String testModelId = 'testModelID';
        Test.startTest();
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.CCModel_ID__c = testModelId;
        upsert settings;
        
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        String newModelId = EinsteinIntent_AdminController.updateCaseModelId(testModelId);
        //Einstein_Settings__c settings_new = Einstein_Settings__c.getOrgDefaults();                
        System.assertEquals(settings.CCModel_ID__c, newModelId);
        
        //test error modelID
        try{
            EinsteinIntent_AdminController.updateCaseModelId('123');    
        }catch(Exception e){
            System.assertEquals(True, e instanceof AuraHandledException);
        }
        
        Test.stopTest();
    }     
    
    static testmethod void TestController_updateADModelId() {
        String testModelId = 'testModelID';
        Test.startTest();
        // added by Shaurya Bajaj , defect 6112110
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults(); 
        settings.CCModel_ID__c = testModelId;
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        String newModelId = EinsteinIntent_AdminController.updateAccDamageModelId(testModelId);           
        System.assertEquals(settings.CCModel_ID__c, testModelId);
        //test error modelID
        try{
            EinsteinIntent_AdminController.updateAccDamageModelId('123');    
        }catch(Exception e){
            System.assertEquals(True, e instanceof AuraHandledException);
        }
        Test.stopTest();
    }
    
    static testmethod void TestController_getUsage() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        EinsteinIntent_AdminController c = new EinsteinIntent_AdminController();
        List<Einstein_ApiUsage> usage = EinsteinIntent_AdminController.getUsage();
        System.assert(usage.size() > 0);
        //test service error
		EinsteinIntent_AdminController.testServiceError = True;
        try{
            EinsteinIntent_AdminController.getUsage();
        }catch(Exception e){
            System.assertEquals(True, e instanceof AuraHandledException);
        }
        Test.stopTest();
    }
    static testmethod void TestController_refreshMetrics() {
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        Test.startTest();
        System.assertEquals('Confusion Matrix refreshed successfully', EinsteinIntent_AdminController.refreshMetrics());
        Test.stopTest();
    }
}
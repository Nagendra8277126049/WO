@isTest
private class ARRProposalApexControllerTest {
	@testSetup static void createData(){
        ARROrderSettings__c orderSetting = new ARROrderSettings__c();
        orderSetting.DSAUrl__c = 'http://sales-sit-g1.dell.com/#/quote/create?customerId={buid}~~{customerNumber}&customerNumber={customerNumber}';
        insert orderSetting; 
        
        ARRProposalSettings__c proposalSettings = new ARRProposalSettings__c();
        proposalSettings.BaseUnitsUrl__c = 'a';
        proposalSettings.BrandsUrl__c = 'b';
        proposalSettings.DeleteVrpUrl__c = 'c';
        proposalSettings.NewUrl__c = 'd';
        proposalSettings.PostServiceSku__c = 'e';
        proposalSettings.ProcessorsUrl__c = 'f';
        proposalSettings.RefreshVrpUrl__c = 'g';
        proposalSettings.SummaryUrl__c = 'h';
        proposalSettings.TypesUrl__c = 'i';
        insert proposalSettings;  
        
        Account mockedAccountId = new Account();
        mockedAccountId.Name = 'Mock Id';
        insert mockedAccountId;
        
    }
    
    @isTest
    static void getMethods(){
        Account mockedId = [SELECT Id from Account WHERE Name = 'Mock Id'];
        String resultOrderSetting =  ARRProposalApexController.getOrderLink('US');
        ARROrderSettings__c assertOrderSetting = [SELECT Id, DSAUrl__c FROM  ARROrderSettings__c];
        system.assertEquals(assertOrderSetting.DSAUrl__c, resultOrderSetting);
        
        String resultOrderSettingError =  ARRProposalApexController.getOrderLink('BR');
		system.assertEquals(null, resultOrderSettingError);
        
        //Check if there are records for this custom metadata
        List<ARRCountry__mdt> countriesList = ARRProposalApexController.getCountries();
        system.assertEquals(false, countriesList.isEmpty());
        
        List<ARRServiceType__mdt> serviceTypeList = ARRProposalApexController.getServiceTypes();
        system.assertEquals(false, serviceTypeList.isEmpty());
        
        ARRProposalSettings__c proposalSettings = ARRProposalApexController.getSettings();
        ARRProposalSettings__c assertproposalSettings = [SELECT BrandsUrl__c, TypesUrl__c, ProcessorsUrl__c, BaseUnitsUrl__c, NewUrl__c, SummaryUrl__c, RefreshVrpUrl__c, DeleteVrpUrl__c, PostServiceSku__c FROM ARRProposalSettings__c];
        system.assertEquals(assertproposalSettings, proposalSettings);
        
        String externalId = ARRProposalApexController.getExternalId(mockedId.Id);
        String assertexternalId = '620c1a93-0b40-426b-2245-08d634f76640';
        system.assertEquals(assertexternalId, externalId);
        
        String internalId = ARRProposalApexController.getInternalId(mockedId.Id);
    }
    
    @isTest
    static void calloutTest(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.makeRequest('GET', 'TEST', 'TEST');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
        
    }
    
    @isTest
    static void calloutTestPost(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.makeRequest('POST', 'TEST', 'TEST');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    
    @isTest
    static void calloutTestPostDispatch(){
        Account mockedId = [SELECT Id from Account WHERE Name = 'Mock Id'];
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.postDispatch(mockedId.Id);
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestGetSummary(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.getSummary('123');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestGetTypes(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.getTypes();
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestGetBrands(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.getBrands();
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestGetProcessors(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.getProcessors();
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestGetBaseUnits(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.getBaseUnits('Base');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestnewVrp(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.newVrp('Base');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestrefreshVrp(){
        Account mockedId = [SELECT Id from Account WHERE Name = 'Mock Id'];
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.refreshVrp(mockedId.Id);
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestdeleteVrp(){
        Account mockedId = [SELECT Id from Account WHERE Name = 'Mock Id'];
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.deleteVrp(mockedId.Id);
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestnewServiceSku(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRProposalApexController.newServiceSku('body');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
}
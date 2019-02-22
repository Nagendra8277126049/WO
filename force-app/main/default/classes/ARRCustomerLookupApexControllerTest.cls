@isTest
private class ARRCustomerLookupApexControllerTest {
	@testSetup static void createData(){
    	ARRCustomerLookupSettings__c customerSetting = new ARRCustomerLookupSettings__c();
        customerSetting.CustomerAssetUrl__c = 'testUrl';
        insert customerSetting;
    }
    
    @isTest
    static void getMethods(){
        ARRCustomerLookupSettings__c assertCustomerSetting = [SELECT Id, CustomerAssetUrl__c FROM ARRCustomerLookupSettings__c];
        ARRCustomerLookupSettings__c customerSetting = ARRCustomerLookupApexController.getSettings();
        system.assertEquals(assertCustomerSetting, customerSetting);
    }
    
    @isTest
    static void calloutTest(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRCustomerLookupApexController.makeRequest('GET', 'TEST', 'TEST');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
        
    }
    
    @isTest
    static void calloutTestPost(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRCustomerLookupApexController.makeRequest('POST', 'TEST', 'TEST');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestGetAssetsFromCustomer(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRCustomerLookupApexController.getAssetsFromCustomer('11', '1234');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTestGetAssetsFromCustomerWithPages(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARRCustomerLookupApexController.getAssetsFromCustomerWithPages('11', '1234', 1, 2, 'name', 'vertical');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
}
@isTest
private class ARROrderApexControllerTest {
	@testSetup static void createData(){
        ARROrderFulfillmentSettings__c orderSettings = new ARROrderFulfillmentSettings__c();
        orderSettings.ReleaseOnHold__c = 'a';
        orderSettings.CreateOrderForDispatch__c = 'b';
        orderSettings.NewOrderUrl__c = 'c';
        insert orderSettings;
    }
    
    @isTest
    static void calloutTest_releaseSettlement(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 	
        ActionResult httpResponse = ARROrderApexController.releaseSettlement('x0XK00000004CJ3MAM');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void calloutTest_postOrderForSettlement(){
        test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess('{"DpId": "123", "Quantity": 5}')); 	
        ActionResult httpResponse = ARROrderApexController.postOrderForSettlement('x0XK00000004CJ3MAM');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
}
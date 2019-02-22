@isTest
private class ARRInvoiceSenderFlowActionTest {
	@testSetup static void createData(){
        ARRValueRecoverySetings__c recoverySettings = new ARRValueRecoverySetings__c();
        recoverySettings.VRDollarURL__c = 'a';
        recoverySettings.RevertInvoiceURL__c = 'revert';
        recoverySettings.WireTransferRequestURL__c = 'tes';
        recoverySettings.CreateInvoiceURL__c = 'create';
        recoverySettings.WireTransferTaxesURL__c = 'taxes';
        insert recoverySettings;         
    }
    
    @isTest
    static void sendInvoiceManual(){
        List<ARRInvoiceSenderFlowAction.InvoiceParameter> invoice = new List<ARRInvoiceSenderFlowAction.InvoiceParameter>();
        ARRInvoiceSenderFlowAction.InvoiceParameter parameters = new ARRInvoiceSenderFlowAction.InvoiceParameter();
        parameters.buId = 11223344;
        parameters.dispatchID = 1232312;
        parameters.isManualInvoice = true;
        parameters.accountName = 'Loggi';
        parameters.accountNumber = '997722';
        parameters.bankBranch = 'Central Park';
        parameters.bankNumber = '231';
        parameters.country = 'CA';
        invoice.add(parameters);
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 
        List<List<String>> result = ARRInvoiceSenderFlowAction.SendInvoice(invoice);
        system.assertEquals(result[0][0], 'OK');
        system.assertEquals(result[0][1], 'Invoice created.<br/>Invoice Total: null<br/>Remaining on Settlement: null');
        test.stopTest();
    }
    
    @isTest
    static void sendInvoiceManualError(){
        List<ARRInvoiceSenderFlowAction.InvoiceParameter> invoice = new List<ARRInvoiceSenderFlowAction.InvoiceParameter>();
        ARRInvoiceSenderFlowAction.InvoiceParameter parameters = new ARRInvoiceSenderFlowAction.InvoiceParameter();
        parameters.buId = 11223344;
        parameters.dispatchID = 1232312;
        parameters.isManualInvoice = true;
        parameters.accountName = 'Loggi';
        parameters.accountNumber = '997722';
        parameters.bankBranch = 'Central Park';
        parameters.bankNumber = '231';
        parameters.country = 'CA';
        invoice.add(parameters);
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockError()); 
        List<List<String>> result = ARRInvoiceSenderFlowAction.SendInvoice(invoice);
        system.assertEquals(result[0][0], 'NOT_OK');
        test.stopTest();
    }
    
    @isTest
    static void sendInvoiceNotManual(){
        List<ARRInvoiceSenderFlowAction.InvoiceParameter> invoice = new List<ARRInvoiceSenderFlowAction.InvoiceParameter>();
        ARRInvoiceSenderFlowAction.InvoiceParameter parameters = new ARRInvoiceSenderFlowAction.InvoiceParameter();
        parameters.buId = 11223344;
        parameters.dispatchID = 1232312;
        parameters.isManualInvoice = false;
        parameters.accountName = 'Loggi';
        parameters.accountNumber = '997722';
        parameters.bankBranch = 'Central Park';
        parameters.bankNumber = '231';
        parameters.country = 'CA';
        parameters.wireTransferItems = '[{"ItemGroup": {"item":{"amount":132,"description":"teste"}}}]';
        invoice.add(parameters);
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 
        ARRInvoiceSenderFlowAction.SendInvoice(invoice);
        test.stopTest();
    }
    
    @isTest
    static void sendInvoiceNotManualError(){
        List<ARRInvoiceSenderFlowAction.InvoiceParameter> invoice = new List<ARRInvoiceSenderFlowAction.InvoiceParameter>();
        ARRInvoiceSenderFlowAction.InvoiceParameter parameters = new ARRInvoiceSenderFlowAction.InvoiceParameter();
        parameters.buId = 11223344;
        parameters.dispatchID = 1232312;
        parameters.isManualInvoice = false;
        parameters.accountName = 'Loggi';
        parameters.accountNumber = '997722';
        parameters.bankBranch = 'Central Park';
        parameters.bankNumber = '231';
        parameters.country = 'CA';
        parameters.wireTransferItems = '[{"ItemGroup": {"item":{"amount":132,"description":"teste"}}}]';
        invoice.add(parameters);
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockError()); 
        ARRInvoiceSenderFlowAction.SendInvoice(invoice);
        test.stopTest();
    }
    
    @isTest
    static void sendRevertInvoice(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 
        ActionResult httpResponse = ARRInvoiceSenderFlowAction.RevertInvoice('testing');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
    
    @isTest
    static void getTaxesbyCountry(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ARRHttpResponseMockSuccess()); 
        ActionResult httpResponse = ARRInvoiceSenderFlowAction.GetTaxesByCountry('USA');
        system.assertEquals(httpResponse.Body, '{"SUCESS": "OK"}');
        system.assertEquals(httpResponse.Status, 200);
        test.stopTest();
    }
}
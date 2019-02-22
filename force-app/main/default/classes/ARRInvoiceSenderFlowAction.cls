global class ARRInvoiceSenderFlowAction{
    @AuraEnabled
    public static ActionResult RevertInvoice(String body) {
        ARRValueRecoverySetings__c settings = ApiSettings();
        HttpResponse res = SendHttp(FullUrl(settings.VRDollarURL__c, settings.RevertInvoiceURL__c), 'POST', body);
        ActionResult response = new ActionResult(res.getBody(), res.getStatusCode());
		return response;
    }
    
    @AuraEnabled
    public static ActionResult GetTaxesByCountry(string country){
        ARRValueRecoverySetings__c settings = ApiSettings();
        string url = FullUrl(settings.VRDollarURL__c, settings.WireTransferTaxesURL__c);
        url = url.replace('{country}', country);
        HttpResponse res = SendHttp(url, 'GET', null);
        ActionResult response = new ActionResult(res.getBody(), res.getStatusCode());
		return response;
    }
    
    @InvocableMethod
    public static List<List<String>> SendInvoice(InvoiceParameter[] invoice) {
        if(invoice[0].isManualInvoice)
        	return ToFlowOutput(SendManualInvoice(invoice[0], ApiSettings()), InvoiceApiResponse.class);
        else
            return ToFlowOutput(SendWireTransferInvoice(invoice[0], ApiSettings()), WireTransferApiResponse.class );
    }
    
    private static List<List<String>> ToFlowOutput(HttpResponse response, Type classType){
        List<String> messages = new List<String>();
        List<List<String>> results = new List<List<String>>();
        results.add(messages);
        String body = response.getBody();
        Integer code = response.getStatusCode();
        
        if(code >= 200 && code < 300)
        {   
            messages.add('OK');
            if(String.isBlank(body)) 
            	messages.add('Invoice Created with success.');
            else{
                IInvoiceApiResponse apiResponse = (IInvoiceApiResponse)JSON.deserialize(body, classType);
                messages.add(apiResponse.HtmlMessage());
            }
        }
        else
        {
            messages.add('NOT_OK'); 
            messages.add(body); 
        }
        return results;
    }
    
    private static string FullUrl(string base, string relative){
        return base.replace('{0}', relative);
    }
    
    private static HttpResponse SendWireTransferInvoice(InvoiceParameter invoice, ARRValueRecoverySetings__c settings){
        return SendHttp(FullUrl(settings.VRDollarURL__c, settings.WireTransferRequestURL__c), 'POST', new WireTransferRequest(invoice));
    }
    
    private static HttpResponse SendManualInvoice(InvoiceParameter invoice, ARRValueRecoverySetings__c settings){
        return SendHttp(FullUrl(settings.VRDollarURL__c, settings.CreateInvoiceURL__c), 'POST', invoice);
    }
    
    private static HttpResponse SendHttp(string url, string method, Object body){
        Http http = new Http();
        HttpRequest request = new HttpRequest();        
        request.setEndpoint(url);
        request.setMethod(method);
        if(method != 'GET') 
        {
            string bodyString = (body instanceof string) ? (string)body : JSON.serialize(body);
            request.setBody(bodyString);
        }
        request.setHeader('Content-Type', 'application/json');         
        return http.send(request);
    }
    
    private static ARRValueRecoverySetings__c ApiSettings(){
        List<ARRValueRecoverySetings__c> settings = [SELECT VRDollarURL__c, 
                                                            CreateInvoiceURL__c, 
                                                            RevertInvoiceURL__c, 
                                                            WireTransferTaxesURL__c, 
                                                            WireTransferRequestURL__c 
                                                     FROM ARRValueRecoverySetings__c];
        return settings[0];
    }
    
    public class InvoiceParameter{
        @InvocableVariable(required=true)
        public long buId;
        
        @InvocableVariable(required=true)
        public long dispatchID;
        
        @InvocableVariable
        public decimal invoiceAmount;
        
        @InvocableVariable(required=true)
        public string currencyCode;
        
        @InvocableVariable(required=true)
        public string customerNumber;
        
        @InvocableVariable(required=true)
        public string transactionType;
        
        @InvocableVariable(required=true)
        public string wireTransferItems;
        
        @InvocableVariable(required=true)
        public Boolean isManualInvoice;
        
        @InvocableVariable
        public string bankNumber;
        
        @InvocableVariable
        public string bankBranch;
        
        @InvocableVariable
        public string accountNumber;
        
        @InvocableVariable
        public string accountName;
        
        @InvocableVariable
        public string country;
    }
    
    private class Beneficiary{
        public string bankNumber;
        public string bankBranch;
        public string accountNumber;
        public string name;
        public string country;
    }
    
    private virtual class Item{
        public decimal amount;
        public string description;
    }
    
    private class TaxItem extends Item{
        public decimal taxRate;
        public string taxType;
    }
    private class ItemGroup{
        public Item item;
        public TaxItem[] taxes;
    }
    
    private class WireTransferRequest{
        public WireTransferRequest(InvoiceParameter parameter){
            buId = parameter.buId;
            currencyCode = parameter.currencyCode;
            customerNumber = parameter.customerNumber;
            dispatchID = parameter.dispatchID;
            invoiceAmount = parameter.invoiceAmount;
            transactionType = parameter.transactionType;
            itemGroups = (List<ItemGroup>)JSON.deserialize(parameter.wireTransferItems, List<ItemGroup>.class);
            beneficiary = new Beneficiary();
            beneficiary.bankNumber = parameter.bankNumber;
            beneficiary.bankBranch = parameter.bankBranch;
            beneficiary.accountNumber = parameter.accountNumber;
            beneficiary.country = parameter.country;
            beneficiary.name = parameter.accountName;
            sourceApplication = 'SALESFORCE';
        }
        public string sourceApplication;
        public long buId;
        public long dispatchID;
        public decimal invoiceAmount;
        public string currencyCode;
        public string customerNumber;
        public string transactionType;
        public List<ItemGroup> itemGroups;
        public Boolean isManualInvoice;
        public Beneficiary beneficiary;
    }
    
    private interface IInvoiceApiResponse{
        string HtmlMessage();
    }
    
    private class WireTransferApiResponse implements IInvoiceApiResponse{
        public string HtmlMessage(){
            return 'Invoice created.<br/>Invoice Total: ';
        }
    }
    
    private class InvoiceApiResponse implements IInvoiceApiResponse{
        public decimal RequestedValue;
        public decimal ValueDebited;
        public decimal ValueRemainingOnSettlement;
        
        public string HtmlMessage(){
            return 'Invoice created.<br/>Invoice Total: ' + ValueDebited + '<br/>Remaining on Settlement: '+ ValueRemainingOnSettlement;
        }
    }
}
public class ARROrderApexController {
    @AuraEnabled
    public static ActionResult releaseSettlement(string requestId) {
        Settlement__x settlementInfo = getSettlement(requestId);
        
        ARROrderFulfillmentSettings__c settings = [SELECT ReleaseOnHold__c from ARROrderFulfillmentSettings__c LIMIT 1];
        string url = settings.ReleaseOnHold__c.replace('{dispatchId}', settlementInfo.DispatchId__c).replace('{serviceType}', 'ResaleAndRecycle');
        
        return makeRequest('POST', url, '', false);
    }
	    
    @AuraEnabled
    public static ActionResult postOrderForSettlement(string requestId) {
        Settlement__x settlementInfo = getSettlement(requestId);
        
		Account account = getAccountByExternalId(settlementInfo.Account__c);

        ARROrderFulfillmentSettings__c settings = [SELECT CreateOrderForDispatch__c from ARROrderFulfillmentSettings__c LIMIT 1];
        string url = settings.CreateOrderForDispatch__c.replace('{dispatchId}', settlementInfo.DispatchId__c).replace('{serviceType}', 'ResaleAndRecycle');
        
        ActionResult dispatchInfoRequest = makeRequest('POST', url, '', false);
        
        if (dispatchInfoRequest.Status == 200) {
            string bodyToParse = dispatchInfoRequest.Body;
            bodyToParse = bodyToParse.substring(bodyToParse.indexOf('{'), bodyToParse.indexOf('}')+1).replace('\\', '');     //(str), dispatchInfoRequest.Body.length() -1);
            OrderForDispatchResponse dispatchInfo = (OrderForDispatchResponse) System.JSON.deserialize(bodyToParse, OrderForDispatchResponse.class);
            
            return postManualOrderFor(account.Id, 'ResaleAndRecycle', dispatchInfo.Quantity, dispatchInfo.DpId);
        } else {
            return dispatchInfoRequest; 
        }           
    }
    
    
    private static ActionResult postManualOrderFor(string requestId, string serviceType, string quantity, string dpId) {
        Account accountInfo = getAccount(requestId);
        Contact contactInfo = getContact(requestId);
		string sku = getSkuForServiceType(serviceType, accountInfo.Buid__c);
        
        string body = OrderRequest(accountInfo, contactInfo, sku, quantity, dpId);
        
 		ARROrderFulfillmentSettings__c settings = [SELECT NewOrderUrl__c from ARROrderFulfillmentSettings__c LIMIT 1];
        return makeRequest('POST', settings.NewOrderUrl__c, body, true);
    }
    
    
    private static Settlement__x getSettlement(string internalId) {
        if(Test.isRunningTest())
            return new Settlement__x(Account__c = '8888-11', DispatchId__c = '666' , TotalDebit__c = 5);
        return  [SELECT Account__c, DispatchId__c, TotalDebit__c FROM Settlement__x WHERE Id = :internalId LIMIT 1];
    }
    
    private static Account getAccountByExternalId(string externalId) {
        string customerNumber = externalId.Split('-')[0];
        string customerBuid = externalId.Split('-')[1];
        return getAccount(customerNumber, customerBuid);
    }
    
    private static Account getAccount(string customerNumber, string buId){
        if(Test.isRunningTest())
            return new Account(Id = '0012a00000UosXtAAJ');
        return [SELECT Id from Account WHERE Buid__c = :buId AND AccountNumber = :customerNumber LIMIT 1];
    }
    
    private static Account getAccount(Id internalId) {
        if(Test.isRunningTest())
            return new Account(Buid__c = '11', AccountNumber = '8888' , Name = 'TestAccount');
        
        return [SELECT Buid__c, AccountNumber, Name FROM Account WHERE Id = :internalId LIMIT 1];
    }
    
    private static Contact getContact(Id internalId) {
        if(Test.isRunningTest())
            return new Contact(Country_Code__c = 'US', Email = 'TestContact@test.com');
        
        return [SELECT Country_Code__c, Name, Email FROM Contact WHERE AccountId = :internalId LIMIT 1];
    }
    
    private static string getSkuForServiceType(string serviceType, string buid) {
        if(Test.isRunningTest())
            return '8080-123';
        
        return [SELECT SkuNumber__c FROM ServiceSku__X WHERE Buid__c = :buid AND ServiceType__c = :serviceType LIMIT 1].SkuNumber__c;
    }
    
    
    private static ActionResult makeRequest(String type, String url, string body, boolean xml){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
		req.setEndpoint(url);	
		req.setMethod(type);
        
        if (xml)
        	req.setHeader('Content-Type', 'text/xml');
        else
        	req.setHeader('Content-Type', 'application/json');
        
        if (type != 'GET' && body != ''){
            req.setBody(body);
        }
        
		HttpResponse res = h.send(req);
        
        ActionResult response = new ActionResult(res.getBody(), res.getStatusCode());
		return response;
    }
    
    
    private static string OrderRequest(Account acc, Contact cct, string sku, string quantityInput, string dpId) {
        string today = Datetime.newInstanceGmt(Date.today(), Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        integer orderNumber = Integer.valueOf(Math.random() * 100000000);
		string xml = '<ns0:Order'+
'\n    xmlns:ns0="http://xmlns.dell.com/Services/DMT/Order/V1">'+
'\n    <ns0:OrderHeader>'+
'\n        <ns0:OrderNum>S'+orderNumber+'</ns0:OrderNum>'+
'\n        <ns0:BUID>'+acc.Buid__c+'</ns0:BUID>'+
'\n        <ns0:DPID>'+dpId+'</ns0:DPID>'+
'\n        <ns0:CustomerNum>'+acc.AccountNumber+'</ns0:CustomerNum>'+
'\n        <ns0:OrderDate>'+today+'</ns0:OrderDate>'+
'\n        <ns0:InvDate/>'+
'\n        <ns0:CurrencyCode>USD</ns0:CurrencyCode>'+
'\n        <ns0:LocalChannel></ns0:LocalChannel>'+
'\n        <ns0:LocalChannelDesc></ns0:LocalChannelDesc>'+
'\n        <ns0:SubChannel></ns0:SubChannel>'+
'\n        <ns0:SvcReqID/>'+
'\n        <ns0:ShipToSeqNum></ns0:ShipToSeqNum>'+
'\n        <ns0:ShippedDate/>'+
'\n        <ns0:ShipByDate>'+today+'</ns0:ShipByDate>'+
'\n        <ns0:PoNum></ns0:PoNum>'+
'\n        <ns0:EmailId>ManualOrder@ARR.COM</ns0:EmailId>'+
'\n        <ns0:SalesrepPhoneExt></ns0:SalesrepPhoneExt>'+
'\n        <ns0:SalesrepNum></ns0:SalesrepNum>'+
'\n        <ns0:SalesrepName></ns0:SalesrepName>'+
'\n        <ns0:SalesrepEmail>ManualOrder@ARR.COM</ns0:SalesrepEmail>'+
'\n        <ns0:OrigRefOrderNum/>'+
'\n        <ns0:CurrentStatusDate>'+today+'</ns0:CurrentStatusDate>'+
'\n        <ns0:LocalOrderStatusCode>EXP</ns0:LocalOrderStatusCode>'+
'\n        <ns0:SoldToCustomer>'+
'\n            <ns0:CustomerNum>'+acc.AccountNumber+'</ns0:CustomerNum>'+
'\n            <ns0:CompanyName>'+acc.Name+'</ns0:CompanyName>'+
'\n            <ns0:CountryCode>US</ns0:CountryCode>'+
'\n            <ns0:StateAbbrev></ns0:StateAbbrev>'+
'\n            <ns0:City></ns0:City>'+
'\n            <ns0:PostalCode>MISSING</ns0:PostalCode>'+
'\n            <ns0:Address1>MISSING</ns0:Address1>'+
'\n            <ns0:Address2/>'+
'\n            <ns0:Address3/>'+
'\n            <ns0:Address4/>'+
'\n            <ns0:WorkPhoneNumber></ns0:WorkPhoneNumber>'+
'\n            <ns0:PhoneAreaCode></ns0:PhoneAreaCode>'+
'\n            <ns0:PhoneNumber></ns0:PhoneNumber>'+
'\n            <ns0:FirstName></ns0:FirstName>'+
'\n            <ns0:LastName>'+cct.Name+'</ns0:LastName>'+
'\n            <ns0:MiddleInitial></ns0:MiddleInitial>'+
'\n            <ns0:EmailId>'+cct.Email+'</ns0:EmailId>'+
'\n        </ns0:SoldToCustomer>'+
'\n        <ns0:BillToCustomer>'+
'\n            <ns0:CustomerNum>9999999999</ns0:CustomerNum>'+
'\n            <ns0:CompanyName>DELL ARR</ns0:CompanyName>'+
'\n            <ns0:CountryCode>US</ns0:CountryCode>'+
'\n            <ns0:StateAbbrev></ns0:StateAbbrev>'+
'\n            <ns0:City></ns0:City>'+
'\n            <ns0:PostalCode>MISSING</ns0:PostalCode>'+
'\n            <ns0:Address1>MISSING</ns0:Address1>'+
'\n            <ns0:Address2></ns0:Address2>'+
'\n            <ns0:Address3/>'+
'\n            <ns0:Address4/>'+
'\n            <ns0:WorkPhoneNumber></ns0:WorkPhoneNumber>'+
'\n            <ns0:PhoneAreaCode></ns0:PhoneAreaCode>'+
'\n            <ns0:PhoneNumber></ns0:PhoneNumber>'+
'\n            <ns0:FirstName></ns0:FirstName>'+
'\n            <ns0:LastName>ARR</ns0:LastName>'+
'\n            <ns0:MiddleInitial/>'+
'\n            <ns0:EmailId>ManualOrder@ARR.COM</ns0:EmailId>'+
'\n        </ns0:BillToCustomer>'+
'\n        <ns0:ShipToCustomer>'+
'\n            <ns0:CustomerNum>'+acc.AccountNumber+'</ns0:CustomerNum>'+
'\n            <ns0:CompanyName>'+acc.Name+'</ns0:CompanyName>'+
'\n            <ns0:CountryCode>US</ns0:CountryCode>'+
'\n            <ns0:StateAbbrev></ns0:StateAbbrev>'+
'\n            <ns0:City></ns0:City>'+
'\n            <ns0:PostalCode>MISSING</ns0:PostalCode>'+
'\n            <ns0:Address1>MISSING</ns0:Address1>'+
'\n            <ns0:Address2></ns0:Address2>'+
'\n            <ns0:Address3/>'+
'\n            <ns0:Address4/>'+
'\n            <ns0:WorkPhoneNumber></ns0:WorkPhoneNumber>'+
'\n            <ns0:PhoneAreaCode></ns0:PhoneAreaCode>'+
'\n            <ns0:PhoneNumber></ns0:PhoneNumber>'+
'\n            <ns0:FirstName></ns0:FirstName>'+
'\n            <ns0:LastName>'+cct.Name+'</ns0:LastName>'+
'\n            <ns0:MiddleInitial/>'+
'\n            <ns0:EmailId>'+cct.Email+'</ns0:EmailId>'+
'\n        </ns0:ShipToCustomer>'+
'\n    </ns0:OrderHeader>'+
'\n    <ns0:OrderLines>'+
'\n        <ns0:OrderLine>'+
'\n            <ns0:ARS_SKU_NUM>'+sku+'</ns0:ARS_SKU_NUM>'+
'\n            <ns0:SkuDesc>SKU from a Manual Order call</ns0:SkuDesc>'+
'\n            <ns0:ShipQty>'+Integer.valueOf(quantityInput)+'</ns0:ShipQty>'+
'\n            <ns0:ProductLineDesc></ns0:ProductLineDesc>'+
'\n            <ns0:UnitListPriceUSD>0.00</ns0:UnitListPriceUSD>'+
'\n            <ns0:OrderSvcTagID/>'+
'\n            <ns0:SystemType></ns0:SystemType>'+
'\n        </ns0:OrderLine>'+
'\n    </ns0:OrderLines>'+
'\n</ns0:Order>';
        
    	string escapedXml = xml.replace('&', 'amp;');
        return escapedXml;
    }
    
    private class OrderForDispatchResponse {
        public string DpId;
        public string Quantity;
    }
    
}
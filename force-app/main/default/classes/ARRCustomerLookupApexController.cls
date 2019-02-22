public class ARRCustomerLookupApexController {
    @AuraEnabled
    public static ActionResult getAssetsFromCustomer(String buid, String customerNum){
        ARRCustomerLookupSettings__c settings = getSettings();
        string url = settings.CustomerAssetUrl__c.replace('{customerNum}', customerNum).replace('{buid}', buid);
        
        return makeRequest('GET', url, null);
    }

    // TEST pagination
    @AuraEnabled
    public static ActionResult getAssetsFromCustomerWithPages(String buid, String customerNum, integer currentPage, integer perPage, String sortedBy, String sortedDirection){
        ARRCustomerLookupSettings__c settings = getSettings();
        
        string tempParamUrl = buid + '&currentPage=' + currentPage + '&perPage=' + perPage +'&sortedBy=' + sortedBy + '&sortedDirection=' + sortedDirection;
        
        string url = settings.CustomerAssetUrl__c
            .replace('{customerNum}', customerNum)
            .replace('{buid}', tempParamUrl);
            
        return makeRequest('GET', url, null);
    }
    
    public static ActionResult makeRequest(String type, String url, string body){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(url);	
        req.setMethod(type);
        req.setHeader('Content-Type','application/json');
        req.setTimeout(40000);
        
        if (type != 'GET')
        	req.setBody(body);
        
        HttpResponse res = h.send(req);
 
        ActionResult response = new ActionResult(res.getBody(), res.getStatusCode());
        
        return response;
    }
    
    public static ARRCustomerLookupSettings__c getSettings(){
        List<ARRCustomerLookupSettings__c> settings = [SELECT CustomerAssetUrl__c FROM ARRCustomerLookupSettings__c];
        return settings[0];
    }
}
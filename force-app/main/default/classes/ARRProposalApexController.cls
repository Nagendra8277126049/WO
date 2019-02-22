public class ARRProposalApexController {
    @AuraEnabled
    public static String getExternalId(Id internalId) {
        return getProposal(internalId).proposalId__c;
    }
    
    public static Proposal__X getProposal(Id internalId) {
        if(!Test.isRunningTest())
        	return [SELECT proposalId__c,
                 		Buid__c,
                 		CustomerNumber__c 
                    FROM Proposal__x WHERE Id = :internalId LIMIT 1];
        else
            return new Proposal__X(proposalId__c ='620c1a93-0b40-426b-2245-08d634f76640', BuId__c = '11', CustomerNumber__c = '12345');
    }
    
    public class DispatchRequest{
        public string customerNumber;
        public Integer buId;
        public Integer quantity;
        public decimal profitShare;
        
        public DispatchRequest(string customerNumber, Integer buId, Integer quantity, decimal profitShare){
            this.customerNumber = customerNumber;
            this.buId = buId;
            this.quantity = quantity;
            this.profitShare = profitShare;
        }
    }
    
    private static ARROrderFulfillmentSettings__c getOrderFulfillmentSettings(){
        if(test.isRunningTest()){
            ARROrderFulfillmentSettings__c settings = new ARROrderFulfillmentSettings__c(DispatchCreationURL__c = 'd');
            return settings;
        }
        return [SELECT DispatchCreationURL__c
                  FROM ARROrderFulfillmentSettings__c 
                 LIMIT 1];
    }
    
    private static Asset__x[] getAssets(String proposalId){
        if(Test.isRunningTest()){
            Asset__x asset = new Asset__x(Quantity__c = 5);
            List<Asset__x> assetList = new List<Asset__x>();
            assetList.add(asset);
            return assetList;
        }           
        return [SELECT Quantity__c FROM Asset__x WHERE ProposalID__c = :proposalId];
        
    }
    
    private static Integer countAssets(Asset__x[] assets){
        Decimal aggregate = 0;
        for(Asset__x a : assets)
            aggregate += a.Quantity__c;
        return aggregate.intValue();
    }
    
    private static Decimal percent(Decimal value){
        return value / 100.0;
    }
    
    private static AccountProfitShare__x getProfitShare(String customerNumber, Integer buId){
        if(Test.isRunningTest())
            return new AccountProfitShare__x(ProfitShare__c = 10);
        return [SELECT ProfitShare__c FROM AccountProfitShare__x
                  WHERE CustomerNumber__c = :customerNumber AND BuId__c = :buId LIMIT 1];
    }
    
    private static DispatchRequest getProposalDispatchRequest(Id internalId){
        Proposal__X requested = getProposal(internalId);
        
        Integer buId = Integer.valueOf(requested.Buid__c);
        
        Integer assetQuantity = countAssets(getAssets(requested.ProposalID__c));
        
        AccountProfitShare__x profitShare = getProfitShare(requested.CustomerNumber__c, buId);
        
        return new DispatchRequest(requested.CustomerNumber__c, buId, assetQuantity, percent(profitShare.ProfitShare__c));
    }
    
    @AuraEnabled
    public static String getInternalId(String requestId){
        if(!Test.isRunningTest())
        	return [SELECT id FROM PROPOSAL__X where ProposalID__c = :requestId LIMIT 1].id;
        else
            return '620c1a93-0b40-426b-2245-08d634f76640';
    }
    
    @AuraEnabled
    public static String getOrderLink(String countryCode){
        ARROrderSettings__c settings = [SELECT DSAUrl__c, GIIUrl__c FROM ARROrderSettings__c LIMIT 1];
        
        // TEMP, should be validating by BUID/Country Code over the _MDT
        if (countryCode == 'US' || countryCode == 'CA')
        	return settings.DSAUrl__c;
        
        return null; //return settings.GIIUrl__c;
    }
    
    @AuraEnabled
    public static List<ARRCountry__mdt> getCountries(){ 
        List<ARRCountry__mdt> countries = [SELECT BUID__c, MasterLabel from ARRCountry__mdt];
        return countries;
    }
    
    @AuraEnabled
    public static List<ARRServiceType__mdt> getServiceTypes(){ 
        List<ARRServiceType__mdt> serviceTypes = [SELECT DeveloperName, MasterLabel from ARRServiceType__mdt];
        return serviceTypes;
    }
    
    @AuraEnabled
    public static ActionResult getSummary(string proposalId){
        ARRProposalSettings__c settings = getSettings();
        string url = settings.SummaryUrl__c.replace('{id}', proposalId);
        
        return makeRequest('GET', url, null);
    }
    
    @AuraEnabled
    public static ActionResult getTypes(){
        ARRProposalSettings__c settings = getSettings();
        return makeRequest('GET', settings.TypesUrl__c, null);
    }
    
    @AuraEnabled
    public static ActionResult getBrands(){
        ARRProposalSettings__c settings = getSettings();
        return makeRequest('GET', settings.BrandsUrl__c, null);
    }
    
    @AuraEnabled
    public static ActionResult getProcessors(){
        ARRProposalSettings__c settings = getSettings();
        return makeRequest('GET', settings.ProcessorsUrl__c, null);
    }
    
    @AuraEnabled
    public static ActionResult getBaseUnits(string queryString){
        ARRProposalSettings__c settings = getSettings();
        string url = settings.BaseUnitsUrl__c + queryString;
        return makeRequest('GET', url, null);
    }
    
    @AuraEnabled
    public static ActionResult newVrp(string body){
        ARRProposalSettings__c settings = getSettings();
        string url = settings.NewUrl__c;

        return makeRequest('POST', url, body);
    }
    
    @AuraEnabled
    public static ActionResult refreshVrp(string requestId){
        ARRProposalSettings__c settings = getSettings();
        String externalId = getExternalId(requestId);
        
        string url = settings.RefreshVrpUrl__c;

        return makeRequest('PUT', url, '"' + externalId + '"');
    }
    
    @AuraEnabled
    public static ActionResult postDispatch(string requestId){
        ARROrderFulfillmentSettings__c settings = getOrderFulfillmentSettings();
        DispatchRequest request = getProposalDispatchRequest(requestId);
        string body = JSON.serialize(request);
        return makeRequest('POST', settings.DispatchCreationURL__c, body);
    }
    
    @AuraEnabled
    public static ActionResult deleteVrp(string requestId){
        ARRProposalSettings__c settings = getSettings();
        String externalId = getExternalId(requestId);
        
        string url = settings.DeleteVrpUrl__c;
        
        return makeRequest('POST', url, '"' + externalId + '"');
    }
    
    @AuraEnabled
    public static ActionResult newServiceSku(string body){
        ARRProposalSettings__c settings = getSettings();
		string url = settings.PostServiceSku__c;
        
        return makeRequest('POST', url, body);
    }
    
    @AuraEnabled
    public static ActionResult makeRequest(String type, String url, string body){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        ARRProposalSettings__c settings = getSettings();
		req.setEndpoint(url);	
		req.setMethod(type);
        req.setHeader('Content-Type','application/json');
        
        if (type != 'GET'){
            req.setBody(body);
        }
        
		HttpResponse res = h.send(req);
        
        ActionResult response = new ActionResult(res.getBody(), res.getStatusCode());
		return response;
    }
    
    public static ARRProposalSettings__c getSettings(){
        List<ARRProposalSettings__c> settings = [SELECT BrandsUrl__c, TypesUrl__c, ProcessorsUrl__c, BaseUnitsUrl__c, NewUrl__c, SummaryUrl__c, RefreshVrpUrl__c, DeleteVrpUrl__c, PostServiceSku__c FROM ARRProposalSettings__c];
        return settings[0];
    }
}
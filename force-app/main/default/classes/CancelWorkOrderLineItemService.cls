public class CancelWorkOrderLineItemService {
	
    @future(callout=true)
    public static void cancelDeltaDispatch(Id workOrderId) {
        
        // get WorkOrder 
        WorkOrder workOrder = [SELECT Id, Status, Project__c FROM WorkOrder WHERE Id = :workOrderId];
		
        // get WorkOrderLineItems (Parts)
		List<WorkOrderLineItem> woLineItems = [SELECT Id, WorkOrderId, DPS_Number__c, AssetId, Status FROM WorkOrderLineItem WHERE WorkOrderId = :workOrderId];

        //Get the Project Data
        pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c WHERE ID = :workOrder.Project__c];
        
        // Get Orders
        List<Order> orders = [SELECT Id, OrderNumber__c, BUID__c, AccountId, ShipToContact.FirstName, ShipToContact.LastName, ShipToContact.Email, ShipToContact.Phone, ShipToContact.HomePhone, ShipToContact.MailingStreet, ShipToContact.MailingCity, ShipToContact.MailingState, ShipToContact.MailingCountry, ShipToContact.MailingStateCode, ShipToContact.MailingCountryCode, ShipToContact.MailingPostalCode
                              FROM Order WHERE Project__c = :project.Id];
        
        // get all assetIds
        List<Id> assetIds = new List<Id>();
        for(WorkOrderLineItem workOrderLineItem : woLineItems) {
            assetIds.add(workOrderLineItem.AssetId);
        }
        
        // get all assets
        List<Asset> assets = [SELECT Id, Name, Customer_Number__c, Customer_BUID__c, Order_Number__c, Order_BUID__c FROM Asset WHERE Id IN :assetIds];
		
		List<Dispatch> dispatches = new List<Dispatch>();
		
		for(WorkOrderLineItem woLineItem : woLineItems) {
            for(Asset asset : assets) {
                if (woLineItem.AssetId != asset.Id)
                    continue;
                
                for (Order order : orders) {
                    if (asset.Order_Number__c != order.OrderNumber__c)
                        continue;
            
                    Dispatch dispatch = new Dispatch(woLineItem.Status, woLineItem.DPS_Number__c, order.BUID__c, woLineItem.Id);
                    
                    dispatches.Add(dispatch);                    
                }                
            }
		}
		
		boolean calloutResult = callout(JSON.serialize(dispatches));
        
        if (calloutResult) {
            workOrder.Status = 'FF - Cancellation Request';
            
            for(WorkOrderLineItem woLineItem : woLineItems) {
                woLineItem.Status = 'FF - Cancellation Request';
            }
            
            //update woLineItems; 
            update workOrder;
        }
    }
    
    private static boolean callout(string jsonMessage) {
        boolean result = false;
        System.debug('----cancelWorkOrderLineItems:jsonMessage'+jsonMessage);
            
        // http request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ResourceScheduling_CancelCase');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        // Set the body as a JSON object
        request.setBody(jsonMessage);
        
        HttpResponse response = http.send(request);
        
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug(LoggingLevel.Error, '[ResourceScheduling - CancelCase] Error HTTP response code: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            result = true;
        }
        
        return result;
    }
    
    public class Dispatch {
        public String DPSStatus;
        public String DPSNumber;
        public String Buid;
        public String SalesforceId;
        public Integer ExternalCaseId;
        
        public Dispatch(string status, string dpsNumber, string buid, Id salesforceId) {
            this.DPSStatus = status;
            this.DPSNumber = dpsNumber;
            this.Buid = buid;
            this.SalesforceId = salesforceId;
            this.ExternalCaseId = 0;
        }
    }
}
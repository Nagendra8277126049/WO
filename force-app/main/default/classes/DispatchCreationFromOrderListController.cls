public class DispatchCreationFromOrderListController {
	public class OrderListResponse {
        
        public OrderListResponse() {
            Assets = new List<Asset>();
        }
        
        //@AuraEnabled
        //public List<OrderItem> orderItems { get; set; } 
        
        //@AuraEnabled
        //public List<WorkOrder> workOrders { get; set; }
        
        //@AuraEnabled
        //public List<pse__Project_Task__c> projectTasks { get; set; }
        
        //@AuraEnabled
        //public List<Order> Orders { get; set; }
        
        @AuraEnabled
        public List<Asset> Assets { get; set; }
        
        //@AuraEnabled
        //public List<WorkOrderLineItem> WorkOrderLineItems { get; set; }
    }
    
    @AuraEnabled
    public static OrderListResponse GetOrderItems(Id workOrderId) 
    {
        OrderListResponse response = new OrderListResponse();
        DispatchCreationFromOrderListProvider provider = new DispatchCreationFromOrderListProvider();
        response.Assets = provider.GetOrderItems(workOrderId);
        
        return response;
    }
    
    @AuraEnabled
    public static String GetWorkOrderStatus(Id workOrderId) 
    {
        System.debug('***workOrderId***');
        System.debug(workOrderId);
        String workOrderStatus = '';
        DispatchCreationFromOrderListProvider provider = new DispatchCreationFromOrderListProvider();
        workOrderStatus = provider.GetWorkOrderStatus(workOrderId);
        System.debug('workOrderStatus: ' + workOrderStatus);
        return workOrderStatus;
    }
    
    @AuraEnabled
    public static void SetWorkOrderLineItems(Id workOrderId, String assets) {
        System.debug('Entering - SetWorkOrderLineItems');
        System.debug(workOrderId);
        System.debug(assets);
        
        Id recordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Installation Dispatch').getRecordTypeId();
        
        //Populate Partner
        List<string> changedWO = new List<string>();
        changedWO.add(workOrderId);
        //WorkOrderPreferredPartnerHandler.SetPreferredPartner(changedWO);

        //String workOrderLineItemIds = '';
        String[] arrAssets = assets.split('#');
        List<Dispatch> dispatches = new List<Dispatch>();
        
        System.debug(arrAssets);
        
        List<WorkOrderLineItem> workOrderLineItems = new List<WorkOrderLineItem>();
        
        for(integer i=0; i<arrAssets.size(); i++) {
      		//insert Word Order Line Item;
      		workOrderLineItems.add(new WorkOrderLineItem(WorkOrderId = workOrderId, Status = 'FF - New', AssetId = Id.valueOf(arrAssets[i]), RecordTypeId = recordTypeId));
        }
        
        insert workOrderLineItems;
      
        System.debug('Work Order Line Items Created.');
        System.debug(workOrderLineItems);
        
        List<Id> workOrderLineItemIds = new List<Id>();
        
        for(WorkOrderLineItem woli : workOrderLineItems) {
            workOrderLineItemIds.add(woli.Id);
        }
        
        //update Work Order to FF - Submitted
        WorkOrder workOrder = [SELECT Project_Task__c from WorkOrder where ID = :workOrderId];
        workOrder.Status = 'FF - Submitted';
        update workOrder;
        
        DispatchCreationFromOrderListService.createDeltaDispatch(workOrderLineItemIds, workOrderId);
    }

    public static void CallWebService(String assetNames, String workOrderLineItems) {
		System.debug('Entering CallWebService');
    }
    
    //public static void createDispatch(string jsonMessage) {
        //System.debug('Entering createDispatch');
        // http request
        //Http http = new Http();
        //HttpRequest request = new HttpRequest();
        //request.setEndpoint('callout:ResourceScheduling_Create_Case');
        //request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        // Set the body as a JSON object
        //request.setBody(jsonMessage);
        
        //HttpResponse response = http.send(request);
        
        //System.debug('HTTP RESPONSE SENT');
        
        // Parse the JSON response
        //if (response.getStatusCode() != 201) {
        //    System.debug(LoggingLevel.Error, '[ResourceScheduling - CreateCase] Error HTTP response code: ' +
        //        response.getStatusCode() + ' ' + response.getStatus());
        //} else {
            // message sent successfully
        //    System.debug('[ResourceScheduling - CreateCase] - HTTP response code: 201');
        //}
        
        //System.debug('HTTP RESPONSE END');
    //}
    
    public class Dispatch {
        public String SalesforceId;
        public String ServiceTag;
    }
    
    public class Interaction {
        public String Notes;
        public String Priority;
        public String DPSType;
        public String DSP;
        public String ServiceHours;
        public Boolean Billable;
        public Boolean CompleteCare;
        public Boolean OutOfHours;
        public Boolean OutOfWarranty;
        public Boolean CallType;
        public String SKU;
        public String FSDDASPFlag;
        public Instruction Instruction;
             
    }	
    
    public class Instruction {
        public String Type;
        public String Area;
        public String Value;
    }
    
    public class Symptom {
        public List<String> Simptoms;
    }  
    
}
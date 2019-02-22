public class CancelWorkOrderLineItemController {
	public WorkOrder workOrder { get; set; }
    public boolean showAlert { get; set; }
    public string alertMessage { get; set; }
    
    public List<WorkOrderLineItem> woLineItems { get; set; }
	
	public CancelWorkOrderLineItemController(ApexPages.StandardController controller) {
		workOrder = (WorkOrder)controller.getRecord();
        showAlert = false;
        alertMessage = '';
        
        woLineItems = new List<WorkOrderLineItem>();
	}
	
	public PageReference cancelWorkOrderLineItems() {
        
        System.debug('----cancelWorkOrderLineItems');
        
        if (isValidStatus(workOrder.Status) && haveAllDispatchDPSNumber(workOrder.Id)) {     
            
            CancelWorkOrderLineItemService.cancelDeltaDispatch(workOrder.Id);
            
            PageReference pageRef = new PageReference('/' + workOrder.Id);
            pageRef.setRedirect(true);
            
            return pageRef;  
        } else {
          	
		  	showAlert = true;
            
          	return null;  
        }       
	}
    
    private boolean haveAllDispatchDPSNumber(Id workOrderId){
        // get WorkOrderLineItems (Parts)
		List<WorkOrderLineItem> woLineItems = [SELECT Id, WorkOrderId, DPS_Number__c, AssetId, Status FROM WorkOrderLineItem WHERE WorkOrderId = :workOrderId];
        
        for(WorkOrderLineItem woLineItem : woLineItems) {
            if(!String.isNotBlank(woLineItem.DPS_Number__c)) {
                alertMessage = 'You cannot Cancel the selected work order because all the Dispatches need to have a DPS Number.';
                return false;
            }
        }

        return true;
    }
    
    private boolean isValidStatus(string workOrderStatus) {
        List<string> validStatus = new List<string> {'FF - Submitted', 'FF - Work In Progress'};
            
        if (validStatus.contains(workOrderStatus)) 
            return true;
        
        alertMessage = 'You cannot Cancel the selected work order because it is in the ' + workOrderStatus + ' status.';
        return false;
        
    }
    
    /*
    
    public void updateWorkOrderLineItems() {
        for(WorkOrderLineItem woLineItem : woLineItems) {
			woLineItem.Status = '';
		}
    }
	
	public string createDispatchJSON() {
		
		woLineItems = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrderId = :workOrder.Id];
		
		List<Dispatch> dispatches = new List<Dispatch>();
		
		for(WorkOrderLineItem woLineItem : woLineItems) {
			Dispatch dispatch = new Dispatch('Cancelled', '', workOrder.BUID__c, woLineItem.Id);
			
			dispatches.Add(dispatch);
		}
		
		return JSON.serialize(dispatches);
	}
    
    public class Dispatch {
        public String DPSStatus;
        public String DPSNumber;
        public String Buid;
        public String SalesforceId; 
        
        public Dispatch(string dpsStatus, string dpsNumber, string buid, string salesforceId) {
            this.DPSStatus = dpsStatus;
            this.DPSNumber = dpsNumber;
            this.Buid = buid;
            this.SalesforceId = '1WL2a0000009pSGGAY';//salesforceId;
        }
    }
	*/
}
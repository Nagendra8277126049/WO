public class DispatchCreationFromOrderListProvider {
	public List<Asset> GetOrderItems(Id workOrderId)
    {
        List<Asset> assets = new List<Asset>();
        String requiredFieldsForDispatch = '';
        
        //Get the Work Order Project Task ID
        WorkOrder[] workOrder = [SELECT Project_Task__c, Country__c, City, State, Contact.Phone, DPSType__c, PartnerName__c, Description from WorkOrder where ID = :workOrderId AND Status = 'FF - New'];

        if (workOrder.size() > 0) {
            
            System.debug('*** Work Order ***');
            System.debug(workOrder[0]);
            
            System.debug('wo Country: ' + workOrder[0].Country__c);
            System.debug('wo City: ' + workOrder[0].City);
            System.debug('wo State: ' + workOrder[0].State);
            System.debug('wo Phone: ' + workOrder[0].Contact.Phone);
            System.debug('wo DPS Type: ' + workOrder[0].DPSType__c);
            System.debug('wo PartnerName: ' + workOrder[0].PartnerName__c);
            System.debug('wo Description: ' + workOrder[0].Description);
            
            if (workOrder[0].Country__c == null) {
                requiredFieldsForDispatch = 'Country';
            }
            
            if (workOrder[0].City == null) {
                if (requiredFieldsForDispatch == '') {
                    requiredFieldsForDispatch = 'City';
                }
                else {
                    requiredFieldsForDispatch = requiredFieldsForDispatch + ', City';
                }
            }
            
            if (workOrder[0].State == null) {
                if (requiredFieldsForDispatch == '') {
                    requiredFieldsForDispatch = 'State';
                }
                else {
                    requiredFieldsForDispatch = requiredFieldsForDispatch + ', State';
                }
            }
            
            if (workOrder[0].Contact.Phone == null) {
                if (requiredFieldsForDispatch == '') {
                    requiredFieldsForDispatch = 'Contact Phone Number';
                }
                else {
                    requiredFieldsForDispatch = requiredFieldsForDispatch + ', Contact Phone Number';
                }
            }
            
            if (workOrder[0].DPSType__c == null) {
                if (requiredFieldsForDispatch == '') {
                    requiredFieldsForDispatch = 'DPS Type';
                }
                else {
                    requiredFieldsForDispatch = requiredFieldsForDispatch + ', DPS Type';
                }
            }
            
            if (workOrder[0].PartnerName__c == null) {
                if (requiredFieldsForDispatch == '') {
                    requiredFieldsForDispatch = 'Partner Name';
                }
                else {
                    requiredFieldsForDispatch = requiredFieldsForDispatch + ', Partner Name';
                }
            }
            
            if (workOrder[0].Description == null) {
                if (requiredFieldsForDispatch == '') {
                    requiredFieldsForDispatch = 'Description';
                }
                else {
                    requiredFieldsForDispatch = requiredFieldsForDispatch + ', Description';
                }
            }
            
            System.debug('Required Fields for Dispatch: ' + requiredFieldsForDispatch);
            
            
            //Get the Project Task Project ID
            pse__Project_Task__c projectTask = [SELECT pse__Project__c from pse__Project_Task__c where ID = :workOrder[0].Project_Task__c];
    
            System.debug(projectTask);
    
            //Get the Project Order Numbers
            List<Order> projectOrders = [SELECT OrderNumber__c from Order where Project__c = :projectTask.pse__Project__c order by OrderNumber__c asc];
    
            System.debug(projectOrders);
            
            List<string> orderNumbers = new List<string>();
    
            for (Order order : projectOrders) {
                orderNumbers.add(order.OrderNumber__c);
            }
    
            System.debug('Order Numbers: ' + orderNumbers);
            
            //Get the Assets
            assets = [SELECT Id, Order_Number__c, Order_Tie_Number__c, Name, Product2.LOB_Description__c FROM Asset WHERE Order_Number__c IN :orderNumbers ORDER BY Order_Number__c, Order_Tie_Number__c];
            System.debug('Assets: ' + assets);
            
            string[] closedStatus = new string[] { 'FF - Cancelled', 'FF - Closed', 'FF - Invalid', 'FF - Service Complete' };
            Integer j = 0;
            
            while (j < assets.size())
            {
                Id assetId = assets.get(j).Id;
                
                List<WorkOrderLineItem> workOrderLineItem = [SELECT Id FROM WorkOrderLineItem WHERE AssetId = :assetId AND Status NOT IN :closedStatus];
                
                System.debug('WorkOrderLineItem to be deleted');
                System.debug(workOrderLineItem);
                
                if (workOrderLineItem.size() <> 0) {
                    assets.remove(j);
                }
                else {
                    j++;
                }
            }
            
            System.debug(assets);
        }

        return assets;
    }
    
    public String GetWorkOrderStatus(Id workOrderId) {
       //Get the Work Order Project Task ID
       System.debug(workOrderId);
       System.debug('work order status');
        WorkOrder workOrder = [SELECT Status from WorkOrder where ID = :workOrderId];
        System.debug(workOrder.Status);
        return workOrder.Status;
    }
}
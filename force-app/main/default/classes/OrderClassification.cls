public class OrderClassification {
    @InvocableMethod()
    public static List<boolean> ClassificateOrders(List<Id> orderIds){
        
        string SVC_EDT_INSTLN = 'SVC EDT INSTLN';
        string ORDER_TYPE_IDS = 'Order_Type_IDS';
        
        List<boolean> result = new List<boolean>();
        
        // Get order
        List<Order> orders = [SELECT Id, OrderNumber__c, Order_Status__c, BUID__c, Type, (SELECT Id, SKU_Number__c, Item_Class_Description__c FROM OrderItems) FROM Order WHERE Id IN :orderIds];
        
        Custom_Order_Status_to_Order_Status_Map__mdt[] statusMappings = 
            [SELECT Custom_Status__c, Order_Status__c FROM Custom_Order_Status_to_Order_Status_Map__mdt];
        
        for (Order order : orders) {
            boolean shouldCreateProject = false;
            
            for(Custom_Order_Status_to_Order_Status_Map__mdt mapping : statusMappings){
                if(order.Order_Status__c == mapping.Custom_Status__c){
                	order.Status = mapping.Order_Status__c;
            	} 
            }           
            
            if(ValidateRegionActiveStatus(order)) {
                if (order.OrderItems.size() > 0) {
                    
                	boolean hasClassDescriptionMatch = false;
                    List<OrderItem> orderItems = order.OrderItems;  
                    List<string> skus = new List<string>();
                    
                    // check the OrderItem class description 
                    for (OrderItem item : order.OrderItems) {
                        if (item.Item_Class_Description__c == SVC_EDT_INSTLN) {
                            hasClassDescriptionMatch = true;
                        }
                        
                        skus.add(item.SKU_Number__c);
                    }
                    
                    if(hasClassDescriptionMatch){
                        shouldCreateProject = hasClassDescriptionMatch;
                    }
                    else { 
                        List<SKU_Effort_Map__c> skuEfforts = [SELECT Id FROM SKU_Effort_Map__c WHERE SKU_Number__c IN :skus AND Active__c = true];
                        shouldCreateProject = skuEfforts.size() > 0;
                    }
                }
                
                order.Type = shouldCreateProject ? ORDER_TYPE_IDS : '';
            }
    
            result.add(shouldCreateProject);            
        }
        
        update(orders);
        return result;
    }
    
    private static boolean ValidateRegionActiveStatus(Order order){
        pse__region__c region = RegionManager.GetRegionByBUID(order.BUID__c);
        return region != null ? region.Active__c : false;
    }
}
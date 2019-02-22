public class ProjectHardwareAndServiceInfoProvider {
    private List<string> GetHardwareLobDescriptions()
    {
        LOB_Hardware_Mapping__mdt[] items = LobDescriptionHardwareMappingManager.GetLobToHardware();
        List<String> LOB_Hardware = new List<String>();
        for (LOB_Hardware_Mapping__mdt item:items) LOB_Hardware.Add(item.LOB_Description__c);
        return LOB_Hardware;
    }
    private List<string> GetServiceItemClassDescription()
    {
        List<string> result = new List<string>();
        result.add('SVC EDT INSTLN');
        result.add('SVC EDT CNSLT');
        result.add('SVC CLNT INSTLN');
        result.add('SVC EIS SVCs');
        
        return result;
    }
    
    public List<OrderItem> GetOrderItems(Id projectId, String filterCriteria)
    {
        List<Order> orders = [SELECT Id FROM Order WHERE Project__c = :projectId];
        
        String criteria = String.isBlank(filterCriteria) ? '%' : '%' + filterCriteria + '%';
        
        List<OrderItem> orderItems = [
            SELECT Id, SKU_Description__c, SKU_Number__c, Quantity, Order.OrderNumber__c, Item_Class_Description__c, LOB_Description__c, Tie_Number__c
            FROM OrderItem 
            WHERE (LOB_Description__c IN :GetHardwareLobDescriptions() OR Item_Class_Description__c IN :GetServiceItemClassDescription())
            AND (LOB_Description__c LIKE: criteria OR Item_Class_Description__c LIKE: criteria
                OR SKU_Number__c LIKE: criteria OR SKU_Description__c LIKE: criteria)
            AND OrderId IN :orders
            order BY Order.OrderNumber__c, Tie_Number__c, SKU_Description__c
        ];
        
        return orderItems;
    }

}
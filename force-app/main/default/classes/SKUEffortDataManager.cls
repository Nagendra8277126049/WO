public class SKUEffortDataManager 
{
    public List<OrderItem> GetOrderItems (string orderId)
    {
        return [SELECT Id , OrderId , Quantity , SKU_Number__c FROM OrderItem WHERE OrderId =: orderId];
    }
    
    public List<Sku_Effort_Map__c> GetSKUEffortMaps (List<string> skus)
    {
        Sku_Effort_Map__c[] mapps = 
        [
            SELECT Id , Name, SKU_Number__c,
        		(SELECT Name__c, Project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c FROM SKU_Effort_Map_Entries__r)  // HERE WE CAN FILTER BY TEMPLATE ID IN THE FUTURE
        	FROM Sku_Effort_Map__c 
            WHERE 
            	SKU_Number__c IN :SKUs and 
            	active__c = true
        ];
        return mapps;     
    }

	public List<SKU_Effort_Map_Entry__c> GetSKUEffortMapEntries (List<string> mapids)
    {
        SKU_Effort_Map_Entry__c[] mappEntries = [
            							SELECT Name__c, project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c
            							FROM SKU_Effort_Map_Entry__c 
            							WHERE SKU_Effort_Map__c IN :mapids
        							];
        return mappEntries;
        
    }

    public List<pse__Project_Task__c> GetProjectTasks (string projectId)
    {
        pse__Project_Task__c[] existingParentTasks = [SELECT Name From pse__Project_Task__c WHERE pse__Project__c =: projectId  and pse__Parent_Task__c = null];
        return existingParentTasks;
    }
    
}
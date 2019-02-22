public class GetOrderAssets
{
    @AuraEnabled
    public static List<Asset> getAssetsFromOrder(String orderId)
    {
        Order order = [SELECT OrderNumber__c FROM Order WHERE Id =: orderId];
        
        String orderNumber = order.OrderNumber__c;
        
        List<Asset> assets = [SELECT Name, Product2.LOB_Description__c, PSNT__c, Order_Tie_Number__c FROM Asset WHERE Order_Number__c =: orderNumber];
        
        return assets;
    }
}
@isTest
private class GetOrderAssetsTest
{
    @isTest static void testGetAssetsFromOrder()
    {        
        Order order = createOrder();
        
        List<Asset> assets = createAssets(order.OrderNumber__c);
        
       /* Verify there is an order with such order Id
       then query for a list of assets that Order_Number__c field matches the OrderNumber__c field from Order */
        Test.startTest();
            Order testOrder = [SELECT OrderNumber__c FROM Order WHERE Id =: order.Id];
            System.Assert(testOrder != null);
            
            List<Asset> testAssets = GetOrderAssets.getAssetsFromOrder(testOrder.Id);
        	
            System.Assert(testAssets.size() != 0);
        Test.stopTest();
       
    }
    
    // mocking order
    static Order createOrder()
    {
        Account account = new Account();
        account.Name = 'Order Status Test Account';
        insert(account);
        Order order = new Order();
        order.OrderNumber__c = '4393426';
        order.EffectiveDate = Date.valueOf('2018-07-17');
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'BK'; 
        insert (order);
        
        return order;
    }
    
    // mocking a list of assets
    static List<Asset> createAssets(String orderNumber)
    {
        List<Asset> assetList = new List<Asset>();
        
        for(Integer i = 0; i < 3; i++){
           	Asset asset = new Asset(Name = 'XYZ-000' + i, Order_Number__c = orderNumber);
            assetList.add(asset);
        }
        
        insert assetList;
        
        return assetList;
    }
    
}
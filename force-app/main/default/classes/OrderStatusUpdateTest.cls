@isTest()
public class OrderStatusUpdateTest {    
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
        order.Pricebook2Id = Test.getStandardPricebookId(); 
        return order;
    } 
    
    static PricebookEntry createPricebookEntry(){
        PricebookEntry entry = new PricebookEntry();
        entry.CurrencyIsoCode = 'USD';
        entry.Pricebook2Id = Test.getStandardPricebookId(); 
        entry.UnitPrice = 0;
        
        Product2 product = new Product2();
        product.Name = 'Order Status Test Product';
        insert(product);
        
        entry.UseStandardPrice = false;
        entry.Product2Id = product.Id;
        insert(entry);
        return entry;
    }
    
    static OrderItem createOrderItem(Id orderId){
        OrderItem item = new OrderItem();
        item.OrderId = orderId;
        item.PricebookEntryId = createPricebookEntry().Id;
        item.UnitPrice = 10;
        item.Quantity = 1;
        
        insert(item);
        return item;
    }
    static void createSkills() {
        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(new pse__Skill__c(Name = 'Project Management (Low)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (Medium)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (High)'));

        insert skills;
    }
    
    static string ConvertStatus(string status){
        Custom_Order_Status_to_Order_Status_Map__mdt[] mapping = 
            [SELECT Custom_Status__c, Order_Status__c FROM Custom_Order_Status_to_Order_Status_Map__mdt WHERE Custom_Status__c =: status limit 1 ];	 
        
        if(mapping.size() == 0) {  return null; }
        
        return mapping[0].Order_Status__c;
    }
    
    @isTest()
    static void Order_Status_Should_Change_Order_Status_c(){
        //Arrange
    	Order order = createOrder();
        //order.Order_Status__c = 'EC';
    	insert(order);
        
        createOrderItem(order.Id);
        createSkills();
        
        //Act
        Test.startTest();
       	Order[] orderFromQuerry = [SELECT Id, Order_Status__c, Status FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        
        order.Status = 'EC';
        update(order);
        
        orderFromQuerry = [SELECT Id, Order_Status__c, Status FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        System.AssertEquals(orderFromQuerry[0].Order_Status__c, orderFromQuerry[0].Status);
        Test.stopTest();
    }
    
    @isTest()
    static void Order_Update_Should_Consider_Order_Status_c_As_Status(){
        //Arrange
    	Order order = createOrder();
        order.Order_Status__c = 'IP';
    	insert(order);
        
        createOrderItem(order.Id);
        createSkills();
        
        //Act
        Test.startTest();
       	Order[] orderFromQuerry = [SELECT Id, Order_Status__c, Status FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        
        order.Order_Status__c = 'HL';
        update(order);
        
        orderFromQuerry = [SELECT Id, Order_Status__c, Status FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        System.AssertEquals(ConvertStatus(order.Order_Status__c), orderFromQuerry[0].Status);
        Test.stopTest();
    } 
    
    @isTest()
    static void POD_Status_Should_Update_Order_Delivered_Date(){
        //Arrange
    	Order order = createOrder();
        order.Order_Status__c = 'IP';
    	insert(order);
        
        createOrderItem(order.Id);
        createSkills();
        
        //Act
        Test.startTest();
       	Order[] orderFromQuerry = [SELECT Id, Order_Status__c, Status FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        
        order.Order_Status__c = 'POD';
        DateTime deliveryDate = DateTime.now();
        order.Status_Date_Time__c = deliveryDate;
        update(order);
        
        orderFromQuerry = [SELECT Id, Delivered_Date__c FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        System.AssertEquals(orderFromQuerry[0].Delivered_Date__c, deliveryDate);
        Test.stopTest();
    } 
    
    @isTest()
    static void RDD_Status_Should_Update_Order_Estimated_Delivery_Date(){
        //Arrange
    	Order order = createOrder();
        order.Order_Status__c = 'IP';
        Date initialEstimated = Date.today();
        order.Estimated_Delivery_Date__c = initialEstimated;
    	insert(order);
        
        createOrderItem(order.Id);
        createSkills();
        
        //Act
        Test.startTest();
       	Order[] orderFromQuerry = [SELECT Id, Order_Status__c, Status FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        
        order.Order_Status__c = 'RDD';
        order.RDD_Date__c = order.Estimated_Delivery_Date__c.addDays(10);
        update(order);
        
        orderFromQuerry = [SELECT Id, Estimated_Delivery_Date__c, Status FROM Order WHERE Id =: order.Id limit 1];
        System.Assert(orderFromQuerry.size() != 0);
        System.AssertEquals(orderFromQuerry[0].Estimated_Delivery_Date__c, order.RDD_Date__c);
        System.assertNotEquals(orderFromQuerry[0].Estimated_Delivery_Date__c, initialEstimated);
        Test.stopTest();
    } 
}
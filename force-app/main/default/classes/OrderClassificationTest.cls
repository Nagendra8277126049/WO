@isTest()
public class OrderClassificationTest {
    static Order createOrder(boolean regionActive) {
        Account account = new Account();
        account.Name = 'Order Status Test Account';
        insert(account);
        
        pse__Region__c region = new pse__Region__c(Name='Test Region', Active__c=regionActive, ISO_Country_Code__c='XX');
        insert(region);
        
        Order order = new Order();
        order.OrderNumber__c = '4393426';
        order.EffectiveDate = Date.valueOf('2018-07-17');
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '0';
        order.Status = 'BK';
        order.Pricebook2Id = Test.getStandardPricebookId(); 
        
        insert(order);
        return order;
    }
    static void createSkills() {
        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(new pse__Skill__c(Name = 'Project Management (Low)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (Medium)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (High)'));

        insert skills;
    }
    static PricebookEntry createPricebookEntry() {
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
    
    static OrderItem createOrderItem(Id orderId, string skuNumber, string classDescription) {
        OrderItem item = new OrderItem();
        item.OrderId = orderId;
        item.PricebookEntryId = createPricebookEntry().Id;
        item.UnitPrice = 10;
        item.Quantity = 1;
        item.SKU_Number__c = skuNumber;
        item.Item_Class_Description__c = classDescription;
        
        insert(item);
        return item;
    }
    
    static SKU_Effort_Map__c createSKUEffortMap(string skuNumber) {
        SKU_Effort_Map__c skuEffort = new SKU_Effort_Map__c();
        skuEffort.SKU_Number__c = skuNumber;
        skuEffort.Description__c = 'Desc';
        
        insert(skuEffort);
        return skuEffort;
    }
    
    @isTest()
    static void Should_ClassificateOrder_True_With_AccountClass_Accepted() {
        
        // Arrange
        Order order = createOrder(true);
        OrderItem orderItem = createOrderItem(order.Id, '', 'SVC EDT INSTLN');
        createSkills();
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        // Act
        List<boolean> results = OrderClassification.ClassificateOrders(orderIds);
        
        // Assert
        System.assert(results.size() > 0);
        System.assertEquals(results[0], true);
    }
    
    @isTest()
    static void Should_ClassificateOrder_True_With_SKUNumber_In_SKUEffortMap() {
        
        // Arrange
        Order order = createOrder(true);
        string skuNumber = 'SKU-123';
        OrderItem orderItem = createOrderItem(order.Id, skuNumber, '');
        SKU_Effort_Map__c skuEffortMap = createSKUEffortMap(skuNumber);
        createSkills();
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        // Act
        List<boolean> results = OrderClassification.ClassificateOrders(orderIds);
        
        // Assert
        System.assert(results.size() > 0);
        System.assertEquals(results[0], true);
    }
    
    @isTest()
    static void Should_NOT_ClassificateOrder_Without_AccountClass_Or_SKUMapping() {
        
        // Arrange
        Order order = createOrder(true);
        OrderItem orderItem = createOrderItem(order.Id, 'SKU-321', 'SVC EDT TEST');
        SKU_Effort_Map__c skuEffortMap = createSKUEffortMap('SKKU-123');
        createSkills();
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        // Act
        List<boolean> results = OrderClassification.ClassificateOrders(orderIds);
        
        // Assert
        System.assert(results.size() > 0);
        System.assertEquals(results[0], false);
        
    }
    
    @isTest()
    static void Should_NOT_ClassificateOrder_With_Region_Inactive() {
        
        // Arrange
        Order order = createOrder(false);
        OrderItem orderItem = createOrderItem(order.Id, 'SKU-123', 'SVC EDT INSTLN');
        SKU_Effort_Map__c skuEffortMap = createSKUEffortMap('SKU-123');
        createSkills();
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        // Act
        List<boolean> results = OrderClassification.ClassificateOrders(orderIds);
        
        // Assert
        System.assert(results.size() > 0);
        System.assertEquals(results[0], false);
        
    }
}
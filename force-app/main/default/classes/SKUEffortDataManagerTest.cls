@isTest()
public with sharing class SKUEffortDataManagerTest {
    
	@testSetup
    static void setupData() {
        Product2 product = new Product2(
        	Name = 'Test product'
        );
        
        insert(product);
        
        PriceBookEntry priceBookEntry = new PriceBookEntry(
        	PriceBook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            IsActive = true,
            UnitPrice = 1
        );
        
        insert(priceBookEntry);
    }
    
    static Id GetPriceBookEntry() {
        return [SELECT Id FROM PriceBookEntry].Id;
    }
    
    static Order createOrderWithOrderItems()
    {
        List<OrderItem> orderItems = new List<OrderItem>();
        Account account = new Account();
        account.Name = 'Create order test';
        insert(account);
        Order order = new Order();
        order.OrderNumber__c = '4393426';
        order.EffectiveDate = Date.valueOf('2018-08-06');
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'IP';
        order.Pricebook2Id = Test.getStandardPricebookId();
        insert(order);
        
        OrderItem orderItem1 = new OrderItem();
        orderItem1.OrderId = order.Id;
        orderItem1.PricebookEntryId = GetPriceBookEntry();
        orderItem1.Quantity = 2;
        orderItem1.Item_Class_Description__c = 'SVC EDT INSTLN';
        orderItem1.SKU_Number__c = '444-9998';
        orderItem1.SKU_Description__c = 'Order Item 1';
        orderItem1.UnitPrice = 99.9;
        insert(orderItem1);
        orderItems.add(orderItem1);
    
        OrderItem orderItem2 = new OrderItem();
        orderItem2.OrderId = order.Id;
        orderItem2.PricebookEntryId = GetPriceBookEntry();
        orderItem2.Quantity = 1;
        orderItem2.Item_Class_Description__c = 'SVC EDT INSTLN';
        orderItem2.SKU_Number__c = '555-9998';
        orderItem2.SKU_Description__c = 'Order Item 2';
        orderItem2.UnitPrice = 99.9;
        insert(orderItem2);
        orderItems.add(orderItem2);
    
        OrderItem orderItem3 = new OrderItem();
        orderItem3.OrderId = order.Id;
        orderItem3.PricebookEntryId = GetPriceBookEntry();
        orderItem3.Quantity = 1;
        orderItem3.Item_Class_Description__c = 'SVC EDT INSTLN';
        orderItem3.SKU_Number__c = '666-9990';
        orderItem3.SKU_Description__c = 'Order Item 3';
        orderItem3.UnitPrice = 99.9;
        insert(orderItem3);
        orderItems.add(orderItem3);
    
        return order;
    }
    
    static void createSKUEffortMaps()
    {
        SKU_Effort_Map__c effortMap1 = new SKU_Effort_Map__c(SKU_Number__c='666-9990', Description__c='Order Item 3');
        insert effortMap1;
    
        SKU_Effort_Map__c effortMap2 = new SKU_Effort_Map__c(SKU_Number__c='555-9998', Description__c='Order Item 2');
        insert effortMap2;
    
        SKU_Effort_Map__c effortMap3 = new SKU_Effort_Map__c(SKU_Number__c='444-9998', Description__c='Order Item 1');
        insert effortMap3;
    
    }
    
    static void createSKUEffortMapsEntries(List<string> MapIds)
    {
		pse__Proj__c template = new pse__Proj__c(pse__Is_Template__c=true, Name='IDS Standart', Project_Visibility__c='All', pse__Is_Active__c = true);
        insert template;
            
        pse__Project_Task__c task = new pse__Project_Task__c(Name='phaseName', pse__Project__c=template.Id);
        insert task;
        
        for (string MapId :MapIds)
        {
            SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c=template.Id, 
                                                                                 Name__c='Remote Config', 
                                                                                 SKU_Effort_Map__c= MapId,
                                                                                 Phase__c=task.Id,
                                                                                 Role__c= 'Project Manager', 
                                                                                 Project_Complexity_Tier__c='Tier 1', 
                                                                                 Estimated_Hours__c=4);
            insert effortMapEntry;
        }
    
    }
    
    static pse__Proj__c createProjectWithTaskAndSubTask(string taskName, string subTaskName, decimal subTaskEstimatedhours) {
            pse__Proj__c project = new pse__Proj__c(Name='Test Project', Project_Visibility__c='All', pse__Is_Active__c = true);
            insert project;
            
            pse__Project_Task__c task = new pse__Project_Task__c(Name=taskName, pse__Project__c=project.Id);
            insert task;
            
            pse__Project_Task__c subTask = new pse__Project_Task__c(Name=subTaskName, pse__Estimated_Hours__c=subTaskEstimatedhours, pse__Project__c=project.Id, pse__Parent_Task__c=task.Id);
            insert subTask;
            
            return project;
    }


    @isTest()
    static void GetOrderItems_Should_Return_Three_Order_Items()
    {
        //Arrange
        Order order = createOrderWithOrderItems();
        SKUEffortDataManager sKUEffortDataManager = new SKUEffortDataManager(); 
            //Act
        Test.startTest();
        List<OrderItem> result = sKUEffortDataManager.GetOrderItems(order.Id);
        
        Test.stopTest();
        
        //Assert
        System.assertEquals(3, result.size());
    
    }
    
    @isTest()
    static void GetSKUEffortMaps_Should_Return_Effort_Maps_With_Same_SKUNumber()
    {
        //Arrange
        Order order = createOrderWithOrderItems();
        createSKUEffortMaps();
        SKUEffortDataManager sKUEffortDataManager = new SKUEffortDataManager(); 
        List<OrderItem> orderItems = sKUEffortDataManager.GetOrderItems(order.Id);
        Set<String> SKUs = new Set<String>();
            for (OrderItem item : orderItems) SKUs.add(item.SKU_Number__c); 
        List<String> listSKUs = new List<String>();
        listSKUs.addAll(SKUs);
        //Act
        Test.startTest();
        List<Sku_Effort_Map__c> result = sKUEffortDataManager.GetSKUEffortMaps(listSKUs);
        
        Test.stopTest();
        
        //Assert
        System.assertEquals(3, result.size());
    
    }
    
    @isTest()
    static void GetSKUEffortMapEntries_Should_Return_Effort_Maps_With_Same_SKUNumber()
    {
        //Arrangea
        Order order = createOrderWithOrderItems();
        createSKUEffortMaps();
        SKUEffortDataManager sKUEffortDataManager = new SKUEffortDataManager(); 
        List<OrderItem> orderItems = sKUEffortDataManager.GetOrderItems(order.Id);
        Set<String> SKUs = new Set<String>();
        
        for (OrderItem item : orderItems) SKUs.add(item.SKU_Number__c); 
        
        List<String> listSKUs = new List<String>();
        listSKUs.addAll(SKUs);
    
        List<String> MapIds = new List<String>();
        List<Sku_Effort_Map__c> maps = sKUEffortDataManager.GetSKUEffortMaps(listSKUs);
        for (Sku_Effort_Map__c SKUmap : maps) MapIds.add(SKUmap.Id); 
        createSKUEffortMapsEntries(MapIds);
        //Act
        Test.startTest();
        List<SKU_Effort_Map_Entry__c> result = sKUEffortDataManager.GetSKUEffortMapEntries(MapIds);
        
        Test.stopTest();
        
        //Assert
        System.assertEquals(3, result.size());
    
    }
    
    @isTest()
    static void GetProjectTasks_Should_Return_a_Task()
    {
        //Arrangea
        Order order = createOrderWithOrderItems();
        createSKUEffortMaps();
        SKUEffortDataManager sKUEffortDataManager = new SKUEffortDataManager(); 
        List<OrderItem> orderItems = sKUEffortDataManager.GetOrderItems(order.Id);
        Set<String> SKUs = new Set<String>();
        
        for (OrderItem item : orderItems) SKUs.add(item.SKU_Number__c); 
        
        List<String> listSKUs = new List<String>();
        listSKUs.addAll(SKUs);
    
        List<String> MapIds = new List<String>();
        List<Sku_Effort_Map__c> maps = sKUEffortDataManager.GetSKUEffortMaps(listSKUs);
        for (Sku_Effort_Map__c SKUmap : maps) MapIds.add(SKUmap.Id); 
        createSKUEffortMapsEntries(MapIds);
        
        pse__Proj__c proj = createProjectWithTaskAndSubTask('phaseName','Task 1', 7 );
        //Act
        Test.startTest();
        List<pse__Project_Task__c> result = sKUEffortDataManager.GetProjectTasks(proj.Id);
        
        Test.stopTest();
        
        //Assert
        System.assertEquals(1, result.size());
    
    }
}
@isTest
private class SKUEffortManagementRemovalServiceTest {
    static void setupTemplateProject() {
        pse__Proj__c templateProject = new pse__Proj__c(
            Name = 'Phased Project Template - Custom - Global',
            pse__Is_Template__c = true,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today()
        );

        insert(templateProject);

        List<pse__Project_Task__c> templateTasks = new List<pse__Project_Task__c>();

        pse__Project_Task__c t1 = new pse__Project_Task__c(
            Name = 'Initiate',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t1);

        pse__Project_Task__c t2 = new pse__Project_Task__c(
            Name = 'Plan',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t2);

        pse__Project_Task__c t3 = new pse__Project_Task__c(
            Name = 'Execute',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t3);
        
        pse__Project_Task__c t4 = new pse__Project_Task__c(
            Name = 'Close',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t4);

        pse__Project_Task__c t5 = new pse__Project_Task__c(
            Name = 'PM Activities',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t5);

        insert(templateTasks);
    }
    
    static void setupSkuEffortMapping() {
        SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
            Active__c = true,
            Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
            SKU_Number__c = '777-1000'
        );

        insert(skuEffortMap);

        List<SKU_Effort_Map_Entry__c> entries = new List<SKU_Effort_Map_Entry__c>();
        
        pse__Proj__c templateProject = [SELECT Id From pse__Proj__c WHERE Name = 'Phased Project Template - Custom - Global'];

        pse__Project_Task__c t1 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Initiate'];
        pse__Project_Task__c t2 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Plan'];
        pse__Project_Task__c t3 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Execute'];
        pse__Project_Task__c t4 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Close'];
        
        SKU_Effort_Map_Entry__c entry1 = new SKU_Effort_Map_Entry__c(
            Phase__c = t1.Id,
            Project_Complexity_Tier__c = 'Low',
            SKU_Effort_Map__c = skuEffortMap.Id,
            Estimated_Hours__c = 1,
            project__c = templateProject.Id,
            Name__c = 'Configuration'
        );

        entries.add(entry1);

        SKU_Effort_Map_Entry__c entry2 = new SKU_Effort_Map_Entry__c(
            Phase__c = t2.Id,
            Project_Complexity_Tier__c = 'Low',
            SKU_Effort_Map__c = skuEffortMap.Id,
            Estimated_Hours__c = 2,
            project__c = templateProject.Id,
            Name__c = 'Planning'
        );

        entries.add(entry2);

        SKU_Effort_Map_Entry__c entry3 = new SKU_Effort_Map_Entry__c(
            Phase__c = t3.Id,
            Project_Complexity_Tier__c = 'Low',
            SKU_Effort_Map__c = skuEffortMap.Id,
            Estimated_Hours__c = 3,
            project__c = templateProject.Id,
            Name__c = 'Physical Installation'
        );

        entries.add(entry3);

        SKU_Effort_Map_Entry__c entry4 = new SKU_Effort_Map_Entry__c(
            Phase__c = t4.Id,
            Project_Complexity_Tier__c = 'Low',
            SKU_Effort_Map__c = skuEffortMap.Id,
            Estimated_Hours__c = 5,
            project__c = templateProject.Id,
            Name__c = 'Config Assist'
        );

        entries.add(entry4);

        insert(entries);
    }
    
    static void setupProject() {
        pse__Proj__c testProj1 = new pse__Proj__c(
            Name = 'Test Proj 1',
            pse__Project_Phase__c = 'Setup',
            pse__Is_Template__c = false,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today(),
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'Low',
            Initiate_Customer_Contact__c = true,
            Planning_and_Design__c = true,
            Delivery_and_Implementation__c = true,
            Closure_Reason__c = 'Services Delivered'
        );

        insert(testProj1);
        
        List<pse__Project_Task__c> testProj1Tasks = new List<pse__Project_Task__c>();

        pse__Project_Task__c t1 = new pse__Project_Task__c(
        	Name = 'Configuration',
            pse__Estimated_Hours__c = 22,
            pse__Project__c = testProj1.Id
        );
        
        testProj1Tasks.add(t1);
        
        pse__Project_Task__c t2 = new pse__Project_Task__c(
        	Name = 'Planning',
            pse__Estimated_Hours__c = 33,
            pse__Project__c = testProj1.Id
        );
        
        testProj1Tasks.add(t2);
        
        pse__Project_Task__c t3 = new pse__Project_Task__c(
        	Name = 'Physical Installation',
            pse__Estimated_Hours__c = 44,
            pse__Project__c = testProj1.Id
        );
        
        testProj1Tasks.add(t3);
        
        pse__Project_Task__c t4 = new pse__Project_Task__c(
        	Name = 'Config Assist',
            pse__Estimated_Hours__c = 55,
            pse__Project__c = testProj1.Id
        );
        
        testProj1Tasks.add(t4);
        
        insert (testProj1Tasks);
        
        pse__Project_Task__c t5 = new pse__Project_Task__c(
        	Name = 'Config Assist - Child',
            pse__Estimated_Hours__c = -5,
            pse__Project__c = testProj1.Id,
            pse__Parent_Task__c = t4.Id
        );
        
        insert(t5);
    }

    static void setupOrder() {
        Account account = new Account(Name = 'Test account');
        
        insert(account);

        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Proj 1'];
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            OrderNumber__c = '555666',
            PriceBook2Id = Test.getStandardPricebookId(),
            Project__c = proj.Id
        );
        
        insert(order);
        
        Product2 product = new Product2(
        	Name = 'Test product'
        );
        
        insert(product);
        
        PriceBookEntry priceBookEntry = new PriceBookEntry(
        	PriceBook2Id = order.Pricebook2Id,
            Product2Id = product.Id,
            IsActive = true,
            UnitPrice = 1
        );
        
        insert(priceBookEntry);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        
		orderItems.Add(new OrderItem(
            SKU_Description__c = 'SKU Desc 1',
            SKU_Number__c = '777-1000',
            Quantity = 1,
            UnitPrice = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            Tie_Number__c = '1',
        	OrderId = order.Id,
        	PriceBookEntryId = priceBookEntry.Id));
            
        insert(orderItems);
    }    
    
    @testSetup
    static void setupData() {
        setupTemplateProject();
        setupSkuEffortMapping();
        setupProject();
        setupOrder();
    }
    
    @isTest
    static void manageTasksForOrderTest() {
        Order order = [SELECT Id, Project__c FROM Order];
        
        SKUEffortManagementRemovalService.SKUEffortManagementRequest request = new SKUEffortManagementRemovalService.SKUEffortManagementRequest();
            
	   	request.orderId = order.Id;
        request.projectId = order.Project__c;
        
        List<SKUEffortManagementRemovalService.SKUEffortManagementRequest> requests = new List<SKUEffortManagementRemovalService.SKUEffortManagementRequest>();
        
        requests.add(request);
        
        List<pse__Project_Task__c> oldProjTasks = [select id from pse__Project_Task__c];
        
        Test.startTest();
        
        SKUEffortManagementRemovalService.ManageTasksForOrder(requests);
        
        Test.stopTest();
        
        List<pse__Project_Task__c> newProjTasks = [select id from pse__Project_Task__c];
        
        System.assertNotEquals(oldProjTasks.size(), newProjTasks.size());
    }
    
}
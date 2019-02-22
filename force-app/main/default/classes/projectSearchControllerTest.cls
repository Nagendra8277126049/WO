@isTest
public class projectSearchControllerTest {
    static void setupProjectComplexities() {
        List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();

        projComplexities.add(new Project_Complexity_Threshold__c (
            Name = 'R1',
            Low_Threshold__c = 1000,
            High_Threshold__c = 2000
        ));

        insert(projComplexities);
    }

    static void setupProjectComplexityMappings() {
        List<Project_Complexity_Mapping__c> projComplexityMappings = new List<Project_Complexity_Mapping__c>();

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'Low',
            PM_Complexity__c = 'Low',
            Revenue_Threshold__c = 'Low'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'Medium',
            PM_Complexity__c = 'Medium',
            Revenue_Threshold__c = 'Medium'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'High',
            PM_Complexity__c = 'High',
            Revenue_Threshold__c = 'High'
        ));

        insert(projComplexityMappings);
    }

    static void setupRegions() {
        List<pse__Region__c> regions = new List<pse__Region__c>();

        regions.add(new pse__Region__c (
            Name = 'Test R1',
            ISO_Country_Code__c = 'R1'
        ));

        insert(regions);
    }

    static void createSkills() {
        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(new pse__Skill__c(Name = 'Project Management (Low)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (Medium)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (High)'));

        insert skills;
    }
    
    @testSetup
    static void setupData() {
    	setupProjectComplexities();
      	setupProjectComplexityMappings();
      	setupRegions();
        createSkills();
        Account account = new Account(Name = 'Test account');
        
        insert(account);
        
        pse__Region__c region = [SELECT Id FROM pse__Region__c WHERE Name = 'Test R1'];
        
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Account__c = account.Id,
            pse__Is_Template__c = false,
            pse__Is_Active__c = true,
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'Low',
            pse__Region__c = region.Id
        );
        
        insert(project);
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            PoNumber = '888999',
            Deal_ID__c = '000111',
            OrderNumber__c = '555666',
            PriceBook2Id = Test.getStandardPricebookId(),
            Project__c = project.Id
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
            SKU_Number__c = '123-456',
            Quantity = 1,
            UnitPrice = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            Tie_Number__c = '1',
        	OrderId = order.Id,
        	PriceBookEntryId = priceBookEntry.Id));
        
        insert(orderItems);
    }
    
    @isTest
    static void searchProjects_Should_Return_One_Project() {
        Order order = [SELECT Id FROM Order];
        
        Test.startTest();
        
        List<pse__Proj__c> projects = projectSearchController.searchProjects('555666', 'Test Project', '888999', 'Test account', '000111', '', '', new List<String> { order.Id });
            
        Test.stopTest();
        
        System.assertEquals(1, projects.size());
    }
    
    @isTest
    static void getOrderNumbers_Should_Return_One_Order() {
        Test.startTest();
        
        Order order = [SELECT Id, OrderNumber FROM Order WHERE OrderNumber__c = '555666'];
        
        String orders = projectSearchController.getOrderNumbers(new List<String> { order.Id });
            
        Test.stopTest();
        
        System.assertEquals(order.OrderNumber, orders);
    }
    
    @isTest
    static void associateOrdersToProject_Should_Return_True() {
        Order order = [SELECT Id, OrderNumber, Project__c FROM Order WHERE OrderNumber__c = '555666'];
        
        Test.startTest();
        
        Boolean result = projectSearchController.associateOrdersToProject(new List<string> { order.Id }, order.Project__c);
        
        Test.stopTest();
        
        System.assertEquals(true, result);
    }
}
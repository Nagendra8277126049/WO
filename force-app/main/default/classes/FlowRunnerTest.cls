@isTest
public class FlowRunnerTest
{
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
    static void setupSkills() {
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
        setupSkills();
    }
    
    @isTest static void testRunCreateOrderBudgetForProject()
    {
        // Arrange
        Order order = CreateOrderWithOrderItem();
        pse__Proj__c project = CreateProject();
        order.Project__c = project.Id;
        update order;
        
        // Act
        Test.startTest();
        FlowRunner.Run_Create_Order_Budget_for_Project(order.Id, project.Id);
        Test.stopTest();
    }
    
    @isTest static void testRunPostChatterMessage()
    {
        // Arrange
        String userId = UserInfo.getUserId();
        String message = 'Welcome to Salesforce';
        
        // Act
        Test.startTest();
        	FlowRunner.Run_Post_Chatter_Message(userId, message);
        Test.stopTest();
    }
    
    @isTest static void testRunAddTasksBasedOnSKUMapping()
    {
        Order order = CreateOrder();
        pse__Proj__c proj = CreateProject();
        
        order.Project__c = proj.id;
        
        update(order);
        
        Test.startTest();
        
        FlowRunner.Run_Add_Tasks_based_on_SKU_Mapping(order.Id, proj.Id, true);
        
        Test.stopTest();
        
        order = [SELECT Milestone__c FROM Order WHERE Id = :order.Id];
        
        System.assertNotEquals(null, order);
    }
    
    // Data Mock
    static Order CreateOrder()
    {
        Account account = new Account();
        account.Name = 'Create order test';
        insert(account);
        
        Order order = new Order();
        order.OrderNumber__c = '4393426';
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'BK';
        order.Order_Status__c = 'BK';
		order.Status_Date_Time__c = Date.today();
        order.RDD_Date__c = Date.today();

        
        insert order;
        return order;
    }
    
    static Order CreateOrderWithOrderItem()
    {
        Account account = new Account(Name='Test');
        insert account;
        Id pricebookId = Test.getStandardPricebookId();
        
        Order order = new Order();
        order.OrderNumber__c = '990088123';
        order.AccountId = account.Id;
        order.EffectiveDate = Date.today();
        order.Status = 'IP';
        order.Pricebook2Id = pricebookId;
        insert order;
        
        Product2 product = new Product2(Name='Product Test');
        insert product;
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = pricebookId;
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;
        
        OrderItem orderItem = new OrderItem();
        orderItem.SKU_Number__c = '444-999';
        orderItem.Quantity = 1;
        orderItem.OrderId = order.Id;
        orderItem.PricebookEntryId = pricebookEntry.Id;
        orderItem.UnitPrice = 1;
        orderItem.SKU_Cost__c = 44;
        orderItem.Item_Class_Description__c = 'SVC EDT INSTLN';
        
        insert orderItem;
        return order;
    }
    
    static pse__Proj__c CreateProject()
    {
        pse__Region__c region = [SELECT Id FROM pse__Region__c];
        
        pse__Proj__c project = new pse__Proj__c();
        project.Name = 'Project Test';
        project.pse__Is_Active__c = true;
        project.Project_Visibility__c = 'All';
        project.pse__End_Date__c = date.today().addDays(50); 
        project.CreatedDate = date.today();
        project.Project_Complexity__c = 'Low';
        project.pse__Region__c = region.Id;

        insert project;
        
        pse__Budget__c budget = new pse__Budget__c (
            pse__Amount__c = 100,
            pse__Project__c = project.Id
        );

        insert(budget);
        
        return project;
    }
}
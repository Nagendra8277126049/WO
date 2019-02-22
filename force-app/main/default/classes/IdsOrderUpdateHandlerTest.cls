@isTest()
public class IdsOrderUpdateHandlerTest {
    
    static void createSkill(string name){
        pse__Skill__c skill = new pse__Skill__c(Name=name);
        insert skill;
    }
    
    static pse__Proj__c createProject(Id accountId) {
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, 
                                                pse__Start_Date__c = Date.today(), pse__Account__c=accountId);
        insert project;
        
        return project;
    }
    
    static Order createOrder(string name, string orderNumber, string status)
    {
        Account account = new Account();
        account.Name = name;
        insert(account);
        
        pse__Proj__c project = createProject(account.Id);
        
        Order order = new Order();
        order.OrderNumber__c = orderNumber;
        order.EffectiveDate = Date.valueOf('2018-07-17');
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = status;
        order.Pricebook2Id = Test.getStandardPricebookId(); 
        order.Milestone__c = createMilestone(project.Id).Id;
        order.Project__c = project.Id;

        insert order;
        
        createOrderItem(order.Id);
        
        return order;
    } 
    
    static pse__Milestone__c createMilestone(Id projectId) {
        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.pse__Project__c = projectId;
        milestone.pse__Target_Date__c = Date.valueOf('2018-07-17');
        
        insert milestone;
        
        return milestone;
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
    
    @testSetup static void setup() {
        createSkill('Project Management (Low)');
        createSkill('Project Management (Medium)');
        createSkill('Project Management (High)');      
    }

    @isTest()
    static void handleUpdateTest() {
        // arrange           

        List<Order> newOrders = new List<Order>();
        
        Order newOrder = createOrder('Test Order1', '12345', 'BK');
        newOrder.Status = 'CL';
        newOrders.add(newOrder);
        
        List<Order> oldOrders = new List<Order>(newOrders);
        //oldOrders.add(createOrder('Test Order2', '54321', 'BK'));
        
        // act
        IdsOrderUpdateHandler.HandleUpdate(newOrders, oldOrders);
        
        // assert
		system.assert(true);
    }
    
    @isTest()
    static void handleStatusUpdateTest() {
        //arrange
        Order order = createOrder('Test Order1', '12345', 'BK');        

        List<Order> newOrders = new List<Order>();
        newOrders.add(order);
        
        List<Order> oldOrders = new List<Order>(newOrders);
        
        List<Custom_Order_Status_to_Order_Status_Map__mdt> maps = [SELECT Id, Custom_Status__c, Order_Status__c FROM Custom_Order_Status_to_Order_Status_Map__mdt];
        
        //act
        IdsOrderUpdateHandler.HandleStatusUpdate(newOrders, oldOrders, maps);
        
        //assert
        system.assert(true);
    }
}
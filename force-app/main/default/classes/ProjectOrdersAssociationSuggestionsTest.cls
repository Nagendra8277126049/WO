@isTest
public class ProjectOrdersAssociationSuggestionsTest {
    
    @testSetup
    static void setupData() {
        setupSkill();
    }
    
    static void setupSkill() {
        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)');
        skills.add(lowSkill);
        pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)');
        skills.add(mediumSkill);
        pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)');

        skills.add(highSkill);
        insert skills;
    }
    
	@isTest
    public static void sugestProjectsWithSameDpid(){
        
        Id projectId = ProjectOrdersAssociationSuggestionsTest.createInsertInProgressProject();
        
        List<Order> orders = ProjectOrdersAssociationSuggestionsTest.createInsertOrders(2);

        orders[0].Project__c = projectId;
        orders[0].DPID__c  = '123123';
        update orders[0];
        orders[1].DPID__c  = '123123';
        update orders[1];
        
        Test.StartTest();
        SuggestedProjectAssociation result = CandidateProjectsToAssociationController.getProjectSuggestions(orders[1].Id)[0];
        Test.StopTest();
         
		System.assertEquals(result.project.Id,projectId);
    }
    
    @isTest
    public static void shouldntSugestProjectsWithDifferentDpids(){
        
        Id projectId = ProjectOrdersAssociationSuggestionsTest.createInsertInProgressProject();
        
        List<Order> orders = ProjectOrdersAssociationSuggestionsTest.createInsertOrders(2);

        orders[0].Project__c = projectId;
        orders[0].DPID__c  = '123123';
        update orders[0];
        orders[1].DPID__c  = '321321';
        update orders[1];
        
        Test.StartTest();
        List<SuggestedProjectAssociation> result = CandidateProjectsToAssociationController.getProjectSuggestions(orders[1].Id);
        Test.StopTest();
         
		System.assert(result.size() == 0);
    }
    
    @isTest
    public static void sugestProjectsWithSameDealId(){
        
        Id projectId = ProjectOrdersAssociationSuggestionsTest.createInsertInProgressProject();
        
        List<Order> orders = ProjectOrdersAssociationSuggestionsTest.createInsertOrders(2);

        orders[0].Project__c = projectId;
        orders[0].Deal_ID__c  = '123123';
        update orders[0];
        orders[1].Deal_ID__c  = '123123';
        update orders[1];
        
        Test.StartTest();
        SuggestedProjectAssociation result = CandidateProjectsToAssociationController.getProjectSuggestions(orders[1].Id)[0];
        Test.StopTest();
         
		System.assertEquals(result.project.Id,projectId);
    }
    
    @isTest
    public static void sugestProjectsWithSamePO(){
        
        Id projectId = ProjectOrdersAssociationSuggestionsTest.createInsertInProgressProject();
        
        List<Order> orders = ProjectOrdersAssociationSuggestionsTest.createInsertOrders(2);

        orders[0].Project__c = projectId;
        orders[0].PoNumber  = '123123';
        update orders[0];
        orders[1].PoNumber  = '123123';
        update orders[1];
        
        Test.StartTest();
        SuggestedProjectAssociation result = CandidateProjectsToAssociationController.getProjectSuggestions(orders[1].Id)[0];
        Test.StopTest();
         
		System.assertEquals(result.project.Id,projectId);
    }
    
    @isTest
    public static void sugestProjectsWithSameBillingAddress() {
 		Account account = new Account(Name = 'Test account');

        insert(account);
        
        pse__Proj__c project = new pse__Proj__c(
        	Name = 'Test Project',
            pse__Account__c = account.Id,
            pse__Is_Active__c = true
        );
        
        insert(project);
        
        Order order1 = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            OrderNumber__c = '5556667',
            PriceBook2Id = Test.getStandardPricebookId(),
            Project__c = project.Id,
            BillingStreet = 'Av Ipiranga, 6681'
        );
        
        insert(order1);        
       
        Order order2 = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            OrderNumber__c = '5556668',
            PriceBook2Id = Test.getStandardPricebookId(),
            CustomerNumber__c = '112233',
            BillingStreet = 'Av Ipiranga, 6681'
        );
        
        insert(order2);
        
        Test.StartTest();

        List<SuggestedProjectAssociation> results = CandidateProjectsToAssociationController.getProjectSuggestions(order2.Id);
        
        Test.StopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project', results[0].project.Name);
    }
    
    @isTest
    public static void getOrderListViews() {
         Test.StartTest();

        List<ListView> listViews = CandidateProjectsToAssociationController.getListViews();
        
        Test.StopTest();
        
        System.assert(listViews != null);
        System.assertNotEquals(0, listViews.size());
    }
    
    private static List<Order> createInsertOrders(Integer qt){
        Account acct = new Account();
        acct.Name = 'Test FF Account'; 
        insert acct;
        Integer rd = (Integer) Math.Random() * 10;
        List<Order> listOrder = new List<Order>(); 
        for(Integer count = 0; count< qt ;count++){
            Order orderExpectingSuggestions = new Order();
        	orderExpectingSuggestions.AccountId = acct.Id;
        	orderExpectingSuggestions.EffectiveDate = System.Today();
        	orderExpectingSuggestions.Status = 'BK';
        	orderExpectingSuggestions.OrderNumber__c = '000'+(count+1)+rd;
        	insert orderExpectingSuggestions;
            listOrder.add(orderExpectingSuggestions);
        }
        return listOrder;
    }
    
    private static Id createInsertInProgressProject(){
        pse__proj__c newProjec = new pse__proj__c();
        newProjec.pse__Stage__c = 'In Progress';
        newProjec.Project_Visibility__c = 'All';
        newProjec.pse__Is_Active__c = true;
        insert newProjec;
        return newProjec.Id;
    }
}
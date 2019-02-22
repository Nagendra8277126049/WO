@isTest
public class OrderApprovalRecallerTest {
    
    @testSetup
    private static void setupData() {
		Account account = new Account(Name = 'Test');
        insert account;
        
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
        
        Order order = new Order(
            EffectiveDate = Date.valueOf('2018-07-07'), 
            AccountId = account.Id, 
            OrderNumber__c = '777620',
            BUID__c = '11', 
            CurrencyIsoCode = 'USD', 
            Status = 'BK',
            Approval_Project_Id__c = testProj1.Id,
            Association_Approver__c = UserInfo.getUserId()
        );
        
        insert(order);

        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(new pse__Skill__c(Name = 'Project Management (Low)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (Medium)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (High)'));

        insert skills;
    }
    
    @isTest
    private static void recallOrderApprovalProcessTest() {
        
        Order order = [SELECT Id FROM Order];
        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(order.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 

        // Submit the record to specific process
        req1.setProcessDefinitionNameOrId('Order_Association_Approval_Process');

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        System.debug([SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status FROM ProcessInstanceWorkitem]);
        
        Test.startTest();
        
        OrderApprovalRecaller.RecallOrderApprovalProcess(new List<String> { order.Id });
            
        Test.stopTest();

        List<ProcessInstanceWorkitem> processIntanceWorkItems = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status FROM ProcessInstanceWorkitem];
        
		System.assertEquals(0, processIntanceWorkItems.size());
    }
    
}
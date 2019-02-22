@isTest()
public class DispatchCreationOrderListProviderTest {

    @isTest()
    static void getOrderItemsTest() {
        // arrange
        
        // - account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        // - project
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today(), pse__Account__c=a.Id);
        insert project;
        
        // - project task
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.pse__Project__c = project.Id;
        insert pt;
        
        // - Contact
        Contact contact = new Contact();
        contact.Phone = '123456';
        contact.FirstName = 'John';
        contact.LastName = 'Test';
        contact.Email = 'test@test.com';
        insert contact;
        
        // - Partner Detail
        Partner_Details__c partner = new Partner_Details__c();
        partner.Name = 'WISTR';
        partner.Code__c = 'WISTR';
        partner.Country__c = 'US';
        insert partner;
        
        // - work order
        WorkOrder workOrder = new WorkOrder();
        workOrder.Status = 'FF - New';
        workOrder.Project_Task__c = pt.Id;
        workOrder.Country__c = 'US';
        workOrder.Partner_Country__c = 'US'; 
        workOrder.CountryCode = 'US';
        workOrder.City= 'Austin';
        workOrder.State = 'Texas';
        workOrder.Contact = contact;
        workOrder.DPSType__c = 'Installation';
        workOrder.PartnerName__c = partner.Id;
        workOrder.Description = 'Test Description';
        insert workOrder;
        
        // - order
        Order order = new Order();
        order.Project__c = pt.pse__Project__c;
        order.OrderNumber__c = '543216';
        order.AccountId = a.Id;
        order.EffectiveDate = Date.newInstance(2019, 2, 7);
        order.Status = 'Draft';
        insert order;
        
        // - asset
        Asset asset = new Asset(Name='Asset Test', Order_Number__c='543216', Order_BUID__c='11');
        insert asset;
        
        // act
        DispatchCreationFromOrderListProvider provider = new DispatchCreationFromOrderListProvider();
        List<Asset> result = provider.GetOrderItems(workOrder.Id);
        
        // assert
        system.assert(result.size() > 0);
        system.assertEquals(result.get(0).Name, 'Asset Test');
        //List<Asset> assets = [SELECT Id, Name FROM Asset WHERE Order_Number__c='54321'];
        //system.debug('Test');
        //system.debug(result);
    }
    
    @isTest()
    static void getWorkOrderStatusTest() {
        // arrange
        WorkOrder wo = new WorkOrder(Status='FF-New');
        insert wo;
        
        // act
        DispatchCreationFromOrderListProvider provider = new DispatchCreationFromOrderListProvider();
        String status = provider.GetWorkOrderStatus(wo.Id);
        
        // assert
        system.assertEquals(status, 'FF-New');
    }

    @isTest()
    static void createDispatchWithError(){
        // - account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        // - project
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, pse__Start_Date__c = Date.today(), pse__Account__c=a.Id);
        insert project;
        
        // - project task
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.pse__Project__c = project.Id;
        insert pt;

        WorkOrder workOrder = new WorkOrder();
        workOrder.Status = 'FF - New';
        workOrder.Project_Task__c = pt.Id;
        workOrder.Country__c = null;
        workOrder.Partner_Country__c = 'US'; 
        workOrder.CountryCode = 'US';
        workOrder.City= null;
        workOrder.State = null;
        workOrder.Contact = null;
        workOrder.DPSType__c = null;
        workOrder.PartnerName__c = null;
        workOrder.Description = null;
        insert workOrder;

        DispatchCreationFromOrderListProvider provider = new DispatchCreationFromOrderListProvider();
        List<Asset> result = provider.GetOrderItems(workOrder.Id);

        system.assertNotEquals(result, null);
    }
    
}
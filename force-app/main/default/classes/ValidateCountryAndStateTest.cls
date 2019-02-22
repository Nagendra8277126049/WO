@isTest()
public class ValidateCountryAndStateTest {    
    
    private static Order createOrder(string mailingCountry, string mailingState, string billingCountry, string billingState, string shippingCountry, string shippingState) {
        //create Contact
        Contact contact = new Contact(FirstName='Test', LastName='Contact', Mailing_Country__c=mailingCountry, Mailing_State__c=mailingState, Email='test@dell.com');
        insert contact;
        
        //create account
        Account account = new Account(Name = 'Order Status Test Account');        
        insert(account);
        
        // create order
        Order order = new Order(OrderNumber__c='987654321', Billing_Country__c=billingCountry, Billing_State__c=billingState, 
                                Shipping_Country__c=shippingCountry, Shipping_State__c=shippingState, BillToContactId=contact.Id, ShipToContactId=contact.Id, 
                                AccountId=account.Id, EffectiveDate = Date.valueOf('2018-07-17'), Pricebook2Id = Test.getStandardPricebookId(), Status='BK');
        insert order;

        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(new pse__Skill__c(Name = 'Project Management (Low)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (Medium)'));
        skills.add(new pse__Skill__c(Name = 'Project Management (High)'));

        insert skills;

        return order;
    }

    @isTest()
    static void validateBillContactAddress() {
        //Arrange
        Order order = createOrder('United States', 'Texas', null, null, null, null);
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        //Act
        ValidateCountryAndState.validadeOrderCountryState(orderIds);
        Order result = [SELECT Id, BillToContact.MailingCountry, BillToContact.MailingState FROM Order WHERE Id =:order.Id LIMIT 1];
        
        //Assert
        System.assert(result != null);
        System.assertEquals(result.BillToContact.MailingCountry, 'United States');
        System.assertEquals(result.BillToContact.MailingState, 'Texas');
    }
    
    @isTest()
    static void validateShipContactAddress() {
        //Arrange
        Order order = createOrder('United States', 'Texas', null, null, null, null);
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        //Act
        ValidateCountryAndState.validadeOrderCountryState(orderIds);
        Order result = [SELECT Id, ShipToContact.MailingCountry, ShipToContact.MailingState FROM Order WHERE Id =:order.Id LIMIT 1];
        
        //Assert
        System.assert(result != null);
        System.assertEquals(result.ShipToContact.MailingCountry, 'United States');
        System.assertEquals(result.ShipToContact.MailingState, 'Texas');
    }
    
    @isTest()
    static void validateBillingAddress() {
        //Arrange
        Order order = createOrder(null, null, 'United States', 'Texas', null, null);
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        //Act
        ValidateCountryAndState.validadeOrderCountryState(orderIds);
        Order result = [SELECT Id, BillingCountry, BillingState FROM Order WHERE Id =:order.Id LIMIT 1];
        
        //Assert
        System.assert(result != null);
        System.assertEquals(result.BillingCountry, 'United States');
        System.assertEquals(result.BillingState, 'Texas');
    }
    
    @isTest()
    static void invalidBillingCountryAddress() {
        //Arrange
        Order order = createOrder(null, null, 'UnitedStates', 'Texas', null, null);
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        //Act
        ValidateCountryAndState.validadeOrderCountryState(orderIds);
        Order result = [SELECT Id, BillingCountry, BillingState FROM Order WHERE Id =:order.Id LIMIT 1];
        
        //Assert
        System.assert(result != null);
        System.assertEquals(result.BillingCountry, null);
        System.assertEquals(result.BillingState, null);
    }
    
    @isTest()
    static void invalidBillingStateAddress() {
        //Arrange
        Order order = createOrder(null, null, 'United States', 'Texass', null, null);
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        //Act
        ValidateCountryAndState.validadeOrderCountryState(orderIds);
        Order result = [SELECT Id, BillingCountry, BillingState FROM Order WHERE Id =:order.Id LIMIT 1];
        
        //Assert
        System.assert(result != null);
        System.assertEquals(result.BillingCountry, 'United States');
        System.assertEquals(result.BillingState, null);
    }
    
    @isTest()
    static void validateShippingAddress() {
        //Arrange
        Order order = createOrder(null, null, null, null, 'United States', 'Texas');
        List<Id> orderIds = new List<Id>();
        orderIds.add(order.Id);
        
        //Act
        ValidateCountryAndState.validadeOrderCountryState(orderIds);
        Order result = [SELECT Id, ShippingCountry, ShippingState FROM Order WHERE Id =:order.Id LIMIT 1];
        
        //Assert
        System.assert(result != null);
        System.assertEquals(result.ShippingCountry, 'United States');
        System.assertEquals(result.ShippingState, 'Texas');
    }
    
}
/**
 * Created by Willian_Paulo on 1/30/2019.
 */

@IsTest
private class OrderTriggerTest {
    static testMethod void testBehavior() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Test account'];
        pse__Proj__c project = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Proj 1'];
        Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                Order_Status__c = 'BK',
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                PriceBook2Id = Test.getStandardPricebookId(),
                Project__c = project.Id
        );


        insert(order);

        Product2 product = new Product2(Name='Product Test');
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=product.Id,  UseStandardPrice=false, UnitPrice=1);
        insert pricebookEntry;

        OrderItem orderItem = new OrderItem(SKU_Number__c='444-999', Quantity=1, OrderId=order.Id, PricebookEntryId=pricebookEntry.Id, UnitPrice=1);
        insert orderItem;

        order.Order_Status__c = 'PP';
        order.Status = 'PP';

        update order;
    }

    @TestSetup
    private static void setupTestData() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PSA Project Manager'];
        User user = new User(
                UserName = 'pm_test_user@dell.com',
                LastName = 'One',
                Email = 'pm_test_user@dell.com',
                Alias = 't1',
                CommunityNickname = 't1',
                Federal_Access__c = false,
                FederationIdentifier = '22334466',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No',
                Dell_NTUserID__c = 'TEST_USER',
                Service_User_Type__c = 'Admin',
                External_ID__c = '22334466',
                Organization__c = 'Test Org',
                File_Source__c = 'AMS - System Admin'
        );

        insert user;

        pse__Region__c region = new pse__Region__c (
                Name = 'Test R1',
                ISO_Country_Code__c = 'R1'
        );

        insert(region);

        Account account = new Account(Name = 'Test account');

        insert account;

        Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'pm_test_user@dell.com',
                AccountId = account.Id,
                pse__Salesforce_User__c = user.Id,
                pse__Region__c = region.Id,
                pse__Is_Resource_Active__c = true,
                pse__Is_Resource__c = true
        );

        pse__Proj__c project = new pse__Proj__c(
                Name = 'Test Proj 1',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = region.Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Project_Manager__c = contact.Id
        );

        insert project;

        pse__Skill__c lowSkill = new pse__Skill__c (Name = 'Project Management (Low)');
        pse__Skill__c mediumSkill = new pse__Skill__c (Name = 'Project Management (Medium)');
        pse__Skill__c highSkill = new pse__Skill__c (Name = 'Project Management (High)');
        insert  lowSkill;
        insert mediumSkill;
        insert highSkill;
    }
}
@isTest class SiteManagerTest {
    @isTest static void CreateAndAssociateOrderSites_Should_CreateSites() {
        Account account = new Account(Name = 'Test account');

        insert(account);

        List<Contact> contacts = new List<Contact>();

        Contact soldToContact = new Contact(
                FirstName = 'Sold To',
                LastName = 'Test',
                Email = 'test@test.com',
                MailingStreet = 'Av Ipiranga, 6800',
                MailingPostalCode = '90123-000',
                MailingCountry = 'Brazil',
                MailingCity = 'Porto Alegre',
                MailingState = 'Rio Grande do Sul',
                Account_Id__c = account.Id
        );

        contacts.add(soldToContact);

        Contact shipToContact = new Contact(
                FirstName = 'Ship To',
                LastName = 'Test',
                Email = 'test@test.com',
                MailingStreet = 'Av Ipiranga, 6800',
                MailingPostalCode = '90123-000',
                MailingCountry = 'Brazil',
                MailingCity = 'Porto Alegre',
                MailingState = 'Rio Grande do Sul',
                Account_Id__c = account.Id
        );

        contacts.add(shipToContact);

        Contact billToContact = new Contact(
                FirstName = 'Bill To',
                LastName = 'Test',
                Email = 'test@test.com',
                MailingStreet = 'Av Ipiranga, 6802',
                MailingPostalCode = '90123-002',
                MailingCountry = 'Brazil',
                MailingCity = 'Porto Alegre',
                MailingState = 'Rio Grande do Sul',
                Account_Id__c = account.Id
        );

        contacts.add(billToContact);

        Contact directContact = new Contact(
                FirstName = 'Direct',
                LastName = 'Test',
                Email = 'test@test.com',
                MailingStreet = 'Av Ipiranga, 6803',
                MailingPostalCode = '90123-003',
                MailingCountry = 'Brazil',
                MailingCity = 'Porto Alegre',
                MailingState = 'Rio Grande do Sul',
                Account_Id__c = account.Id
        );

        contacts.add(directContact);


        Contact installAtContact = new Contact(
                FirstName = 'InstallAt',
                LastName = 'Test',
                Email = 'test@test.com',
                MailingStreet = 'Av Ipiranga, 6803',
                MailingPostalCode = '90123-003',
                MailingCountry = 'Brazil',
                MailingCity = 'Porto Alegre',
                MailingState = 'Rio Grande do Sul',
                Account_Id__c = account.Id
        );

        contacts.add(installAtContact);


        insert contacts;

        Order order = new Order(
                Sold_to_Contact__c = soldToContact.Id,
                ShipToContactId = shipToContact.Id,
                BillToContactId = billToContact.Id,
                Direct_Contact__c = directContact.Id,
                AccountId = account.Id,
                Install_At_Contact__c = installAtContact.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                OrderNumber__c = '112233'
        );

        insert(order);

        Test.startTest();

        SiteManager.CreateAndAssociateOrderSites(new List<Id>{
                order.Id
        });

        Test.stopTest();

        //Dell_Site__c
        //Project_Site__c


        //System.assert(orderItems != null);

        //System.assert(orderItems.size() == 0);
    }
}
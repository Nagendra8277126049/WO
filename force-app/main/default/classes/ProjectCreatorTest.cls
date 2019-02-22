@isTest
private class ProjectCreatorTest {
    static Group createIDS_EMEA_ProjectsQueue()
    {
        Group EMEA_Queue = new Group();
        EMEA_Queue.DeveloperName = 'IDS_EMEA_Projects';
        EMEA_Queue.Name = 'IDS - EMEA Projects';
        EMEA_Queue.Type = 'Queue';
        insert(EMEA_Queue);
        return EMEA_Queue;
    }

    static Group createIDS_Global_ProjectsQueue()
    {
        Group Global_Queue = new Group();
        Global_Queue.DeveloperName = 'IDS_Undefined_Projects';
        Global_Queue.Name = 'IDS - Undefined Projects';
        Global_Queue.Type = 'Queue';
        insert(Global_Queue);
        return Global_Queue;
    }

    static pse__region__c CreateGlobalRegion()
    {
        pse__region__c regionGlobal = new pse__Region__c();
        regionGlobal.Name = 'Global';
        insert(regionGlobal);
        return regionGlobal;
    }

    static pse__region__c CreateUSRegion()
    {
        pse__region__c regionAMERICAS = new pse__Region__c();
        regionAMERICAS.Name = 'AMERICAS';
        insert(regionAMERICAS);
        
        pse__region__c regionUS = new pse__Region__c();
        regionUS.Name = 'US';
        regionUS.ISO_Country_Code__c = 'US';
        regionUS.pse__Parent_Region__c = regionAMERICAS.Id;
        insert(regionUS);
        return regionUS;
    }

    static void CreateRegions()
    {
        pse__region__c regionEMEA = new pse__Region__c();
        regionEMEA.Name = 'EMEA';
        insert(regionEMEA);

        pse__region__c regionAMERICAS = new pse__Region__c();
        regionAMERICAS.Name = 'AMERICAS';
        insert(regionAMERICAS);

        pse__region__c regionAPJ = new pse__Region__c();
        regionAPJ.Name = 'APJ';
        insert(regionAPJ);

        pse__region__c regionUS = new pse__Region__c();
        regionUS.Name = 'US';
        regionUS.ISO_Country_Code__c = 'US';
        regionUS.pse__Parent_Region__c = regionAMERICAS.Id;
        insert(regionUS);

        pse__region__c regionFR = new pse__Region__c();
        regionFR.Name = 'FR';
        regionFR.ISO_Country_Code__c = 'FR';
        regionFR.pse__Parent_Region__c = regionEMEA.Id;
        insert(regionFR);

        pse__region__c regionAU = new pse__Region__c();
        regionAU.Name = 'AU';
        regionAU.ISO_Country_Code__c = 'AU';
        regionAU.pse__Parent_Region__c = regionAPJ.Id;
        insert(regionAU);
    }

    static Order createOrder() {
        Account account = new Account();
        account.Name = 'Create order test';
        insert(account);
        Order order = new Order();
        order.OrderNumber__c = '4393426';
        order.EffectiveDate = Date.valueOf('2018-07-17');
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'IP';
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.OCI_Order_Type__c = 'US Order';
        
        return order;   
    }

    static Order createOrderWithYesterdayEffectiveDate()
    {
        Date EffectiveDate = Date.today();
        
        Account account = new Account();
        account.Name = 'Create order test';
        insert(account);
        Order order = new Order();
        order.OrderNumber__c = '4393426';
        order.EffectiveDate = EffectiveDate.addDays(-1);
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'IP';
        order.Pricebook2Id = Test.getStandardPricebookId();
        return order;
    }

    static pse__Proj__c createTemplateIDS()
    {
        pse__Proj__c TemplateIDS = new pse__Proj__c();
        TemplateIDS.Name = 'Phased Project Template - Custom - Global';
        TemplateIDS.pse__Is_Template__c = true;
        TemplateIDS.pse__Is_Active__c = true;
        TemplateIDS.Project_Visibility__c = 'All';
        return TemplateIDS;
    }

    static pse__Proj__c createTemplateNoIDS()
    {
        pse__Proj__c TemplateIDS = new pse__Proj__c();
        TemplateIDS.Name = 'No IDS Template';
        TemplateIDS.pse__Is_Template__c = true;
        TemplateIDS.pse__Is_Active__c = true;
        TemplateIDS.Project_Visibility__c = 'All';
        return TemplateIDS;
    }

    @isTest
    static void getOrderInformation_Should_Return_USD_CurrencyIsoCode()
    {
        //Arrange
        Order order = createOrder();
        insert(order);
        
        //Act
        Test.startTest();
        Order result = ProjectCreator.getOrderInformation(new List<String> { order.Id })[0];
        string CurrencyIsoCode = order.CurrencyIsoCode;
        Test.stopTest();
        
        //Assert
        System.assert(CurrencyIsoCode == 'USD');
    }

    @isTest
    static void getOrderInformation_Should_Return_BUID()
    {
        //Arrange
        Order order = createOrder();
        insert(order);
        
        //Act
        Test.startTest();
        Order result = ProjectCreator.getOrderInformation(new List<String> { order.Id })[0];
        string BUID = order.BUID__c;
        Test.stopTest();
        
        //Assert
        System.assert(BUID == '11');
    }

    @isTest
    static void getProjectTemplate_Should_Return_EmptyString()
    {
        //Arrange
        pse__Proj__c templateIDS = createTemplateIDS();
        insert(templateIDS);
        
        //Act
        Test.startTest();
        pse__Proj__c result = ProjectCreator.getProjectTemplate('No-IDS');
        Test.stopTest();
        
        //Assert
        System.assertEquals(null, result);
    }

    @isTest
    static void getAccount_Should_Return_Name()
    {
        //Arrange
        Account account = new Account();
        account.Name = 'Create order test';
        insert(account);
            
        //Act
        Test.startTest();
        Account result = ProjectCreator.getAccountInformation(account.Id);
        Test.stopTest();
        
        //Assert
        System.assertEquals(account.Name, result.Name);
    }

    @isTest
    static void getPracticeInformation_Should_Return_Name()
    {
        //Arrange
        pse__Practice__c practice = new pse__Practice__c();
        practice.Name = 'Infrastructure Deployment Services';
        insert(practice);
            
        //Act
        Test.startTest();
        pse__Practice__c result = ProjectCreator.getPracticeInformation('Infrastructure Deployment Services');
        Test.stopTest();
        
        //Assert
        System.assertEquals(practice.Name, result.Name);
    }

    @isTest
    static void setCurrencyMappField_Should_Return_USD_Currency()
    {
        Order order = createOrder();
        insert(order);
        
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setCurrencyMappField(order);
        Test.stopTest();
        
        //Assert
        System.assertEquals(order.CurrencyIsoCode, result.defaultValue);
    }

    @isTest
    static void setIsTemplateMappField_Should_Return_false()
    {
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setIsTemplateMappField();
        Test.stopTest();
        
        //Assert
        System.assertEquals(false, result.defaultValue);
    }

    @isTest
    static void setProjectVisibilityMappField_Should_Return_All() {
        //Arrange
        Order order = createOrder();
        
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setProjectVisibilityMappField(order);
        Test.stopTest();
        
        //Assert
        System.assertEquals('All', result.defaultValue);
    }

    @isTest
    static void setProjectVisibilityMappField_Should_Return_Federal_To_OMEGA() {
        //Arrange
        Order order = createOrder();
        order.OCI_Order_Type__c = 'US FED Order';
        
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setProjectVisibilityMappField(order);
        Test.stopTest();
        
        //Assert
        System.assertEquals('Federal', result.defaultValue);
    }

    @isTest
    static void setProjectVisibilityMappField_Should_Return_Federal_To_DOMS() {
        //Arrange
        Order order = createOrder();
        order.Sales_Channel__c = 'Fed';
        
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setProjectVisibilityMappField(order);
        Test.stopTest();
        
        //Assert
        System.assertEquals('Federal', result.defaultValue);
    }    

    @isTest
    static void setProjectManagerMappField_Should_Return_ProjectManagerId()
    {
        //Arrange
        Contact pmContact = new Contact();
        pmContact.FirstName = 'Some';
        pmContact.LastName = 'Name';
        pmContact.Email = 'somemail@dell.com';
        insert(pmContact);
        
        IDS_Default_Project_Manager__c config = new IDS_Default_Project_Manager__c();
        config.value__c = pmContact.Id;
        insert(config);
        
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setProjectManagerMappField();
        Test.stopTest();
        
        //Assert
        System.assertEquals(pmContact.Id , result.defaultValue);
    }

    @isTest
    static void setProjectManagerMappField_Should_Return_Null_When_PmContact_Does_Not_Exist()
    {
        //Arrange    
        IDS_Default_Project_Manager__c config = new IDS_Default_Project_Manager__c();
        config.value__c = 'PMIdThatDoesNotExist';
        insert(config);
        
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setProjectManagerMappField();
        Test.stopTest();
        
        //Assert
        System.assertEquals(null , result.defaultValue);
    }

    @isTest
    static void setNameMappField_Should_Return_Correct_Name()
    {
        //Arrange
        Order order = createOrder();
        insert(order);
        Account account = ProjectCreator.getAccountInformation(order.AccountId);
        string expectadedName = account.Name + Datetime.now().format('MMM dd yyyy HHmmss');
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setNameMappField(account);
        Test.stopTest();
        
        //Assert
        System.assertEquals(expectadedName, result.defaultValue);
    }

    @isTest
    static void setUniqueNameMappField_Should_Return_Correct_Name()
    {
        //Arrange
        Order order = createOrder();
        insert(order);
        Account account = ProjectCreator.getAccountInformation(order.AccountId);
        string expectadedName = account.Name + Datetime.now().format('MMM dd yyyy HHmmss');
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setUniqueNameMappField(account);
        Test.stopTest();
        
        //Assert
        System.assertEquals(expectadedName, result.defaultValue);
    }

    @isTest
    static void setAccountMappField_Should_Return_Account()
    {
        //Arrange
        Order order = createOrder();
        insert(order);
        Account account = ProjectCreator.getAccountInformation(order.AccountId);
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setAccountMappField(account);
        Test.stopTest();
        
        //Assert
        System.assertEquals(order.AccountId, result.defaultValue);
    }

    @isTest
    static void setRegionMappField_Should_Return_US()
    {
        //Arrange
        
        pse__Region__c r = new pse__Region__c();
        r.ISO_Country_Code__c = 'US';
        r.Name = 'Test Country';
        insert(r);
        Order order = createOrder();
        insert(order);
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setRegionMappField(order);
        Test.stopTest();
        
        //Assert
        System.assertEquals(r.Id, result.defaultValue);
    }

    @isTest
    static void setStartDateMappField_Should_Return_Today()
    {
        //Arrange
        Order order = createOrder();
        insert(order);
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setStartDateMappField(order);
        Test.stopTest();
        
        //Assert
        System.assertEquals(Date.today(), result.defaultValue);
    }

    @isTest
    static void setEndDateMappField_Should_Return_Today()
    {
        //Arrange
        Order order = createOrder();
        insert(order);
        //Act
        Test.startTest();
        pse.SObjectCloneMapper.Field result = ProjectCreator.setEndDateMappField(order);
        Test.stopTest();
        
        //Assert
        System.assertEquals(Date.today().addDays(7), result.defaultValue);
    }

    @isTest
    static void getRegion_Should_Return_US()
    {
        //Arrange
        pse__region__c region = CreateUSRegion();
        
        //Act
        Test.startTest();
        pse__region__c result = ProjectCreator.getRegion(region.Id);
        Test.stopTest();
        
        //Asserta
        System.assertEquals(region.Name, result.Name);
    }

    @isTest
    private static void getRegion_Should_Return_Null()
    {
        //Arrange
        pse__region__c region = CreateUSRegion();
        
        //Act
        Test.startTest();
        pse__region__c result = ProjectCreator.getRegion('');
        Test.stopTest();
        
        //Assert
        System.assertEquals(null, result);
    }

    @testSetup
    static void setupData(){
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Phased Project Template - Custom - Global',
            pse__Is_Template__c = true,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today()
        );

        insert(project);

        pse__Practice__c practice = new pse__Practice__c(
            Name = 'Infrastructure Delivery Services'
        );

        insert(practice);

        pse__Region__c region = new pse__Region__c(
            Name = 'Global'
        );

        insert region;
        
        pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)');
        pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)');
        pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)');
        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(lowSkill);
        skills.add(mediumSkill);
        skills.add(highSkill);
        insert skills;
    }

    @isTest
    static void createProjectByOrderId_Should_Return_NewProject() {
        Account account = new Account(Name = 'Test account');
        
        insert(account);
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            OrderNumber__c = '555666',
            PriceBook2Id = Test.getStandardPricebookId()
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

		orderItems.Add(new OrderItem(
            SKU_Description__c = 'SKU Desc 2',
            SKU_Number__c = '123-457',
            Quantity = 1,
            UnitPrice = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            LOB_Description__c = 'Software PBU',
            Tie_Number__c = '1',
        	OrderId = order.Id,
        	PriceBookEntryId = priceBookEntry.Id));

        insert(orderItems);

        Test.startTest();

        List<String> projects = ProjectCreator.createProjectByOrderId(new List<string> { order.Id });

        Test.stopTest();

        System.assertNotEquals(0, projects.size());
    }
    
    @isTest
    static void createProjectByOrderIdWithCreateOrder_Should_Return_NewProject() {
        Account account = new Account(Name = 'Test account');
        
        insert(account);
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            OrderNumber__c = '555666',
            PriceBook2Id = Test.getStandardPricebookId()
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

		orderItems.Add(new OrderItem(
            SKU_Description__c = 'SKU Desc 2',
            SKU_Number__c = '123-457',
            Quantity = 1,
            UnitPrice = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            LOB_Description__c = 'Software PBU',
            Tie_Number__c = '1',
        	OrderId = order.Id,
        	PriceBookEntryId = priceBookEntry.Id));

        insert(orderItems);

        Test.startTest();

        String project = ProjectCreator.createProjectByOrderIdWithCreateOrder(new List<string> { order.Id });

        Test.stopTest();

        System.assertEquals('Project has been created.', project);
    }
}
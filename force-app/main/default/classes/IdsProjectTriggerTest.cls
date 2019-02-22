@isTest
private class IdsProjectTriggerTest {
    static void setupSite() {
        Site__c newSite = new Site__C (
                Address_1__c = 'Av Ipiranga, 6681',
                Address_2__c = 'Predio 99',
                City__c = 'Porto Alegre',
                Country__c = 'Brazil',
                Name = 'Porto Alegre Site',
                Postal_Code__c = '90670000',
                State__c = 'Rio Grande do Sul',
                Status__c = 'Active'
        );

        insert(newSite);
    }

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

    static void setupTemplateProject() {
        pse__Proj__c templateProject = new pse__Proj__c(
                Name = 'Phased Project Template - Custom - Global',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today()
        );

        insert(templateProject);

        List<pse__Project_Task__c> templateTasks = new List<pse__Project_Task__c>();

        pse__Project_Task__c t1 = new pse__Project_Task__c(
                Name = 'Initiate',
                pse__Project__c = templateProject.Id
        );

        templateTasks.add(t1);

        pse__Project_Task__c t2 = new pse__Project_Task__c(
                Name = 'Plan',
                pse__Project__c = templateProject.Id
        );

        templateTasks.add(t2);

        pse__Project_Task__c t3 = new pse__Project_Task__c(
                Name = 'Execute',
                pse__Project__c = templateProject.Id
        );

        templateTasks.add(t3);

        pse__Project_Task__c t4 = new pse__Project_Task__c(
                Name = 'Close',
                pse__Project__c = templateProject.Id
        );

        templateTasks.add(t4);

        pse__Project_Task__c t5 = new pse__Project_Task__c(
                Name = 'PM Activities',
                pse__Project__c = templateProject.Id
        );

        templateTasks.add(t5);

        insert(templateTasks);
    }

    static void setupSkuEffortMapping() {
        SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
                SKU_Number__c = '777-1000'
        );

        insert(skuEffortMap);

        List<SKU_Effort_Map_Entry__c> entries = new List<SKU_Effort_Map_Entry__c>();

        pse__Proj__c templateProject = [SELECT Id From pse__Proj__c WHERE Name = 'Phased Project Template - Custom - Global'];

        pse__Project_Task__c t1 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Initiate'];
        pse__Project_Task__c t2 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Plan'];
        pse__Project_Task__c t3 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Execute'];
        pse__Project_Task__c t4 = [SELECT Id FROM pse__Project_Task__c WHERE Name = 'Close'];

        SKU_Effort_Map_Entry__c entry1 = new SKU_Effort_Map_Entry__c(
                Phase__c = t1.Id,
                Project_Complexity_Tier__c = 'Low',
                SKU_Effort_Map__c = skuEffortMap.Id,
                Estimated_Hours__c = 1,
                project__c = templateProject.Id,
                Name__c = 'Configuration'
        );

        entries.add(entry1);

        SKU_Effort_Map_Entry__c entry2 = new SKU_Effort_Map_Entry__c(
                Phase__c = t2.Id,
                Project_Complexity_Tier__c = 'Low',
                SKU_Effort_Map__c = skuEffortMap.Id,
                Estimated_Hours__c = 2,
                project__c = templateProject.Id,
                Name__c = 'Planning'
        );

        entries.add(entry2);

        SKU_Effort_Map_Entry__c entry3 = new SKU_Effort_Map_Entry__c(
                Phase__c = t3.Id,
                Project_Complexity_Tier__c = 'Low',
                SKU_Effort_Map__c = skuEffortMap.Id,
                Estimated_Hours__c = 3,
                project__c = templateProject.Id,
                Name__c = 'Physical Installation'
        );

        entries.add(entry3);

        SKU_Effort_Map_Entry__c entry4 = new SKU_Effort_Map_Entry__c(
                Phase__c = t4.Id,
                Project_Complexity_Tier__c = 'Low',
                SKU_Effort_Map__c = skuEffortMap.Id,
                Estimated_Hours__c = 5,
                project__c = templateProject.Id,
                Name__c = 'Config Assist'
        );

        entries.add(entry4);

        insert(entries);

        Id skillRecordType = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Skill').getRecordTypeId();

        List<pse__Skill__c> skills = new List<pse__Skill__c>();

        pse__Skill__c skill1 = new pse__Skill__c(
                Name = 'C#',
                RecordTypeId = skillRecordType
        );

        skills.add(skill1);

        pse__Skill__c skill2 = new pse__Skill__c(
                Name = 'Apex',
                RecordTypeId = skillRecordType
        );

        skills.add(skill2);

        pse__Skill__c skill3 = new pse__Skill__c(
                Name = 'C++',
                RecordTypeId = skillRecordType
        );

        skills.add(skill3);

        insert(skills);

        List<Skill_SKU_Effort_Map_Entry__c> skillSkuEffortMapEntries = new List<Skill_SKU_Effort_Map_Entry__c>();

        Skill_SKU_Effort_Map_Entry__c skillSkuMapEntry1 = new Skill_SKU_Effort_Map_Entry__c(
                Skill_Certification__c = skill1.Id,
                SKU_Effort_Map_Entry__c = entry1.Id
        );

        Skill_SKU_Effort_Map_Entry__c skillSkuMapEntry2 = new Skill_SKU_Effort_Map_Entry__c(
                Skill_Certification__c = skill2.Id,
                SKU_Effort_Map_Entry__c = entry2.Id
        );

        Skill_SKU_Effort_Map_Entry__c skillSkuMapEntry3 = new Skill_SKU_Effort_Map_Entry__c(
                Skill_Certification__c = skill3.Id,
                SKU_Effort_Map_Entry__c = entry3.Id
        );

        Skill_SKU_Effort_Map_Entry__c skillSkuMapEntry4 = new Skill_SKU_Effort_Map_Entry__c(
                Skill_Certification__c = skill3.Id,
                SKU_Effort_Map_Entry__c = entry4.Id
        );

        insert(skillSkuEffortMapEntries);

        List<WO_SKU_Effort_Map__c> woSkuEffortMappings = new List<WO_SKU_Effort_Map__c>();

        WO_SKU_Effort_Map__c woSkuEffortMap1 = new WO_SKU_Effort_Map__c(
                Calculation_Type__c = 'By Threshold',
                Delivery_Method__c = 'Remote',
                Description__c = 'Customer Kickoff',
                Duration__c = 0,
                High_Threshold_Duration__c = 100,
                Low_Threshold_Duration__c = 50,
                SKU_Effort_Mapping_Entry__c = entry1.Id,
                Threshold_Value__c = 1,
                Wo_Record_Type__c = 'Installation Badge'
        );

        woSkuEffortMappings.add(woSkuEffortMap1);

        WO_SKU_Effort_Map__c woSkuEffortMap2 = new WO_SKU_Effort_Map__c (
                Calculation_Type__c = 'By SKU Quantity',
                Delivery_Method__c = 'Remote',
                Description__c = 'Planing & Design',
                Duration__c = 200,
                SKU_Effort_Mapping_Entry__c = entry2.Id,
            	Wo_Record_Type__c = 'FF - Unknown'
        );

        woSkuEffortMappings.add(woSkuEffortMap2);

        WO_SKU_Effort_Map__c woSkuEffortMap3 = new WO_SKU_Effort_Map__c(
                Calculation_Type__c = 'By SKU Quantity',
                Delivery_Method__c = 'OnSite',
                Description__c = 'Prepare Installation',
                Duration__c = 250,
                SKU_Effort_Mapping_Entry__c = entry3.Id,
            	Wo_Record_Type__c = 'FF - Unknown'
        );

        woSkuEffortMappings.add(woSkuEffortMap3);

        WO_SKU_Effort_Map__c woSkuEffortMap4 = new WO_SKU_Effort_Map__c(
                Calculation_Type__c = 'By SKU Quantity',
                Delivery_Method__c = 'Remote',
                Description__c = 'Prepare Documents',
                Duration__c = 671,
                SKU_Effort_Mapping_Entry__c = entry4.Id,
            	Wo_Record_Type__c = 'FF - Unknown'
        );

        woSkuEffortMappings.add(woSkuEffortMap4);
        
        WO_SKU_Effort_Map__c woSkuEffortMap5 = new WO_SKU_Effort_Map__c(
                Calculation_Type__c = 'By SKU Quantity',
                Delivery_Method__c = 'OnSite',
                Description__c = 'Prepare Installation',
                Duration__c = 88,
                SKU_Effort_Mapping_Entry__c = entry3.Id,
            	Wo_Record_Type__c = 'FF - Unknown'
        );

        woSkuEffortMappings.add(woSkuEffortMap5);

        insert(woSkuEffortMappings);
    }

    static void setupUser() {
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

        insert(user);
    }

    static void setupContact() {
        pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c(
                Name = 'Test Work Calendar'
        );

        insert (workCalendar);

        Account account = new Account(Name = 'Test account');

        insert(account);

        pse__Region__c region = [SELECT Id FROM pse__Region__c];

        User user = [SELECT Id FROM User WHERE UserName = 'pm_test_user@dell.com'];

        Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'pm_test_user@dell.com',
                AccountId = account.Id,
                pse__Salesforce_User__c = user.Id,
                pse__Region__c = region.Id,
                pse__Work_Calendar__c = workCalendar.Id,
                pse__Is_Resource_Active__c = true,
                pse__Is_Resource__c = true
        );

        insert(contact);
    }

    static void setupProject() {
        pse__Region__c r1 = [SELECT Id FROM pse__Region__c];
        Contact contact = [SELECT ID FROM Contact];

        pse__Proj__c testProj1 = new pse__Proj__c(
                Name = 'Test Proj 1',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = r1.Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Project_Manager__c = contact.Id
        );

        insert(testProj1);

        Site__c site = [SELECT Id FROM Site__c];

        Project_Site__c projectSite = new Project_Site__c(
                Address_Type__c = 'Shipping',
                Site__c = site.Id,
                Project__c = testProj1.Id
        );

        insert(projectSite);

        pse__Budget__c budget = new pse__Budget__c (
                pse__Amount__c = 100,
                pse__Project__c = testProj1.Id
        );

        insert(budget);

        List<pse__Project_Task__c> testProj1Tasks = new List<pse__Project_Task__c>();

        pse__Project_Task__c t1 = new pse__Project_Task__c(
                Name = 'Configuration',
                pse__Estimated_Hours__c = 22,
                pse__Project__c = testProj1.Id,
                Project_Site__c = projectSite.Id
        );

        testProj1Tasks.add(t1);

        pse__Project_Task__c t2 = new pse__Project_Task__c(
                Name = 'Planning',
                pse__Estimated_Hours__c = 33,
                pse__Project__c = testProj1.Id
        );

        testProj1Tasks.add(t2);

        pse__Project_Task__c t3 = new pse__Project_Task__c(
                Name = 'Physical Installation',
                pse__Estimated_Hours__c = 44,
                pse__Project__c = testProj1.Id
        );

        testProj1Tasks.add(t3);

        pse__Project_Task__c t4 = new pse__Project_Task__c(
                Name = 'Config Assist',
                pse__Estimated_Hours__c = 55,
                pse__Project__c = testProj1.Id
        );

        testProj1Tasks.add(t4);

        insert (testProj1Tasks);

        pse__Skill__c csharpSkill = [SELECT Id FROM pse__Skill__c WHERE Name = 'C#'];

        List<Project_Task_Skill__c> projectTasksSkills = new List<Project_Task_Skill__c>();

        Project_Task_Skill__c pts1 = new Project_Task_Skill__c(
                Project_Task__c = t1.Id,
                Skill_Certification__c = csharpSkill.Id
        );

        projectTasksSkills.add(pts1);

        Project_Task_Skill__c pts2 = new Project_Task_Skill__c(
                Project_Task__c = t2.Id,
                Skill_Certification__c = csharpSkill.Id
        );

        projectTasksSkills.add(pts2);

        Project_Task_Skill__c pts3 = new Project_Task_Skill__c(
                Project_Task__c = t3.Id,
                Skill_Certification__c = csharpSkill.Id
        );

        projectTasksSkills.add(pts3);

        Project_Task_Skill__c pts4 = new Project_Task_Skill__c(
                Project_Task__c = t4.Id,
                Skill_Certification__c = csharpSkill.Id
        );

        projectTasksSkills.add(pts4);

        insert(projectTasksSkills);

        /*List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();

        pse__Milestone__c milestone1 = new pse__Milestone__c(
                Name = 'Forecast Completion Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, Current__c = true
        );

        milestones.add(milestone1);

        pse__Milestone__c milestone2 = new pse__Milestone__c(
                Name = 'Next Follow Up Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, Current__c = false
        );

        milestones.add(milestone2);

        insert(milestones);*/
    }

    static void setupOrder() {
        Account account = [SELECT Id FROM Account];
        pse__proj__c proj = [SELECT Id FROM pse__proj__c WHERE Name = 'Test Proj 1'];

        Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                PriceBook2Id = Test.getStandardPricebookId(),
                Project__c = proj.Id
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
                SKU_Number__c = '777-1000',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = order.Id,
                PriceBookEntryId = priceBookEntry.Id));

        insert(orderItems);
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

    static void setupWorkType() {
        WorkType workType = new WorkType(Name = 'FSE Task', DurationType = 'Hours', EstimatedDuration = 0, ShouldAutoCreateSvcAppt = true);
        insert workType;
    }
    @testSetup
    static void setupData() {
        setupSite();
        setupProjectComplexities();
        setupProjectComplexityMappings();
        setupRegions();
        setupTemplateProject();
        setupSkuEffortMapping();
        setupUser();
        setupContact();
        setupProject();
        setupOrder();
        setupSkill();
        setupWorkType();
    }

    @isTest
    static void IdsProjectTrigger_Should_Create_WorkOrders() {
        String[] taskNames = new String[]{
                'Configuration', 'Planning', 'Physical Installation'
        };
        String[] phaseNames = new String[]{
                'Initiate', 'Plan', 'Execute', 'Close'
        };
        SKU_Effort_Map_Entry__c skuEffortMapEntry = new SKU_Effort_Map_Entry__c();
        pse__Project_Task__c configurationTask = new pse__Project_Task__c();


        for (String name : taskNames) {
            skuEffortMapEntry = [SELECT Id FROM SKU_Effort_Map_Entry__c WHERE Name__c = :name];
            configurationTask = [SELECT Id, pse__Project__c, pse__Project__r.Id FROM pse__Project_Task__c WHERE Name = :name];

            Project_Task_SKU_Effort_Mapping_Entry__c entry = new Project_Task_SKU_Effort_Mapping_Entry__c(
                    SKU_Effort_Mapping_Entry__c = skuEffortMapEntry.Id,
                    Project_Task__c = configurationTask.Id,
                    SKU_Quantity__c = 2,
                    Processed__c = false

            );

            insert(entry);
        }
        WO_SKU_Effort_Map__c skuEffortMaps = [SELECT Id, SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c FROM WO_SKU_Effort_Map__c WHERE SKU_Effort_Mapping_Entry__c = :skuEffortMapEntry.Id LIMIT 1];
        Order order = [SELECT Id FROM Order WHERE Project__c = :configurationTask.pse__Project__c LIMIT 1];
        OrderItem orderItem = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id LIMIT 1];

        Order_Item_Sku_Effort_Map__c orderItemSKU = new Order_Item_Sku_Effort_Map__c();
        orderItemSKU.Order_Product__c = orderItem.Id;
        orderItemSKU.SKU_to_Effort_Mapping__c = skuEffortMaps.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c;
        orderItemSKU.Project_Task__c = configurationTask.Id;
        insert orderItemSKU;
        Test.startTest();

        for (String name : phaseNames) {
            pse__Proj__c testProj1 = [SELECT Name, pse__Project_Phase__c FROM pse__Proj__c WHERE Name = 'Test Proj 1'];

            testProj1.pse__Project_Phase__c = name;

            update(testProj1);
        }

        Test.stopTest();

        List<Project_Task_SKU_Effort_Mapping_Entry__c> entries = [SELECT Processed__c FROM Project_Task_SKU_Effort_Mapping_Entry__c];

        for (Project_Task_SKU_Effort_Mapping_Entry__c entry : entries) {
            System.assertEquals(true, entry.Processed__c);
        }

        List<WorkOrder> workOrders = [SELECT Subject FROM WorkOrder];

        System.assert(workOrders != null);
        System.assertEquals(3, workOrders.size());

        List<Work_Order_Skill__c> workOrderSkills = [SELECT Skill_Certification__c, Work_Order__c FROM Work_Order_Skill__c];

        System.assert(workOrderSkills != null);
        System.assertEquals(3, workOrderSkills.size());
    }

    @isTest
    static void IdsProjectTrigger_Should_Approve_Milestones() {
        Test.startTest();

        pse__Proj__c testProj1 = [SELECT Name, pse__Project_Phase__c, Closure_Reason__c FROM pse__Proj__c WHERE Name = 'Test Proj 1'];

        testProj1.pse__Project_Phase__c = 'Close';
        testProj1.Closure_Reason__c = 'Services Delivered';

        update(testProj1);

        Test.stopTest();

        List<pse__Milestone__c> milestones = [SELECT Id, Name FROM pse__Milestone__c WHERE pse__Project__c = :testProj1.Id AND pse__Status__c = 'Approved'];

        System.assert(milestones != null);
        System.debug('milestones: ' + milestones);
        System.assertEquals(1, milestones.size());
    }

    @isTest
    static void IdsProjectTrigger_Should_Cancel_Milestones() {
        Test.startTest();

        pse__Proj__c testProj1 = [SELECT Name, pse__Project_Phase__c, Closure_Reason__c FROM pse__Proj__c WHERE Name = 'Test Proj 1'];

        testProj1.pse__Project_Phase__c = 'Close';
        testProj1.Closure_Reason__c = 'Services Not Delivered';

        update(testProj1);

        Test.stopTest();

        List<pse__Milestone__c> milestones = [SELECT Id FROM pse__Milestone__c WHERE pse__Project__c = :testProj1.Id AND pse__Status__c = 'Canceled'];

        System.assert(milestones != null);
        System.assertEquals(1, milestones.size());
    }


    @isTest
    static void IdsProjectTrigger_Should_Update_Proj_To_OnHold() {
        SKU_Effort_Map__c skuEffortMap = [SELECT Id, SKU_Number__c FROM SKU_Effort_Map__c WHERE SKU_Number__c = '777-1000'];

        skuEffortMap.X30_Day_Support__c = true;

        update (skuEffortMap);

        Test.startTest();

        pse__Proj__c testProj1 = [SELECT Name, pse__Project_Phase__c, Closure_Reason__c FROM pse__Proj__c WHERE Name = 'Test Proj 1'];

        testProj1.pse__Project_Phase__c = 'Close';
        testProj1.Closure_Reason__c = 'Services Delivered';

        update(testProj1);

        Test.stopTest();

        List<pse__Milestone__c> milestones = [SELECT Id, Name, pse__Status__c, pse__Target_Date__c FROM pse__Milestone__c WHERE pse__Project__c = :testProj1.Id];
        pse__Proj__c updatedTestProj1 = [SELECT Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c, On_Hold_Reason__c, On_Hold_Date__c FROM pse__Proj__c WHERE Name = 'Test Proj 1'];
        Order order = [SELECT Id, Milestone__c FROM Order WHERE project__c = :testProj1.Id];

        System.assert(milestones != null);
        System.assertEquals(2, milestones.size());
        System.assertEquals(testProj1.pse__Project_Phase__c, updatedTestProj1.pse__Project_Phase__c);
        System.assertEquals('On Hold', updatedTestProj1.pse__Stage__c);
        System.assertEquals('30 Day Support', updatedTestProj1.On_Hold_Reason__c);
        System.assertEquals(Date.today().addDays(30), updatedTestProj1.On_Hold_Date__c);
    }

	@IsTest
    static void testChangeProjectToCancelled() { 
        pse__Proj__c proj = new pse__Proj__c(Name='Test 1', pse__Is_Active__c = true);
        insert proj;
        
        pse__Milestone__c milestone = new pse__Milestone__c(Name='Milestone 1', Current__c = true, pse__Project__c = proj.id, pse__Target_Date__c = system.today());
        insert milestone;
        
        proj.pse__Stage__c = 'Cancelled';
        update proj;
        
        List<pse__Milestone__c> milestonesProject = [SELECT Id, Name, pse__Status__c FROM pse__Milestone__c
                                                     WHERE pse__Project__c =: proj.Id
                                                    ];
        
        System.assertEquals('Canceled', milestonesProject[0].pse__Status__c);
    }
}
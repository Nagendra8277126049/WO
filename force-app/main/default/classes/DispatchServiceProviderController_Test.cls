/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchServiceProviderController_Test
Description:  This class contain the test method for DispatchServiceProviderController for Test coverage - STORY 5587160
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ---------------------------------------------------------------------------------
09/16/2018     1.0    Harsha Reddy         Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private with sharing class DispatchServiceProviderController_Test {

    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static User u;
    private static Contact co;
    private static WorkOrder wo;
    private static Product2 prd;
    private static DispatchServiceEvent__c dSE3;
    
    private static void setupTestData() {
        
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        /*u = new User(Alias = 'auser', Email='adminuser@dell.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',FederationIdentifier='1234526',
        		    LocaleSidKey='en_US',ProfileId=[SELECT Id FROM Profile WHERE Name='System Administrator'].Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName, OSP__c='Yes');
        insert u;*/
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        //create a test account
    	acnt = new Account(Name='Test Company',Industry='Fashion',Type='Customer',AccountNumber='1234567890',BUID__c='99');
        insert acnt;
        
        //create a new product
        prd = new Product2(	ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
        insert prd;
        
        //create a test asset
        ast = new Asset(Name='Test Asset',Status='Installed',AccountId=acnt.Id,Product2Id=prd.Id,InstallDate=System.Today(),UsageEndDate=System.Today());
        insert ast;
        
        //create a test contact
        co = new Contact(Email = 'testtag@test.com',firstname = 'firstname',LastName = 'testtag',Accountid = acnt.id, Country_Code__c = 'USA & Canada (1)', Primary_Phone__c = '1234567890');
        insert co;
            
        //create a test case
        cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id,ContactId=co.Id);
        insert cse;
        
        string lineAddress = '';
        
        lineAddress = lineAddress + 'line 1\n\r';
        lineAddress = lineAddress + 'line 2\n\r';
        lineAddress = lineAddress + 'line 3\n\r';
        lineAddress = lineAddress + 'line 4';
        
        //ceate a test work Order
        wo = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,Street=lineAddress,AdditionalContactId__c=co.id,StateCode='TX',
                            city='Austin',State='Texas',Country='United States',Region__c='1',PostalCode='786664',CountryCode='US',subject='testing Work Order',
                            Schedule_Enable_Flag__c='Y',EntitlementStartDate__c='2018-04-05T07:05:24',EntitlementEndDate__c='2018-04-05T17:05:24',
                            Service_Option__c='Available-24x5',StartDate=system.now().addDays(1),EndDate=system.now().addDays(1).addHours(1),DSP__c='QLX',
                            Scheduling_URL__c='https://test.wwts.com/CFSPartnerSlotsService/cCFSPartnerSlotsService.asmx',SLAStartDate__c='2018-05-02T00:00:00',
                            SLAEndDate__c='2018-05-02T23:59:00',IsScheduled__c=true,Deferred__c='N',ScheduleStartDate__c='2018-05-09T14:00:00Z',
                            ScheduleEndDate__c='2018-05-09T23:00:00Z',timeZone__c='America');
        insert wo;
        
        //ceate a test Service Event
        dSE3 = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XR',Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100001',Reply_Code_Description__c='Sucess',Service_Event__c='RESCHEDULE_SERVICE',
                                Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),Work_Order__c=wo.Id);
        insert dSE3;
		
        
        List<Exception_Hours__c> expHList = new List<Exception_Hours__c>();
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-8), Name='USA Holidays', Start_Date__c=DateTime.now().addDays(-8)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-11), Name='USA Holidays', Start_Date__c=DateTime.now().addDays(-11)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-13), Name='USA Holidays', Start_Date__c=DateTime.now().addDays(-13)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-18), Name='USA Holidays', Start_Date__c=DateTime.now().addDays(-18)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-20), Name='USA Holidays', Start_Date__c=DateTime.now().addDays(-20)));
        
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-1), Name='Canada Holidays', Start_Date__c=DateTime.now().addDays(-1)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-2), Name='Canada Holidays', Start_Date__c=DateTime.now().addDays(-2)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-3), Name='Canada Holidays', Start_Date__c=DateTime.now().addDays(-3)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-4), Name='Canada Holidays', Start_Date__c=DateTime.now().addDays(-4)));
        expHList.add(new Exception_Hours__c(End_Date__c=DateTime.now().addDays(-5), Name='Canada Holidays', Start_Date__c=DateTime.now().addDays(-5)));
        
        insert expHList;
        
    }
    
    

    @isTest
    private static void rescheduledSlot_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            RescheduleSlots__x mockedReshuleSlots= new RescheduleSlots__x(ISPConfirmationNumber__c='1234567890', ResponseCode__c='100',
                                                                          ResponseMessage__c='Sucess',ReplyCode__c = '100000');
    		DispatchServiceProviderController.mockedReshuleSlots.add(mockedReshuleSlots);
            string response = 
                DispatchServiceProviderController.saveRescheduledSlot(wo.Id,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assert(response.equalsIgnoreCase('SUCCESS'));
        }
    }
    
    @isTest
    private static void rescheduledSlot_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            RescheduleSlots__x mockedReshuleSlots= new RescheduleSlots__x(ISPConfirmationNumber__c='1234567890', ResponseCode__c='101',
                                                                          ResponseMessage__c='Failed',ReplyCode__c = '100000');
    		DispatchServiceProviderController.mockedReshuleSlots.add(mockedReshuleSlots);
            string response = 
                DispatchServiceProviderController.saveRescheduledSlot(wo.Id,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assert(string.isNotBlank(response));
        }
    }
    
    @isTest
    private static void rescheduledSlot8_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            RescheduleSlots__x mockedReshuleSlots= new RescheduleSlots__x(ISPConfirmationNumber__c='1234567890', ResponseCode__c='100',
                                                                          ResponseMessage__c='Failed',ReplyCode__c = '100001');
    		DispatchServiceProviderController.mockedReshuleSlots.add(mockedReshuleSlots);
            string response = 
                DispatchServiceProviderController.saveRescheduledSlot(wo.Id,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assert(string.isNotBlank(response));
        }
    }
    
    @isTest
    private static void rescheduledSlot1_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            string response = 
                DispatchServiceProviderController.saveRescheduledSlot(wo.Id,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void rescheduledSlotFail_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            string response = 
                DispatchServiceProviderController.saveRescheduledSlot(u.Id,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void getReScheduleSlots_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00Z',ISPEndTime__c='2018-04-14T01:59:00Z',ResponseCode__c='100',ResponseMessage__c='Success',ReplyCode__c='100000'));
            DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T03:00:00Z',ISPEndTime__c='2018-04-14T05:59:00Z',ResponseCode__c='100',ResponseMessage__c='Success',ReplyCode__c='100000'));
			DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T09:00:00Z',ISPEndTime__c='2018-04-14T23:59:00Z',ResponseCode__c='100',ResponseMessage__c='Success',ReplyCode__c='100000'));
			DispatchServiceProviderController.responseWrapper response = DispatchServiceProviderController.getReScheduleSlots(wo.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
	
	@isTest
    private static void getReScheduleSlots_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00Z',ISPEndTime__c='2018-04-14T01:59:00Z',ResponseCode__c='100',ResponseMessage__c='Success',ReplyCode__c='100000'));
            DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T03:00:00Z',ISPEndTime__c='2018-04-14T05:59:00Z',ResponseCode__c='100',ResponseMessage__c='Success',ReplyCode__c='100000'));
			DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T09:00:00Z',ISPEndTime__c='2018-04-14T23:59:00Z',ResponseCode__c='100',ResponseMessage__c='Success',ReplyCode__c='100000'));
			DispatchServiceProviderController.responseWrapper response = DispatchServiceProviderController.getReScheduleSlots(u.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
	
	@isTest
    private static void getReScheduleSlots_Test2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchServiceProviderController.responseWrapper response = DispatchServiceProviderController.getReScheduleSlots(wo.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
   	
    @isTest
    private static void getReScheduleSlots_Test3(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00Z',ISPEndTime__c='2018-04-14T01:59:00Z',ResponseCode__c='101',ResponseMessage__c='Failed',ReplyCode__c='100000'));
			DispatchServiceProviderController.responseWrapper response = DispatchServiceProviderController.getReScheduleSlots(wo.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void getReScheduleSlots_Test4(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14',ISPEndTime__c='2018-04-14',ResponseCode__c='100',ResponseMessage__c='SUCCESS',ReplyCode__c='100000'));
			DispatchServiceProviderController.responseWrapper response = DispatchServiceProviderController.getReScheduleSlots(wo.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void getReScheduleSlots_Test5(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DispatchServiceProviderController.mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00Z',ISPEndTime__c='2018-04-14T01:59:00Z',ResponseCode__c='101',ResponseMessage__c='Failed',ReplyCode__c='100001'));
			DispatchServiceProviderController.responseWrapper response = DispatchServiceProviderController.getReScheduleSlots(wo.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void createServiceEvent_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            //create a test Service Event
            DispatchServiceEvent__c dSE = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XR',
                                                                      Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                                                      Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100001',
                                                                      Reply_Code_Description__c='Sucess',Service_Event__c='GET_AVAILABLE_SLOT',
                                    								  Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),
                                                                      Work_Order__c=wo.Id);
            insert dSE;
			DispatchServiceProviderController.createServiceEvent('QLX','100001',wo.Id,'replyMessage');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void createServiceEvent_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
			DispatchServiceProviderController.createServiceEvent(null,null,null,null);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void createServEventFail_Test(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            List<RescheduleSlots__x> mockedReshuleSlots = new List<RescheduleSlots__x>();
                mockedReshuleSlots.add(new RescheduleSlots__x(ISPConfirmationNumber__c='1234567890', ResponseCode__c='100',
                                                                          ResponseMessage__c='Failed',ReplyCode__c = '100001'));
			DispatchServiceProviderController.createServEvent(mockedReshuleSlots,null,'','');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void checkIsFiveBusinessDays_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DateTime curDT = DateTime.now();
			boolean response = DispatchServiceProviderController.checkIsFiveBusinessDays(curDT,'United States');
            Test.stopTest();
            System.assert(response);
        }
    }
    @isTest
    private static void checkIsFiveBusinessDays_Test2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DateTime curDT = DateTime.now();
			boolean response = DispatchServiceProviderController.checkIsFiveBusinessDays(curDT,'');
            Test.stopTest();
            System.assert(!response);
        }
    }
    @isTest
    private static void checkIsFiveBusinessDays_Test3(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
            DateTime curDT = DateTime.now().addDays(-50);
			boolean response = DispatchServiceProviderController.checkIsFiveBusinessDays(curDT,'United States');
            Test.stopTest();
            System.assert(!response);
        }
    }
    @isTest
    private static void checkIsFiveBusinessDays_Test4(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DateTime curDT = DateTime.now().addDays(-7);
                boolean response = DispatchServiceProviderController.checkIsFiveBusinessDays(curDT,'Canada');
            Test.stopTest();
            System.assert(response);
        }
    }
    
    @isTest
    Private Static void checkBussinessHourLogic_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                DateTime curDT = DateTime.now();
                boolean response = DispatchGccConfiguration.checkBussinessHourLogic(curDT,'United States');
            Test.stopTest();
        }
    }
    
    @isTest
    Private Static void processTime_Test1(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                string response = DispatchServiceProviderController.processTime('2018-04-14T00:00:00Z','America/Chicago');
            Test.stopTest();
            system.assert(string.isNotBlank(response));
        }
    }
    
    @isTest
    Private Static void processTime_Test2(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                string response = DispatchServiceProviderController.processTime('2018-04-14T00:00:00Z','');
            Test.stopTest();
            system.assert(string.isNotBlank(response));
        }
    }
    @isTest
    Private Static void processTime_Test3(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                string response = DispatchServiceProviderController.processTime('2018-04-14T00:00:00+05:00','America/Chicago');
            Test.stopTest();
            system.assert(string.isNotBlank(response));
        }
    }
   
    @isTest
    Private Static void processTime_Test4(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                string response = DispatchServiceProviderController.processTime('2018-04-14T00:00:00-05:00','America/Chicago');
            Test.stopTest();
            system.assert(string.isNotBlank(response));
        }
    }
    
    @isTest
    Private Static void processTime_Test5(){
        setupTestData();
        system.runAs(u){
            Test.startTest();
                string response = DispatchServiceProviderController.processTime('2018','America/Chicago');
            Test.stopTest();
            system.assert(string.isBlank(response));
        }
    }
}
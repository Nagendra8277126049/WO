/* -----------------------------------------------------------------------------------------------------------------------
Name:       SlotsController_Test
Description:  This class contain the test method for SlotsController to validate coverage - story #4916977
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/13/2018     1.0    Rodrigo Carpio       Initial Release
04/13/2018     1.0    Harsha Reddy         Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class SlotsController_Test {
    
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static User u;
    private static User u1;
    private static Contact co;
    private static WorkOrder wo;
    private static WorkOrder wo1;
    private static WorkOrder wo2;
    private static Product2 prd;
    private static DispatchServiceEvent__c dSE;
    private static DispatchServiceEvent__c dSE1;
    private static DispatchServiceEvent__c dSE2;
    private static DispatchServiceEvent__c dSE3;
    private static DispatchServiceEvent__c dSE4;
    private static DispatchServiceEvent__c dSE5;
    private static DispatchDefaults__c dd;
    
    private static void setupTestData() {
        // Create a unique UserName
        u=SRVS_CreateTestDataFactory.createUser('System Administrator');
        u1 = SRVS_CreateTestDataFactory.createUser('Service Agent');
        
        //create a test account
        acnt = new Account(Name='Test Company',Industry='Fashion',Type='Customer',AccountNumber='1234567890',BUID__c='99');
        insert acnt;
        
        //create a new product
        prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
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
                            ScheduleEndDate__c='2018-05-09T23:00:00Z');
        insert wo;
        //ceate a test work Order 2
        wo1 = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,Street=lineAddress,AdditionalContactId__c=co.id,StateCode='TX',
                            city='Austin',State='Texas',Country='United States',Region__c='1',PostalCode='786664',CountryCode='US',subject='testing Work Order',
                            Schedule_Enable_Flag__c='Y',EntitlementStartDate__c='2018-04-05T07:05:24',EntitlementEndDate__c='2018-04-05T17:05:24',
                            Service_Option__c=null,StartDate=system.now().addDays(1),EndDate=system.now().addDays(1).addHours(1),DSP__c='QLX',
                            Scheduling_URL__c='https://test.wwts.com/CFSPartnerSlotsService/cCFSPartnerSlotsService.asmx',SLAStartDate__c='2018-05-02T00:00:00',
                            SLAEndDate__c='2018-05-02T23:59:00',IsScheduled__c=true,Deferred__c='N',ScheduleStartDate__c='2018-05-09T14:00:00Z',
                            ScheduleEndDate__c='2018-05-09T23:00:00Z');
        insert wo1;
        
        //ceate a test work Order 2
        wo2 = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,Street=lineAddress,AdditionalContactId__c=co.id,StateCode='TX',
                            city='Austin',State='Texas',Country='United States',Region__c='1',PostalCode='786664',CountryCode='US',subject='testing Work Order',
                            Schedule_Enable_Flag__c='Y',EntitlementStartDate__c='2018-04-05T07:05:24',EntitlementEndDate__c='2018-04-05T17:05:24',
                            Service_Option__c=null,StartDate=system.now().addDays(1),EndDate=system.now().addDays(1).addHours(1),DSP__c='QLX',
                            Scheduling_URL__c='https://test.wwts.com/CFSPartnerSlotsService/cCFSPartnerSlotsService.asmx',SLAStartDate__c='2018-05-02T00:00:00',
                            SLAEndDate__c='2018-05-02T23:59:00',IsScheduled__c=true,Deferred__c='N',ScheduleStartDate__c='2018-05-09T14:00:00Z',
                            ScheduleEndDate__c='2018-05-09T23:00:00Z',Timezone__c='America/Chicago');
        insert wo2;
        
        system.runAs(u1){
            //ceate a test Service Event
            dSE = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XW',Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                    Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100000',Reply_Code_Description__c='Sucess',Service_Event__c='CANCEL_SCHEDULE',
                                    Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),Work_Order__c=wo.Id);
            insert dSE;
            
            //ceate a test Service Event
            dSE1 = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XW',Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                    Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100001',Reply_Code_Description__c='Sucess',Service_Event__c='CANCEL_SCHEDULE',
                                    Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),Work_Order__c=wo.Id);
            insert dSE1;
        
            //ceate a test Service Event
            dSE2 = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XR',Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                    Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100001',Reply_Code_Description__c='Sucess',Service_Event__c='CONFIRM_SCHEDULE',
                                    Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),Work_Order__c=wo.Id);
            insert dSE2;
            
                    //ceate a test Service Event
            dSE3 = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XR',Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                    Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100001',Reply_Code_Description__c='Sucess',Service_Event__c='RESCHEDULE_SERVICE',
                                    Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),Work_Order__c=wo.Id);
            insert dSE3;
            
            //ceate a test Service Event
            dSE4 = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XS',Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                    Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100001',Reply_Code_Description__c='Sucess',Service_Event__c='CONFIRM_SCHEDULE',
                                    Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),Work_Order__c=wo.Id);
            insert dSE4;
            
            //ceate a test Service Event
            dSE5 = new DispatchServiceEvent__c(DSP_Code__c='QLX',DSP_Reference__c='test123445',Event_Code__c='XX',Event_DateTime__c='2018-05-02T00:00:00' +'|'+ '2018-05-02T00:00:00',
                                    Event_Source__c='SFDC',Reject_Reason__c='Reason',Reply_Code__c='100001',Reply_Code_Description__c='Sucess',Service_Event__c='CANCEL_SCHEDULE_ATTRCHNG',
                                    Vendor_Transaction_DateTime__c=string.valueOfGmt(System.now()),Work_Order__c=wo.Id);
            insert dSE5;
        }
        
        //create a test Dispatch Default
        dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',PO_Number__c='18458',selected_service_option__c='Available-24x5',
                                    OutOfWarranty__c=True,Service_Configurations__c='XPS Notebooks',SpecialOptions__c='CBBF',Bill_To__c='Customer',Keep_Your_Components__c=True,
                                    DSP_Override_Request__c=False,Bill_To_Order_Number__c='test Order Number',AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||',
                                    CompleteCareOption__c=True,OrderNumber__c='124563',Work_Order__c=wo.id);
        insert dd;
        
        
    }
    
    @isTest
    private static void nonSubmittedDispatchFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            SlotsController.scheduleWrap sWrap = 
                SlotsController.nonSubmittedDispatch(u.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertEquals(sWrap,null);
        }
    }

    @isTest
    private static void scheduleSlot_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x mockedRequest = new ScheduleSlotByAttributes__x(ConfirmationNumber__c=null, ResponseCode__c='101',ResponseMessage__c='Failed',ReplyCode__c='100000');
            SlotsController.mockedScheduleSlotsByArrtributes.add(mockedRequest);
            ScheduleSlotByAttributes__x SSAttribute=SlotsController.scheduleSlot(wo,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(SSAttribute,null);
        }
    }
    
    @isTest
    private static void scheduleSlot5_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x mockedRequest = new ScheduleSlotByAttributes__x(ConfirmationNumber__c=null, ResponseCode__c='101',ResponseMessage__c='Failed',ReplyCode__c='100000');
            SlotsController.mockedScheduleSlotsByArrtributes.add(mockedRequest);
            ScheduleSlotByAttributes__x SSAttribute=SlotsController.scheduleSlot(wo,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assertNotEquals(SSAttribute,null);
        }
    }
    
    @isTest
    private static void scheduleSlot2_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x SSAttribute=SlotsController.scheduleSlot(wo,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertEquals(SSAttribute,null);
        }
    }
    
    @isTest
    private static void scheduleSlotFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x SSAttribute = 
                SlotsController.scheduleSlot(wo1,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertEquals(SSAttribute,null);
        }
    }
    
    @isTest
    private static void cancelSlot_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            CancelSlot__x mockedCancelSlots = new CancelSlot__x(ISPConfirmationNumber__c='1234567890',ResponseCode__c='100',ResponseMessage__c='Sucess',DispatchID__c=wo.WorkOrderNumber,ReplyCode__c='100000');
            SlotsController.mockedCancelSlots.add(mockedCancelSlots);
            CancelSlot__x cSAttribute = SlotsController.cancelSlot(wo);
            Test.stopTest();
            system.assertNotEquals(cSAttribute,null);
        }
    }
    
    @isTest
    private static void cancelSlot1_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            CancelSlot__x cSAttribute = SlotsController.cancelSlot(wo);
            Test.stopTest();
            system.assertEquals(cSAttribute,null);
        }
    }
    
    @isTest
    private static void cancelSlotFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            CancelSlot__x cSAttribute = SlotsController.cancelSlot(null);
            Test.stopTest();
            system.assertEquals(cSAttribute,null);
        }
    }
    
   /* @isTest
    private static void transformDate_Test1(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            String resTime=SlotsController.transformDate('00:00');
            Test.stopTest();
            system.assertEquals(resTime,'12AM');
        }
    }
    
    @isTest
    private static void transformDate_Test2(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            String resTime=SlotsController.transformDate('12:00');
            Test.stopTest();
            system.assertEquals(resTime,'12PM');
        }
    }
    
    @isTest
    private static void transformDate_Test3(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            String resTime=SlotsController.transformDate('1:00');
            Test.stopTest();
            system.assertEquals(resTime,'1AM');
        }
    }
    
    @isTest
    private static void transformDate_Test4(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            String resTime=SlotsController.transformDate('13:00');
            Test.stopTest();
            system.assertEquals(resTime,'1PM');
        }
    }
    
    @isTest
    private static void transformDateFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            String resTime=SlotsController.transformDate('');
            Test.stopTest();
            system.assertEquals(resTime,null);
        }
    }   */
    
    @isTest
    private static void scheduledSlot_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x mockedScheduledSlots =new ScheduleSlotByAttributes__x(ConfirmationNumber__c='1234567890', 
                                                                                              ResponseCode__c='100',ResponseMessage__c='Sucess',
                                                                                              ReplyCode__c = '100000');
            SlotsController.mockedScheduledSlots.add(mockedScheduledSlots);
            string response = SlotsController.scheduledSlot(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void scheduledSlot8_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x mockedScheduledSlots =new ScheduleSlotByAttributes__x(ConfirmationNumber__c='1234567890', 
                                                                                              ResponseCode__c='100',ResponseMessage__c='Failed',
                                                                                              ReplyCode__c = '100001');
            SlotsController.mockedScheduledSlots.add(mockedScheduledSlots);
            string response = SlotsController.scheduledSlot(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void scheduledSlotFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            string response = SlotsController.scheduledSlot(wo1.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertEquals(response,null);
        }
    }
    
    @isTest
    private static void scheduledSlot_Test1(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            string response = SlotsController.scheduledSlot(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertEquals(response,null);
        }
    }
    
    
    @isTest
    private static void cancelScheduledSlot_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
                CancelSlot__x mockedCancelSlots = new CancelSlot__x(ISPConfirmationNumber__c='1234567890',ResponseCode__c='100',
                                                                    ResponseMessage__c='Sucess',DispatchID__c=wo.WorkOrderNumber,
                                                                    ReplyCode__c='100000');
                SlotsController.mockedCancelSlots.add(mockedCancelSlots);
                SlotsController.cancelScheduledSlot(wo.Id);
            Test.stopTest();
            
        }
    }
    
    @isTest
    private static void cancelScheduledSlot8_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
                CancelSlot__x mockedCancelSlots = new CancelSlot__x(ISPConfirmationNumber__c='1234567890',ResponseCode__c='100',
                                                                    ResponseMessage__c='Failed',DispatchID__c=wo.WorkOrderNumber,
                                                                    ReplyCode__c='100001');
                SlotsController.mockedCancelSlots.add(mockedCancelSlots);
                SlotsController.cancelScheduledSlot(wo.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void cancelScheduledSlotFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
                SlotsController.cancelScheduledSlot(u.Id);
            Test.stopTest();
        }
    }
    
   @isTest
    private static void cancelScheduledSlot1_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
                SlotsController.cancelScheduledSlot(wo.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void rescheduledSlot_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            RescheduleSlots__x mockedReshuleSlots= new RescheduleSlots__x(ISPConfirmationNumber__c='1234567890', ResponseCode__c='100',
                                                                          ResponseMessage__c='Sucess',ReplyCode__c = '100000');
            SlotsController.mockedReshuleSlots.add(mockedReshuleSlots);
            string response = 
                SlotsController.rescheduledSlot(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void rescheduledSlot8_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            RescheduleSlots__x mockedReshuleSlots= new RescheduleSlots__x(ISPConfirmationNumber__c='1234567890', ResponseCode__c='100',
                                                                          ResponseMessage__c='Failed',ReplyCode__c = '100001');
            SlotsController.mockedReshuleSlots.add(mockedReshuleSlots);
            string response = 
                SlotsController.rescheduledSlot(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void rescheduledSlot1_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            string response = 
                SlotsController.rescheduledSlot(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertEquals(response,null);
        }
    }
    
    @isTest
    private static void rescheduledSlotFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            string response = 
                SlotsController.rescheduledSlot(u.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertEquals(response,null);
        }
    }
    
    @isTest
    private static void setDeferralDate_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            string response = 
                SlotsController.setDeferralDate(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24','','');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void setDeferralDate_Test1(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            string response = 
                SlotsController.setDeferralDate(wo.Id,'','','','');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void setDeferralDateFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            string response = 
                SlotsController.setDeferralDate(u.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24','test','test');
            Test.stopTest();
            system.assertEquals(response,null);
        }
    }
    
    @isTest
    private static void getScheduleSlots_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            GetSiebelDeferralDates__x mokedGetSiebelDeferralDates = new GetSiebelDeferralDates__x(SLAStartDate__c='2018-04-14T00:00:00',SLAEndDate__c='2018-04-14T23:59:00', 
                                                StartTime__c='2018-04-14T00:00:00',EndTime__c='2018-04-14T23:59:00',ResponseCode__c='100',ResponseMessage__c='Sucess' );
            SlotsController.mokedGetSiebelDeferralDates.add(mokedGetSiebelDeferralDates);
            mokedGetSiebelDeferralDates = new GetSiebelDeferralDates__x(SLAStartDate__c='2018-04-14T00:00:00',SLAEndDate__c='2018-04-14T23:59:00', 
                                                StartTime__c='2018-04-15T00:00:00',EndTime__c='2018-04-15T23:59:00',ResponseCode__c='100',ResponseMessage__c='Sucess' );
            SlotsController.mokedGetSiebelDeferralDates.add(mokedGetSiebelDeferralDates);
            
             AvailableSlotsByAttributes__x mockedAvailableSlotsByAttr = new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00',ISPEndTime__c='2018-04-14T23:59:00',
                                                  ResponseCode__c='100',ResponseMessage__c='Sucess');
            SlotsController.mockedAvailableSlotsByAttr.add(mockedAvailableSlotsByAttr);
            mockedAvailableSlotsByAttr = new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-15T00:00:00',ISPEndTime__c='2018-04-15T23:59:00',
                                                  ResponseCode__c='100',ResponseMessage__c='Sucess');
            SlotsController.mockedAvailableSlotsByAttr.add(mockedAvailableSlotsByAttr);
            DispatchServiceProviderController.responseWrapper response = 
                SlotsController.getScheduleSlots(wo.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void getScheduleSlots1_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            GetSiebelDeferralDates__x mokedGetSiebelDeferralDates = new GetSiebelDeferralDates__x(SLAStartDate__c='2018-04-14T00:00:00',SLAEndDate__c='2018-04-14T23:59:00', 
                                                StartTime__c='2018-04-14T00:00:00',EndTime__c='2018-04-14T23:59:00',ResponseCode__c='100',ResponseMessage__c='Sucess', WorkOrderNumber__c = wo.Id);
            SlotsController.mokedGetSiebelDeferralDates.add(mokedGetSiebelDeferralDates);
            mokedGetSiebelDeferralDates = new GetSiebelDeferralDates__x(SLAStartDate__c='2018-04-14T00:00:00',SLAEndDate__c='2018-04-14T23:59:00', 
                                                StartTime__c='2018-04-15T00:00:00',EndTime__c='2018-04-15T23:59:00',ResponseCode__c='100',ResponseMessage__c='Sucess', WorkOrderNumber__c = wo.Id);
            SlotsController.mokedGetSiebelDeferralDates.add(mokedGetSiebelDeferralDates);
            DispatchServiceProviderController.responseWrapper response = SlotsController.getScheduleSlots(wo.Id);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    @isTest
    private static void getScheduleSlots4_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            DispatchServiceProviderController.responseWrapper response = SlotsController.getScheduleSlots(wo.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void getScheduleSlotsFail_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            GetSiebelDeferralDates__x mokedGetSiebelDeferralDates = new GetSiebelDeferralDates__x(SLAStartDate__c='2018-04-14T00:00:00',SLAEndDate__c='2018-04-14T23:59:00', 
                                                StartTime__c='2018-04-14T00:00:00',EndTime__c='2018-04-14T23:59:00',ResponseCode__c='100',ResponseMessage__c='Sucess');
            SlotsController.mokedGetSiebelDeferralDates.add(mokedGetSiebelDeferralDates);
            AvailableSlotsByAttributes__x mockedAvailableSlotsByAttr = new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00',ISPEndTime__c='2018-04-14T23:59:00',
                                                  ResponseCode__c='100',ResponseMessage__c='Sucess');
            SlotsController.mockedAvailableSlotsByAttr.add(mockedAvailableSlotsByAttr);
            DispatchServiceProviderController.responseWrapper response = 
                SlotsController.getScheduleSlots(u.Id);
            Test.stopTest();
            //system.assertEquals(response.LOB,null);
            //system.assertEquals(response,null);
        }
    }
    
    
    @isTest
    private static void getScheduleSlots_Test1(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            GetSiebelDeferralDates__x mokedGetSiebelDeferralDates = new GetSiebelDeferralDates__x(SLAStartDate__c='2018-04-14T00:00:00',SLAEndDate__c='2018-04-14T23:59:00', 
                                                StartTime__c='2018-04-14T00:00:00',EndTime__c='2018-04-14T23:59:00',ResponseCode__c='100',ResponseMessage__c='Sucess');
            SlotsController.mokedGetSiebelDeferralDates.add(mokedGetSiebelDeferralDates);
            AvailableSlotsByAttributes__x mockedAvailableSlotsByAttr = new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00',ISPEndTime__c='2018-04-14T23:59:00',
                                                  ResponseCode__c='100',ResponseMessage__c='Sucess');
            SlotsController.mockedAvailableSlotsByAttr.add(mockedAvailableSlotsByAttr);
            DispatchServiceProviderController.responseWrapper response = 
                SlotsController.getScheduleSlots(wo2.Id);
            Test.stopTest();
            //system.assertEquals(response,null);
        }
    }
        
   /* @isTest
    private static void getLocalTime_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            SlotsController sCon = new SlotsController();
            string response = sCon.getLocalTime(null);
            Test.stopTest();
            system.assertEquals(response,null);
        }
    }
    */
    @isTest
    private static void processTime_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            //SlotsController sCon = new SlotsController();
            string pTime = SlotsController.processTime('0+9:00',null);
            Test.stopTest();
            //system.assertNotEquals(pTime,null);
        }
    }
    
    @isTest
    private static void processTime_Test1(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            //SlotsController sCon = new SlotsController();
            string pTime = SlotsController.processTime('0-9:00',null);
            Test.stopTest();
            //system.assertNotEquals(pTime,null);
        }
    }
    
    @isTest
    private static void processTime_Test2(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            SlotsController.getDeferralSlots(wo.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void nonSubmittedDispatch_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            CancelSlot__x mockedCancelSlots = new CancelSlot__x(ISPConfirmationNumber__c='1234567890',ResponseCode__c='100',ResponseMessage__c='Sucess',DispatchID__c=wo.WorkOrderNumber,ReplyCode__c='100000');
            SlotsController.mockedCancelSlots.add(mockedCancelSlots);
            ScheduleSlotByAttributes__x mockedRequest = new ScheduleSlotByAttributes__x(ConfirmationNumber__c='1234567890', ResponseCode__c='100',ResponseMessage__c='Sucess',ReplyCode__c='100000');
            SlotsController.mockedScheduleSlotsByArrtributes.add(mockedRequest);
            SlotsController.scheduleWrap sWrap=SlotsController.nonSubmittedDispatch(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
        }
    }
    
    @isTest
    private static void nonSubmittedDispatch1_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x mockedRequest = new ScheduleSlotByAttributes__x(ConfirmationNumber__c=null, ResponseCode__c='101',ResponseMessage__c='Failed',ReplyCode__c='100000');
            SlotsController.mockedScheduleSlotsByArrtributes.add(mockedRequest);
            CancelSlot__x mockedCancelSlots = new CancelSlot__x(ISPConfirmationNumber__c='1234567890',ResponseCode__c='100',ResponseMessage__c='Sucess',DispatchID__c=wo.WorkOrderNumber,ReplyCode__c='100000');
            SlotsController.mockedCancelSlots.add(mockedCancelSlots);
            SlotsController.scheduleWrap sWrap=SlotsController.nonSubmittedDispatch(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
        }
    }
    
    @isTest
    private static void nonSubmittedDispatch8_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            ScheduleSlotByAttributes__x mockedRequest = new ScheduleSlotByAttributes__x(ConfirmationNumber__c='1234567890', ResponseCode__c='100',ResponseMessage__c='Sucess',ReplyCode__c='100001');
            SlotsController.mockedScheduleSlotsByArrtributes.add(mockedRequest);
            CancelSlot__x mockedCancelSlots = new CancelSlot__x(ISPConfirmationNumber__c='1234567890',ResponseCode__c='100',ResponseMessage__c='Sucess',DispatchID__c=wo.WorkOrderNumber,ReplyCode__c='100001');
            SlotsController.mockedCancelSlots.add(mockedCancelSlots);
            SlotsController.scheduleWrap sWrap=SlotsController.nonSubmittedDispatch(wo.Id,'2018-04-05T07:05:24','2018-04-05T07:05:24');
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
        }
    }
    
    @isTest
    private static void dispatchDefaultsTrigger_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            DispatchDefaults__c ddup = new DispatchDefaults__c(Id=dd.Id);
            ddup.OrderNumber__c='98077';
            update ddup;
            Test.stopTest();
        }
    }
    
    @isTest
    private static void fetchDeferralSlotInfo_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            GetSiebelDeferralDates__x mokedGetSiebelDeferralDates = new GetSiebelDeferralDates__x(SLAStartDate__c='2018-04-14T00:00:00',SLAEndDate__c='2018-04-14T23:59:00', 
                                                StartTime__c='2018-04-14T00:00:00',EndTime__c='2018-04-14T23:59:00',ResponseCode__c='100',ResponseMessage__c='Sucess' );
            SlotsController.mokedGetSiebelDeferralDates.add(mokedGetSiebelDeferralDates); 
            //SlotsController sCon  = new SlotsController();
            //sCon.fetchDeferralSlotInfo();
            Test.stopTest();
        }
    }  
    
    @isTest
    private static void fetchSheduleSlotInfo_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            AvailableSlotsByAttributes__x mockedAvailableSlotsByAttr = new AvailableSlotsByAttributes__x(ISPStartTime__c='2018-04-14T00:00:00',ISPEndTime__c='2018-04-14T23:59:00',
                                                  ResponseCode__c='101',ResponseMessage__c='Failure');
            SlotsController.mockedAvailableSlotsByAttr.add(mockedAvailableSlotsByAttr);
            //SlotsController sCon  = new SlotsController();
            //sCon.fetchSheduleSlotInfo();
            Test.stopTest();
        }
    } 
    
    @isTest
    private static void fetchSheduleSlotInfo1_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            AvailableSlotsByAttributes__x mockedAvailableSlotsByAttr = new AvailableSlotsByAttributes__x();
            SlotsController.mockedAvailableSlotsByAttr.add(mockedAvailableSlotsByAttr);
            //SlotsController sCon  = new SlotsController();
            //sCon.fetchSheduleSlotInfo();
            Test.stopTest();
        }
    }
        
    @isTest
    private static void nonSubmittedDispatch7_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            CancelSlot__x mockedCancelSlots = new CancelSlot__x(ISPConfirmationNumber__c='1234567890',ResponseCode__c='100',ResponseMessage__c='Sucess',DispatchID__c=wo.WorkOrderNumber,ReplyCode__c='100000');
            SlotsController.mockedCancelSlots.add(mockedCancelSlots);
            ScheduleSlotByAttributes__x mockedRequest = new ScheduleSlotByAttributes__x(ConfirmationNumber__c='1234567890', ResponseCode__c='100',ResponseMessage__c='Sucess',ReplyCode__c='100000');
            SlotsController.mockedScheduleSlotsByArrtributes.add(mockedRequest);
            SlotsController.scheduleWrap sWrap=SlotsController.nonSubmittedDispatch(wo.Id,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assertNotEquals(sWrap,null);
        }
    }
    
        
    @isTest
    private static void rescheduledSlot4_Test(){
        setupTestData();
        system.runAs(u1){
            Test.startTest();
            RescheduleSlots__x mockedReshuleSlots= new RescheduleSlots__x(ISPConfirmationNumber__c='1234567890', ResponseCode__c='100',
                                                                          ResponseMessage__c='Sucess',ReplyCode__c = '100000');
            SlotsController.mockedReshuleSlots.add(mockedReshuleSlots);
            string response = 
                SlotsController.rescheduledSlot(wo.Id,'2018-04-05T07:05:24Z','2018-04-05T07:05:24Z');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
}
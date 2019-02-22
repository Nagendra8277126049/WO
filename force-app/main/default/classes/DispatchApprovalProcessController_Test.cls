/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchApprovalProcessController_Test
Description:  This is unit test class for DispatchApprovalProcessController
Date         Version    Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
12-02-2019    v1        Deepa Lakamanhalli  Feb release text class fix   
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class DispatchApprovalProcessController_Test {
    private static List<User> lstUsrs;
    private static List<DispatchDefaults__c> ddList;
    private static List<WorkOrder> lstWO;
    private static List <WorkOrderLineItem> lstWOL;
    private static List <Approval_Attribute_Set__c> lstAAS;
    private static List <Queue_Approval_Attribute_Map__c> lstQmap;
    private static List <Approval_Criterion__c> lstAC ;
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static Product2 prd;
    private static Contact co;
    /* This method creates the test data */
    @testSetup
    private static void setupTestData() {
        lstUsrs = new List<User>();
        User u1 = new User(Alias = 'auser1', Email = 'adminusert1@dell.com', File_Source__c='AMS - System Admin', Dell_NTUserID__c='TEST1_T',
            Service_User_Type__c='Admin',EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US',
            External_ID__c='1234526', FederationIdentifier = '1234526',LocaleSidKey = 'en_US', Organization__c='Dell',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminuser1@dell.com', OSP__C = 'No');
        
        User u2 = new User(Alias = 'auser2', Email = 'adminuser2@dell.com', File_Source__c='AMS - System Admin', Dell_NTUserID__c='TEST2_T',
            Service_User_Type__c='Admin',EmailEncodingKey = 'UTF-8', LastName = 'Testing2', LanguageLocaleKey = 'en_US',
            External_ID__c='9997533', FederationIdentifier = '9997533',LocaleSidKey = 'en_US', Organization__c='Dell',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Work Order Approver' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminusert2@dell.com', OSP__C = 'Yes');      
        lstUsrs.add(u1);
        lstUsrs.add(u2);
        insert lstUsrs;

        //create a test account
        acnt = new Account(Name = 'Test Company', Industry = 'Fashion', Type = 'Customer');
        insert acnt;

        //create a new product
        prd = new Product2(ProductCode = '12345', Description = 'test description', Name = 'Test Product', LOB_Code__c = '4SV');
        insert prd;

        //create a test asset
        ast = new Asset(Name = 'Test Asset', Status = 'Installed', AccountId = acnt.Id, Product2Id = prd.Id,
            InstallDate = System.Today(), UsageEndDate = System.Today());
        insert ast;

        //create a test contact
        co = new Contact(Email = 'testtag@test.com', firstname = 'firstname',
            LastName = 'testtag', Accountid = acnt.id);
        insert co;

        //create a test case
        cse = new Case(Subject = 'Test Case', AccountId = acnt.Id, AssetId = ast.Id,
            ContactId = co.Id, ApprovalQueueName__c='test');
        insert cse;

        lstWO = new List<WorkOrder>();
        //test WO for method1
        WorkOrder wo1 = new WorkOrder(assetId = ast.id, accountId = acnt.id, contactId = co.id, caseId = cse.id, City = 'Round Rock',
            Country = 'United States', Region__c = '1', PostalCode = '786664', AdditionalContactId__c = co.id, CountryCode = 'US',
            subject = 'testing Work Order', StateCode = 'Tx', Service_Type__c = 'Labor Only',
            Deferred__c = 'Y', Sanbao_FLG__c = 'Y', FSD_DASP_Flag__c = true, Service_Option__c = 'NextDay-8x5', CallType__c = 'test',
            DPSType__c = 'test', DSP__c = 'test', State = 'Texas', Street = 'Test Street', IsDeferralAllowed__c = false);
        lstWO.add(wo1);
        insert lstWO;

        //create a test Dispatch Default
        ddList = new List<DispatchDefaults__c>();
        DispatchDefaults__c dd = new DispatchDefaults__c(Service_Options_Picklist_values__c = 'NextDay-8x5', Service_Type__c = 'Labor Only',
            PO_Number__c = '18458', selected_service_option__c = 'Available-24x5', OutOfWarranty__c = True,
            Service_Configurations__c = 'XPS Notebooks', SpecialOptions__c = 'CBBF', Bill_To__c = 'Customer',
            Keep_Your_Components__c = True, Bill_To_Order_Number__c = 'test Order Number',
            AvailableCoverages__c = '|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c = True,
            OrderNumber__c = '124563', Work_Order__c = lstWO[0].Id, AD_Override__c = 'CSAT', DPSType__c = 'test', DefaultDPSType__c = 'test',
            CallType__c = 'test', DefaultCallType__c = 'test', ServiceLevel__c = 'test', ServiceHours__c = 'test',
            Billable__c = 'Y', KYHDOption__c = true, OconusDispatch__c = 'N', PremierCode__c = 'yy', OutOfHours__c = true);
        ddList.add(dd);
        insert ddList;
        system.debug('ddList >> d>'+ddList);
        Group testGroup = new Group();
        QueuesObject testQueue = new QueuesObject();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            testGroup.Name = 'Test_New_Queue_App';
            testGroup.Type = 'Queue';

            insert testGroup;

            testQueue.QueueID = testGroup.id;
            testQueue.SObjectType = 'DispatchPendingApproval__c';
            insert testQueue;
        }
        // Create a multiple test Approval Attribute Set Records
        lstAAS = new List <Approval_Attribute_Set__c> ();
        Approval_Attribute_Set__c aas = new Approval_Attribute_Set__c(AAS_Name__c = 'AAS 1', Overall__c = true);
        lstAAS.add(aas);
        insert lstAAS;

        lstAC = new List<Approval_Criterion__c>();
        Approval_Criterion__c ac1 = new Approval_Criterion__c(Name='AC 1', Active__c=true, Approval_Attribute_Set__c = lstAAS[0].Id, Overall__c = true);
        lstAC.add(ac1);
        insert lstAC;

        lstQmap = new List<Queue_Approval_Attribute_Map__c>();
        Queue_Approval_Attribute_Map__c qmap1 = new Queue_Approval_Attribute_Map__c(Approval_Attribute_Set__c = lstAAS[0].Id,
            Queue_User__c = lstUsrs[0].Dell_NTUserID__c, Approver__c = 'Test_New_Queue_App');
        Queue_Approval_Attribute_Map__c qmap2 = new Queue_Approval_Attribute_Map__c(Approval_Attribute_Set__c = lstAAS[0].Id,
            Queue_User__c = lstUsrs[1].Dell_NTUserID__c, Approver__c = 'Test_New_Queue_App', OSP_Workorder_Approval_Queue__c = 'Test_New_Queue_App');
        lstQmap.add(qmap1);
        lstQmap.add(qmap2);
        insert lstQmap;

    }
    @isTest
    private static void appovalTestMethod1() {
        lstUsrs = [select id,Dell_NTUserID__c, OSP__c from User where Dell_NTUserID__c='TEST1_T' limit 1 ];
        ast = [select id from asset limit 1];
        lstWO = [SELECT Id, WorkOrderNumber, CaseApprovalQueueName__c, CaseId, Deferred__c, EntitlementEndDate__c,
                EntitlementStartDate__c, IsDeferralAllowed__c, IsScheduled__c, ScheduleEndDate__c, ScheduleStartDate__c,
                Schedule_Enable_Flag__c, Service_Option__c, Service_Type__c, Status, schedulingInternalLogic__c,
                AD_Override_Flg__c, Complete_Care_Option__c, CountryCode, Country, KYHD__c, FSD_System_Model__c, LOB__c,
                Repeat_Dispatch_Count__c, Reason_for_repeat_Work_Order__c, Sanbao_FLG__c,
                DPSType__c, KYC__c, OwnerLogin__c, AssetProductModel__c,
                CreatedDate, Approval_Criteria_Met__c, CallType__c, DASP__c FROM Workorder limit 1];
        ddList = [SELECT DSP_Override_Request__c, DPSType__c, Bill_To__c, Billable__c, Category__c,
                CompleteCareOption__c, OutOfWarranty__c, SpecialOptions__c, Service_Configurations__c,
                CallType__c FROM DispatchDefaults__c limit 1];
        lstAC= [SELECT Bill_To__c, Commodity__c, KYHD__c, Part_ID__c, Quantity__c,
                Service_Type__c, System_Class__c, Billable__c, AD_Override_Request__c,
                Category__c, Complete_Care__c, Cost__c, CRU__c, Day_of_Week__c,
                FRU__c, Model__c, Out_of_Warranty__c, Overall__c, Product_LOB__c,
                Repeat_Dispatch_Count__c, Repeat_Reason__c, SanBao__c, Service_Hours__c,
                Service_Level__c, SR_Diagnostic_Results__c, SR_Diagnostic_Tool__c, Time_of_Day__c,
                Country__c, KYC__c, DPS_Type__c, Quantity_excluding_Also_Shipped_Parts__c,
                Approval_Message__c, Approval_Attribute_Set__c, Name, APS_Flag__c FROM Approval_Criterion__c];
        lstAAS= [SELECT AAS_Name__c, AD_Override_Request__c, Approval_Criteria_Message__c, Billable__c, Bill_To__c, Category__c,
                Commodity__c, Complete_Care__c, Cost__c, Country__c, CRU__c, Day_of_Week__c,
                DPS_Type__c, FRU__c, Id, Individual_Dispatch_Probation__c,
                KYC__c, KYHD__c, Model__c, Name, Out_of_Warranty__c, Overall__c, Part_ID__c,
                Product_LOB__c, Quantity_excluding_Also_Shipped_Parts__c, Quantity__c,
                Repeat_Dispatch_Count__c, Repeat_Reason__c, SanBao__c, Service_Hours__c,
                Service_Level__c, Service_Type__c, SR_Diagnostic_Results__c,
                SR_Diagnostic_Tool__c, System_Class__c, Time_of_Day__c, APS_Flag__c
                FROM Approval_Attribute_Set__c ];
        lstWOL = new List<WorkOrderLineItem>();
        
        //system.debug('ddlist>>appovalTestMethod1>>'+ddList);
        system.runAs(lstUsrs[0]) {
            Test.startTest();
            DispatchApprovalProcessController.approvalWrapper appWrap = new DispatchApprovalProcessController.approvalWrapper();
            appWrap = DispatchApprovalProcessController.checkApprovalCriteria(lstWO[0].Id);
            string responseM = DispatchApprovalProcessController.approvalAttributeCheck();
            boolean drp = DispatchApprovalProcessController.dispatchRoutingProcess(lstWO[0], ddList[0], lstWOL, lstAC[0], lstAAS[0]);
            drp = DispatchApprovalProcessController.workOrderDetailMatch(lstWO[0], ddList[0], lstAC[0],  lstAAS[0]);
            Set<String> partsSet = new Set<String>{'1234','12','123'}; 
            WorkOrderLineItem wol1 = new WorkOrderLineItem(WorkOrderId = lstWO[0].Id, PartNumber__c = '1234',PartPrice__c = '1234',
            PartType__c = 'type',Line_Item_Type__c = 'APS',PartCommodity__c = 'HARD DRIVE', Selected_By_user__c = true,
            DefectiveComponent__c = 'test', ServiceBUID__c = 'test',Part_Quantity__c = '1', AssetId = ast.Id,
            CustomerReplaceableUnit__c = '1', FieldReplaceableUnit__c = '1');
            lstWOL.add(wol1);
            insert lstWOL;
            drp = DispatchApprovalProcessController.workOrderLineItemMatch(lstWOL, lstAC[0], lstAAS[0]);
            drp = DispatchApprovalProcessController.DispatchCheckPartsAndCommodityMatch('1234', partsSet , true);
            Test.stopTest();
        }
    }
}
/**
 * Thomas Davis
 * 2019-01-23
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Provides test code coverage for the following classes:
 *
 * GetAppointmentsController.cls
 * GetAppsPlanningTaskRequest.cls
 * GetAppsPreImpTaskRequest.cls
 * GetAppsResponse.cls
 * ProcessTaskExResponse.cls
 * ProcessTaskExSLARequest.cls
 * ProcessTaskExTechnicalRequest.cls
 */
@IsTest
private class GetAppointmentsControllerTest
{
    @TestSetup
    static void setup()
    {
        pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
        );
        insert testRegion;

        pse__Practice__c testPractice = new pse__Practice__c(
                Name = 'Test Practice'
        );
        insert testPractice;

        pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
        );
        insert testPC;

        Contact testContact = new Contact(
                FirstName = 'Test',
            	LastName = 'Contact',
                Primary_Phone__c = '555-5555',
                Email = 'test@email.com',
                Phone = '555-5555',
                TimeZone__c = 'Eastern Standard Time',
                Badge_ID__c = '1234567',
                pse__Is_Resource__c = true,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
        );
        insert testContact;

        pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
        );
        insert testProject;

        Account testAccount = new Account(
                Name = 'Test Account'
        );
        insert testAccount;

        Order testOrder = new Order(
                Project__c = testProject.Id,
                OrderNumber__c = '1234',
                Status = 'BK',
                AccountId = testAccount.Id,
                EffectiveDate = System.today()
        );
        insert testOrder;

        pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
        );
        insert testProjectTask;

        WorkOrder testWorkOrder = new WorkOrder(
                Contact = testContact,
                Duration = 8,
                Delivery_Method__c = 'Remote',
                Project_Task__c = testProjectTask.Id

        );
        insert testWorkOrder;

        pse__Skill__c testSkill = new pse__Skill__c(Name = 'Test Skill 1');
        insert testSkill;

        pse__Skill__c testSkill2 = new pse__Skill__c(Name = 'Project Management (Low)');
        insert testSkill2;

        pse__Skill__c testSkill3 = new pse__Skill__c(Name = 'Project Management (Medium)');
        insert testSkill3;

        pse__Skill__c testSkill4 = new pse__Skill__c(Name = 'Project Management (High)');
        insert testSkill4;

        Work_Order_Skill__c testWorkOrderSkill = new Work_Order_Skill__c(Skill_Certification__c = testSkill.Id, Work_Order__c = testWorkOrder.Id);
        insert testWorkOrderSkill;

        ServiceAppointment requiredEngineerSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                ParentRecordId = testWorkOrder.Id,
                Duration = 8,
                Latitude = -34.64646377383453,
                Longitude = -58.39512164685306,
                Assignee__c = testContact.Id

        );
        insert requiredEngineerSA;

        ServiceAppointment excludedEngineerSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                ParentRecordId = testWorkOrder.Id,
                Duration = 8,
                Latitude = -34.64646377383453,
                Longitude = -58.39512164685306,
                Assignee__c = testContact.Id

        );
        insert excludedEngineerSA;

        ServiceAppointment testServiceAppointment = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Assigned',
                ParentRecordId = testWorkOrder.Id,
                Duration = 8,
                Latitude = -34.64646377383453,
                Longitude = -58.39512164685306,
                Required_Engineer_SA__c = requiredEngineerSA.Id,
                Excluded_Engineer_SA__c = excludedEngineerSA.Id
        );
        insert testServiceAppointment;
    }

    @IsTest
    static void testGetSA()
    {
        Test.startTest();
        ServiceAppointment sa = GetAppointmentsController.getSA([ SELECT Id FROM ServiceAppointment WHERE Status = 'Assigned' LIMIT 1 ].Id);
        Test.stopTest();

        System.assert(sa != null);
    }

    @IsTest
    static void testGetAppointmentsPlanningCallout()
    {
        ServiceAppointment testSA = [ SELECT Id FROM ServiceAppointment WHERE Status = 'Assigned' LIMIT 1 ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetAppointmentsMock());
        Map<String, String> slotMap = GetAppointmentsController.getAppointmentsCallout(testSA.Id);
        System.assert(slotMap != null);
        Test.stopTest();
    }

    @IsTest
    static void testGetAppointmentsPreImplementationValidationCallout()
    {
        ServiceAppointment testSA = [ SELECT Id FROM ServiceAppointment WHERE Status = 'Assigned' LIMIT 1 ];
        WorkOrder testWorkOrder = [ SELECT Id FROM WorkOrder LIMIT 1 ];
        pse__Proj__c testProject = [ SELECT Pre_Implementation_Validation__c FROM pse__Proj__c LIMIT 1 ];

        ServiceAppointment testServiceAppointment = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Assigned',
                ParentRecordId = testWorkOrder.Id,
                Duration = 8,
                Latitude = -34.64646377383453,
                Longitude = -58.39512164685306

        );
        insert testServiceAppointment;

        testProject.Pre_Implementation_Validation__c = true;
        update testProject;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetAppointmentsMock());
        Map<String, String> slotMap = GetAppointmentsController.getAppointmentsCallout(testSA.Id);
        System.assert(slotMap != null);
        Test.stopTest();
    }

    @IsTest
    static void testProcessTaskExCallout()
    {
        ServiceAppointment testSA = [ SELECT Id FROM ServiceAppointment WHERE Status = 'Assigned' LIMIT 1 ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProcessTaskExMock());
        GetAppointmentsController.processTaskExCallout(testSA.Id,
                '{"Start":"2018-10-12T08:00:00","Finish":"2018-10-12T10:00:00","Grade":0,"SuggestedArrangement":null}',
                false, false
        );
        Test.stopTest();

        ServiceAppointment updatedSA =
        [
                SELECT Integration_Message__c, Status, SchedStartTime, SchedEndTime, Assignee__c, Assignment__c, Chosen_Slot__c
                FROM ServiceAppointment
                WHERE Status = 'Assigned'
                LIMIT 1
        ];

        System.assert(updatedSA.Integration_Message__c != null);
        System.assert(updatedSA.Status == 'Assigned');
        System.assert(updatedSA.SchedStartTime != null);
        System.assert(updatedSA.SchedEndTime != null);
        System.assert(updatedSA.Assignee__c != null);
        System.assert(updatedSA.Assignment__c != null);
        //System.assert(updatedSA.Chosen_Slot__c != null);
    }

    @IsTest
    static void testProcessTaskExCalloutForSLA()
    {
        ServiceAppointment testSA = [ SELECT Id FROM ServiceAppointment WHERE Status = 'Assigned' LIMIT 1 ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProcessTaskExMock());
        GetAppointmentsController.processTaskExCallout(testSA.Id,
                '{"Start":"2018-10-12T08:00:00","Finish":"2018-10-12T10:00:00","Grade":0,"SuggestedArrangement":null}',
                true, false
        );
        Test.stopTest();

        ServiceAppointment updatedSA =
        [
                SELECT Integration_Message__c, Status, SchedStartTime, SchedEndTime, Assignee__c, Assignment__c
                FROM ServiceAppointment
                WHERE Status = 'Assigned'
                LIMIT 1
        ];

        System.assert(updatedSA.Integration_Message__c != null);
        System.assert(updatedSA.Status == 'Assigned');
        System.assert(updatedSA.SchedStartTime != null);
        System.assert(updatedSA.SchedEndTime != null);
        System.assert(updatedSA.Assignee__c != null);
        System.assert(updatedSA.Assignment__c != null);
    }

    private class GetAppointmentsMock implements HttpCalloutMock
    {
        private Integer calloutNumber = 0;

        public HttpResponse respond(HttpRequest req)
        {
            HTTPResponse res = new HTTPResponse();

            if (calloutNumber == 0)
            {
                res.setBody(
                        '{"TimeInterval": null}'
                );
            }
            else
            {
                res.setBody(
                        '{' +
                                '"TimeInterval":[' +
                                '{' +
                                '"Start":"2018-10-12T08:00:00",' +
                                '"Finish":"2018-10-12T10:00:00",' +
                                '"Grade":0,' +
                                '"SuggestedArrangement":null' +
                                '},' +
                                '{' +
                                '"Start":"2018-10-12T10:00:00",' +
                                '"Finish":"2018-10-12T12:00:00",' +
                                '"Grade":0,' +
                                '"SuggestedArrangement":null' +
                                '}' +
                                ']' +
                                '}'
                );
            }

            res.setStatusCode(200);
            calloutNumber ++;
            return res;
        }
    }

    private class ProcessTaskExMock implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            HTTPResponse res = new HTTPResponse();
            res.setBody(
                    '{' +
                        '"ReturnCode":"Success",' +
                        '"Task":{' +
                            '"@objectType":"Task",' +
                            '"Key":390119425,' +
                            '"Revision":2,' +
                            '"CallID":"IDSnonAppointment1",' +
                            '"Number":1,' +
                            '"Status":{' +
                                '"Key":124135426,' +
                                '"@DisplayString":"Assigned"' +
                            '},' +
                            '"ExternalRefID":"IDSnonAppointment1"' +
                        '},' +
                        '"Assignment":{' +
                            '"@objectType":"Assignment",' +
                            '"Key":-1,' +
                            '"Revision":1,' +
                            '"Task":{' +
                                '"Key":390119425,' +
                                '"@DisplayString":"IDSnonAppointment1"' +
                            '},' +
                            '"Start":"2018-10-16T12:00:00",' +
                            '"Finish":"2018-10-16T13:00:00",' +
                            '"PS_EngineerID":"1234567"' +
                        '},' +
                        '"LinkedTasks":null,' +
                        '"SchedulingError":null' +
                    '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }
}
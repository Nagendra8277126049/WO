/**
 * Thomas Davis
 * 2019-01-15
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Provides test code coverage for the following assets:
 *
 * METHODS:
 * ServiceAppointmentHandler.cancelClickTask()
 * ServiceAppointmentHandler.setNumberField()
 * ServiceAppointmentHandler.populateAssignment()
 * ServiceAppointmentHandler.synchronizeWorkOrderStatus()
 *
 * CLASSES:
 * CancelTaskRequest.cls
 * CancelTaskResponse.cls
 *
 */
@IsTest
private class ServiceAppointmentHandlerTest
{
    @TestSetup
    static void setup()
    {
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.Status = 'FF - Work In Progress';
        insert testWorkOrder;

        WorkOrder testWorkOrder2 = new WorkOrder();
        testWorkOrder2.Status = 'FF - Work In Progress';
        insert testWorkOrder2;
    }

    @IsTest
    static void testCancelClickTask()
    {
        WorkOrder testWorkOrder = [
                SELECT Id FROM WorkOrder
                LIMIT 1
        ];

        Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();

        ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Click_Open',
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
        );
        insert testSA;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        testSA.Status = 'Click_Cancelled';
        update testSA;
        Test.stopTest();

        ServiceAppointment updatedSA = [ SELECT Click_Task_Cancelled__c FROM ServiceAppointment LIMIT 1];

        System.assert(updatedSA.Click_Task_Cancelled__c == true);

    }

    @IsTest
    static void testSetNumberField()
    {
        WorkOrder testWorkOrder = [
                SELECT Id FROM WorkOrder
                LIMIT 1
        ];

        WorkOrder testWorkOrder2 = [
                SELECT Id FROM WorkOrder
                LIMIT 1
        ];

        ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Open',
                ParentRecordId = testWorkOrder.Id
        );

        ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = testWorkOrder2.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Assigned',
                ParentRecordId = testWorkOrder2.Id
        );

        Test.startTest();
        insert testSA1;
        insert testSA2;
        Test.stopTest();

        ServiceAppointment updatedTestSA1 = [ SELECT Number__c FROM ServiceAppointment WHERE Status = 'Open' LIMIT 1 ];
        ServiceAppointment updatedTestSA2 = [ SELECT Number__c FROM ServiceAppointment WHERE Status = 'Assigned' LIMIT 1 ];

        System.assert(updatedTestSA1.Number__c == 0);
        System.assert(updatedTestSA2.Number__c == 1);
    }

    @IsTest
    static void testPopulateAssignment()
    {
        WorkOrder testWorkOrder = [
                SELECT Id FROM WorkOrder
                LIMIT 1
        ];

        pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
        );
        insert testRegion;

        pse__Practice__c testPractice = new pse__Practice__c(
                Name = 'Test Practice'
        );
        insert testPractice;

        Contact testContact = new Contact(
                FirstName = 'Test',
            	LastName = 'Contact',
                Primary_Phone__c = '555-5555',
                Email = 'test@email.com',
                Phone = '555-5555',
                TimeZone__c = 'Eastern Standard Time',
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

        pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
        );
        insert testProjectTask;

        testWorkOrder.Project_Task__c = testProjectTask.Id;
        update testWorkOrder;

        pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
        );
        insert testPC;

        ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Open',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id
        );
        insert testSA;

        Test.startTest();
        testSA.Assignee__c = testContact.Id;
        update testSA;
        Test.stopTest();

        ServiceAppointment updatedSA = [ SELECT Assignment__c FROM ServiceAppointment LIMIT 1 ];
        //System.assert(updatedSA.Assignment__c != null);

    }

    @IsTest
    static void testSynchronizeWorkOrderStatus()
    {

    }

    private class Mock implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            HTTPResponse res = new HTTPResponse();
            res.setBody(
                    '{' +
                    '    \"ReturnCode\": \"ScheduleFailed\",' +
                    '    \"Task\": {' +
                    '        \"objectType\": \"Task\",' +
                    '        \"Key\": 415506432,' +
                    '        \"Revision\": 3,' +
                    '        \"CallID\": \"PWA-100028\",' +
                    '        \"Number\": 1,' +
                    '        \"ExternalRefID\": \"PWA-100028\"' +
                    '    },' +
                    '    \"Assignment\": null,' +
                    '    \"LinkedTasks\": null,' +
                    '    \"SchedulingError\": null' +
                    '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

}
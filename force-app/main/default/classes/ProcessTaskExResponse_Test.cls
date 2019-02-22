/**
 * Thomas Davis
 * 2018-11-01
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Provides test code coverage for the following classes:
 *
 * ProcessTaskExResponse.cls
 */
@IsTest
public class ProcessTaskExResponse_Test {

    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
                '   \"ReturnCode\":\"Success\",'+
                '   \"Task\":{'+
                '      \"objectType\":\"Task\",'+
                '      \"Key\":390119425,'+
                '      \"Revision\":2,'+
                '      \"CallID\":\"IDSnonAppointment1\",'+
                '      \"Number\":1,'+
                '      \"Status\":{'+
                '         \"Key\":124135426,'+
                '         \"DisplayString\":\"Assigned\"'+
                '      },'+
                '      \"ExternalRefID\":\"IDSnonAppointment1\"'+
                '   },'+
                '   \"Assignment\":{'+
                '      \"objectType\":\"Assignment\",'+
                '      \"Key\":-1,'+
                '      \"Revision\":1,'+
                '      \"Task\":{'+
                '         \"Key\":390119425,'+
                '         \"DisplayString\":\"IDSnonAppointment1\"'+
                '      },'+
                '      \"Start\":\"2018-10-16T12:00:00\",'+
                '      \"Finish\":\"2018-10-16T13:00:00\",'+
                '      \"PS_EngineerID\":\"1234567\",'+
                '      \"PS_ResourceTimeZone\":\"Test Timezone\"'+
                '   },'+
                '   \"LinkedTasks\":null,'+
                '   \"SchedulingError\":null'+
                '}';
        ProcessTaskExResponse r = ProcessTaskExResponse.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ProcessTaskExResponse.Status objStatus = new ProcessTaskExResponse.Status(System.JSON.createParser(json));
        System.assert(objStatus != null);
        System.assert(objStatus.Key == null);
        System.assert(objStatus.DisplayString == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ProcessTaskExResponse.Assignment objAssignment = new ProcessTaskExResponse.Assignment(System.JSON.createParser(json));
        System.assert(objAssignment != null);
        System.assert(objAssignment.objectType == null);
        System.assert(objAssignment.Key == null);
        System.assert(objAssignment.Revision == null);
        System.assert(objAssignment.Task == null);
        System.assert(objAssignment.Start == null);
        System.assert(objAssignment.Finish == null);
        System.assert(objAssignment.PS_EngineerID == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ProcessTaskExResponse.Task objTask = new ProcessTaskExResponse.Task(System.JSON.createParser(json));
        System.assert(objTask != null);
        System.assert(objTask.objectType == null);
        System.assert(objTask.Key == null);
        System.assert(objTask.Revision == null);
        System.assert(objTask.CallID == null);
        System.assert(objTask.Number_Z == null);
        System.assert(objTask.Status == null);
        System.assert(objTask.ExternalRefID == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ProcessTaskExResponse.InnerArray objInnerArray = new ProcessTaskExResponse.InnerArray(System.JSON.createParser(json));
        System.assert(objInnerArray != null);
        System.assert(objInnerArray.Task == null);
        System.assert(objInnerArray.Assignment == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ProcessTaskExResponse.LinkedTasks objLinkedTasks = new ProcessTaskExResponse.LinkedTasks(System.JSON.createParser(json));
        System.assert(objLinkedTasks != null);
        System.assert(objLinkedTasks.InnerArray == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ProcessTaskExResponse objProcessTaskExResponse = new ProcessTaskExResponse(System.JSON.createParser(json));
        System.assert(objProcessTaskExResponse != null);
        System.assert(objProcessTaskExResponse.ReturnCode == null);
        System.assert(objProcessTaskExResponse.Task == null);
        System.assert(objProcessTaskExResponse.Assignment == null);
        System.assert(objProcessTaskExResponse.LinkedTasks == null);
        System.assert(objProcessTaskExResponse.SchedulingError == null);
    }
}
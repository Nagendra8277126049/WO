/**
 * Thomas Davis
 * 2019-01-15
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Provides test code coverage for the following classes:
 *
 * OpenTextNodeIDBatch.cls
 * OpenTextSearchResponse.cls
 * OpenTextNodeIDBatchScheduled.cls
 */
@IsTest
private class OpenTextNodeIDBatchTest
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

        Contact testContact = new Contact(
                LastName = 'Test Contact',
                Primary_Phone__c = '555-5555',
                Email = 'test@email.com'
        );
        insert testContact;

        pse__Proj__c testProject1 = new pse__Proj__c(
                Name = 'Test Project 1',
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
        insert testProject1;
    }

    @IsTest
    static void test()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        SchedulableContext sc = null;
        OpenTextNodeIDBatchScheduled openTextNodeIDBatchScheduled = new OpenTextNodeIDBatchScheduled();
        openTextNodeIDBatchScheduled.execute(sc);
        Test.stopTest();

        pse__Proj__c testProject = [
                SELECT OpenText_Node_ID__c
                FROM pse__Proj__c
                LIMIT 1
        ];

        System.assert(testProject.OpenText_Node_ID__c != null);
    }

    private class Mock implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            if (req.getEndpoint().endsWith('auth'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"ticket": "bi/4JIG96IgLksxpXGdwDVkiweCyyS7fz4/Mb6m2yRU1wqOT+QcexfmJOi2k0pHgoD49MjOfwVytnMytorCFKwUonYdG+wFXPjPQsqk1fXWIZB9BTM135A=="}');
                res.setStatusCode(200);
                return res;
            }

            if (req.getEndpoint().endsWith('search'))
            {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"collection":{"paging":{"limit":25,"page":1,"page_total":1,"range_max":1,"range_min":1,"result_header_string":"Results 1 to 1 of about 1 sorted by Relevance","total_count":1},"searching":{"cache_id":1621571356,"result_title":"Search Results for: Attr_213871_2: PR-000023 AND OTSubType: 848"},"sorting":{"links":{"asc_Attr_60903_11":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356&sort=asc_Attr_60903_11","method":"POST","name":"Solution Opportunity:Reference Number (Ascending)"},"asc_OTObjectDate":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356&sort=asc_OTObjectDate","method":"POST","name":"Date (Ascending)"},"asc_OTObjectSize":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356&sort=asc_OTObjectSize","method":"POST","name":"Size (Ascending)"},"desc_Attr_60903_11":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356&sort=desc_Attr_60903_11","method":"POST","name":"Solution Opportunity:Reference Number (Descending)"},"desc_OTObjectDate":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356&sort=desc_OTObjectDate","method":"POST","name":"Date (Descending)"},"desc_OTObjectSize":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356&sort=desc_OTObjectSize","method":"POST","name":"Size (Descending)"},"relevance":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356","method":"POST","name":"Relevance"}}}},"links":{"data":{"self":{"body":"","content_type":"","href":"/api/v2/search?cache_id=1621571356","method":"POST","name":""}}},"results":[{"data":{"properties":{"container":true,"container_size":3,"create_date":"2018-11-26T19:46:05Z","create_user_id":1000,"description":"","description_multilingual":{"en_US":""},"external_create_date":null,"external_identity":"","external_identity_type":"","external_modify_date":null,"external_source":"","favorite":false,"id":558833,"mime_type":null,"modify_date":"2018-12-04T13:21:04Z","modify_user_id":1000,"name":"The Boeing Company Nov 26 2018 174557 PR-000023","name_multilingual":{"en_US":"The Boeing Company Nov 26 2018 174557 PR-000023"},"owner_group_id":363189,"owner_user_id":1000,"parent_id":432204,"permissions_model":"advanced","reserved":false,"reserved_date":null,"reserved_shared_collaboration":false,"reserved_user_id":0,"rm_enabled":false,"short_summary":"","size":3,"size_formatted":"3 Items","summary":"","type":848,"type_name":"Business Workspace","versions_control_advanced":false,"volume_id":-2000}},"links":{"ancestors":[{"href":"api/v1/nodes/2000","name":"Dell Home"},{"href":"api/v1/nodes/60721","name":"Connected Workspaces"},{"href":"api/v1/nodes/213978","name":"Infrastructure Deployment Services"},{"href":"api/v1/nodes/363191","name":"Project Workspaces"},{"href":"api/v1/nodes/432204","name":"2018"}],"ancestors_nodes":[{"href":"api/v1/nodes/2000/nodes","name":"Dell Home"},{"href":"api/v1/nodes/60721/nodes","name":"Connected Workspaces"},{"href":"api/v1/nodes/213978/nodes","name":"Infrastructure Deployment Services"},{"href":"api/v1/nodes/363191/nodes","name":"Project Workspaces"},{"href":"api/v1/nodes/432204/nodes","name":"2018"}],"parent":{"href":"api/v1/nodes/432204","name":"2018"},"parent_nodes":{"href":"api/v1/nodes/432204/nodes","name":"2018"}},"search_result_metadata":{"current_version":null,"object_href":null,"object_id":"DataId=558833&Version=0","result_type":"264","source_id":"98821","version_type":null}}]}');
                res.setStatusCode(200);
                return res;
            }

            return null;
        }
    }
}
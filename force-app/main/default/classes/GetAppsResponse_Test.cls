/**
 * Created by tdavis on 10/25/18.
 */

@IsTest
public class GetAppsResponse_Test
{
    // This test method should give 100% coverage
    static testMethod void testParse()
    {
        String json = '{' +
                '   \"TimeInterval\":[' +
                '      {' +
                '         \"Start\":\"2018-10-12T08:00:00\",' +
                '         \"Finish\":\"2018-10-12T10:00:00\",' +
                '         \"Grade\":0,' +
                '         \"SuggestedArrangement\":null' +
                '      }' +
                '   ]' +
                '}';
        GetAppsResponse r = GetAppsResponse.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        GetAppsResponse.TimeInterval objTimeInterval = new GetAppsResponse.TimeInterval(System.JSON.createParser(json));
        System.assert(objTimeInterval != null);
        System.assert(objTimeInterval.Start == null);
        System.assert(objTimeInterval.Finish == null);
        System.assert(objTimeInterval.Grade == null);
        System.assert(objTimeInterval.SuggestedArrangement == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        GetAppsResponse objGetAppsResponse = new GetAppsResponse(System.JSON.createParser(json));
        System.assert(objGetAppsResponse != null);
        System.assert(objGetAppsResponse.TimeInterval == null);
    }
}
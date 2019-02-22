/**
 * Thomas Davis
 * 2018-11-29
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Batch class used to retrieve the Node ID to be recorded in the OpenText_Node_ID__c field of pse__Proj__c records.
 * Utilizes callouts to a custom API developed by Dell IT.
 */
public class OpenTextNodeIDBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful
{
    public final String QUERY;
    public final Boolean isProduction;
    public final String searchRequestEndpointURL;
    public final String searchRequestWhereClauseValue;
    public final String ticketRequestUsername;
    public final String ticketRequestPassword;
    public final String ticketRequestEndpointURL;
    public final String openTextURL;

    public OpenTextNodeIDBatch()
    {
        QUERY = 'SELECT OpenText_Node_ID__c, pse__Project_ID__c ' +
                'FROM pse__Proj__c';

        OpenText_NodeID_Settings__mdt setting =
        [
                SELECT Is_Production__c, Search_Request_Endpoint_URL__c, Search_Request_Where_Clause_Value__c,
                        Ticket_Request_Development_Username__c, Ticket_Request_Development_Password__c,
                        Ticket_Request_Production_Username__c, Ticket_Request_Production_Password__c,
                        Ticket_Request_Endpoint_URL__c, OpenText_URL__c
                FROM OpenText_NodeID_Settings__mdt
                LIMIT 1
        ];

        if (setting.Is_Production__c)
        {
            ticketRequestUsername = setting.Ticket_Request_Production_Username__c;
            ticketRequestPassword = setting.Ticket_Request_Production_Password__c;
        }
        else
        {
            ticketRequestUsername = setting.Ticket_Request_Development_Username__c;
            ticketRequestPassword = setting.Ticket_Request_Development_Password__c;
        }

        ticketRequestEndpointURL = setting.Ticket_Request_Endpoint_URL__c;
        searchRequestEndpointURL = setting.Search_Request_Endpoint_URL__c;
        searchRequestWhereClauseValue = setting.Search_Request_Where_Clause_Value__c;
        openTextURL = setting.OpenText_URL__c;
    }

    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext BC, List<pse__Proj__c> scope)
    {
        for (pse__Proj__c project : scope)
        {
            HttpRequest ticketRequest = new HttpRequest();
            ticketRequest.setEndpoint(ticketRequestEndpointURL);
            ticketRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            ticketRequest.setBodyAsBlob(Blob.valueOf('username=' + ticketRequestUsername + '&password=' + ticketRequestPassword));
            ticketRequest.setMethod('POST');
            ticketRequest.setTimeout(120000);

            HttpResponse ticketResponse = new Http().send(ticketRequest);

            Map<String, Object> ticketResponseBody = (Map<String, Object>) JSON.deserializeUntyped(ticketResponse.getBody());

            String ticket = (String) ticketResponseBody.get('ticket');

            HttpRequest searchRequest = new HttpRequest();
            searchRequest.setEndpoint(searchRequestEndpointURL);
            searchRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            searchRequest.setHeader('OTCSTicket', ticket);
            searchRequest.setBodyAsBlob(Blob.valueOf('where=' + searchRequestWhereClauseValue + ': ' + project.pse__Project_ID__c + ' AND OTSubType: 848'));
            searchRequest.setMethod('POST');
            searchRequest.setTimeout(120000);

            HttpResponse searchResponse = new Http().send(searchRequest);

            OpenTextSearchResponse deserializedSearchResponse = OpenTextSearchResponse.parse(searchResponse.getBody());

            if (searchResponse.getStatusCode() == 200 && !deserializedSearchResponse.results.isEmpty())
            {
                project.OpenText_Node_ID__c = openTextURL + String.valueOf(deserializedSearchResponse.results[0].data.properties.id);
            }

            update scope;
        }
    }

    public void finish(Database.BatchableContext BC)
    {

    }
}
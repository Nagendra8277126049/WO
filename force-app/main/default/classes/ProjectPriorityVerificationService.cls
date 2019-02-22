public with sharing class ProjectPriorityVerificationService {

    public class ProjectPriorityVerificationRequest 
    {
        @InvocableVariable(required=true)
        public Id projectId;
    }
    
    @InvocableMethod
    public static void InvokeAffinityPriorityVerificationAsync(List<ProjectPriorityVerificationRequest> requests)
    {         
        for(ProjectPriorityVerificationRequest req : requests)
        {
			AffinityPriorityVerificationAsync(req.projectId);
        }
    }

    @Future(Callout=true)
    public static void AffinityPriorityVerificationAsync(Id projectId)
    { 
        pse__proj__c proj = [SELECT Id , Name , pse__Account__r.AccountNumber , pse__Account__r.BUID__c FROm  pse__proj__c WHERE Id =: projectId];
            
        string costumerNumber = proj.pse__Account__r.AccountNumber;
        string BUID = proj.pse__Account__r.BUID__c;
        
        System.debug('Calling Affinity Service ...');
        System.debug(proj);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Affinity_Is_Account_Priority');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"CustomerNumber": "' + costumerNumber + '", "BUID": "' + BUID + '"}');
        Http http = new Http();
        
        boolean result = false;
        HttpResponse response = new HttpResponse();
        
        try 
        {
            response = http.send(req);    
            result = Boolean.valueOf(response.getBody());
            
            System.debug('Affinity Response: ' + response);
            System.debug('Affinity Response for {' + costumerNumber + '/' + BUID  + '}: ' + result);
        } 
        catch(Exception ex) 
        {
            System.debug(LoggingLevel.Error, 'Exception Trying to call Affinity Service: ' + ex);
            system.debug(ex);
            System.debug(LoggingLevel.Error, 'HTTP response content = '+ response);
            System.debug(response);
        }
        
        proj.Is_Priority__c = result;
        update(proj);
    }    
}
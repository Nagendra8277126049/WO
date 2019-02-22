@isTest
public class ProjectPriorityVerificationServiceTest {
    
    class UnauthorizedEndpointResponse implements HttpCalloutMock {
    	public HttpResponse respond(HttpRequest request) {
        	CalloutException e = (CalloutException)CalloutException.class.newInstance();
        	e.setMessage('Unauthorized');
        	throw e;
    	}
	}
    
	@isTest
    static void InvokeAffinityPriorityVerificationAsync_Should_Be_Priority() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('AffinityPriorityVerificationMockedResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/text');

        Test.setMock(HttpCalloutMock.class, mock);
        
        Account account = new Account(Name = 'Test account', AccountNumber = '556677', BUID__c = '11');
        
        insert(account);
        
        pse__Proj__c project = new pse__Proj__c(Name = 'Test Project 2', pse__Account__c = account.Id, pse__Is_Active__c = true);
        
        insert(project);
        
        Test.startTest();
        
        List<ProjectPriorityVerificationService.ProjectPriorityVerificationRequest> request = new List<ProjectPriorityVerificationService.ProjectPriorityVerificationRequest>();
        ProjectPriorityVerificationService.ProjectPriorityVerificationRequest projectPriorityVerificationServiceRequest = new ProjectPriorityVerificationService.ProjectPriorityVerificationRequest();
        projectPriorityVerificationServiceRequest.projectId = project.Id;
        
        request.add(projectPriorityVerificationServiceRequest);
        
        ProjectPriorityVerificationService.InvokeAffinityPriorityVerificationAsync(request);
      
        Test.stopTest();
        
        pse__proj__c updatedproj = [SELECT Is_Priority__c FROM pse__proj__c WHERE Id =: project.Id];
        
        System.assertNotEquals(null, updatedproj);
        System.assertEquals(true, updatedproj.Is_Priority__c);
    }
    
    @isTest
    static void InvokeAffinityPriorityVerificationAsync_Should_Not_Be_Priority() {
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
      
        Account account = new Account(Name = 'Test account', AccountNumber = '556677', BUID__c = '11');
        
        insert(account);
        
        pse__Proj__c project = new pse__Proj__c(Name = 'Test Project 2', pse__Account__c = account.Id, pse__Is_Active__c = true);
        
        insert(project);
        
        Test.startTest();
        
        List<ProjectPriorityVerificationService.ProjectPriorityVerificationRequest> request = new List<ProjectPriorityVerificationService.ProjectPriorityVerificationRequest>();
        ProjectPriorityVerificationService.ProjectPriorityVerificationRequest projectPriorityVerificationServiceRequest = new ProjectPriorityVerificationService.ProjectPriorityVerificationRequest();
        projectPriorityVerificationServiceRequest.projectId = project.Id;
        
        request.add(projectPriorityVerificationServiceRequest);
        
        ProjectPriorityVerificationService.InvokeAffinityPriorityVerificationAsync(request);
      
        Test.stopTest();
        
        pse__proj__c updatedproj = [SELECT Is_Priority__c FROM pse__proj__c WHERE Id =: project.Id];
        
        System.assertNotEquals(null, updatedproj);
        System.assertEquals(false, updatedproj.Is_Priority__c);
    }
}
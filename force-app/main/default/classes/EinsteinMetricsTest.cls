/* -----------------------------------------------------------------------------------------------------------------------
Name:       EinsteinMetricsTest
Description:  This class contain the test method for EinsteinMetrics.
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
2018/08/31     1.0    Jorge Montalv�o       Initial Release
2018/10/16     1.0    Jorge Moreira         Added User context with the needed permission sets - DEFECT 5630751
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
public with sharing class EinsteinMetricsTest {
    @isTest static void refreshMetrics() {             
         //File_Source__c,Dell_NTUserID__c,Service_User_Type__c,External_id__c added by Shaurya Bajaj, defect 6112110
		String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        User u = new User(Alias = 'auser',File_Source__c = 'Test', Dell_NTUserID__c= 'TESTUSER', Service_User_Type__c='Admin', Email='adminuser@dell.com',EmailEncodingKey='UTF-8',LastName='Testing',
                          LanguageLocaleKey='en_US',Organization__c = 'Test',External_id__c = '1234', FederationIdentifier= '1234',LocaleSidKey='en_US',
                          ProfileId=[SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName, OSP__c='Yes');
        insert u;
        
        List<PermissionSet> permiSet = [SELECT Id 
                                        FROM PermissionSet 
                                        WHERE Name = 'EinsteinAnalyticsUser' OR Name = 'EinsteinAnalyticsAdmin'];
        
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        PermissionSetAssignment psa2 = new PermissionSetAssignment();
        
        psa1.AssigneeId = u.id;        
    	psa1.PermissionSetId = permiSet[0].id;
    	insert psa1;
        
        psa2.AssigneeId = u.id;
    	psa2.PermissionSetId = permiSet[1].id;
    	insert psa2;
        
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        
       /* System.runas(u){
        	Boolean test_result = EinsteinMetrics.refreshMetrics();
        	System.assertEquals(true,test_result);
        }*/
        
        Test.stopTest();
    }
}
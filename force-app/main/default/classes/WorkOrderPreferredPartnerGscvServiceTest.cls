@isTest
public class WorkOrderPreferredPartnerGscvServiceTest {
	@isTest static void getPreferredPartnerFromGscvTest() {
        
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        pse__Practice__c practice = new pse__Practice__c();
        insert practice;
        
        // partner details
        Partner_Details__c partnerDetails = new Partner_Details__c(Name = 'WISTR', Code__c= 'WISTR', DPS_Type__c = 'WTR', Call_Type__c = 'INSTALL', Country__c = 'US');
        insert partnerDetails;
        
        // acoount partner preference
        Account_Partner_Preference__c accountPartner = new Account_Partner_Preference__c(Account__c = a.Id, Country__c = 'US', Practice__c = practice.Id, Partner__c = partnerDetails.Id);
        insert accountPartner;
        
        // work order
        WorkOrder workOrder = new WorkOrder(Status='FF-New', PartnerName__c = partnerDetails.Id, Country__c = 'US', Partner_Country__c = 'US', CountryCode = 'US');
        insert workOrder;
        
        String countryCode = 'US';
        String state = 'TX';
        String city = 'Texas';
        String zipCode = '10004';
        String region = 'AMERICAS';
        
        //act
        Test.setMock(HttpCalloutMock.class, new GscvCalloutMock());
        Test.startTest();
        WorkOrderPreferredPartnerFromGscvService.getPreferredPartnerFromGscv(workOrder.Id, countryCode, state, city, zipCode, region);
        Test.stopTest();
    }
}
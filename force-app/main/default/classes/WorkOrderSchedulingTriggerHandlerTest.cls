@isTest
public class WorkOrderSchedulingTriggerHandlerTest {
	@isTest static void PopulatePartnerDetailsFieldsTest() {
        
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
        
        List<WorkOrder> wo = new List<WorkOrder>();
        
        // work order
        WorkOrder wolist = new WorkOrder(Status='FF-New', AccountId = a.Id, Country__c = 'US', Partner_Country__c = 'US', CountryCode = 'US');
        insert wolist;
            
        wo.add(wolist);
        
        String countryCode = 'US';
        String state = 'TX';
        String city = 'Texas';
        String zipCode = '10004';
        String region = 'AMERICAS';
        
        //act
        Test.startTest();
        WorkOrderSchedulingTriggerHandler.PopulatePartnerDetailsFields(wo);
        Test.stopTest();
    }
    
    @isTest static void CheckWorkOrderStatusTest() {
        
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
                
        List<WorkOrder> wo = new List<WorkOrder>();
        
        // work order
        WorkOrder wolist = new WorkOrder(Status='FF-New', AccountId = a.Id);
        insert wolist;
            
        wo.add(wolist);
        
        //act
        Test.startTest();
        WorkOrderSchedulingTriggerHandler.CheckWorkOrderStatus(wo);
        Test.stopTest();
    }
}
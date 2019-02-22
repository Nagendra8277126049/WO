public with sharing class WorkOrderSchedulingTriggerHandler {
	//public static Boolean runonce = true;
	
	public static void PopulatePartnerDetailsFields(List < WorkOrder > wolist) {
        System.debug('[ResourceScheduling: WorkOrderSchedulingTriggerHandler - PopulatePartnerDetailsFields');
        System.debug(wolist);
        
        
        for (WorkOrder wo: wolist) {
            System.debug('Work Order Id: ' + wo.Id);
            System.debug('Work Order Status: ' + wo.Status);
            
            if (wo.Id == null && wo.Status != 'FF - New') {
                wo.Status = 'FF - New';
            }
            
            if ((wo.AccountId != null) && (wo.PartnerName__c == null)) {
                System.debug('Get Partner Details by Custommer Preference');
                System.debug('Customer Account Id: ' + wo.AccountId);
                System.debug('Country Code:' + wo.CountryCode);
                
                wo.Partner_Country__c = wo.CountryCode;
                
                Id accountId = wo.AccountId;
                String countryCode = wo.CountryCode;
                
                Account_Partner_Preference__c[] preferredLine = 
                    [
                      SELECT Name, Account__c, Partner__c, Country__c FROM Account_Partner_Preference__c WHERE Country__C = :countryCode AND Account__c = :accountId];
                
                if (preferredLine.size() > 0) {
                	System.debug(preferredLine);
                    System.debug(preferredLine[0].Partner__c);
                    wo.PartnerName__c = preferredLine[0].Partner__c;
                }
            }
            
            if (wo.PartnerName__c != null) {
                // Get the partner details
                Partner_Details__c[] preferredPartner =
                        [ SELECT Id, Name, Code__c, Call_Type__c, DPS_Type__c
                        FROM Partner_Details__c p
                        WHERE p.Id =: wo.PartnerName__c
                        LIMIT 1 ];
                System.debug(preferredPartner);
                
                if (preferredPartner.size() > 0) {
                    wo.Partner_Code__c = preferredPartner[0].Code__C;
        			wo.CallType__c = preferredPartner[0].Call_Type__c;
                    wo.DPSType__c = preferredPartner[0].DPS_Type__c;
    			}
            }
        }
    }
    
    public static void CheckWorkOrderStatus (List <WorkOrder> wolist) {
    	for (WorkOrder wo: wolist) {
            System.debug('Work Order Id: ' + wo.Id);
            System.debug('Work Order Status: ' + wo.Status);
            
            if (wo.Id == null && wo.Status != 'FF - New') {
                wo.Status = 'FF - New';
            }
        }    
    }
}
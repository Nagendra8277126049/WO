public class ValidateCountryAndState {
    static final string COUNTRY = 'Country';
    static final string STATE = 'States';
    
    @InvocableMethod()
    public static void validadeOrderCountryState(List<Id> orderIds) {
        List<Order> orders = [
            SELECT Id, BillingCountry, BillingState, Billing_Country__c, Billing_State__c, 
            	ShippingCountry, ShippingState, Shipping_Country__c, Shipping_State__c,
            	BillToContact.MailingCountry, BillToContact.MailingState, BillToContact.Mailing_Country__c, BillToContact.Mailing_State__c,
            	ShipToContact.MailingCountry, ShipToContact.MailingState, ShipToContact.Mailing_Country__c, ShipToContact.Mailing_State__c
            FROM Order WHERE Id IN :orderIds];
        
        for (Order order: orders) {
            
            //validate billing address
            order.BillingCountry = isCountryValid(order.Billing_Country__c) ? order.Billing_Country__c : null;
            order.BillingState = order.BillingCountry != null && isStateValid(order.Billing_State__c) ? order.Billing_State__c : null;
            
            //validate Shipping address
			order.ShippingCountry = isCountryValid(order.Shipping_Country__c) ? order.Shipping_Country__c : null;
			order.ShippingState = order.ShippingCountry != null && isStateValid(order.Shipping_State__c) ? order.Shipping_State__c : null;
            
            //validate Contacts address
            Set<Contact> setContacts = new Set<Contact>();
            if(order.BillToContact != null) 
                setContacts.add(order.BillToContact);
            
            if(order.ShipToContact != null) 
                setContacts.add(order.ShipToContact);
            
            for (Contact contact : setContacts) {                
                contact.MailingCountry = isCountryValid(contact.Mailing_Country__c) ? contact.Mailing_Country__c : null;
                contact.MailingState = contact.MailingCountry != null && isStateValid(contact.Mailing_State__c) ? contact.Mailing_State__c : null;                
            }
            
            List<Contact> contacts = new List<Contact>(setContacts);
            
            Update contacts;			
        }
        
        Update orders;
    }
    
    private static boolean isCountryValid(string countryName) {
        return isCountryOrStateValid(COUNTRY, countryName);
    }
    
    private static boolean isStateValid(string stateName) {
        return isCountryOrStateValid(STATE, stateName);
    }
    
	private static boolean isCountryOrStateValid(string infoType, string name) {
        
        Boolean result = false;
        Schema.DescribeFieldResult fieldResult = infoType == COUNTRY ? User.Countrycode.getDescribe() : User.statecode.getDescribe();
               
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for(Schema.PicklistEntry f : ple){
            if(f.getLabel() == name) { 
                result = true;   
                break;
            }
        }
        
        return result;
	} 
}
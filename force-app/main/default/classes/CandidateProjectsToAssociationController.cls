public class CandidateProjectsToAssociationController {
    @AuraEnabled
    public static List<SuggestedProjectAssociation> getProjectSuggestions(Id orderId) {
        Order order = [SELECT Id, Name, EffectiveDate, AccountId, BillingStreet, ShippingStreet, Deal_ID__c, DPID__c, PoNumber, CustomerNumber__c, Project__r.Id FROM Order WHERE ID = :orderId];
        ProjectOrdersAssociationSuggestions project = new ProjectOrdersAssociationSuggestions();

        return project.aksAdviserThereSugestions(order);
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = 
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Order'];
    
        // Perform isAccessible() check here
        return listviews;
    }
}
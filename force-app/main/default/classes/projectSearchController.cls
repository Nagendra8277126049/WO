public class projectSearchController {
	@AuraEnabled
	public static List<pse__Proj__c> searchProjects(String orderNumber, String projectName, String poNumber,
                                                    String customerName, String dealId, String dateCreatedStart,
                                                    String dateCreatedEnd, List<String> orderIds) {
		orderNumber = String.isNotBlank(orderNumber) ? '%' + orderNumber + '%' : '-1';
		projectName = String.isNotBlank(projectName) ? '%' + projectName + '%' : '-1';
		poNumber = String.isNotBlank(poNumber) ? '%' + poNumber + '%' : '-1';
        customerName = String.isNotBlank(customerName) ? '%' + customerName + '%' : '-1';    	  
        dealId = String.isNotBlank(dealId) ? '%' + dealId + '%' : '-1';                                          
        Date dateStart = String.isNotBlank(dateCreatedStart) ? Date.valueOf(dateCreatedStart) : Date.today();
        Date dateEnd = String.isNotBlank(dateCreatedEnd) ? Date.valueOf(dateCreatedEnd) : Date.today();
                                                        
		List<Id> projectIdsRelatedToOrders = new List<Id>();
		for(Order order : [SELECT Id, Project__c from Order 
                           WHERE OrderNumber LIKE: orderNumber
                           OR OrderNumber__c LIKE: orderNumber
                           OR PoNumber LIKE: poNumber
                           OR Deal_ID__c LIKE: dealId]){
			projectIdsRelatedToOrders.Add(order.Project__c);
		}
                                                        
        List<Id> accountIds = new List<Id>();
		for(Account account : [SELECT Id from Account 
                           WHERE Name LIKE: customerName]){
			accountIds.Add(account.Id);
		}
                                                        
 		List<Order> lstOfOrders = [SELECT Id, CurrencyIsoCode from Order 
                                            WHERE Id IN: orderIds];
 		List<String> orderCurrencies = new List<String>();
		for (Order order: lstOfOrders) {
			orderCurrencies.add(order.CurrencyIsoCode);
		}
                                                        
		List<pse__Proj__c> returnList = new List<pse__Proj__c>();
		List<pse__Proj__c> lstOfProjects = [SELECT id, Name, CurrencyIsoCode from pse__Proj__c 
                                            WHERE CurrencyIsoCode IN :orderCurrencies
                                            AND (Name LIKE: projectName
                                            OR pse__Account__c IN: accountIds
                                            OR Id IN :projectIdsRelatedToOrders 
                                            OR (pse__Start_Date__c <=: dateEnd AND pse__Start_Date__c >=: dateStart))
                                            ORDER BY Name DESC NULLS LAST];
 
		for (pse__Proj__c project: lstOfProjects) {
			returnList.add(project);
		}
		return returnList;
	}
    
    @AuraEnabled
	public static String getOrderNumbers(List<String> orderIds) {
        List<Order> lstOfOrders = [SELECT Id, OrderNumber from Order 
                                            WHERE Id IN: orderIds
                                            ORDER BY OrderNumber ASC NULLS LAST];
 		List<String> orderNumbers = new List<String>();
		for (Order order: lstOfOrders) {
			orderNumbers.add(order.OrderNumber);
		}
		return String.join(orderNumbers, ', ');
	}
    
    @AuraEnabled
    public static Boolean associateOrdersToProject(List<String> orderIds, String projectId){
        for(String orderId : orderIds){
            Map<String, Object> params = new Map<String, Object>();
            params.put('OrderId', orderId);
            params.put('ProjectId', projectId);

            Flow.Interview flow = new Flow.Interview.Unassociate_Associate_Order_to_Project_Processing(params);
            flow.start();
        }
        
        return true;
    }
}
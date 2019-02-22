public class ProjectSearch {
    private string projClosedStage = 'Closure';
	private string projCancelledStage = 'Cancelled';
    
    public void GetProjectByOrderFilter(string orderFilter, Id orderId){
        string query = 'SELECT Id, (SELECT Project__r.Id FROM Project__r WHERE Project__r.pse__Stage__c != :projCancelledStage and Project__r.pse__Stage__c != :projClosedStage) FROM Order WHERE Id != :orderId AND ' + orderFilter;
        query = string.escapeSingleQuotes(query);
        
         List<sObject> test = Database.query(query);   
    }
}
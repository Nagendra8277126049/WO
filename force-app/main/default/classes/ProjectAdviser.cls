public abstract class ProjectAdviser {
    protected string reason;
    abstract List<Order> associatedOrders(Order order);
    
    public string getReason(){
        return reason;
    }
    
    public Map<Id, pse__Proj__c> getSuggestions(Order order){
        return cast(associatedOrders(order));
    }  
    
    private Map<Id, pse__Proj__c> cast(List<Order> toCast){
        Map<Id,pse__Proj__c> suggestionsMapped = new Map<Id,pse__Proj__c>();
        for(Order o : toCast){
            if(!suggestionsMapped.containsKey(o.Project__r.Id)){
                suggestionsMapped.put(o.Project__r.Id, o.Project__r);
            }
        }
        return suggestionsMapped;
    }
}
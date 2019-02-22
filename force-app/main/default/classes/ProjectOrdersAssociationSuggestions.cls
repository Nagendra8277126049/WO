public class ProjectOrdersAssociationSuggestions {
    protected List<ProjectAdviser> advisers;
    
    public ProjectOrdersAssociationSuggestions(){
        advisers = new List<ProjectAdviser>();
        advisers.add(new DPIDProjectAdviser());
        advisers.add(new DealIdProjectAdviser());
        advisers.add(new PoNumberProjectAdviser());
        advisers.add(new CustomerNumberProjectAdviser());
        advisers.add(new BillingAddressProjectAdviser());
        advisers.add(new ShippingAddressProjectAdviser());
    }
    
    public List<SuggestedProjectAssociation> aksAdviserThereSugestions(Order order){
        Id projId;
        Map<Id,SuggestedProjectAssociation> mapped =  new Map<Id,SuggestedProjectAssociation>();
        for(ProjectAdviser adviser : advisers){
            mergeSuggestions(mapped, adviser.getSuggestions(order), adviser.getReason());
        }
        if(mapped.containsKey(order.Project__r.Id)){
            mapped.remove(order.Project__r.Id);   
        }
        List<SuggestedProjectAssociation> suggestions = mapped.values();
        suggestions.sort();
        
        List<SuggestedProjectAssociation> returnValue = new List<SuggestedProjectAssociation>();
        integer maxItens = 5 < suggestions.size() ? 5 : suggestions.size();
        for(integer i = 0; i < maxItens; i++){
            returnValue.Add(suggestions.get(i));
        }
        return returnValue;
    }
    
    public Map<Id,SuggestedProjectAssociation> mergeSuggestions(Map<Id,SuggestedProjectAssociation> mapped, Map<Id,pse__Proj__c> newSugestions, string reason){
        for(Id projId : newSugestions.keySet()){
            if(mapped.containsKey(projId)){
                mapped.get(projId).addReason(reason);
            }
            else{
            	SuggestedProjectAssociation newSug = new SuggestedProjectAssociation();
                newSug.addReason(reason); 
            	newSug.project=newSugestions.get(projId);
            	mapped.put(projId,newSug);
            }
        }
        return mapped;
    }
}
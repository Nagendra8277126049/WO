public class DealIdProjectAdviser extends ProjectAdviser{
    public DealIdProjectAdviser(){
        super();
        reason = 'Deal Id';
    }
    private List<Order> associatedOrders(Order order){
        if(order.Deal_ID__c == null)
            return new List<Order>();
        return [SELECT proj.Id, orderS.Deal_ID__c, proj.Name, proj.pse__Stage__c, proj.pse__Project_Manager__r.Name , proj.pse__Account__r.Name, proj.pse__Start_Date__c, proj.pse__End_Date__c  
                from Order orderS, orderS.Project__r proj
                where proj.Id != null and orderS.Deal_ID__c = :order.Deal_ID__c and orderS.Id != :order.Id];
    }
}
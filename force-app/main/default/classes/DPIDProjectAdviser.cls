public class DPIDProjectAdviser extends ProjectAdviser{
    public DPIDProjectAdviser(){
        super();
        reason = 'DPID';
    }
    private List<Order> associatedOrders(Order order){
        if(order.DPID__c == null)
            return new List<Order>();
        return [SELECT proj.Id, o.DPID__c, proj.Name, proj.pse__Stage__c, proj.pse__Project_Manager__r.Name , proj.pse__Account__r.Name, proj.pse__Start_Date__c, proj.pse__End_Date__c                
                from Order o, o.Project__r proj
                where proj.pse__Stage__c not in ('Closure','Cancelled') and proj.Id != null and o.DPID__c = :order.DPID__c];
    }
}
public class CustomerNumberProjectAdviser extends ProjectAdviser{
    public CustomerNumberProjectAdviser(){
        super();
        reason = 'Customer Number';
    }
    private List<Order> associatedOrders(Order order){
        if(order.CustomerNumber__c == null && String.isEmpty(order.CustomerNumber__c))
            return new List<Order>();
        return [SELECT proj.Id, orderS.CustomerNumber__c, proj.Name, proj.pse__Stage__c, proj.pse__Project_Manager__r.Name , proj.pse__Account__r.Name, proj.pse__Start_Date__c, proj.pse__End_Date__c  
                from Order orderS, orderS.Project__r proj
                where proj.Id != null and orderS.CustomerNumber__c = :order.CustomerNumber__c and orderS.Id != :order.Id
                AND (Project__r.pse__Start_Date__c <= :order.EffectiveDate.addDays(30) AND Project__r.pse__End_Date__c >= :order.EffectiveDate.addDays(-30))];
    }
}
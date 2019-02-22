public class BillingAddressProjectAdviser extends ProjectAdviser{
    public BillingAddressProjectAdviser(){
        super();
        reason = 'Billing Address';
    }
    private List<Order> associatedOrders(Order order){
        if(order.CustomerNumber__c == null && String.isEmpty(order.CustomerNumber__c))
            return new List<Order>();
        return [SELECT proj.Id, proj.pse__Stage__c, proj.Name, proj.pse__Project_Manager__r.Name , proj.pse__Account__r.Name, proj.pse__Start_Date__c, proj.pse__End_Date__c  
                from Order orderS, orderS.Project__r proj
                where proj.Id != null and orderS.Id != :order.Id
                AND orderS.BillingStreet LIKE :'%'+order.BillingStreet+'%'];
    }
}
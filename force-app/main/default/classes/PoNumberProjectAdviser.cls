public class PoNumberProjectAdviser extends ProjectAdviser{
        public PoNumberProjectAdviser(){
            super();
            reason = 'PO Number';
        }
        private List<Order> associatedOrders(Order order){
            if(order.PoNumber == null && String.isEmpty(order.PoNumber))
                return new List<Order>();
            return [SELECT proj.Id, orderS.PoNumber, proj.Name, proj.pse__Stage__c, proj.pse__Project_Manager__r.Name , proj.pse__Account__r.Name, proj.pse__Start_Date__c, proj.pse__End_Date__c  
					from Order orderS, orderS.Project__r proj
					where proj.Id != null and orderS.PoNumber = :order.PoNumber and orderS.Id != :order.Id];
        }
}
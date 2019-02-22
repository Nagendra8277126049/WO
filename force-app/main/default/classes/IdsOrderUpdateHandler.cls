public class IdsOrderUpdateHandler {
    public static void HandleUpdate(List<Order> newOrders, List<Order> oldOrders){
        List<Id> updatedProjects = new List<Id>();
        List<Id> ordersNewlyAssociated = new List<Id>();
        List<Id> ordersCancelledOrReassociated = new List<Id>();
        List<Id> reassociatedOrdersProject = new List<Id>();
        
        for(Order newOrder : newOrders){
            for(Order oldOrder : oldOrders){
                //If the current newOrder and oldOrder are not the same, go to next oldOrder
                if(newOrder.Id != oldOrder.Id){                    continue;                }
                
                //If the order milestone has been changed
                if(newOrder.Milestone__c != oldOrder.Milestone__c){                    System.debug('Order Milestone Updated');                    if(newOrder.Project__c != null && !updatedProjects.Contains(newOrder.Project__c)){                        updatedProjects.add(newOrder.Project__c);
                    }                }                 //If the order has been cancelled
                if(newOrder.Status != oldOrder.Status && (newOrder.Status == 'Cancelled' || newOrder.Status == 'CL')){    if(newOrder.Project__c != null && !updatedProjects.Contains(newOrder.Project__c)){                        updatedProjects.add(newOrder.Project__c);                    }                                        ordersCancelledOrReassociated.add(newOrder.Id);
                }
                
                if(newOrder.Project__c != oldOrder.Project__c) {                    if(!updatedProjects.contains(oldOrder.Project__c) && oldOrder.Project__c != null) {                        updatedProjects.add(oldOrder.Project__c);                    }if(!updatedProjects.contains(newOrder.Project__c) && newOrder.Project__c != null) {                        updatedProjects.add(newOrder.Project__c);                    } if(oldOrder.Project__c != NULL) {                        ordersCancelledOrReassociated.add(oldOrder.Id);                        reassociatedOrdersProject.add(oldOrder.Project__c);                    }                    else {                        if(!ordersNewlyAssociated.contains(newOrder.Id)) {                            ordersNewlyAssociated.add(newOrder.Id);
                        }                    }                }            }        }        
        System.debug('Number of Projects to update: ' + updatedProjects.size());
        UpdateProjectMilestonesAmount(updatedProjects);
        ResourceRequestSkillAutomator.UpdateSkillsFromSkuMapping(ordersNewlyAssociated, ordersCancelledOrReassociated, reassociatedOrdersProject);
    }

    public static void HandleStatusUpdate(List<Order> newOrders, List<Order> oldOrders, List<Custom_Order_Status_to_Order_Status_Map__mdt> maps){
        Map<String,Custom_Order_Status_to_Order_Status_Map__mdt> statusByNameMap = new Map<String,Custom_Order_Status_to_Order_Status_Map__mdt>();
        Map<String,Custom_Order_Status_to_Order_Status_Map__mdt> statusByCustomNameMap = new Map<String, Custom_Order_Status_to_Order_Status_Map__mdt>();
        
    	for(Custom_Order_Status_to_Order_Status_Map__mdt mapping : maps){
        	statusByCustomNameMap.put(mapping.Custom_Status__c,mapping);
            statusByNameMap.put(mapping.Order_Status__c,mapping);
    	}
        
        for(Order newOrder : newOrders){
            for(Order oldOrder : oldOrders){
                if(newOrder.Id == oldOrder.Id){
                    if (newOrder.Status != oldOrder.Status) {                        newOrder.Order_Status__c = newOrder.Status;
                    }
                    switch on newOrder.Order_Status__c {
                        when 'POD'{                            if(newOrder.Delivered_Date__c == null)                                newOrder.Delivered_Date__c = newOrder.Status_Date_Time__c;
                        }
                        when 'RDD' {                            newOrder.Estimated_Delivery_Date__c = newOrder.RDD_Date__c;
                        }
                        when else {
                            Custom_Order_Status_to_Order_Status_Map__mdt orderStatusUpdate = statusByCustomNameMap.get(newOrder.Order_Status__c);
                            Custom_Order_Status_to_Order_Status_Map__mdt oldOrderStatus = statusByNameMap.get(oldOrder.Status);
                            
                            if(orderStatusUpdate != null && newOrder.Order_Status__c == orderStatusUpdate.Custom_Status__c && oldOrderStatus.Status_Order__c < orderStatusUpdate.Status_Order__c) {                                newOrder.Status = orderStatusUpdate.Order_Status__c;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void UpdateProjectMilestonesAmount(List<Id> projectIds){
        System.debug('Update Project Milestones Started');
        System.debug('Number of Projects to upadte: ' + projectIds.size());
        for(Id projectId : projectIds){
            System.debug('Project: ' + projectId);
        }
        //Get All Projects information
        Map<Id, pse__proj__c> projects = new Map<Id, pse__proj__c>([SELECT Id, pse__Practice__c FROM pse__proj__c WHERE Id IN :projectIds]);
        
        //Get All Orders related to projects information
        Map<Id, Order> orders = new Map<Id, Order>([SELECT Id, Project__c, Milestone__c, Status FROM Order WHERE Project__c IN :projectIds]);
        
        //Get all Milestones related to projects information
        Map<Id, pse__Milestone__c> milestones = new Map<Id, pse__Milestone__c>([SELECt Id, pse__Project__c, pse__Milestone_Amount__c FROM pse__Milestone__c WHERE pse__Project__c IN :projectIds]);
        
        for(pse__Milestone__c milestone : milestones.values()){            milestone.pse__Milestone_Amount__c = 0;
        }
        
        List<Id> orderIds = new List<Id>();
        for(Order order : orders.values()){            orderIds.add(order.Id);
        }
        
        //Get all order items related to orders
        List<OrderItem> orderItems = [SELECT Id, OrderId, Item_Class_Description__c, TotalPrice FROM OrderItem WHERE OrderId IN :orderIds];
        
        List<Id> practiceIds = new List<Id>();
        for(pse__proj__c project : projects.values()){            practiceIds.add(project.pse__Practice__c);
        }
        
        //Get all item classes related to projects
        List<Item_Class__c> itemClasses = [SELECT Id, Practice__c, Item_Class_Description__c FROM Item_Class__c WHERE Practice__c IN :practiceIds];
        
        for(OrderItem orderItem : orderItems){            Order order = orders.get(orderItem.OrderId);            if(order.Status == 'Cancelled' || order.Status == 'CL'){                continue;            }if(projects.containsKey(order.Project__c)){                pse__Proj__c project = projects.get(order.Project__c);                for(Item_Class__c itemClass : itemClasses){                    if(orderItem.Item_Class_Description__c != itemClass.Item_Class_Description__c){                        continue;                   }if(milestones.containsKey(order.Milestone__c)){                		pse__Milestone__c milestone = milestones.get(order.Milestone__c);                        if(orderItem.TotalPrice <= 0){                            continue;                        }                		milestone.pse__Milestone_Amount__c = milestone.pse__Milestone_Amount__c + orderItem.TotalPrice;
            		}
                }
            }
        }
        
        update(milestones.values());
    }
}
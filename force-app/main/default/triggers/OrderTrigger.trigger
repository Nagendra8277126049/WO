trigger OrderTrigger on Order (after update, before update, before insert) {
    if(Trigger.isAfter && Trigger.isUpdate){
        IdsOrderUpdateHandler.HandleUpdate(Trigger.new, Trigger.old);
    }


    Custom_Order_Status_to_Order_Status_Map__mdt[] statusMappings =
    [SELECT Custom_Status__c, Order_Status__c, Status_Order__c FROM Custom_Order_Status_to_Order_Status_Map__mdt];
    Map<String,Custom_Order_Status_to_Order_Status_Map__mdt> statusMap = new Map<String, Custom_Order_Status_to_Order_Status_Map__mdt>();
    for(Custom_Order_Status_to_Order_Status_Map__mdt mapping : statusMappings){
        statusMap.put(mapping.Custom_Status__c,mapping);
    }

    if(Trigger.isInsert && Trigger.isBefore){
        for(Order newOrder : Trigger.new){
            Custom_Order_Status_to_Order_Status_Map__mdt orderStatus = statusMap.get(newOrder.Order_Status__c);
            //for(Custom_Order_Status_to_Order_Status_Map__mdt mapping : statusMappings){
                if(orderStatus != null && newOrder.Order_Status__c == orderStatus.Custom_Status__c){

                    newOrder.Order_Status__c = orderStatus.Order_Status__c;
                }
            //}
        }
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        IdsOrderUpdateHandler.HandleStatusUpdate(Trigger.new, Trigger.old, statusMappings);
    }
}
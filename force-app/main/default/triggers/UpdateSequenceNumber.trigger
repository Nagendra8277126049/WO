trigger UpdateSequenceNumber on WorkOrderLineItem (after insert,after Delete,after update)
{
    
    List<WorkOrderLineItem> updatedWorkLineItemList= new List<WorkOrderLineItem>();
    List<WorkOrder> workOrderlist= new List<WorkOrder>();
    
    Set<Id> WorkOrderIds= new Set<Id>();
    If((Trigger.Isafter && Trigger.isInsert) || (Trigger.Isafter && Trigger.isUpdate))
    {
        for(WorkOrderLineItem wl : Trigger.new)
        {
            WorkOrderIds.add(wl.WorkOrderId);
        }
        If(workOrderIds.size()>0)
        {
            WorkOrderLineItemTriggerHelper.updateSequenceNumberHelper(WorkOrderIds);
        }
        
    }
    If(Trigger.Isafter && Trigger.IsDelete)
    {
       
        Set<id> workOrderIds = new Set<Id>();
        for(WorkOrderLineItem wl : Trigger.old)
        {
            System.debug('>>>>wl Id'+wl.id);
            System.debug('>>> workOrderId'+wl.WorkOrderId);
            workOrderIds.add(wl.WorkOrderId);
        }
        If(workOrderIds.size()>0)
        {
            WorkOrderLineItemTriggerHelper.updateSequenceNumberHelper(WorkOrderIds);
        }
        WorkOrderLineItemTriggerHelper.deleteInfoparts(Trigger.old);//this will delete the related InfoPartswhenever Required
        WorkOrderLineItemTriggerHelper.deleteAutoAddedCFIParts(Trigger.old); 
    }
}
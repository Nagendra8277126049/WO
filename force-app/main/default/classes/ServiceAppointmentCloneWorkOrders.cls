/*
      Purpose:
            Clone related work orders and work order skills from Service Appointment when status is 'Cannot Complete'
            
      Author    : Pawan Kumar
      Company   : OAC Services INC.
      Created   : 1/8/19

    =============================================================================================================
    Modification History:
    ----------------------------------------------------------------------------
    Name        Date        Company             Description
    ----------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
*/

public class ServiceAppointmentCloneWorkOrders 
{
    public static void cloneWorkOrders( set<Id> workOrderIds )
    {
        //------------------------------------------------------------
            list<WorkOrder> listWO = new list<WorkOrder>();
        //------------------------------------------------------------
        
        //Get Work Orders
        if(!workOrderIds.isEmpty())
        {
            listWO = getWorkOrders(workOrderIds);
        }
        system.debug('workOrderIds '+workOrderIds);
        system.debug('WO '+listWO);
        
        //clone work orders and work order skills
        if( !listWO.isEmpty() )
        {
            runWorkOrderCloning(listWO);
        }
    }
    
    public static void runWorkOrderCloning( list<WorkOrder> listWO )
    {
        //------------------------------------------------------------
            map<Id,WorkOrder> mapClonedWOs = new map<Id,WorkOrder>();
            list<Work_Order_Skill__c> clonedWOS = new list<Work_Order_Skill__c>();
            WorkOrder newWO;
            Work_Order_Skill__c newWOS;
        //------------------------------------------------------------
        
        for( WorkOrder objWO : listWO )
        {
            newWO = objWO.clone(false);
            mapClonedWOs.put(objWO.Id,newWO);
        }
        
        //insert Cloned WO's
        database.insert(mapClonedWOs.values(),true);
        
        system.debug('Cloned WO '+mapClonedWOs);
        
        //Cloning Work Order Skills
        for(WorkOrder objWO : listWO)
        {
            if(mapClonedWOs != NULL && mapClonedWOs.get(objWO.Id) != NULL && mapClonedWOs.get(objWO.Id).Id != NULL)
            {
                for(Work_Order_Skill__c objWOS : objWO.Work_Orders_Skills__r)
                {
                    newWOS = objWOS.clone(false);
                    newWOS.Work_Order__c = mapClonedWOs.get(objWO.Id).Id;
                    clonedWOS.add(newWOS);
                }
            }
        }
        
        //insert Cloned WOS
        database.insert(clonedWOS,true);
        system.debug('WOS '+clonedWOS);
    }
    
    public static list<WorkOrder> getWorkOrders( set<Id> workOrderIds)
    {
        //Get list of Work Orders and Work Order Items along with fields to be cloned
        
        list<WorkOrder> listWO = [SELECT Id,
                                            Address,
                                            Duration,
                                            WorkTypeId,
                                            Delivery_Method__c,
                                            Schedule_Type__c,
                                            Resource_Type__c,
                                            Description,
                                            CurrencyIsoCode,
                                            AccountId,
                                            Project_Task__c,
                                            OwnerId,
                                            recordTypeId,
                                            (
                                                SELECT Id,Name, 
                                                    OwnerId,
                                                    Skill_Certification__c,
                                                    CurrencyIsoCode
                                                FROM Work_Orders_Skills__r
                                            )
                                    FROM WorkOrder
                                    WHERE Id IN: workOrderIds];
        system.debug('listWO '+listWO);
        
        return listWO;
        
    }
}
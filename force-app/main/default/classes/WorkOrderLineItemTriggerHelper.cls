/* -----------------------------------------------------------------------------------------------------------------------
Name:       WorkOrderLineItemTriggerHelper 
Description:  contains all the auraenabled methods which are used to update sequence number and delete line item
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
08/06/2018    1.0          Amit Datta       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public class WorkOrderLineItemTriggerHelper{

  
public static  boolean CheckforUpdate= false ;
public static boolean deleteCFIPart = true;
            /*
                Description : This method update sequence number in the WorkOrderLineItem
            */
            public static void updateSequenceNumberHelper(Set<Id> workOrderIds)
            {
            if(CheckforUpdate== false)
            {
            CheckforUpdate=true;
            List<WorkOrderLineItem> updatedWorkLineItemList= new List<WorkOrderLineItem>();
            List<WorkOrder> workOrderlist= new List<WorkOrder>();
               for(WorkOrder w : [Select Id,(Select Id,Sequence_Number__c, Selected_By_user__c from WorkOrderLineItems where Selected_By_user__c =true and Selected_Work_Order__c!=null  order by LineItemNumber) from WorkOrder where id in : WorkOrderIds])
                  {
                             integer sqno = 1;
                                for(WorkOrderLineItem wl : w.WorkOrderLineItems)
                                {
                                    wl.Sequence_Number__c= sqno;
                                     sqno=sqno+1;
                                    updatedWorkLineItemList.add(wl);
                                    
                                }
                   }
                   if(!updatedWorkLineItemList.isEmpty())
                   {
                    update updatedWorkLineItemList;
                   }
                 }
            }
            
            /*
                Description : This method delete WorkOrderLineItem
            */
            public static void deleteInfoparts(List<WorkOrderLineItem> deleteLineItemListOld){
                List<WorkOrderLineItem>deleteLineItemList=new List<WorkOrderLineItem>();
                for(WorkOrderLineItem wl : deleteLineItemListOld){
                    if(wl.Selected_Work_Order__c!=null){                       
                        deleteLineItemList.add(wl);
                    }
                }
                Set<Id> workOrderIds= new Set<Id>();
                Set<Id> workOrderIdsWithHardDrive= new Set<Id>();
                List<WorkOrderLineItem> deleteWorkOrderLineItems= new List<WorkOrderLineItem>();
                List<Dispatch_Alert__c > deleteDispatchAlert =new List<Dispatch_Alert__c >();
                List<Dispatch_Alert__c > createDispatchAlert=new List<Dispatch_Alert__c >();
                List<Customer_Reminder__c> deleteCustomerReminder=new List<Customer_Reminder__c >();
                List<WorkOrder> updateWorkOrderList=new List<WorkOrder>();
                Boolean checkRemainingBattery=true; 
                Id groundShipmentWorkOrderId;               
                try{
                if(!deleteLineItemList.isempty()){
                    for(WorkOrderLineItem wl : deleteLineItemList){                        
                        if((wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && wl.PartCommodity__c.containsIgnoreCase('HARD DRIVE'))||(wl.SubComponent__c !=null && wl.SubComponent__c !='' && wl.SubComponent__c.containsIgnoreCase('HARD DRIVE')) && wl.Selected_Work_Order__c!=null ){
                            workOrderIds.add(wl.WorkOrderId);
                        }
                        if((wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && wl.PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE'))||(wl.SubComponent__c !=null && wl.SubComponent__c !='' && wl.SubComponent__c.containsIgnoreCase('SOLID STATE DRIVE')) && wl.Selected_Work_Order__c!=null ){
                            workOrderIds.add(wl.WorkOrderId);
                        }   
                        //akhil : check deleted batteries
                        if(wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && wl.PartCommodity__c.containsIgnoreCase('BATTERY')&& wl.Selected_Work_Order__c!=null ){                           
                            checkRemainingBattery=false;
                            workOrderIds.add(wl.WorkOrderId);
                            groundShipmentWorkOrderId = wl.WorkOrderId;
                        }
                    }
                    if(!workOrderIds.isempty()){
                        List<WorkOrderLineItem>remainingLineItemList=[Select Id,PartCommodity__c,Line_Item_Type__c,workOrderId,SubComponent__c,Selected_Work_Order__c from WorkOrderLineItem where workOrderId in :workOrderIds and Id not in :deleteLineItemList];
                        //system.debug('remainingLineItemList>>>'+remainingLineItemList);
                        if(!remainingLineItemList.isempty()){                           
                            for(WorkOrderLineItem wl : remainingLineItemList){
                                if(wl.Line_Item_Type__c != null && wl.Line_Item_Type__c!='' && !wl.Line_Item_Type__c.containsIgnoreCase('Info Parts-Hard Drive') && wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && (wl.PartCommodity__c.containsIgnoreCase('HARD DRIVE')|| wl.PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE') )){
                                    workOrderIdsWithHardDrive.add(wl.workOrderId);
                                }
                                
                                //akhil : to check whether there are any batteries. if there is a battery, then set the flag to true.
                                if(wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && wl.PartCommodity__c.containsIgnoreCase('BATTERY')&& wl.Selected_Work_Order__c!=null ){
                                    checkRemainingBattery = true;                                   
                                }
                                
                            }                                                       
                            
                            if(!workOrderIdsWithHardDrive.isempty()){
                                workOrderIds.removeAll(workOrderIdsWithHardDrive);
                            }
                            //system.debug('workOrderIds>>>'+workOrderIds);
                            if(!workOrderIds.isempty()){
                                for(WorkOrderLineItem wl : remainingLineItemList){
                                    if(wl.Line_Item_Type__c != null && wl.Line_Item_Type__c!='' && wl.Line_Item_Type__c.containsIgnoreCase('Info Parts-Hard Drive') && workOrderIds.contains(wl.workOrderId)){
                                        deleteWorkOrderLineItems.add(wl);
                                    }
                                }
                                //system.debug('deleteWorkOrderLineItems>>>'+deleteWorkOrderLineItems);
                                List<Dispatch_Alert__c> DispatchAlert =[select Id,Alert_Reason__c from Dispatch_Alert__c where Work_Order__c in :workOrderIds ];
                                //system.debug('DispatchAlert >>>'+DispatchAlert );
                                if(!DispatchAlert.isempty()){
                                    for(Dispatch_Alert__c disp : DispatchAlert  ){
                                        if(disp.Alert_Reason__c !=null && disp.Alert_Reason__c!='' && disp.Alert_Reason__c.containsIgnoreCase('Info Parts Hard Drive')){
                                            deleteDispatchAlert.add(disp);
                                        }
                                    }                                   
                                }
                            }
                            //system.debug('deleteWorkOrderLineItems>>>'+deleteWorkOrderLineItems);
                            If(!deleteWorkOrderLineItems.isempty() && deleteWorkOrderLineItems<>NULL){
                                Delete deleteWorkOrderLineItems;
                            }
                        }
                            //akhil : if no remaining battery then create alert and update workorkder. 
                            if(!checkRemainingBattery)
                            {
                                List<WorkOrder> workOrderobjList = [Select Id,Override_Ground_Shipment__c,Ground_Shipment_Flag__c from WorkOrder where Id=:groundShipmentWorkOrderId];
                                
                                if(workOrderobjList[0].Ground_Shipment_Flag__c){
                                    
                                    //akhil.add the logic to create alert.
                                    Dispatch_Alert__c DAlert = new Dispatch_Alert__c(Name='Battery is Removed',Alert_Details__c='You Removed the battery from this work order, so it will be sent via default shipping',Work_Order__c=groundShipmentWorkOrderId,Alert_Reason__c='Ground Shipment Battery Delete');
                                    createDispatchAlert.add(DAlert);                                    
                                    
                                    //akhil:update work order
                                    workOrderobjList[0].Ground_Shipment_Flag__c=false;
                                    workOrderobjList[0].Override_Ground_Shipment__c=false;
                                    updateWorkOrderList.add(workOrderobjList[0]);                                   
                                    
                                    //akhil:Query to remove alert 
                                    List<Dispatch_Alert__c> groundShipmentDispatchAlert =[select Id,Alert_Reason__c from Dispatch_Alert__c where Work_Order__c=:groundShipmentWorkOrderId and Alert_Reason__c='Ground Shipment Battery'];
                                    if(groundShipmentDispatchAlert <> NULL && !groundShipmentDispatchAlert.isEmpty()){
                                    deleteDispatchAlert.addAll(groundShipmentDispatchAlert);
                                    }
                                    //akhil:Query to remove Custom Reminder.
                                     deleteCustomerReminder = [Select Id,Type__c,Work_Order__c from Customer_Reminder__c where Work_Order__c=:groundShipmentWorkOrderId and Type__c='Ground Shipment Flag'];                                     
                                     
                                     //akhil:DML statements
                                    If(!deleteCustomerReminder.isempty()&&deleteCustomerReminder<>NULL){                                            
                                            Delete deleteCustomerReminder;
                                    }                           
                                    If(!updateWorkOrderList.isempty()&&updateWorkOrderList<>NULL){                                      
                                            Database.update(updateWorkOrderList);
                                    }
                                    If(!createDispatchAlert.isempty()&&createDispatchAlert<>NULL){
                                        Database.insert(createDispatchAlert);
                                    }
                                }
                            }
                            
                            //system.debug('deleteDispatchAlert >>>'+deleteDispatchAlert);
                            if(!deleteDispatchAlert.isempty() && deleteDispatchAlert<>NULL){
                                delete deleteDispatchAlert;
                            }
                            
                    }
                }
                }
                catch (exception ex){
                    ExceptionHandler.logHandledExceptions(ex,'WorkOrderLineItemTriggerHelper','deleteInfoparts','Dispatch');
                }
            }
            // MB: below method needs to be bulkified in further releases
            public static void deleteAutoAddedCFIParts(List<WorkOrderLineItem> hDOrSSDPartsList){
                
                
                if(null != hDOrSSDPartsList && hDOrSSDPartsList.size() > 0){
                    
                    String callType = hDOrSSDPartsList[0].Line_Item_Type__c;
                    string woId = hDOrSSDPartsList[0].WorkOrderId;
                    Boolean deleteIfLastHDorSSDReached = false;
                    Integer countOfDeletedHDOrSSDParts = 0;
                    List<WorkOrderLineItem> allHDOrSSDList = new List<WorkOrderLineItem>();
                    
                    allHDOrSSDList = [Select Id, PartCommodity__c, SubComponent__c, Selected_Work_Order__c, Selected_By_User__c, CFI_ON_Work_Order__c   
                    from WorkOrderLineItem where ((PartCommodity__c LIKE  '%HARD DRIVE%' OR SubComponent__c LIKE '%HARD DRIVE%')  OR (PartCommodity__c LIKE '%SOLID STATE DRIVE%' OR SubComponent__c LIKE '%SOLID STATE DRIVE%') )
                    AND WorkOrderId = :woId AND Selected_By_User__c = true AND Selected_Work_Order__c != null AND Line_Item_Type__c LIKE :'%'+calltype ];
                    
                    system.debug('allHDOrSSDList  ###'+allHDOrSSDList);
                    
                    List<WorkOrderLineItem> autoAddedCFIPartsList = [Select Id from WorkOrderLineItem where PartNumber__c LIKE :'57906%' AND  workOrderId = :woId  AND Dont_delete_on_bulk_deletion__c = true AND Line_Item_Type__c LIKE :'%'+callType ];
                    system.debug('deleteIfLastHDorSSDReached ###'+deleteIfLastHDorSSDReached );
                    
                    
                   if(allHDOrSSDList.size() == 0 && 
 
 
                     (((String.isNotBlank(hDOrSSDPartsList[0].PartCommodity__c) && hDOrSSDPartsList[0].PartCommodity__c.containsIgnoreCase('HARD DRIVE'))
                    
                     || (String.isnotBlank(hDOrSSDPartsList[0].SubComponent__c) && hDOrSSDPartsList[0].SubComponent__c.containsIgnoreCase('HARD DRIVE'))) ||
                                            
                     ((String.isnotBlank(hDOrSSDPartsList[0].PartCommodity__c) && hDOrSSDPartsList[0].PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE')) 
                     
                     || (String.isnotBlank(hDOrSSDPartsList[0].SubComponent__c) && hDOrSSDPartsList[0].SubComponent__c.containsIgnoreCase('SOLID STATE DRIVE'))))
                      
                      && hDOrSSDPartsList[0].Selected_Work_Order__c != null && hDOrSSDPartsList[0].Selected_By_User__c == true && hDOrSSDPartsList[0].CFI_ON_Work_Order__c == true ){    
                           
                           deleteIfLastHDorSSDReached = true;
                    }
                    
                    else if(allHDOrSSDList.size() > 1 && 
 
 
                     (((String.isNotBlank(hDOrSSDPartsList[0].PartCommodity__c) && hDOrSSDPartsList[0].PartCommodity__c.containsIgnoreCase('HARD DRIVE'))
                    
                     || (String.isnotBlank(hDOrSSDPartsList[0].SubComponent__c) && hDOrSSDPartsList[0].SubComponent__c.containsIgnoreCase('HARD DRIVE'))) ||
                                            
                     ((String.isnotBlank(hDOrSSDPartsList[0].PartCommodity__c) && hDOrSSDPartsList[0].PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE')) 
                     
                     || (String.isnotBlank(hDOrSSDPartsList[0].SubComponent__c) && hDOrSSDPartsList[0].SubComponent__c.containsIgnoreCase('SOLID STATE DRIVE'))))
                      
                      && hDOrSSDPartsList[0].Selected_Work_Order__c != null && hDOrSSDPartsList[0].Selected_By_User__c == true && hDOrSSDPartsList[0].CFI_ON_Work_Order__c == true
                      
                      && autoAddedCFIPartsList != null && autoAddedCFIPartsList.size() > 1){    
                           
                           deleteIfLastHDorSSDReached = true;
                    }
                    
                    system.debug('deleteIfLastHDorSSDReached ### '+deleteIfLastHDorSSDReached );
                    
                    if(null != autoAddedCFIPartsList  && autoAddedCFIPartsList.size() > 0 && deleteCFIPart && deleteIfLastHDorSSDReached )
                        delete autoAddedCFIPartsList[0];
                }
         }
}
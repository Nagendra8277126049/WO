/* -----------------------------------------------------------------------------------------------------------------------
Name:       Dispatch_LineItemEditController 
Description:  contains all the auraenabled methods which are used in the lightning component
              (work order line item edit button override)
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
24/04/2018    1.0          Megha Bhardwaj        Initial Release
-------------------------------------------------------------------------------------------------------------------------- */

public class Dispatch_LineItemEditController {
    /*
    Description : This method returns the WorkOrderLineItem for the particular lineItem
    */
    @AuraEnabled
    public static WorkOrderLineItem fetchworkOrderLineItem ( String lineItemId ){
        
        try{
        
            List<WorkOrderLineItem> workOrderLineItemList = [Select Id,PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FunctionalDescription__c,Image_Url__c,
                                                                WorkOrderId,Selected_Work_Order__c,Do_not_Sub__c, ServiceBUID__c, ServiceTag__c,Valid_Parts__c,Validate_Parts_Response__c, Quantity, Part_Quantity__c,Return_Qty__c,InventoryStatus__c, WorkOrder.DPS_Region__c from workorderlineitem  where Id = : lineItemId LIMIT 100];
            if(null != workOrderLineItemList && workOrderLineItemList.size() > 0)
                return workOrderLineItemList[0];
            else 
                return null;
        }
        catch(Exception ex){
             system.debug('Exception occurred @@@'+ex.getMessage());
             return null;
         }
    }
    
    /*
    Description : This method Validates the WorkOrderLineItem based on the CallType and return the lineItemList
    */
    @AuraEnabled
    public static AutoSelectPartController.workorderLineItemWrapper validateWorkOrderLineItem ( WorkOrderLineItem lineItem ){
        
         try{
             List<WorkOrderLineItem> workOrderLineItemList = new List<WorkOrderLineItem>();
             workOrderLineItemList.add(lineItem);
             List<AutoSelectPartController.workorderLineItemWrapper> lineItemListListReturned = AutoSelectPartController.validateSelectedParts(workOrderLineItemList,true,'MPS',false);
             if(null != lineItemListListReturned  && lineItemListListReturned.size() > 0)
                 return lineItemListListReturned[0];
             else
                 return null;
         }
         catch(Exception ex){
             system.debug('Exception occurred @@@'+ex.getMessage());
             return null;
         }
    }
    /*
    Description : This method saves the WorkOrderLineItem
    */
    @AuraEnabled
    public static string saveLineItem( WorkOrderLineItem lineItem ){
        
        try{
            update lineItem;
            return 'SUCCESS';
         }
         catch(Exception ex){
             system.debug('Exception occurred @@@'+ex.getMessage());
             return null;
         }
    }
}
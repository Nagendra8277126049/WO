public with sharing class DispatchReturnedPartController {
    
    public class customException extends Exception {}
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:         getReturnedParts
    Description:  This method query returned parts - User story:5535030
	Developer: Harsha 09/25/2018
    ----------------------------------------------------------------------------------------------------------------- */
	@AuraEnabled(cacheable=true)
    public static list<DispatchPartsOrderLine__c> getReturnedParts(string workOrderId) {
        list<DispatchPartsOrderLine__c> dispatchPartsOrderLineList = new List<DispatchPartsOrderLine__c>();
        try{
            if(string.isNOtBlank(workOrderId)){
                dispatchPartsOrderLineList = [SELECT ISP_Part__c,ISP_Description__c,ISP_Qty__c,ISP_Return_Date__c,
                                              ISP_Service_Tag__c,ISP_UserName__c,ISP_Unit_Price__c,
                                              ISP_Waybill__c,ISP_Carrier__c,Part__r.PartDescription__c,Part__r.PartPrice__c,Part__r.URLLInk__c
                                              FROM DispatchPartsOrderLine__c 
                                              WHERE Work_Order__c=:workOrderId AND ISP_Status__c='RETURNED' LIMIT 1000];
                
            } else {
                throw new customException('Input Param - WorkOrderId is Blank');
            }
            return dispatchPartsOrderLineList;
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchDefaultDetailsController','getReturnedParts','Dispatch Management');
            return dispatchPartsOrderLineList;
        }
	}
}
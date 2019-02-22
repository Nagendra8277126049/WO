/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchExceptionTriggerHandler
Description:  This class contain method that handles dispatch exception trigger - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public class DispatchExceptionTriggerHandler {
	private static List < DispatchETMSetup__c > etmList;
    @TestVisible
	public static void performStatusUpdate(Map<Id,DispatchException__c> oldMap, Map<Id,DispatchException__c> newMap)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       performStatusUpdate
    Description:  this function contains the logic of status transition update
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
	09/01/2018     1.0     Rodrigo Carpio    Initial Release
	-------------------------------------------------------------------------------------------------------------------------- */
    {
        try {            
            string sMessageType;
            string dlpExceptionCode;
            etmList = new List<DispatchETMSetup__c>();
            
            List <WorkOrder> woDetailList = new List <WorkOrder>();
            
            WorkOrder woDetail = new WorkOrder();
            List<WorkOrder> woToBeUpdated = new List<WorkOrder>();
            List<DispatchPartsOrderLine__c> woLine = new List<DispatchPartsOrderLine__c>();
            List<DispatchPartsOrderLine__c> woLineToBeUpdated = new List<DispatchPartsOrderLine__c>();
            
            Profile profileInfo = [select id,Name from Profile where id=:Userinfo.getProfileid()];
            if( (profileInfo.Name !='Service Integration Profile') && (profileInfo.Name !='System Administrator'))
                return;
            system.debug('DispatchException__c '+ newMap);
            for (DispatchException__c se: newMap.values())
            {
                system.debug('woDetail.woDetail ' + se);
                //system.debug(maplookupObject.get(se.Work_Order__c).Id);
                woDetail = [SELECT Service_Type__c, DPS_Region__c, DPS_Sub_Region__c, MessageTypeID__c, 
                            ShipmentStatus__c, Status, Parts_Status__c, Labor_Status__c, subject, LOB__c, 
                            DLP_Rejected_Cancellation__c, DispatchEventCode__c, WO_Type__c, DispatchEvent__c
                           FROM WorkOrder WHERE Id =: se.Work_Order__c LIMIT 1];
                
                system.debug('woDetail.woDetail ' + woDetail);
                sMessageType = woDetail.MessageTypeID__c;
                dlpExceptionCode = se.ISP_FSD_DLP_Exception_Code__c;
                
                if (woDetail.WO_Type__c.equalsIgnoreCase('Break Fix'))
                {
                    woDetail.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                    
                    if (sMessageType.endsWithIgnoreCase('ServiceStatusUpdate'))
                        se.ISP_FSD_Exception_Type__c = 'DSP';
                   	else
                        se.ISP_FSD_Exception_Type__c = 'DLP';
                    
                    if (sMessageType.endsWithIgnoreCase('PartsOrderStatusUpdate'))
                    {
                        system.debug('dlpExceptionCode ' + dlpExceptionCode);
                        if (dlpExceptionCode.endsWithIgnoreCase('FTC')) {
                            // get parts order line
                            woLine = [SELECT ISP_Status__c FROM DispatchPartsOrderLine__c WHERE Work_Order__c =: se.Work_Order__c  LIMIT 100];
                            
                            for (DispatchPartsOrderLine__c woItem : woLine){
                                system.debug('dlpExceptionCode woLine ' + woItem);
                                if (woItem.ISP_Status__c.endsWithIgnoreCase('BACKLOG') || woItem.ISP_Status__c.endsWithIgnoreCase('NEW ETA')){
                                    woItem.ISP_Status__c = 'IN STOCK';
                                    woItem.ISP_COM_Date_Time__c = se.ISP_FSD_DLP_Exception_Date_Time__c; 
                                    woLineToBeUpdated.add(woItem);
                                }                            
                            }
                            woDetail.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                            woDetail.Parts_Status__c = 'In Progress';
                            woDetail.DispatchEventCode__c = 'VF';
                            
                            woToBeUpdated.add(woDetail);                        
                        }
                    }
                }
                
            }
            if(woLineToBeUpdated.size()>0)
            	update woLineToBeUpdated;
            
            if(woToBeUpdated.size()>0)
            	update woToBeUpdated;
        }catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchExceptionTriggerHandler', 'performStatusUpdate', 'Dispatch Management');              
        }
        
    }
}
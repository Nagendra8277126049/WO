/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchPartsOrderLineTriggerHandler
Description:  This class contain method that handles parts order line trigger - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public class DispatchPartsOrderLineTriggerHandler {
    private static List < DispatchETMSetup__c > etmList;
    public static void performStatusUpdate(Map<Id,DispatchPartsOrderLine__c> oldMap, Map<Id,DispatchPartsOrderLine__c> newMap)
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
            String sPartStatus = ''; 
            String sServType = '';
            String sRegion = '';
            String sSubRegion = '';
            String sMessageType = '';
            String sShipmentStatus = '';
            
            String sActStatus = '';
            String sEventCode = '';
            String sOprType = '';
            String sOprType1 = '';
            String sLaborStatus = '';   
            string sOldActStatus = '';
            String sStatusCode = '';
            String sOldDisPartStatus = '';
            String sDisPartsStatus = '';
            String sPartLineStatus = '';
            String sOldPartLineStatus = '';
            String sOldLaborStatus = '';   
            String sPartStatusLookup = '';
            Boolean performStatusTransitionProcess = true;
            String sOperation = '';
            etmList = new List < DispatchETMSetup__c >();
            
            List <WorkOrder> woDetailList = new List <WorkOrder>();
            WorkOrder woDetail = new WorkOrder();
            
            Profile profileInfo = [select id,Name from Profile where id=:Userinfo.getProfileid()];
            if ((profileInfo.Name !='Service Integration Profile') && (profileInfo.Name !='System Administrator') )
                return;
            
            for (DispatchPartsOrderLine__c po: newMap.values())
            {
                woDetail = [SELECT Service_Type__c, DPS_Region__c, DPS_Sub_Region__c, MessageTypeID__c, DispatchEvent__c,
                            ShipmentStatus__c, Status, Parts_Status__c, Labor_Status__c, Sub_Status__c, WO_Type__c, DCCMTEventCode__c
                            FROM WorkOrder WHERE Id =: po.Work_Order__c LIMIT 1];
                
                sOldActStatus = woDetail.Status;
                sMessageType = woDetail.MessageTypeID__c;
                if((sOldActStatus == 'Closed' || sOldActStatus == 'Cancelled' || sOldActStatus == 'Done') || 
                           (sOldActStatus == 'Cancellation Request' && 
                            (sMessageType != 'PartsOrderCancelConfirmation'  
                             && sMessageType != 'ServiceCallCancellationConfirmation' 
                             && sMessageType != 'BreakFixCancelConfirmation'))) 
                            performStatusTransitionProcess = false;
                string woType = woDetail.WO_Type__c;
                if (woType != null && woType.equalsIgnoreCase('Break Fix') && performStatusTransitionProcess)
                {
                    sPartStatus = po.ISP_Status__c;
                    sServType = woDetail.Service_Type__c;
                    sRegion = woDetail.DPS_Region__c;
                    sSubRegion = woDetail.DPS_Sub_Region__c;
                    
                    sShipmentStatus = woDetail.ShipmentStatus__c;
                    
                    woDetail.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                    
                    //sOldActStatus = woDetail.Status;
                    //sOldDisPartStatus = woDetail.Parts_Status__c;
                    //sOldLaborStatus = woDetail.Labor_Status__c;
                    if (string.isNotBlank(woDetail.Labor_Status__c))
                        sOldLaborStatus = woDetail.Labor_Status__c;
                    else
                        sOldLaborStatus = '';
                    
                    if (string.isNotBlank(woDetail.Parts_Status__c))
                        sOldDisPartStatus = woDetail.Parts_Status__c;
                    else
                        sOldDisPartStatus = '';
                                        
                    if (oldMap != null)
                        sOldPartLineStatus = oldMap.get(po.Id).ISP_Status__c;
                    
                    if (string.isEmpty(sShipmentStatus))
                        sShipmentStatus = '';
                    
                    if (sRegion.equalsIgnoreCase('AMERICAS')) {
                        
                        if(sPartStatus == 'IN STOCK' || (sPartStatus == 'DELIVERED' && (sServType == 'Parts Only' || sServType == 'Parts and Labor'))){
                            system.debug(sPartStatus + ' DELIVERED ' + sServType + ' ' + sPartStatus);
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion AND DeliveryStatus__c =: sPartStatus ];                    
                        }
                        else if(sPartStatus == 'SHIPPED')
                        {                    
                            if((sServType != 'Mail-In' && sSubRegion != 'LA') || sSubRegion == 'LA') sServType = 'NA';                     
                            if(sShipmentStatus.equalsIgnoreCase('PARTIALLY SHIPPED')) 
                            {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND DeliveryStatus__c =: sPartStatus AND MessageType__c =: sMessageType 
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  AND FileType__c =: 'PSHP' ];                         
                            }                        
                            else
                            {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND DeliveryStatus__c =: sPartStatus AND MessageType__c =: sMessageType 
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  AND FileType__c =: 'SHP' ];                         
                            }                     
                        }
                        else if(sPartStatus == 'DELIVERED' && sServType != 'Parts Only')
                        {
                            /*etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE ServiceType__c =: sServType AND DeliveryStatus__c =: sPartStatus AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion ];  */      
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE ServiceType__c != 'Parts Only' AND DeliveryStatus__c =: sPartStatus AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion];
                        }   
                        else {
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE DeliveryStatus__c =: sPartStatus AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1];                                             
                        } 
                    }
                    else {
                        etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                   WHERE DeliveryStatus__c =: sPartStatus AND MessageType__c =: sMessageType 
                                   AND Region__c =: sRegion];                         
                    }
                    
                    // AP
                    if (sRegion.equalsIgnoreCase('AP')) 
                    {
                        if(sPartStatusLookup != 'BACKLOG')
                            sPartStatusLookup = po.ISP_Status__c;
                        string vNewPPID = po.ISP_New_PPID__c;
                        string vOldPPID = po.ISP_Old_PPID__c;
                        string vComments ='';
                        string sPartNum;
                        if (sPartStatus == 'SHIPPED'){                            
                            if (!string.isEmpty(vNewPPID))
                            {
                                if(vNewPPID.equalsIgnoreCase('NOT APPLICABLE') || vNewPPID.equalsIgnoreCase('NOT DETECTABLE'))
                                {
                                    vComments ='DLP Shipped Status: ' + sPartNum + ' : PPID is ' + vNewPPID.toUpperCase();
                                    addInstruction(po.Work_Order__c, vComments);
                                }    
                            }                            
                        }
                        else if (sPartStatus == 'RETURNED') {
                            if (!string.isEmpty(vOldPPID))
                            {
                                if(vOldPPID.equalsIgnoreCase('NOT APPLICABLE') || vOldPPID.equalsIgnoreCase('NOT DETECTABLE'))
                                {
                                    vComments ='DLP Return Status: ' + sPartNum + ' : PPID is ' + vOldPPID.toUpperCase();
                                    addInstruction(po.Work_Order__c, vComments);
                                }
                            }
                        }
                        if(sPartStatus != 'RETURNED'){
                            sPartLineStatus = po.ISP_Status__c; 
                            if((sPartLineStatus != '') && (sOldPartLineStatus != '') && (sOldPartLineStatus != sPartLineStatus))
                            {
                                if(!DispatchSubmissionProcess.statusUpdateCheck('Part Line Status', sOldPartLineStatus, sPartLineStatus, 'AP', ''))
                                    po.ISP_Status__c = sOldPartLineStatus;
                            }
                        }
                        
                        if(sPartStatusLookup == 'RETURNED'){
                            if(sOldLaborStatus == 'Service Call Closure' || sOldLaborStatus == ''){
                                woDetail.Status = 'Closed';
                                woDetail.Parts_Status__c = 'Part Order Complete';   
                            }
                            else{
                                woDetail.Parts_Status__c = 'Part Order Complete';                                   
                            }
                        } else {
                            if(sPartStatusLookup == 'DELIVERED' && (sServType == 'Parts Only' || sServType == 'Parts and Labor'))
                            {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType
                                           AND Region__c =: sRegion AND DeliveryStatus__c =: sPartStatusLookup LIMIT 1];
                            }
                            else {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE MessageType__c =: sMessageType
                                           AND Region__c =: sRegion AND DeliveryStatus__c =: sPartStatusLookup LIMIT 1];
                            }
                        }                        
                    }
                    
                    if (!etmList.isEmpty())                    
                    {
                        sActStatus 	= 	etmList[0].ActivityStatus__c;
                        sEventCode 	= 	etmList[0].EventCode__c;
                        sOprType 	= 	etmList[0].OperationType__c;
                        sOprType1 	= 	etmList[0].OperationType__c;
                        if(etmList.size() > 1)
                        	sOprType1	=	etmList[0].OperationType__c + ',' + etmList[1].OperationType__c;	    
                        sLaborStatus = etmList[0].LaborStatus__c;
                          
                                             
                        
                        if((sOldActStatus == 'Closed' || sOldActStatus == 'Cancelled' || sOldActStatus == 'Done') || 
                           (sOldActStatus == 'Cancellation Request' && (sMessageType != 'PartsOrderCancelConfirmation'  && sMessageType != 'ServiceCallCancellationConfirmation' && sMessageType != 'BreakFixCancelConfirmation'))) 
                            sActStatus = 'NA';
                        
                        if(sOldActStatus == 'Closed') sStatusCode = 'CLO';
                        else if(sOldActStatus == 'Cancelled') sStatusCode = 'CNL';
                        else if(sOldActStatus == 'Cancellation Request' && sActStatus == 'NA') sStatusCode = 'CNR';
                        else sStatusCode = etmList[0].FileType__c;
                        
                        if (sOprType!=null && sOprType != null){
                            po.ISP_Event_Code__c = etmList[0].EventCode__c;
                            po.ISP_Operation_Type__c = sOprType;
                            if(sActStatus != 'NA'){
                                woDetail.Status = sActStatus;                        
                            }
                           	if((etmList[0].PartsStatus__c) != 'NA'){
                            woDetail.Parts_Status__c = etmList[0].PartsStatus__c;
							}
                            if (sLaborStatus != 'NA')   { 
                                if (!sServType.endsWithIgnoreCase('Parts Only'))
                                    woDetail.Labor_Status__c = sLaborStatus;
                            }
                        }
                        sDisPartsStatus = woDetail.Parts_Status__c; 
                        sPartLineStatus = po.ISP_Status__c; 
                        //if (sPartStatus == 'DELIVERED' || sPartStatus == 'SHIPPED' || sPartStatus == 'RETURNED')
                        //    woDetail.OperationType__c = 'DPS';// added for DCCMT
                        //else
                        woDetail.OperationType__c 	= 	sOprType1;
                        woDetail.DCCMTEventCode__c 	= 	po.ISP_Event_Code__c;
                        
                        if (sRegion.equalsIgnoreCase('AMERICAS')) {                    
                            if(((sSubRegion == 'US' || sSubRegion == 'CA') && (sDisPartsStatus != 'Acknowledged' && sDisPartsStatus != 'Closed' && sDisPartsStatus != 'Cancelled' && sDisPartsStatus != 'Rejected' && sDisPartsStatus != 'Cancellation Rejected')) || 
                               ((sSubRegion == 'LA' && (sDisPartsStatus != 'Acknowledged' && sDisPartsStatus != 'Cancelled' && sDisPartsStatus != 'Cancellation Rejected'))))
                            {
                                
                                if((sPartLineStatus != '') && (sOldPartLineStatus != '') && (sOldPartLineStatus != sPartLineStatus))
                                {
                                    if(!DispatchSubmissionProcess.statusUpdateCheck('Part Line Status', sOldPartLineStatus, sPartLineStatus, sRegion, sSubRegion))
                                        po.ISP_Status__c = sOldPartLineStatus;
                                }
                            }
                        } else {
                            // EMEA
                            if (sRegion.equalsIgnoreCase('EMEA')) {
                                if (sActStatus != 'NA' && sRegion.equalsIgnoreCase('EMEA'))
                                    woDetail.Status = sActStatus;
                                if(sRegion == 'EMEA' && (sDisPartsStatus != 'Acknowledged' && sDisPartsStatus != 'Part Order Complete' && sDisPartsStatus != 'Rejected'))
                                {
                                    if((sPartLineStatus != '') && (sOldPartLineStatus != '') && (sOldPartLineStatus != sPartLineStatus))
                                    {
                                        if(!DispatchSubmissionProcess.StatusUpdateCheck('Part Line Status', sOldPartLineStatus, sPartLineStatus, sRegion, sRegion))
                                            po.ISP_Status__c = sOldPartLineStatus;
                                    }
                                }
                            }
                            
                        }
                        
                        if((sDisPartsStatus != '') && (sOldDisPartStatus != '') && (sOldDisPartStatus != sDisPartsStatus))
                        {
                            if(!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Parts Status', sOldDisPartStatus, sDisPartsStatus, sRegion, sSubRegion))
                                woDetail.Parts_Status__c = sOldDisPartStatus;
                        }
                        if((sLaborStatus != '') && (sOldLaborStatus != '') && (sOldLaborStatus != sLaborStatus)){
                            if(!DispatchSubmissionProcess.statusUpdateCheck('Labor Status', sOldLaborStatus, sLaborStatus, sRegion, sSubRegion))
                            {
                                woDetail.Labor_Status__c = sOldLaborStatus;
                            }
                        }
                        if((sActStatus != '') && (sOldActStatus != sActStatus)){
                            if(!DispatchSubmissionProcess.statusUpdateCheck('Labor Status', sOldActStatus, sActStatus, sRegion, sSubRegion))
                            {
                                woDetail.Status = sOldActStatus;
                            }
                        }                        
                    }
                    
                    // perform for status = 
                    
                    boolean allPartsReturned = false;
                    String woLineItemId = po.Part__c;
                    list<WorkOrderLineItem> woLine = new List<WorkOrderLineItem>();
                    woLine = [SELECT Id, Part_Quantity__c, PartDescription__c, PartPrice__c, PartNumber__c FROM WorkOrderLineItem WHERE Id=: woLineItemId LIMIT 1];
                    if (sPartStatus.equalsIgnoreCase('RETURNED') && sRegion.equalsIgnoreCase('AMERICAS')) 
                    {                    
                        List<DispatchPartsOrderLine__c> allPOLine = new List<DispatchPartsOrderLine__c>();
                        
                        allPOLine = [SELECT Id, ISP_Qty__c, Part__r.Part_Quantity__c, Part__r.PartDescription__c,Part__r.PartPrice__c, Part__r.PartNumber__c FROM DispatchPartsOrderLine__c WHERE ISP_Status__c ='RETURNED' AND Part__c=: woLineItemId LIMIT 100];
                        string partQty = '0';
                        double totalReturnQty = 0;
                        
                        if (woLine.size()>0 && !woLine.isEmpty()  && woLine != null) {
                            partQty = woLine[0].Part_Quantity__c;
                            po.ISP_Description__c = woLine[0].PartDescription__c;
                            po.ISP_Unit_Price__c = double.valueOf(woLine[0].PartPrice__c);
                        }
                        
                        if (allPOLine.size()>0 && !allPOLine.isEmpty()  && allPOLine != null)
                        {
                            for (DispatchPartsOrderLine__c poItem : allPOLine)
                            {
                                totalReturnQty = totalReturnQty + poItem.ISP_Qty__c;                            
                            }                            
                        } 
                        
                        if (totalReturnQty >= double.valueOf(partQty))
                            allPartsReturned = true;
                    } 
                    else {       
                        if (!woLine.isEmpty() && woLine.size()>0 && woLine != null) {
                            po.ISP_Description__c = woLine[0].PartDescription__c; 
                            if (string.isNotEmpty(woLine[0].PartPrice__c))
                                po.ISP_Unit_Price__c = double.valueOf(woLine[0].PartPrice__c);
                        }
                    }
                    
                    if (allPartsReturned)
                        woDetail.Parts_Status__c = 'All Parts Returned';
                    
                    woDetailList.add(woDetail);
                }
                
            }
            if(woDetailList.size()>0)
                update woDetailList;
        }catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispathPartsOrderLineTriggerHandler', 'performStatusUpdate', 'Dispatch Management');              
        }
    }
    @TestVisible
    private static void addInstruction(Id woId, string instructions)
    {
        try {
            DispatchInstruction__c getInstruct = new DispatchInstruction__c();
            
            getInstruct.Instruction__c = instructions;
            getInstruct.Type__c = 'General Comment';
            getInstruct.Receiver__c = 'DELL';
            getInstruct.Vendor_Instructions__c = false;
            getInstruct.Work_Order__c = woId;
            // Update Instruction record
            Insert getInstruct;
            
        }catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispathPartsOrderLineTriggerHandler', 'addInstruction', 'Dispatch Management');              
        }
    }
    
}
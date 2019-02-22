/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchServiceEventTriggerHandler
Description:  This class contain method that handles service event trigger - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public class DispatchServiceEventTriggerHandler {
    @testvisible public static List < DispatchETMSetup__c > etmList;
    @testvisible public static List < DispatchETMSetup__c > mockedETMList = new List < DispatchETMSetup__c >();
    @testvisible public static string mockedReplyDesc = '';
    public static void performStatusUpdate(Map<Id,DispatchServiceEvent__c> oldMap, Map<Id,DispatchServiceEvent__c> newMap)
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
            String sMessageType = '';    
            String sReplyCode = '';
            String sServType = '';
            String psIspServiceEvent = '';
            String sLOB = '';
            String sRegion = '';
            String sSubRegion = '';
            String sReplyCodeDesc = '';
            String sOldPartsStatus = '';
            String sOldLaborStatus = '';
            String sEvntDateTime = '';    
            String sDLPRejected = '';
            String sActStatus = '';
            String sEventCode = '';
            String sOprType = '';
            String sLaborStatus = '';  
            String sPartsStatus = '';
            String sStatusCode = '';
            String sOldActStatus = '';
            Boolean performStatusTransitionProcess = true;
            String sOperation = 'TRN';
            String sDSPCode = '';
            etmList = new List<DispatchETMSetup__c>();
            
            List <WorkOrder> woDetailList = new List <WorkOrder>();
            
            WorkOrder woDetail = new WorkOrder();
            
            Profile profileInfo = [select id,Name from Profile where id=:Userinfo.getProfileid()];
            if( (profileInfo.Name !='Service Integration Profile') && (profileInfo.Name !='System Administrator'))
                return;
            
            /*set<id> setlookup = new set<id>();
System.debug('### maplookupObject : ' + newMap); //null in logs
for(DispatchServiceEvent__c se : newMap.values()){
setlookup.add(se.Work_Order__c);
}
*/
            //query data from object 2 as relationship data is not available inside trigger.
            /*Map<id,WorkOrder> maplookupObject =  new Map<id,WorkOrder>([select id, MessageTypeID__c from WorkOrder where id in : setlookup]);
System.debug('### maplookupObject : ' + maplookupObject); //null in logs
*/
            for (DispatchServiceEvent__c se: newMap.values())
            {
                woDetail = [SELECT Service_Type__c, DPS_Region__c, DPS_Sub_Region__c, MessageTypeID__c, WO_Type__c, DispatchEvent__c,
                            ShipmentStatus__c, Status, Parts_Status__c, Labor_Status__c, subject, LOB__c, DLP_Rejected_Cancellation__c, 
                            DCCMTEventCode__c, DSP__c
                            FROM WorkOrder WHERE Id =: se.Work_Order__c LIMIT 1];
                
                sOldActStatus = woDetail.Status;
                sMessageType = woDetail.MessageTypeID__c;
                if((sOldActStatus == 'Closed' || sOldActStatus == 'Cancelled' || sOldActStatus == 'Done' || sOldActStatus == 'Service Complete') || (sOldActStatus == 'Cancellation Request' && (sMessageType != 'PartsOrderCancelConfirmation' && sMessageType != 'ServiceCallCancellationConfirmation' && sMessageType != 'BreakFixCancelConfirmation' && sMessageType != 'ServiceCallClosure' && sMessageType != 'SvcCallCancelConfirmation' && sMessageType != 'ServiceCallCancellation')))
                  performStatusTransitionProcess = false;
                
                if (null != woDetail.WO_Type__c && woDetail.WO_Type__c.equalsIgnoreCase('Break Fix') && performStatusTransitionProcess)
                {                
                    sServType = woDetail.Service_Type__c;
                    sRegion = woDetail.DPS_Region__c;
                    sSubRegion = woDetail.DPS_Sub_Region__c;
                    sMessageType = woDetail.MessageTypeID__c;
                    psIspServiceEvent = se.Service_Event__c;
                    sLOB = woDetail.LOB__c;
                    sDLPRejected = woDetail.DLP_Rejected_Cancellation__c;
                    sDSPCode = woDetail.DSP__c;
                    woDetail.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                    
                    //se.Reject_Reason__c = sMessageType + ' : ' + psIspServiceEvent;
                    //sOldPartsStatus = woDetail.Parts_Status__c;
                    //sOldActStatus = woDetail.Status;
                    //sOldLaborStatus = woDetail.Labor_Status__c;
                    //woDetail.subject = sMessageType + ' : ' + psIspServiceEvent;
                    
                    if (woDetail.Labor_Status__c != null)
                        sOldLaborStatus = woDetail.Labor_Status__c;
                    else
                        sOldLaborStatus = '';
                                        
                    if (woDetail.Parts_Status__c != null)
                        sOldPartsStatus = woDetail.Parts_Status__c;
                    else
                        sOldPartsStatus = '';
                    
                    sOldActStatus = woDetail.Status;
                    
                    if(psIspServiceEvent == 'SERVICE_COMPLETED')
                        sEvntDateTime = se.Event_DateTime__c;
                    sReplyCode = se.Reply_Code__c;
                    if(sMessageType != 'ServiceCallRejection' && !(sReplyCode == '109' && sServType == 'Mail-In'))
                        sMessageType = sMessageType;
                    //sMessageType = TheApplication().InvokeMethod('LookupValue','ISP_MESSAGETYPE_ID', psIspServiceEvent);
                    else if(!(sReplyCode == '109' && sServType == 'Mail-In'))
                        woDetail.Sub_Status__c = 'Rejected'; 
                    
                    if (sMessageType == 'ServiceStatusUpdate')
                    {
                        if(sReplyCode == '109' && sServType == 'Mail-In')
                        {
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c FROM DispatchETMSetup__c
                                       WHERE MessageType__c =: sMessageType AND LaborStatus__c =: 'Box Shipped'
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1];  
                        }
                        else if((sReplyCode == '112' || sReplyCode == '111') && sServType == 'Mail-In')
                        {
                            //sReplyCodeDesc = TheApplication().InvokeMethod('LookupValue','ISP_REPLY_CODE_NOTIFY', sReplyCode);
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE LaborStatus__c =: sReplyCodeDesc AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1];                
                        }
                        else 
                        {
                            
                            if (sRegion.equalsIgnoreCase('AMERICAS')){
                                if(psIspServiceEvent == 'VENDOR GENERATED ALERT')
                                {
                                    //if (string.isNotBlank(psIspServiceEvent)) {
                                    etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                               WHERE ServiceType__c =: 'NA' AND ProgressEvent__c =: psIspServiceEvent AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                               AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1]; 
                                    /*}
                                    else {
                                        etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                               WHERE ServiceType__c =: 'NA' AND MessageType__c =: sMessageType AND OperationType__c = 'TRN'
                                               AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1];
                                    }*/
                                }
                                
                                else{
                                    etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                               WHERE ProgressEvent__c =: psIspServiceEvent AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                               AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1];             
                                }
                            } 
                            else {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ProgressEvent__c =: psIspServiceEvent AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion LIMIT 1];   
                            }
                        }
                    }
                    else if(sMessageType == 'ServiceCallClosure')
                    {
                        if (sRegion.equalsIgnoreCase('AMERICAS')){
                            if((sOldPartsStatus == '' || sOldPartsStatus == null || sOldPartsStatus == 'All Parts Returned') || (sServType == 'Mail-In' && sLOB == '4FO'))
                            {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  AND ActivityStatus__c =: 'Closed' LIMIT 1];
                            }                        
                            else {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  AND ActivityStatus__c =: 'Service Complete' LIMIT 1];
                            } 
                        }    
                        else {
                            if (sServType.equalsIgnoreCase('Labor Only')) {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion LIMIT 1];
                            } else if ((sOldPartsStatus == '' || sOldPartsStatus == null || sOldPartsStatus == 'Part Order Complete') && sRegion.equalsIgnoreCase('AP')) {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND ActivityStatus__c =: 'Closed' LIMIT 1];
                            } else if (sDLPRejected != 'Y' && sOldActStatus == 'Cancellation Request') {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND ActivityStatus__c =: 'NA' LIMIT 1];
                            } else {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND ActivityStatus__c =: 'Service Complete' LIMIT 1];                                
                            }
                        }
                    }
                    else
                    {
                        if (sRegion.equalsIgnoreCase('AMERICAS')){
                            if (psIspServiceEvent.equalsIgnoreCase('Acknowledged') && sMessageType=='ServiceCallConfirmation')
                            {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: 'NA' AND ProgressEvent__c =: psIspServiceEvent AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1];
                            }
                            else {
                                if (sMessageType=='ServiceCallRejection' || sMessageType=='SvcCallCancelConfirmation') {
                                    /*if (sServType.equalsIgnoreCase('Labor Only') || sServType.equalsIgnoreCase('Mail-In') || sServType.equalsIgnoreCase('Parts and Labor'))
                                    {
                                        etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                        WHERE ServiceType__c =: 'NA' AND MessageType__c =: sMessageType AND OperationType__c = 'DPS'
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  LIMIT 1];    
                                    }
                                    else {*/
                                      etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: 'NA' AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  LIMIT 1];    
                                    //}
                                }
                                else {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  LIMIT 1];
                                }
                            }
                        }
                        else {
                            if (sRegion.equalsIgnoreCase('EMEA') )
                            {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: 'NA' AND ProgressEvent__c =: psIspServiceEvent AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                           AND Region__c =: sRegion LIMIT 1];
                            }
                            else
                            {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE MessageType__c =: sMessageType AND Region__c =: sRegion AND OperationType__c=:sOperation LIMIT 1];    
                            }
                            
                        }
                        
                    }   
                    
                    if((sMessageType == 'ServiceCallClosure') && (sServType == 'Mail-In') && (sLOB != '4FO'))
                    {
                        etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                   WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType AND OperationType__c=:sOperation
                                   AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  LIMIT 1];                     
                    }
                    
                    system.debug('etmList ' + etmList);
                    
                    if (!etmList.isEmpty())
                    {                        
                        if((sOldActStatus == 'Closed' || sOldActStatus == 'Cancelled' || sOldActStatus == 'Done' || sOldActStatus == 'Service Complete') || (sOldActStatus == 'Cancellation Request' && (sMessageType != 'PartsOrderCancelConfirmation' && sMessageType != 'ServiceCallCancellationConfirmation' && sMessageType != 'BreakFixCancelConfirmation' && sMessageType != 'ServiceCallClosure')))
                        {
                            performStatusTransitionProcess = false;
                            sActStatus = 'NA';
                        }                        
                        else if(sMessageType == 'ServiceCallClosure' && sOldActStatus == 'Cancellation Request')
                        {
                            if(sOldPartsStatus == '' || sDLPRejected == 'Y')
                            {
                                sActStatus = 'Closed';
                                sStatusCode = 'CLO';
                            }
                            else
                                sActStatus = 'NA';
                        }
                        else 
                            sActStatus = etmList[0].ActivityStatus__c;
                        
                        
                        //if (performStatusTransitionProcess)
                        {
                            if(sOldActStatus == 'Closed') sStatusCode = 'CLO';
                            else if(sOldActStatus == 'Cancelled') sStatusCode = 'CNL';
                            else if(sOldActStatus == 'Cancellation Request' && sActStatus == 'NA') sStatusCode = 'CNR';
                            else sStatusCode = etmList[0].FileType__c; 
                            if (etmList.size()>0)
                            {
                                sActStatus = etmList[0].ActivityStatus__c;
                                sEventCode = etmList[0].EventCode__c;
                                sOprType = etmList[0].OperationType__c;
                                sLaborStatus = etmList[0].LaborStatus__c;   
                                sPartsStatus  = etmList[0].PartsStatus__c;   
                            }           
                            woDetail.OperationType__c = sOprType;
                            
                                 sReplyCode = se.Reply_Code__c;
                                if(string.isNotBlank(sReplyCode)){
                                    if (sRegion.equalsIgnoreCase('AMERICAS'))
                                        sReplyCodeDesc = [SELECT ReplyCodeDesc__c FROM Vendor_Reply_Code__mdt WHERE ReplyCodeDesc__c != null and ReplyCode__c=:sReplyCode and DSPCode__c =: sDSPCode LIMIT 1].ReplyCodeDesc__c;
                                    else
                                        sReplyCodeDesc =  [SELECT ReplyCodeDesc__c FROM Vendor_Reply_Code__mdt WHERE ReplyCodeDesc__c != null and ReplyCode__c=:sReplyCode LIMIT 1].ReplyCodeDesc__c;
                                }
                            if (sOprType == 'TRN')
                            {
                                
                                se.Event_Code__c = sEventCode;
                                se.Operation_Type__c = sOprType;
                                se.File_Type__c = sStatusCode;                    
                                if(sLaborStatus != 'NA') {
                                
                                    if(!sLaborStatus.toUpperCase().contains('DISPLAY THE TEXT OF THE REPLY'))
                                        woDetail.Labor_Status__c = sLaborStatus;   
                                }                                                           
                                if(sPartsStatus != 'NA')
                                    woDetail.Parts_Status__c = sPartsStatus;                                                
                                if(sActStatus != 'NA')
                                    woDetail.Status = sActStatus;                                                
                            }
                            else {
                                                             
                                    
                                if(psIspServiceEvent == 'VENDOR GENERATED ALERT'){
                                    
                                    if(sReplyCodeDesc !='')
                                    {
                                        if(sMessageType == 'ServiceStatusUpdate')
                                        {
                                            if(sLaborStatus != 'NA')
                                                woDetail.Labor_Status__c = sReplyCodeDesc;
                                            if(sActStatus != 'NA')
                                                woDetail.Status = sActStatus;
                                        }
                                        se.Event_Code__c = sEventCode;
                                        se.Operation_Type__c = sOprType;
                                        se.File_Type__c = sStatusCode; 
                                    }
                                }
                                else {
                                    if(sLaborStatus != 'NA')
                                        woDetail.Labor_Status__c = sReplyCodeDesc;
                                    if(sActStatus != 'NA')
                                        woDetail.Status = sActStatus;
                                    
                                    se.Event_Code__c = sEventCode;
                                    se.Operation_Type__c = sOprType;
                                    se.File_Type__c = sStatusCode;
                                }                        
                            }
                            if(string.isNotBlank(sReplyCodeDesc))
                            {
                                se.Reply_Code_Description__c = sReplyCodeDesc;
                            }   
                            woDetail.DCCMTEventCode__c = se.Event_Code__c; 
                            
                            if(sOldActStatus == 'Closed' || sOldActStatus == 'Cancelled' || sOldActStatus == 'Rejected')
                            {
                                woDetail.Status = sOldActStatus;
                            }
                            if(sOldLaborStatus == 'Service Call Closure' || sOldLaborStatus == 'Rejected')
                            {
                                woDetail.Labor_Status__c = sOldLaborStatus;
                            }
                            
                            //sLaborStatus = woDetail.Labor_Status__c;
                            
                            if(sLaborStatus != '' && sOldLaborStatus != sLaborStatus)
                            {
                                if(!DispatchSubmissionProcess.statusUpdateCheck('Labor Status', sOldLaborStatus, sLaborStatus, sRegion, sSubRegion))
                                    woDetail.Labor_Status__c = sOldLaborStatus;
                            }
                            if(sPartsStatus != '' && sOldPartsStatus != sPartsStatus)
                            {
                                if(!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Parts Status', sOldPartsStatus, sPartsStatus, sRegion, sSubRegion))
                                    woDetail.Parts_Status__c = sOldPartsStatus;
                            }
                            sActStatus = woDetail.Status;
                            if(sActStatus != '' && sOldActStatus != sActStatus)
                            {
                                if(!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Status', sOldActStatus, sActStatus, sRegion, sSubRegion))
                                {
                                    woDetail.Status = sActStatus;
                                }
                            }
                        }
                        
                        woDetailList.add(woDetail);
                    }
                }
                
            }
            if (woDetailList.size()>0)
              update woDetailList;
        }catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceEventTriggerHandler', 'performStatusUpdate', 'Dispatch Management');              
        }
    }
}
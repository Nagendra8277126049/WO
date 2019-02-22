/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchPartsOrderTriggerHandler
Description:  This class contain method that handles parts order trigger - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
08/31/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public class DispatchPartsOrderTriggerHandler {
    @TestVisible
    public static List < DispatchETMSetup__c > mockedETMList = new List<DispatchETMSetup__c>();
    private static List < DispatchETMSetup__c > etmList = new List<DispatchETMSetup__c>();
    /*    
public class UniqueKey {
UniqueKey(string messageType, String subRegion, String region) {
this.messageType = messageType;
this.subRegion = subRegion;
this.region = region;
}
string messageType, subRegion, region;

integer hashCode() {
return toString().hashCode();
}

boolean equals(Object o) {
return toString() == ((UniqueKey)o).toString();
}

public override string toString() {
return String.format(
'messageType = \'\'{0}\'\' AND subRegion = \'\'{1}\'\' AND region = \'\'{2}\'\'',
new String[] {
messageType==null?'':String.escapeSingleQuotes(messageType.tolowercase()),
subRegion==null?'':String.escapeSingleQuotes(subRegion.tolowercase()),
region==null?'':String.escapeSingleQuotes(region.tolowercase())
}
);
}
}
*/
    
    public static void performStatusUpdate(Map<Id,DispatchPartsOrder__c> oldMap, Map<Id,DispatchPartsOrder__c> newMap)
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
        try{
            
            /*
set<Id> WorkOrderIds = new set<Id>();

string sPartStatus = '';
string sEventCode = '';
string sOperType = '';
string sLaborStatus = '';
boolean bCancellationRejected = false;
string sActStatus = '';
string sStatusCode = '';
String sStatusRejected = '';
String fileType = '';
String activityStatus = '';

for (DispatchPartsOrder__c po: newMap.values()) {
if(po.Work_Order__c != null) {
WorkOrderIds.add(po.Work_Order__c);
}
}

if(!WorkOrderIds.isEmpty() && WorkOrderIds.size() >0) {
Map<Id,WorkOrder> workOrderMap1 = new Map<Id,WorkOrder>([SELECT Id,Service_Type__c,DPS_Region__c,
DPS_Sub_Region__c,MessageTypeID__c,Labor_Status__c,Parts_Status__c
FROM WorkOrder WHERE Id IN : WorkOrderIds LIMIT 5000);  
if( !workOrderMap1.isEmpty() && workOrderMap1.size() >0 ) {
set<string> MessageTypeSet = new set<string>();
set<String> subRegionSet = new set<String>();
set<String> sRegionSet = new set<String>();

for (WorkOrder wo : workOrderMap1.values()){
if(String.isNotBlank(wo.MessageTypeID__c)){
MessageTypeSet.add(wo.MessageTypeID__c);
}
if(String.isNotBlank(wo.DPS_Sub_Region__c)){
subRegionSet.add(wo.DPS_Region__c);
}
if(String.isNotBlank(wo.DPS_Region__c)){
sRegion.add(wo.DPS_Region__c);
}
}

UniqueKey key;

Map<UniqueKey, List<DispatchETMSetup__c>> etmUniqueKeyMap = new Map<UniqueKey, List<DispatchETMSetup__c>>();     

List<DispatchETMSetup__c> etmList = new List<DispatchETMSetup__c>();

for(DispatchETMSetup__c dETM : [SELECT Id,EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c,
MessageType__c,Region__c,SubRegion__c
FROM DispatchETMSetup__c WHERE MessageType__c IN:MessageTypeSet AND SubRegion__c IN: subRegionSet
AND Region__c IN: sRegion LIMIT 50000]){
etmList.clear();
key = new UniqueKey(dETM.MessageType__c,dETM.SubRegion__c,dETM.Region__c);
if (etmUniqueKeyMap.containsKey(key)){
etmList = etmUniqueKeyMap.get(key);
if(!etmList.isEmpty()){
etmList.add(dETM);
etmUniqueKeyMap.put(key,etmList);
}
} else {
etmUniqueKeyMap.put(key, new List<DispatchETMSetup__c>{dETM});
}
}
}
}

UniqueKey key;
if( !workOrderMap1.isEmpty() && workOrderMap1.size() >0 ) {
for (DispatchPartsOrder__c po: newMap.values()) {
bCancellationRejected = false;
if(po.Work_Order__c != null) {
if(workOrderMap1.containsKey(po.Work_Order__c)){
if(String.isNotBlank(workOrderMap1.get(po.Work_Order__c).MessageTypeID__c)){
if (workOrderMap1.get(po.Work_Order__c).MessageTypeID__c.equalsIgnoreCase('PartsOrderConfirmation')) {
if(String.isNotBlank(workOrderMap1.get(po.Work_Order__c).ISP_Operation_Type__c)) {
if(workOrderMap1.get(po.Work_Order__c).ISP_Operation_Type__c.equalsIgnoreCase('REJECTED')) {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
if(String.isNotBlank(dspESp.PartsStatus__c)){
if(dspESp.PartsStatus__c.equalsIgnoreCase('Rejected')){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c; 
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
}
}
} else {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
if(String.isNotBlank(dspESp.PartsStatus__c)){
if(dspESp.PartsStatus__c.equalsIgnoreCase('Acknowledged')){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c;
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
}
}
} 
} else {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
if(String.isNotBlank(dspESp.PartsStatus__c)){
if(dspESp.PartsStatus__c.equalsIgnoreCase('Acknowledged')){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c; 
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
}
}
}
}  else if (workOrderMap1.get(po.Work_Order__c).MessageTypeID__c.equalsIgnoreCase('PartsOrderCancelConfirmation')) {
if(String.isNotBlank(workOrderMap1.get(po.Work_Order__c).ISP_Operation_Type__c)) {
if(workOrderMap1.get(po.Work_Order__c).ISP_Operation_Type__c.equalsIgnoreCase('REJECTED')) {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
if(String.isNotBlank(dspESp.PartsStatus__c)){
if(dspESp.PartsStatus__c.equalsIgnoreCase('Cancellation Rejected')){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c; 
bCancellationRejected = true;
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
}
}
} else {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
if(String.isNotBlank(dspESp.PartsStatus__c)){
if(dspESp.PartsStatus__c.equalsIgnoreCase('Cancelled')){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c;
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
}
}   
}
} else {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
if(String.isNotBlank(dspESp.PartsStatus__c)){
if(dspESp.PartsStatus__c.equalsIgnoreCase('Cancelled')){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c;
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
}
} 
}
} else if (workOrderMap1.get(po.Work_Order__c).MessageTypeID__c.equalsIgnoreCase('SvcCallCancelConfirmation') ||
workOrderMap1.get(po.Work_Order__c).MessageTypeID__c.equalsIgnoreCase('PartsOrderCancellation')) {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c;
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
} else {
key = new UniqueKey(workOrderMap1.get(po.Work_Order__c).MessageTypeId__c,workOrderMap1.get(po.Work_Order__c).DPS_Sub_Region__c,workOrderMap1.get(po.Work_Order__c).DPS_Region__c);
if(etmUniqueKeyMap.containsKey(key)){
if(!setmUniqueKeyMap.get(key).isEmpty()){
for(DispatchETMSetup__c dspESp : setmUniqueKeyMap.get(key)){
sPartStatus = dspESp.PartsStatus__c;
sEventCode = dspESp.EventCode__c;
sOperType = dspESp.OperationType__c;
sLaborStatus = dspESp.LaborStatus__c;
fileType = dspESp.FileType__c;
activityStatus = dspESp.ActivityStatus__c;
break;
}
}
}
}
}

if(bCancellationRejected && !string.isNotBlank(workOrderMap1.get(po.Work_Order__c).Labor_Status__c)) {                  
sActStatus = 'Closed';
sStatusCode = 'CLO';
} else if (bCancellationRejected && workOrderMap1.get(po.Work_Order__c).Labor_Status__c.equalsIgnoreCase('Service Call Closure')){
sActStatus = sStatusRejected;
sStatusCode = fileType;
} else {
sActStatus = sStatusRejected;
sStatusCode = fileType;
}

if(sActStatus.equalsIgnoreCase('Closed') ||

}
}
}
}

*/
            String sActStatus 				= 	'';
            String sStatusCode 				= 	'';
            String sServType 				= 	'';
            String sRegion 					= 	'';
            String sSubRegion 				= 	'';
            String sMessageType 			= 	'';
            Boolean bCancellationRejected 	= 	false;            
            String sStatusRejected 			= 	'';
            String sPartStatus 				= 	'';
            String sEventCode 				= 	'';
            String sOperType 				= 	'';
            String sOperType1 				= 	'';
            String sLaborStatus 			= 	'';
            String sOldActStatus 			= 	'';
            String sOldLaborStatus 			= 	'';
            String sOldPartsStatus 			= 	'';
            Boolean performStatusTransitionProcess = true;
            String sOperation = 'TRN';
            etmList = new List < DispatchETMSetup__c >();
            List <WorkOrder> woDetailList = new List <WorkOrder>();
            WorkOrder woDetail = new WorkOrder();
            
            Profile profileInfo = [select id,Name from Profile where id=:Userinfo.getProfileid()];
            
            if( (profileInfo.Name !='Service Integration Profile') && (profileInfo.Name !='System Administrator'))
                return;
            
            for (DispatchPartsOrder__c po: newMap.values())
            {
                woDetail = [SELECT Service_Type__c, DPS_Region__c, DPS_Sub_Region__c, MessageTypeID__c, 
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
                    sServType = woDetail.Service_Type__c;
                    sRegion = woDetail.DPS_Region__c;
                    sSubRegion = woDetail.DPS_Sub_Region__c;
                    sMessageType = woDetail.MessageTypeID__c;
                    
                    woDetail.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';

                    if (string.isNotBlank(woDetail.Labor_Status__c)) 
                        sOldLaborStatus = woDetail.Labor_Status__c;
                    else
                        sOldLaborStatus = '';
                    
                    if (string.isNotBlank(woDetail.Parts_Status__c))
                        sOldPartsStatus = woDetail.Parts_Status__c;
                    else
                        sOldPartsStatus = '';
                    
                    sOldActStatus = woDetail.Status;
                    sPartStatus = '';
                    sEventCode = '';
                    sOperType = '';
                    sLaborStatus = '';
                    if (sMessageType == 'PartsOrderConfirmation') {
                        if (sRegion.equalsIgnoreCase('AMERICAS')) 
                        {
                            if (po.ISP_Operation_Type__c == 'REJECTED'){
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion AND PartsStatus__c =: 'Rejected' ];
                            } else {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                           AND Region__c =: sRegion AND SubRegion__c =: sSubRegion AND PartsStatus__c =: 'Acknowledged' ];
                            }
                        } else {
                            if (po.ISP_Operation_Type__c == 'REJECTED'){
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                           AND Region__c =: sRegion AND PartsStatus__c =: 'Rejected' ];
                            } else {
                                etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                           WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                           AND Region__c =: sRegion AND PartsStatus__c =: 'Acknowledged' ];
                            }
                        }
                    }
                    else if (sMessageType == 'PartsOrderCancelConfirmation'){
                        //if (sRegion.equalsIgnoreCase('EMEA')) 
                            sServType = 'NA';
                        if (po.ISP_Operation_Type__c == 'REJECTED'){
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion AND PartsStatus__c =: 'Cancellation Rejected' ];
                            bCancellationRejected = true;
                        } else {
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion AND PartsStatus__c =: 'Cancelled' ];
                        }
                    }
                    else if(sMessageType == 'SvcCallCancelConfirmation' || sMessageType == 'PartsOrderCancellation') {
                        etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                   WHERE MessageType__c =: sMessageType AND Region__c =: sRegion AND SubRegion__c =: sSubRegion  ];                    
                    }
                    else {
                        if (sRegion.equalsIgnoreCase('AMERICAS')) {
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion AND SubRegion__c =: sSubRegion ];
                        }
                        else {
                            etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c, LaborStatus__c, PartsStatus__c FROM DispatchETMSetup__c
                                       WHERE ServiceType__c =: sServType AND MessageType__c =: sMessageType 
                                       AND Region__c =: sRegion ];
                        }
                        
                    }
                    po.ISP_Operation_Type__c = '';
                    if (!etmList.isEmpty())
                    {
                        if(bCancellationRejected && sOldLaborStatus == 'Service Call Closure')
                        {                   
                            sActStatus = 'Closed';
                            sStatusCode = 'CLO';
                        }
                        else if(bCancellationRejected && sOldLaborStatus == '')
                        {
                            sActStatus = sStatusRejected;
                            sStatusCode = etmList[0].FileType__c; 
                        }
                        else
                        {
                            sActStatus = etmList[0].ActivityStatus__c;
                            sStatusCode = etmList[0].FileType__c;
                        }
                        
                        
                        if (etmList.size()>0 )
                        {
                            sPartStatus 	= 	etmList[0].PartsStatus__c;
                            sEventCode 		= 	etmList[0].EventCode__c;
                            sOperType 		= 	etmList[0].OperationType__c;
                            sOperType1 		= 	etmList[0].OperationType__c;
                            if(etmList.size() > 1)   
                               sOperType1  	=  	etmList[0].OperationType__c + ',' + etmList[1].OperationType__c;
                            sLaborStatus 	= 	etmList[0].LaborStatus__c;                                                            
                        }
                        
                        woDetail.OperationType__c = sOperType1;
                        if((sOldActStatus == 'Closed' || sOldActStatus == 'Cancelled' || sOldActStatus == 'Done') || (sOldActStatus == 'Cancellation Request' && (sMessageType != 'PartsOrderCancelConfirmation' && sMessageType != 'SvcCallCancelConfirmation' && sMessageType != 'BreakFixCancelConfirmation'))) sActStatus = 'NA';
                        
                        if(sOldActStatus == 'Closed') sStatusCode = 'CLO';
                        else if(sOldActStatus == 'Cancelled') sStatusCode = 'CNL';
                        else if(sOldActStatus == 'Cancellation Request' && sActStatus == 'NA') sStatusCode = 'CNR';
                        
                        if(sActStatus != 'NA'){                                        
                            woDetail.Status = sActStatus;                                        
                        }
                        else if(sMessageType == 'PartsOrderCancelConfirmation' && sServType == 'Parts Only')
                        {
                            if(sPartStatus == 'Cancellation Rejected')
                            {
                                woDetail.Status = sStatusRejected;                    
                            }
                            else if(sPartStatus == 'Cancelled')
                            {
                                woDetail.Status = 'Cancelled';                    
                            }
                        }
                        
                        if(sLaborStatus != 'NA') 
                        {   
                            woDetail.Labor_Status__c = sLaborStatus;
                        }
                        
                        if(sPartStatus != 'NA') 
                        {
                            if(sPartStatus == 'Rejected')
                            {
                                woDetail.Parts_Status__c = sPartStatus;
                                woDetail.Sub_Status__c = 'Rejected';                        
                            }
                            if(sOperType != '' && sOperType!=null)
                            {   
                                po.ISP_Event_Code__c = sEventCode;
                                po.ISP_Operation_Type__c = sOperType;
                                po.ISP_File_Type__c = sStatusCode;
                                woDetail.Parts_Status__c = sPartStatus;                                                     
                            }                   
                        }
                        woDetail.DCCMTEventCode__c = po.ISP_Event_Code__c;
                        if(sOldActStatus == 'Closed' || sOldActStatus == 'Cancelled' || sOldActStatus == 'Rejected') 
                            woDetail.Status = sOldActStatus; 
                        
                        if((sLaborStatus != '') && (sOldLaborStatus != '') && (sOldLaborStatus != sLaborStatus))
                        {
                            if(!DispatchSubmissionProcess.statusUpdateCheck('Labor Status', sOldLaborStatus, sLaborStatus, sRegion, sSubRegion))
                            {
                                woDetail.Labor_Status__c = sOldLaborStatus;                    
                            }
                        }
                        
                        if(sPartStatus != '' && sOldPartsStatus != sPartStatus)
                        {
                            if(!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Parts Status', sOldPartsStatus, sPartStatus, sRegion, sSubRegion))
                            {
                                if (!sMessageType.endsWithIgnoreCase('PartsOrderCompletion') && !sRegion.equalsIgnoreCase('EMEA'))
                                    woDetail.Parts_Status__c = sOldPartsStatus;                         
                            }
                        }
                        
                        if(sActStatus != '' && sOldActStatus != sActStatus)
                        {                        
                            if(!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Status', sOldActStatus, sActStatus, sRegion, sSubRegion))
                            {
                                woDetail.Status = sOldActStatus;
                            }
                        }         
                        woDetailList.add(woDetail);
                    }
                        
                }
                
            }
            
            
            if (woDetailList.size()>0)
                update woDetailList;
        }Catch(Exception e){
            ExceptionHandler.logHandledExceptions(e,'WorkOrderTriggerHandler','performStatusTransitionCheck','Dispatch Management');
        }
    }
}
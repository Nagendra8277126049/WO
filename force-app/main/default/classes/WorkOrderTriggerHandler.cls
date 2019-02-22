/* -----------------------------------------------------------------------------------------------------------------------
Name:         WorkOrderTriggerHandler
Description:  This class contain method that deletes custom reminders and alerts upon update of Groundshipment flag.
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
08/31/2018     1.1     Rodrigo Carpio               check for story #5183322
12/20/2018     1.2      Rayana Alencar              creation of Accidental Damage Notification check for story #5870144 
-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class WorkOrderTriggerHandler {
    
    public static Boolean runonce = true;
    
    //private static List < DispatchETMSetup__c > etmList; // Commented By Harsha - 09/19/2018
    /* -----------------------------------------------------------------------------------------------------------------------
Name:       performStatusTransitionCheck
Description:  this function contains the logic of status transition check story #5183322
Input: 
Output: None
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/01/2018     1.0     Rodrigo Carpio    Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
    // Commented By Harsha - Since Code is Not Bulkified
    /*
private static WorkOrder performStatusTransitionCheck(WorkOrder localWorkOrder, string oldStatus )
{
try{
string activityStatus;
string currStatus = localWorkOrder.Status;
string sRegion = localWorkOrder.DPS_Region__c;
string sSubRegion = localWorkOrder.DPS_Sub_Region__c;
string sMessageType = localWorkOrder.MessageTypeID__c;

etmList = new List < DispatchETMSetup__c >();
if(localWorkOrder.MessageTypeID__c == 'BreakFixCreationConfirmation') {
currStatus = 'Awaiting Acknowledgement';
activityStatus = currStatus;
if(currStatus != oldStatus)
if (!PartnerUpdatesProcess.statusUpdateCheck('Dispatch Status', oldStatus, currStatus, localWorkOrder.DPS_Region__c, localWorkOrder.DPS_Sub_Region__c))
activityStatus = oldStatus;
localWorkOrder.Status = activityStatus;
}
if(localWorkOrder.MessageTypeID__c == 'DispatchInitializationUpdate') {
if ((oldStatus == 'PUDO Assignment Failure') || (oldStatus == 'DLP Assignment Failure'))
localWorkOrder.Status = 'Awaiting Acknowledgement';
activityStatus = oldStatus;
localWorkOrder.Status = activityStatus;
}
if(localWorkOrder.MessageTypeID__c == 'AdditionalPartRequest') {
localWorkOrder.DispatchEvent__c = 'AdditionalPartRequest';
localWorkOrder.DispatchEventCode__c = 'DY';
}
if(localWorkOrder.MessageTypeID__c == 'ServiceCallConfirmation') {
etmList = [SELECT EventCode__c, FileType__c, OperationType__c, ActivityStatus__c FROM DispatchETMSetup__c
WHERE MessageType__c =: sMessageType AND Region__c =: sRegion AND SubRegion__c =: sSubRegion LIMIT 1]; 
localWorkOrder.Status = etmList[0].ActivityStatus__c;
}

return localWorkOrder;
}Catch(Exception e){
ExceptionHandler.logHandledExceptions(e,'WorkOrderTriggerHandler','performStatusTransitionCheck','Dispatch Management');
return null;
}  
}
*/
    
    // HArsha Code Added Starts Here- 09/19/2018 - Code Bulkification
    public class UniqueKey {
        Public UniqueKey(string messageType, String subRegion, String region, String serviceType) {
            this.messageType = messageType;
            this.subRegion = subRegion;
            this.region = region;
            this.serviceType = serviceType;
        }
        string messageType;
        string subRegion;
        string region;
        string serviceType;
        
        integer hashCode() {
            return toString().hashCode();
        }
        
        boolean equals(Object o) {
            return toString() == ((UniqueKey) o).toString();
        }
        
        public override string toString() {
            return String.format(
                'messageType = \'\'{0}\'\' AND subRegion = \'\'{1}\'\' AND region = \'\'{2}\'\'',
                new String[] {
                    messageType == null ? '' : String.escapeSingleQuotes(messageType.tolowercase()),
                        subRegion == null ? '' : String.escapeSingleQuotes(subRegion.tolowercase()),
                            region == null ? '' : String.escapeSingleQuotes(region.tolowercase()),
                                serviceType == null ? '' : String.escapeSingleQuotes(serviceType.tolowercase())
                                    }
            );
        }
    }
    // HArsha Code Added Ends Here- 09/19/2018 - Code Bulkification
    
    
    /*------------------------------------------------------------------------------------------------------------
Method Name : updateRegionIdonWorkOrder
Description : Update RegionId upon change in CountryCode on WorkOrder
--------------------------------------------------------------------------------------------------------------  */
    public static void updateRegionIdonWorkOrder(Map < Id, WorkOrder > oldMap, Map < Id, WorkOrder > newMap) {
        try {
            WorkOrderTriggerHandler.runonce = false; //change to a generic class later.
            set < String > setCountryCode = new set < String > ();
            Map < String, Asset_Country__mdt > mapCountryCodeToAssetCountry = new Map < String, Asset_Country__mdt > ();
            List < WorkOrder > listCountryCodeChanged = new List < WorkOrder > ();
            List < String > splitCriteriaList = new List < String > ();
            List < String > tempSplitList = new List < String > ();
            List < DispatchETMSetup__c > etmList = new List < DispatchETMSetup__c > (); // Added By HArsha  09/19/2018 - Code Bulkification
            Set < String > setRegionCode = new Set < String > (); // Added By HArsha  09/19/2018 - Code Bulkification
            set < String > setMessageType = new Set < String > (); // Added By HArsha  09/19/2018 - Code Bulkification
            Set < String > setSubRegionCode = new Set < String > (); // Added By HArsha  09/19/2018 - Code Bulkification
            Set < String > setServiceType = new Set < String > ();
            Set < String > setPartsStatus = new Set < String > ();
            Set < String > setSubStatus = new Set < String > ();
            List < WorkOrder > listETMLogicWorkOrders = new List < WorkOrder > (); // Added By HArsha  09/19/2018 - Code Bulkification
            List < WorkOrder > BrazilWorkOrderList = new List < WorkOrder > ();
            Set < String > LatamCountrySet = new Set < String > ();
            string messageTypeId = '';
            string dpsRegion = '';
            string dpsSubRegion = '';
            string serviceType = '';
            string oldStatus = '';
            string oldLaborStatus = '';
            string oldPartsStatus = '';
            string profileInfo = [select id, Name from Profile where id =: Userinfo.getProfileid() LIMIT 1].Name;
            Id submittedLatamRecTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Submitted - Latam').getRecordTypeId();
            // Moved Above Query to Outside for Loop - By Harsha - 09/19/2018
            /*
A Trigger is called separately for each Users actions. 
Even if two users do the same action at the same time you will get one invocation for each
- Harsha - 09/19/2018
*/
            //Added LIMIT in SOQL - Harsha - 09/19/2018
            System.debug('Akhil++Before validation rule, before trigger is fired');
            for (WorkOrder wo: newMap.values()) {
                if (wo.WO_Type__c.equalsIgnoreCase('Break Fix')) {
                    if (((wo.Dispatch_Country__c != oldMap.get(wo.Id).Dispatch_Country__c && String.isNotBlank(wo.Dispatch_Country__c)) || 
                         (wo.Status != oldMap.get(wo.Id).Status && String.isNotBlank(wo.Dispatch_Country__c))) 
                        && wo.Dispatch_Country__c.equalsIgnoreCase('Latam') && !wo.Status.equalsIgnoreCase('Open') 
                        && !wo.Status.equalsIgnoreCase('Pending Schedule') && !wo.Status.equalsIgnoreCase('Rework')
                        && !wo.Status.equalsIgnoreCase('Pending Review')) 
                    {
                        wo.RecordTypeId = submittedLatamRecTypeId;
                    }                  
                    
                    if (wo.Dispatch_Country__c != oldMap.get(wo.Id).Dispatch_Country__c && String.isNotBlank(wo.Dispatch_Country__c)) {
                        wo.Street = '';
                        wo.PostalCode = '';
                        wo.Country = '';
                        wo.City = '';
                        wo.Address_Line_1__c = '';
                        wo.Address_Line_2__c = '';
                        wo.Address_Line_2__c = '';
                        wo.Address_Line_3__c = '';
                        wo.Address_Line_4__c = '';
                        wo.State = '';
                        wo.Country__c = '';
                        wo.City_new__c = null;
                        wo.City__c = '';
                        wo.State__c = '';
                        wo.Zip_Code__c = '';
                        wo.CountryCode__c = '';
                        wo.StateCode__c = '';
                    }
                    
                    //Profile profileInfo = [select id,Name from Profile where id=:Userinfo.getProfileid()];
                    //Above Query is Commented By Harsha - Since Code is Not Bulkified.
                    //if((profileInfo.Name =='Service Integration Profile' || profileInfo.Name =='System Administrator') && wo.MessageTypeID__c != '')
                    messageTypeId = wo.MessageTypeID__c;
                    dpsRegion = wo.DPS_Region__c;
                    dpsSubRegion = wo.DPS_Sub_Region__c;
                    serviceType = wo.Service_Type__c;
                    if ((profileInfo.equalsIgnoreCase('Service Integration Profile')) && string.isNotBlank(wo.MessageTypeID__c)) // This Line Modified By Harsha
                        // Move the Profile Names to Custom Labels - Harsha - 09/19/2018
                    {
                        
                        //wo = performStatusTransitionCheck(wo, oldMap.get(wo.Id).Status); // commented by Harsha - As Code is nOt Bulkified ...
                        // HArsha Code Added Starts Here- 09/19/2018 - Code Bulkification
                        system.debug('messageTypeId ' + messageTypeId);
                        if (string.isNotBlank(messageTypeId)) {
                            oldPartsStatus = wo.Parts_Status__c;
                            wo.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                            // if (messageTypeId.equalsIgnoreCase('ServiceCallConfirmation') || messageTypeId.equalsIgnoreCase('SvcCallCancelConfirmation')) {
                            if (messageTypeId.equalsIgnoreCase('ServiceCallConfirmation') || messageTypeId.equalsIgnoreCase('BreakFixCancelConfirmation') ) {
                                
                                // Move the Hard Coded Values to Custom Label - Harsha 
                                if (dpsRegion.equalsIgnoreCase('AMERICAS')) {
                                    setMessageType.add(messageTypeId);
                                    if (String.isNotBlank(dpsRegion)) {
                                        setRegionCode.add(dpsRegion);
                                    }
                                    if (String.isNotBlank(dpsSubRegion)) {
                                        setSubRegionCode.add(dpsSubRegion);
                                    }
                                    listETMLogicWorkOrders.add(wo);
                                }
                                system.debug('listETMLogicWorkOrders ' + listETMLogicWorkOrders);
                            } else if (wo.MessageTypeID__c.equalsIgnoreCase('AdditionalPartRequest')) {
                                // Move the Hard Coded Values to Custom Label - Harsha 
                                wo.DispatchEvent__c = 'AdditionalPartRequest';
                                wo.DispatchEventCode__c = 'DY';
                                //wo.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                            } else if (wo.MessageTypeID__c.equalsIgnoreCase('DispatchInitializationUpdate')) {
                                // Move the Hard Coded Values to Custom Label - Harsha 
                                if ((oldMap.get(wo.Id).Status.equalsIgnoreCase('PUDO Assignment Failure')) || (oldMap.get(wo.Id).Status.equalsIgnoreCase('DLP Assignment Failure'))) {
                                    wo.Status = 'Awaiting Acknowledgement';
                                }
                                wo.Status = oldMap.get(wo.Id).Status;
                            } else if (wo.MessageTypeID__c.equalsIgnoreCase('BreakFixCreationConfirmation')) {
                                // Move the Hard Coded Values to Custom Label - Harsha 
                                wo.Status = 'Awaiting Acknowledgement';
                                //wo.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                                if (!oldMap.get(wo.Id).Status.equalsIgnoreCase('Awaiting Acknowledgement')) {
                                    if (!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Status', oldMap.get(wo.Id).Status, 'Awaiting Acknowledgement', wo.DPS_Region__c, wo.DPS_Sub_Region__c)) {
                                        wo.Status = oldMap.get(wo.Id).Status;
                                    }
                                }
                            }
                            
                            // EMEA 
                            if (dpsRegion.equalsIgnoreCase('EMEA')) {
                                string serviceTypeLoc = '';
                                if (messageTypeId == 'PartsOrderConfirmation' || messageTypeId == 'PartsOrderRejection' || messageTypeId == 'PartsOrderCompletion')
                                    serviceTypeLoc = serviceType;
                                else
                                    serviceTypeLoc = 'NA';
                                setMessageType.add(messageTypeId);
                                if (String.isNotBlank(dpsRegion)) {
                                    
                                    setRegionCode.add(dpsRegion);
                                }
                                setServiceType.add(serviceTypeLoc);
                                
                                if (String.isNotBlank(dpsSubRegion)) {
                                    setSubRegionCode.add(dpsSubRegion);
                                }
                                listETMLogicWorkOrders.add(wo);
                            }
                            // AP
                            if (dpsRegion.equalsIgnoreCase('AP')) {
                                string serviceTypeLoc = '';
								if (messageTypeId == 'PartsOrderConfirmation')
									serviceTypeLoc = serviceType;
								if (messageTypeId == 'PartsStatusUpdate')
									serviceTypeLoc = 'NA';
                                if (String.isNotBlank(dpsSubRegion)) {
                                    setSubRegionCode.add(dpsSubRegion);
                                }
                                if (messageTypeId == 'PartsOrderCancelConfirmation') 
                                {
                                    //wo.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                                    wo.Parts_Status__c = 'Cancelled';
                                    wo.DispatchEventCode__c = 'CC';
                                    //wo.DispatchEvent__c = 'TRN';
                                    
                                } 
                                else if (messageTypeId == 'PartsOrderCancelConfirmationRejection') 
                                {
                                    wo.Parts_Status__c = 'Cancellation Rejected';
                                    //wo.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                                    if (wo.Status == 'Cancellation Request' && wo.Labor_Status__c == 'Service Call Closure')
                                        wo.Status = 'Service Complete';
                                    else if (wo.Labor_Status__c == '')
                                        wo.Status = 'Work In Progress';
                                    
                                    if (serviceType.equalsIgnoreCase('Parts Only'))
                                        wo.Status = 'Work In Progress';
                                    
                                    if (wo.Parts_Status__c.equalsIgnoreCase('Acknowledged')) {
                                        if (String.isNotBlank(dpsRegion)) {
                                            setRegionCode.add(dpsRegion);
                                        }
                                        setServiceType.add(serviceType);
                                        setPartsStatus.add(oldPartsStatus);
                                        
                                        listETMLogicWorkOrders.add(wo);
                                    } else {
                                        if (String.isNotBlank(dpsRegion)) {
                                            setRegionCode.add(dpsRegion);
                                        }
                                        setPartsStatus.add(oldPartsStatus);
                                        
                                        listETMLogicWorkOrders.add(wo);
                                    }
                                } else {
                                    if (messageTypeId == 'TradeComplianceUpdate') 
                                    {
                                        setSubStatus.add(wo.Sub_Status__c);
                                        if (String.isNotBlank(dpsRegion)) {
                                            setRegionCode.add(dpsRegion);
                                        }
                                        listETMLogicWorkOrders.add(wo);
                                        setMessageType.add(messageTypeId);
                                    } else if (messageTypeId == 'PartsOrderConfirmation') 
                                    {
                                        setMessageType.add(messageTypeId);
                                        if (String.isNotBlank(dpsRegion)) {
                                            setRegionCode.add(dpsRegion);
                                        }
                                        setServiceType.add(serviceType);
                                    } else {
                                        if (!messageTypeId.equalsIgnoreCase('PartsStatusUpdate')) 
                                        {
                                            setMessageType.add(messageTypeId);
                                        	if (String.isNotBlank(dpsRegion)) {
                                            	setRegionCode.add(dpsRegion);
                                        	}
                                        //if (messageTypeId == 'PartsStatusUpdate')
										//		setServiceType.add(serviceTypeLoc);
                                        	listETMLogicWorkOrders.add(wo);
                                        }                                        
                                    }
                                }
                            }
                        }
                        // HArsha Code Added Ends Here- 09/19/2018 - Code Bulkification
                    }
                    
                    System.debug('Akhil++ EMEA country oldMap.get(wo.Id).CountryCode ' + oldMap.get(wo.Id).CountryCode);
                    if (wo.CountryCode != oldMap.get(wo.Id).CountryCode && (String.isNotEmpty(wo.CountryCode))) 
                    {
                        System.debug('Akhil++ EMEA country captured');
                        setCountryCode.add(wo.CountryCode);
                        listCountryCodeChanged.add(wo);
                    } else {
                        if (String.isEmpty(wo.PartnerWorkOrderNumber__c) && String.isNotEmpty(wo.CountryCode)) {
                            System.debug('Akhil++ EMEA country captured String.isEmpty(wo.PartnerWorkOrderNumber__c) && String.isNotEmpty(wo.CountryCode)');
                            setCountryCode.add(wo.CountryCode);
                            listCountryCodeChanged.add(wo);
                        }
                        /*else if (String.isEmpty(wo.PartnerWorkOrderNumber__c) && wo.Dispatch_Country__c.equalsIgnoreCase('LATAM') && String.isEmpty(wo.CountryCode)) {

System.debug('Akhil++ EMEA country captured String.isEmpty(wo.CountryCode)');
setCountryCode.add(wo.CountryCode__c);
listCountryCodeChanged.add(wo);
}*/
                    }
                    
                    if (wo.Approval_Criteria_Met__c != oldMap.get(wo.Id).Approval_Criteria_Met__c &&
                        String.isNotEmpty(wo.Approval_Criteria_Met__c) &&
                        wo.Approval_Criteria_Met__c.contains('||')) {
                            splitCriteriaList = wo.Approval_Criteria_Met__c.replace('||', ',').split(',');
                            
                            for (String s: splitCriteriaList) {
                                if (string.isNotEmpty(s) && string.isNotBlank(s)) {
                                    tempSplitList.add(s);
                                }
                            }
                            
                            if (tempSplitList.size() > 0 && !tempSplitList.isEmpty()) {
                                wo.Approval_Criteria_Met__c = string.join(tempSplitList, ',');
                            }
                            tempSplitList.clear();
                            splitCriteriaList.Clear();
                        }
                    
                    //Akhil-Added to update Brazil State value
                    System.debug('Akhil++ custom label value:' + System.Label.LatamCountries);
                    System.debug('Akhil++ Country Code is:' + wo.CountryCode);
                    System.debug('Akhil++ Country Code is:' + wo.CountryCode__c);
                    System.debug('Akhil++ Country is:' + wo.Country);
                    System.debug('Akhil++ Old Country is:' + oldMap.get(wo.Id).Country);
                    System.debug('Akhil++ Old CountryCode is:' + oldMap.get(wo.Id).CountryCode);
                    System.debug('Akhil++ State is:' + wo.State);
                    System.debug('Akhil++ State latam is:' + wo.State__c);
                    System.debug('Akhil++ StateCode is:' + wo.StateCode);
                    /*if(wo.CountryCode!=null){
if(System.Label.LatamCountries.contains(wo.CountryCode)&& wo.State<>NULL && wo.StateCode<>NULL&&wo.State__c==NULL){
System.debug('Akhil++ Setting up latam country and state fields');
wo.State__c=wo.State;
wo.Country__c=wo.Country;
}
}*/
                    //Logic to update Region and BUID for Brazil
                    System.debug('Country old value Akhil++' + oldMap.get(wo.Id).Country);
                    System.debug('Akhil++ Setting up latam BUID. Old CountryCode is:' + oldMap.get(wo.Id).CountryCode);
                    if (wo.Country != null) {
                        if (System.Label.LatamCountryNames.contains(wo.Country) && (oldMap.get(wo.Id).Country != wo.Country) && String.isNotEmpty(wo.Country)) {
                            System.debug('Akhil++ Setting up latam BUID. Country Code is:' + wo.CountryCode);
                            System.debug('Akhil++ Setting up latam BUID. Country is:' + wo.Country);
                            System.debug('Akhil++ Setting up latam BUID. Old Country is:' + oldMap.get(wo.Id).Country);
                            System.debug('Akhil++ Setting up latam BUID. Old CountryCode is:' + oldMap.get(wo.Id).CountryCode);
                            BrazilWorkOrderList.add(wo);
                            LatamCountrySet.add(wo.Country);
                        }
                    }
                    else {
                        // added by Rodrigo for DEFECT 5764486
                        if (wo.Country__c != null) 
                        {
                            //wo.Country = wo.Country__c;
                            BrazilWorkOrderList.add(wo);
                            LatamCountrySet.add(wo.Country__c);
                        } // ends here DEFECT 5764486
                    }
                }
                
            }
            
            
            // HArsha Code Added Starts Here- 09/19/2018 - Code Bulikfication
            if (!setMessageType.isEmpty() && !setSubRegionCode.isEmpty() && !setRegionCode.isEmpty() && !listETMLogicWorkOrders.isEmpty()) {
                UniqueKey uKey;
                Map < UniqueKey, DispatchETMSetup__c > mapDETM = new Map < UniqueKey, DispatchETMSetup__c > ();
                system.debug('setMessageType' +setMessageType+ 'setRegionCode' +setRegionCode+ 'setSubRegionCode' +setSubRegionCode+ 'setServiceType' +setServiceType+ 'setSubStatus' +setSubStatus);
                for (DispatchETMSetup__c dETM: [SELECT EventCode__c, FileType__c, OperationType__c, ProgressEvent__c,
                                                ActivityStatus__c, MessageType__c, Region__c, SubRegion__c, ServiceType__c, LaborStatus__c, PartsStatus__c
                                                FROM DispatchETMSetup__c
                                                WHERE MessageType__c IN: setMessageType
                                                AND Region__c IN: setRegionCode
                                                AND(SubRegion__c IN: setSubRegionCode OR ServiceType__c IN: setServiceType OR ProgressEvent__c IN: setSubStatus)
                                                LIMIT 50000
                                               ]) {
                                                   mapDETM.put(new UniqueKey(dETM.MessageType__c, dETM.SubRegion__c, dETM.Region__c, dETM.ServiceType__c), dETM);                                                   
                                               }                
                if (!mapDETM.isEmpty() && !listETMLogicWorkOrders.isEmpty()) {
                    for (WorkOrder wo: listETMLogicWorkOrders) {                        
                        string servType;
                        if (!dpsRegion.equalsIgnoreCase('AMERICAS') && messageTypeId.equalsIgnoreCase('BreakFixCancelConfirmation') || dpsRegion.equalsIgnoreCase('AP') && messageTypeId.equalsIgnoreCase('PartsStatusUpdate'))
                            servType = 'NA';
                        else 
                            servType = wo.Service_Type__c;
                        if (mapDETM.containsKey(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, servType))) {
                            if (string.isNotBlank(mapDETM.get(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, servType)).ActivityStatus__c)) {
                                wo.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                                oldStatus = wo.status;
                                system.debug('getting the oldStatus ' + oldStatus);
                                string localStatus = mapDETM.get(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, servType)).ActivityStatus__c;
                                if (!localStatus.equalsIgnoreCase('NA'))
                                    wo.status = localStatus;
                                system.debug('getting the localStatus ' + localStatus);
                                oldLaborStatus = wo.Labor_Status__c;
                                string localLaborStatus = mapDETM.get(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, servType)).LaborStatus__c;
                                if (!localLaborStatus.equalsIgnoreCase('NA'))
                                    wo.Labor_Status__c = localLaborStatus;
                                
                                oldPartsStatus = wo.Parts_Status__c;
                                string localPartsStatus = mapDETM.get(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, servType)).PartsStatus__c;
                                if (!localPartsStatus.equalsIgnoreCase('NA'))
                                    wo.Parts_Status__c = localPartsStatus;
                                
                                if (dpsRegion.equalsIgnoreCase('AP')) {
                                    string eventCode = mapDETM.get(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, servType)).EventCode__c;
                                    if (!eventCode.equalsIgnoreCase('NA'))
                                        wo.DispatchEventCode__c = eventCode;
                                    
                                    //string operationType = mapDETM.get(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, servType)).OperationType__c;
                                    //if (!localStatus.equalsIgnoreCase('NA'))
                                    //    wo.DispatchEvent__c = operationType;
                                    
                                    //string statusCode = mapDETM.get(new UniqueKey(wo.MessageTypeID__c, wo.DPS_Sub_Region__c, wo.DPS_Region__c, wo.Service_Type__c)).FileType__c;
                                    //if (!statusCode.equalsIgnoreCase('NA'))
                                    //    wo.Status_Code__c = statusCode;
                                    
                                    if ((localLaborStatus != '') && (oldLaborStatus != '') && (oldLaborStatus != localLaborStatus)) {
                                        if (!DispatchSubmissionProcess.statusUpdateCheck('Labor Status', oldLaborStatus, localLaborStatus, dpsRegion, '')) {
                                            wo.Labor_Status__c = oldLaborStatus;
                                        }
                                    }
                                    
                                    if ((localPartsStatus != '') && (oldPartsStatus != '') && (oldPartsStatus != localPartsStatus) && (localPartsStatus != 'Cancellation Rejected') && (messageTypeId != 'PartsOrderCancelConfirmation')) {
                                        if (!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Parts Status', oldPartsStatus, localPartsStatus, dpsRegion, '')) {
                                            wo.Parts_Status__c = oldPartsStatus;
                                        }
                                    }
                                    
                                    if ((localPartsStatus != '' && oldPartsStatus != '') && (oldPartsStatus != localPartsStatus) && (messageTypeId == 'PartsOrderCancelConfirmation') && (dpsRegion == 'EMEA')) {
                                        if (localPartsStatus == 'Cancellation Rejected') {
                                            wo.Parts_Status__c = oldPartsStatus;
                                        }
                                    }
                                    
                                    if (localStatus != '' && oldStatus != localStatus) {
                                        if (!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Status', oldStatus, localStatus, dpsRegion, '')) {
                                            wo.Status = oldStatus;
                                        }
                                    }
                                }
                                if (dpsRegion.equalsIgnoreCase('EMEA')) {
                                    if ((localLaborStatus != '') && (oldLaborStatus != '') && (oldLaborStatus != localLaborStatus)) {
                                        if (!DispatchSubmissionProcess.statusUpdateCheck('Labor Status', oldLaborStatus, localLaborStatus, dpsRegion, dpsRegion)) {
                                            wo.Labor_Status__c = oldLaborStatus;
                                        }
                                    }
                                    
                                    if ((localPartsStatus != '') && (oldPartsStatus != '') && (oldPartsStatus != localPartsStatus) && (localPartsStatus != 'Cancellation Rejected') && (messageTypeId != 'PartsOrderCancelConfirmation')) {
                                        if (!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Parts Status', oldPartsStatus, localPartsStatus, dpsRegion, dpsRegion)) {
                                            wo.Parts_Status__c = oldPartsStatus;
                                        }
                                    }
                                    
                                    if ((localPartsStatus != '' && oldPartsStatus != '') && (oldPartsStatus != localPartsStatus) && (messageTypeId == 'PartsOrderCancelConfirmation') && (dpsRegion == 'EMEA')) {
                                        if (localPartsStatus == 'Cancellation Rejected') {
                                            wo.Parts_Status__c = oldPartsStatus;
                                        }
                                    }
                                    
                                    if (localStatus != '' && oldStatus != localStatus) {
                                        if (!DispatchSubmissionProcess.statusUpdateCheck('Dispatch Status', oldStatus, localStatus, dpsRegion, dpsRegion)) {
                                            wo.Status = oldStatus;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // HArsha Code Added Ends Here- 09/19/2018 - Code Bulkification
            
            if (!setCountryCode.isEmpty()) {
                for (Asset_Country__mdt objAssetCountry: [SELECT RegionId__c, CountryCode__c, CountryBUID__c, RegionName__c, SubRegionName__c, CountryDPSCode__c
                                                          FROM Asset_Country__mdt
                                                          WHERE Active__c = true AND CountryCode__c IN: setCountryCode
                                                         ]) {
                                                             mapCountryCodeToAssetCountry.put(objAssetCountry.CountryCode__c, objAssetCountry);
                                                         }
            }
            System.debug('Checking whether list of Emea countries is empty:' + listCountryCodeChanged);
            System.debug('Checking whether list of Emea countries empty is true or false:' + listCountryCodeChanged.isEmpty());
            if (!listCountryCodeChanged.isEmpty())
            {
                System.debug('Akhil++Inside EMEA entry region');
                // assign RegionId values from matched Asset Country metadataType 
                for (WorkOrder wo: listCountryCodeChanged) {
                    if (mapCountryCodeToAssetCountry.containsKey(wo.CountryCode)) {
                        System.debug('Akhil++Inside EMEA copying Region');
                        wo.Region__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).RegionId__c;
                        wo.DPS_BUID__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).CountryBUID__c;
                        wo.DPS_Region__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).RegionName__c;
                        wo.CountryCode__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).CountryCode__c;
                        wo.DPS_Sub_Region__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).SubRegionName__c;
						//wo.CustomerRegion__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).RegionId__c; 
                        
                        /*
if (!mapCountryCodeToAssetCountry.get(wo.CountryCode).RegionId__c.equals('1')) {
wo.PartnerWorkOrderNumber__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).CountryDPSCode__c + wo.WorkOrderNumber;
} else {
wo.PartnerWorkOrderNumber__c = wo.WorkOrderNumber;
}
*/
                        System.debug('Work order for update' + wo);
                    } else {
                        wo.addError('Lightning Work Order is not available in this Country');
                    }
                }
            }
            
            //Logic to update Region and BUID for Brazil
            if (BrazilWorkOrderList.size() > 0) {
                System.debug('Akhil++ Inside BrazilWorkOrderList');
                List < Asset_Country__mdt > objAssetCountryList = [SELECT RegionId__c, CountryCode__c, CountryBUID__c, RegionName__c, SubRegionName__c, CountryDPSCode__c, MasterLabel FROM Asset_Country__mdt WHERE Active__c = true AND MasterLabel IN: LatamCountrySet];
                Map < String, Asset_Country__mdt > objAssetCountryMap = new Map < String, Asset_Country__mdt > ();
                System.debug('Akhil++ Inside BrazilWorkOrderList--QueryResult:' + objAssetCountryList);
                for (Asset_Country__mdt obj: objAssetCountryList) {
                    objAssetCountryMap.put(obj.MasterLabel, obj);
                }
                if (objAssetCountryMap <> NULL && objAssetCountryMap.size() > 0) {
                    System.debug('Akhil++ Inside LATAM BUID Setup:' + objAssetCountryMap);
                    for (WorkOrder wo: BrazilWorkOrderList) {
                        System.debug('Akhil++Inside LATAM copying Region');
                        Asset_Country__mdt objAssetCountry;
                        if (string.isNotEmpty(wo.Country)) //added by Rodrigo for DEFECT 5764486
                            objAssetCountry = objAssetCountryMap.get(wo.Country);
                        else //added by Rodrigo for DEFECT 5764486
                            objAssetCountry = objAssetCountryMap.get(wo.Country__c);
                        wo.Region__c = objAssetCountry.RegionId__c;
                        wo.DPS_BUID__c = objAssetCountry.CountryBUID__c;
                        wo.DPS_Region__c = objAssetCountry.RegionName__c;
                        wo.CountryCode__c = objAssetCountry.CountryCode__c;
                        wo.DPS_Sub_Region__c = objAssetCountry.SubRegionName__c;
                        wo.CountryCode = objAssetCountry.CountryCode__c;//added by Rodrigo for DEFECT 5764486
                        wo.CustomerRegion__c = objAssetCountry.RegionId__c; //added by Rodrigo for DEFECT 6115974
                    } 
                }
            }
        }
        Catch(Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'updateRegionIdonWorkOrder', 'updateRegionIdonWorkOrder', 'Dispatch Management');
        }
    }
    
    /*------------------------------------------------------------------------------------------------------------
Method Name : deleteReminders
Description : Used to delete custom reminders and alerts based on Ground shipment flag
--------------------------------------------------------------------------------------------------------------  */
    @InvocableMethod(label = 'Delete Reminders'
                     description = 'Delete the customer Reminders')
    public static void deleteReminders(List < Id > workorderId) {
        List < WorkOrder > workorderList = new List < WorkOrder > ();
        List < Customer_Reminder__c > crListforGroundShipment = new List < Customer_Reminder__c > ();
        List < Customer_Reminder__c > crListforOverRideGroundShipment = new List < Customer_Reminder__c > ();
        List < Customer_Reminder__c > delcrList = new List < Customer_Reminder__c > ();
        List < Dispatch_Alert__c > delAlerts = new List < Dispatch_Alert__c > ();
        List < Dispatch_Alert__c > alertListforGroundShipment = new List < Dispatch_Alert__c > ();
        Set < Id > groundshipmentforAlertIds = new Set < Id > ();
        Set < Id > groundShipmentIds = new Set < Id > ();
        Set < Id > groundShipmentIdsforDel = new Set < Id > ();
        Set < Id > OverRideGroundShipmentIds = new Set < Id > ();
        
        for (WorkOrder wl: [Select Ground_Shipment_Flag__c, Override_Ground_Shipment__c from WorkOrder where Id in: workorderId LIMIT 10000]) {
            // Added LIMIT in SOQL By Harsha - 09/19/2018
            if (!wl.Ground_Shipment_Flag__c || wl.Override_Ground_Shipment__c) {
                groundShipmentIds.add(wl.Id);
            }
            if (!wl.Override_Ground_Shipment__c) {
                OverRideGroundShipmentIds.add(wl.id);
            }
            
            if (wl.Ground_Shipment_Flag__c) {
                groundshipmentforAlertIds.add(wl.Id);
            }
        }
        if (groundShipmentIds.size() > 0) {
            crListforGroundShipment = [Select Id, Type__c from Customer_Reminder__c where Work_Order__c in: groundShipmentIds and Type__c = 'Ground Shipment Flag'
                                       LIMIT 10000
                                      ];
            // Added LIMIT in SOQL By Harsha - 09/19/2018
            if (!crListforGroundShipment.isEmpty()) {
                delcrList.addall(crListforGroundShipment);
            }
        }
        
        if (OverRideGroundShipmentIds.size() > 0) {
            crListforOverRideGroundShipment = [Select Id, Type__c from Customer_Reminder__c where Work_Order__c in: OverRideGroundShipmentIds and Type__c = 'Override Ground Shipment'
                                               LIMIT 10000
                                              ];
            // Added LIMIT in SOQL By Harsha - 09/19/2018
            if (!crListforOverRideGroundShipment.isEmpty()) {
                delcrList.addall(crListforOverRideGroundShipment);
            }
        }
        
        if (!groundshipmentforAlertIds.isEmpty()) {
            alertListforGroundShipment = [Select Id, Alert_Reason__c from Dispatch_Alert__c where Work_Order__c in: groundshipmentforAlertIds and Alert_Reason__c = 'Ground Shipment Battery Delete'
                                          LIMIT 10000
                                         ];
            // Added LIMIT in SOQL By Harsha - 09/19/2018
            if (!alertListforGroundShipment.isEmpty()) {
                delAlerts.addall(alertListforGroundShipment);
            }
        }
        
        if (!delcrList.isEmpty()) {
            try {
                delete delcrList;
            }
            Catch(exception e) {
                ExceptionHandler.logHandledExceptions(e, 'WorkOrderTriggerHandler ', 'deleteReminders', 'EntitlementManagement');
                return;
            }
        }
        
        if (!delAlerts.isEmpty()) {
            try {
                delete delAlerts;
            }
            Catch(exception e) {
                ExceptionHandler.logHandledExceptions(e, 'WorkOrderTriggerHandler ', 'deleteAlerts', 'EntitlementManagement');
                return;
            }
        }
    }
    public static void updatePartnerWorkOrderNumber(List < WorkOrder > wlist) {
        List < WorkOrder > wolist = wlist;
        List < WorkOrder > updateWorkorder = new List < WorkOrder >();
        
        set < String > setCountryCode = new set < String > ();
        Map < String, Asset_Country__mdt > mapCountryCodeToAssetCountry = new Map < String, Asset_Country__mdt > ();
        
        for (WorkOrder wo: wolist) {
            if (String.isNotEmpty(wo.CountryCode)) {
                setCountryCode.add(wo.CountryCode);
            }
            
            
        }
        if (!setCountryCode.isEmpty()) {
            for (Asset_Country__mdt objAssetCountry: [SELECT RegionId__c, CountryCode__c, CountryBUID__c, RegionName__c, SubRegionName__c, CountryDPSCode__c
                                                      FROM Asset_Country__mdt
                                                      WHERE Active__c = true AND CountryCode__c IN: setCountryCode
                                                     ]) {
                                                         mapCountryCodeToAssetCountry.put(objAssetCountry.CountryCode__c, objAssetCountry);
                                                     }
        }
        for (WorkOrder w: wolist) {
            WorkOrder wo = new WorkOrder();
            wo.id = w.id;
            if (!mapCountryCodeToAssetCountry.get(w.CountryCode).RegionId__c.equals('1')) {
               /* if(mapCountryCodeToAssetCountry.containsKey(w.CountryCode)){
                    if(String.isNotBlank(mapCountryCodeToAssetCountry.get(w.CountryCode).CountryDPSCode__c)){
                        wo.PartnerWorkOrderNumber__c = mapCountryCodeToAssetCountry.get(w.CountryCode).CountryDPSCode__c + wo.WorkOrderNumber;
                    } else{
                        wo.PartnerWorkOrderNumber__c = wo.WorkOrderNumber;
                    }
                } else{
                    wo.PartnerWorkOrderNumber__c = wo.WorkOrderNumber;
                }*/
                wo.PartnerWorkOrderNumber__c = mapCountryCodeToAssetCountry.get(w.CountryCode).CountryDPSCode__c + wo.WorkOrderNumber;
            } else {
                wo.PartnerWorkOrderNumber__c = wo.WorkOrderNumber;
            }
            updateWorkorder.add(wo);
        }
        
        update updateWorkorder;
    }
    
    public static void PopulateCityLookup(List < WorkOrder > wolist) {
        List < String > cityList = new List < String > ();
        Map < String, Id > mapofcityname = new Map < String, Id > ();
        for (Integer i = 0; i < wolist.size(); i++) {
            if (wolist[i].city__c != null) {
                cityList.add(wolist[i].city__c);
            }
        }
        
        if (!cityList.Isempty()) {
            for (Address_Data__c dd: [Select Id, name from Address_Data__c where name in: cityList]) {
                
                mapofcityname.put(dd.name.toLowerCase(), dd.Id);
                
            }
        }
        
        for (WorkOrder w: wolist) {
            if (w.city__c != null) {
                w.City_new__c = mapofcityname.get(w.city__c.toLowerCase());
            }
        }
    }
    
    public static void populateCities(List < WorkOrder > wlist, Map < Id, WorkOrder > oldmap) {
    WorkOrderTriggerHandler.runonce = false;
                List < Address_Data_GCC__c > citynames = new List < Address_Data_GCC__c > ();
       List < WorkOrder > Wolist = new List < WorkOrder > ();
       Set<String>postalCodeSet= new Set<String>();
       Set<String>countrycodeset= new Set<String>();
        Map < String, List < String >> mapOfNames = new Map < String, List < String >> ();
        Map < String, String > mapofPostcodes = new Map < String, String > ();
        Map<String, String> mapofStatecodes = new Map<String, String>();
        List < String > strList = new List < String > ();
        List<String> strList1 = new List<String>();
        List < String > SetofAddressset = new List < String > ();
                             List<Address_Data_GCC__c> addressList = new List<Address_Data_GCC__c>();
                             Set<String> postalCodeSetAUIN = new Set<String>();
                             
                             
                             
        
        for (WorkOrder w: wlist) {
            if(string.isNotBlank(w.CountryCode) && String.isNotBlank(w.PostalCode) && String.isNotBlank(w.City) && String.isNotBlank(w.region__C) && w.region__C=='4'){ // Added for Defect DEFECT 6029857
                //Akhil - To remove and optimize in FEB Release
                      postalCodeSet.add(w.postalCode);
                      countrycodeset.add(w.CountryCode);

            }
            
        }
        //Akhil - To remove and optimize in FEB Release
        if(!postalCodeSet.isEmpty() && !countrycodeset.isEmpty()){
            List<Address_Data_GCC__c> addList = [Select Name, POSTCODE__c, COUNTRYCODE__c,STATENAME__c from Address_Data_GCC__c where POSTCODE__c in: postalCodeSet AND COUNTRYCODE__c in :countrycodeset];
            if(addList.isEmpty()){
                wlist[0].addError('Zipcode is not valid for the selected Country');
            }
        }
                             
                             
                             if(!postalCodeSet.isEmpty() && !countrycodeset.isEmpty())
                             {
                             addressList = [Select Name, POSTCODE__c, COUNTRYCODE__c,STATENAME__c from Address_Data_GCC__c where POSTCODE__c in: postalCodeSet and COUNTRYCODE__c in: countrycodeset];
                             }
                             
                                      
        for (Address_Data_GCC__c dd : addressList){
            SetofAddressset.add(dd.name);
            if(!mapofPostcodes.containsKey(dd.name))
            {
            mapofPostcodes.put(dd.name, dd.POSTCODE__c);
            }
            
            if(!mapofStatecodes.containsKey(dd.name))
            {
            mapofStatecodes.put(dd.name,dd.STATENAME__c);
            }
            
            

            List < String > temp = mapOfNames.get(dd.COUNTRYCODE__c+dd.POSTCODE__c);

            if (temp == null) {
                mapOfNames.put(dd.COUNTRYCODE__c+dd.POSTCODE__c, new List < String > {
                    dd.name
                });
            } else {
                temp.add(dd.name);
            }
        }

        for (WorkOrder w: Wlist) {
            
            if (w.city != null && mapofPostcodes != null) {

                System.debug('Akhil++ Checking for invalid ZipCode'); //to be removed
                if (mapofNames.get(w.CountryCode+w.PostalCode) != null) {
                    strList = mapOfNames.get(w.CountryCode+w.PostalCode);
                }
                
               strList1= new List<String>();
                for(String s : strList)
                {
                 String str= mapofStatecodes.get(s)+'--'+ s;
                 strList1.add(str);             
                }
                if (!strList1.isEmpty()) {
                    w.Available_Cities__c = String.join(strList1, '||');
                    System.debug('Akhil++ postalCodeChanged');
                    
                    w.Postal_Code_Changed__c = true;
                    
                }
                
                if(!strList.isEmpty() && strList.size()== 1)
                {
                w.City_APJ__c=strList[0];
                w.State_APJ__c=mapofStatecodes.get(strList[0]);
                }
                       if(!strList.isEmpty() && strList.size()>1)
                       {
                         
                         w.State_APJ__c=mapofStatecodes.get(strList[0]);
                       }
            }

        }


    }
    public static void populateLatamAddressfields(List < WorkOrder > wolist) {
        
        Set < String > LatamCountryset = new Set < String > ();
        List < WorkOrder > workOrderList = new List < WorkOrder > ();
        Map < String, Asset_Country__mdt > mapCountryCodeToAssetCountry = new Map < String, Asset_Country__mdt > ();
        // Added Newly
        List < String > latamCountryCodeslist = new List < String > ();
        String temPString = System.Label.LatamCountries;
        if (string.isNotBlank(temPString)) {
            latamCountryCodeslist = temPString.split(',');
        }
        List<WorkOrder> updateWorkOrderList = new List<WorkOrder>();
        List<WorkOrder> newWorkOrderList = new List<WorkOrder>();
        
        newWorkOrderList = [SELECT Id,countryCode,country,state__c,Country__c,DPS_Sub_Region__c,CountryCode__c,DPS_Region__c,
                            DPS_BUID__c,Region__c,State,City__c
                            FROM WorkOrder WHERE Id IN:wolist LIMIT 500];
        
        // Added Newly
        //for (WorkOrder w: wolist) {
        for (WorkOrder w :newWorkOrderList){
            //if(w.country!=null  &&  w.countryCode!=null && System.Label.LatamCountries.contains(w.countryCode))
            if (w.countryCode != null && latamCountryCodeslist.contains(w.countryCode) && w.country!=null && w.City__c!=null && w.State!=null) {
                workOrderList.add(w);
                LatamCountryset.add(w.countryCode);
            }
        }
        
        if (!LatamCountryset.isEmpty()) {
            for (Asset_Country__mdt objAssetCountry: [SELECT RegionId__c, CountryCode__c, CountryBUID__c, RegionName__c, SubRegionName__c,
                                                      CountryDPSCode__c, Label
                                                      FROM Asset_Country__mdt
                                                      WHERE Active__c = true AND CountryCode__c IN: LatamCountryset LIMIt 1000
                                                     ]) {
                                                         mapCountryCodeToAssetCountry.put(objAssetCountry.CountryCode__c, objAssetCountry);
                                                     }
        }
        
        for (WorkOrder wo: workOrderList) {
            if (mapCountryCodeToAssetCountry.get(wo.CountryCode) != null) {
                wo.Region__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).RegionId__c;
                wo.DPS_BUID__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).CountryBUID__c;
                wo.DPS_Region__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).RegionName__c;
                wo.CountryCode__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).CountryCode__c;
                wo.DPS_Sub_Region__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).SubRegionName__c;                
                if (String.isNotBlank(wo.country)) {
                    wo.Country__c = wo.country;
                } else {
                    wo.Country__c = mapCountryCodeToAssetCountry.get(wo.CountryCode).Label;
                }
                wo.state__c = wo.State;                
                updateWorkOrderList.add(wo);
            }
        }
        
        if (updateWorkOrderList.size() > 0) {
            Database.SaveResult[] srList = Database.update(updateWorkOrderList, false);
            //update updateWorkOrderList;
        }
        
    }
    
    public static void updateAddressonLatamUpdate(Map<Id,WorkOrder> oldMap,List<WorkOrder> newWorkOrderList){
        
        for(WorkOrder wo : newWorkOrderList){
            System.debug('Akhil+++ Inside updateAddressonLatamUpdate Old City'+oldMap.get(wo.Id).City__c);
            System.debug('Akhil+++ Inside updateAddressonLatamUpdate Old State'+oldMap.get(wo.Id).State__c);
            System.debug('Akhil+++ Inside updateAddressonLatamUpdate Old Country'+oldMap.get(wo.Id).Country__c);
            System.debug('Akhil+++ Inside updateAddressonLatamUpdate Old Zip Code'+oldMap.get(wo.Id).Zip_Code__c);
            if(wo.City__c <> oldMap.get(wo.Id).City__c){
                System.debug('Akhil+++ Change in City. New City:'+wo.City__c);
                wo.City=wo.City__c;
            }
            if(wo.State__c <> oldMap.get(wo.Id).State__c){
                System.debug('Akhil+++ Change in State. New State:'+wo.State__c);
                wo.State=wo.State__c;
            }
            if(wo.Country__c <> oldMap.get(wo.Id).Country__c){
                System.debug('Akhil+++ Change in Country. New Country:'+wo.Country__c);
                wo.Country=wo.Country__c;
            }
            if(wo.Zip_Code__c <> oldMap.get(wo.Id).Zip_Code__c){
                System.debug('Akhil+++ Change in ZipCode. New ZipCode:'+wo.Zip_Code__c);
                wo.PostalCode=wo.Zip_Code__c;
            }
            if(wo.StateCode <> oldMap.get(wo.Id).StateCode){
                System.debug('Akhil+++ Change in StateCode. New ZipCode:'+wo.StateCode);
                wo.StateCode__c=wo.StateCode;
            }
            if(wo.CountryCode <> oldMap.get(wo.Id).CountryCode){
                System.debug('Akhil+++ Change in CountryCode. New ZipCode:'+wo.CountryCode);
                wo.CountryCode__c=wo.CountryCode;
            }           
            if((wo.Address_Line_1__c <>oldMap.get(wo.Id).Address_Line_1__c)||(wo.Address_Line_2__c <>oldMap.get(wo.Id).Address_Line_2__c)||(wo.Address_Line_3__c <>oldMap.get(wo.Id).Address_Line_3__c)||(wo.Address_Line_4__c <>oldMap.get(wo.Id).Address_Line_4__c)){
                String AddressLine='';
                AddressLine=wo.Address_Line_1__c+'\r\n'+wo.Address_Line_2__c+'\r\n'+wo.Address_Line_3__c+'\r\n'+wo.Address_Line_4__c;
                if(AddressLine.length()>255){
                    AddressLine=AddressLine.substring(0,255);
                }
                wo.Street=AddressLine;
            }
        }
        
    }
    public static void mapLatamCountryStateonInsert(List<WorkOrder> woList){
        
        List<WorkOrder> latamWorkOrderList = new List<WorkOrder>();
        List<String> latamCountryList = new List<String>();
        for(WorkOrder wo : woList){
            
            /*if(wo.CountryCode<>NULL && System.label.LatamCountries.contains(wo.CountryCode)&& wo.StateCode<>NULL && (wo.Country__c==NULL || wo.State__c=NULL){            
CountryStateList.add(wo.CountryCode+'_'+wo.StateCode);  
}*/
            if(wo.CountryCode<>NULL && System.label.LatamCountries.contains(wo.CountryCode)&& (wo.Country__c==NULL || wo.State__c==NULL)){
                latamWorkOrderList.add(wo);
                latamCountryList.add(wo.CountryCode);
            }
        }
        
        if(latamWorkOrderList.size()>0 && latamWorkOrderList<>NULL){
            Map<String,String> countryMap = new Map<String,String>();
            Map<String,LATAMCountryStateMapping__mdt> countryStateMap = new Map<String,LATAMCountryStateMapping__mdt>();
            for(LATAMCountryStateMapping__mdt lcs : [Select Country__c,CountryCode__c,State__c,StateCode__c from LATAMCountryStateMapping__mdt where CountryCode__c IN: latamCountryList]){
                countryStateMap.put(lcs.CountryCode__c+'_'+lcs.StateCode__c,lcs);
                countryMap.put(lcs.CountryCode__c,lcs.Country__c);
            }
            
            for(WorkOrder wo : latamWorkOrderList){
                if(wo.CountryCode<>NULL && wo.StateCode<>NULL && countryStateMap.containsKey(wo.CountryCode+'_'+wo.StateCode)){
                    wo.Country__c=countryStateMap.get(wo.CountryCode+'_'+wo.StateCode).Country__c;
                    wo.State__c=countryStateMap.get(wo.CountryCode+'_'+wo.StateCode).State__c;
                }
                else if(wo.CountryCode<>NULL && countryMap.containsKey(wo.CountryCode)){
                    wo.Country__c = countryMap.get(wo.CountryCode);
                }
            }
            
        }
        
    }
    /* -----------------------------------------------------------------------------------------------------------------------
Name:       deleteAlertOnRejectWorkOrder
Description:  this function contains the logic for deleting alert on WorkOrder Rejection #5605642 
Input: 
Output: None
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
22/11/2019     1.0     Akhil VM          Feb 2019 Release
-------------------------------------------------------------------------------------------------------------------------- */
    
    public static void deleteAlertOnRejectWorkOrder(Map<Id,WorkOrder> oldMap,List<WorkOrder> newWorkOrderList){
        try{
            system.debug('Akhil++ inside deleteAlertOnRejectWorkOrder');
            Set<Id> woSet = new Set<Id>();
            for(WorkOrder wo : newWorkOrderList){
                if(wo.Status<>NULL && wo.Status<>'Rework' && oldMap.get(wo.Id).Status=='Rework'){
                    system.debug('Akhil++ inside deleteAlertOnRejectWorkOrder'+ wo.Id);
                    woSet.add(wo.Id);
                }
            }
            if(woSet<>NULL && woSet.size()>0){
                system.debug('Akhil++ inside deleteAlertOnRejectWorkOrder Set:'+woSet);
                List<Dispatch_Alert__c> alertList =[Select Id from Dispatch_Alert__c where Work_Order__c IN:woSet AND Alert_Reason__c='Work Order has been rejected'];
                system.debug('Akhil++ inside deleteAlertOnRejectWorkOrder List:'+alertList);
                if(alertList.size()>0 && alertList<> NULL){
                    system.debug('Akhil++ inside alsertList'+alertList);
                    Delete alertList;
                }
                
            }   
        }Catch(Exception e){
            ExceptionHandler.logHandledExceptions(e, 'deleteAlertOnRejectWorkOrder', 'deleteAlertOnRejectWorkOrder', 'Dispatch Management');
            System.debug('Error in Exception:'+e.getMessage());
        }
    }
    
    
    /* -----------------------------------------------------------------------------------------------------------------------
Name:       createAdNotification
Description:  this function create or delete Accidental Damage alert in a work order object based on the Einstein classification and AD entitlement
Input: 
Output: None
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
19/12/2019     1.0     Rayana Alencar     STORY 5870144
09/01/2019     1.1     Rayana Alencar     STORY 5870144
-------------------------------------------------------------------------------------------------------------------------- */
    // AD Notification as requested on STORY 5870144
    public static void createAdNotification(List<WorkOrder> orders) {
        // get relation between case and work orders
        Set<ID> workOrdersID = new Set<ID>();      
        Map<ID,List<WorkOrder>> caseWorkOrders     = new Map<ID,List<WorkOrder>>();
        
        for(WorkOrder order: orders) {
            
            List<WorkOrder> workOrders = null;
            if(caseWorkOrders.containsKey(order.CaseId)) {
                workOrders = caseWorkOrders.get(order.CaseId);
                workOrders.add(order);
            } else {
                workOrders = new List<WorkOrder>();
                workOrders.add(order);
                caseWorkOrders.put(order.CaseId,workOrders);
            }
            workOrdersID.add(order.Id);
        }
        
        //get relation between work ordes and alerts
        Map<ID,List<Dispatch_Alert__c>> workOrderAlerts = new Map<ID,List<Dispatch_Alert__c>>();
        List<Dispatch_Alert__c> alerts = [SELECT Id,Name,Work_Order__c, Work_Order__r.CaseID, Alert_Details__c, Alert_Reason__c, Alerts_Id__c
                                          FROM Dispatch_Alert__c 
                                          WHERE Work_Order__c in :workOrdersID and Einstein_AD_Classification__c = True];
        
        //CompleteCareOption__c is related with adEntitlement
        Map<ID,Boolean> workOrderDispatch = new Map<ID,Boolean>();
        List<DispatchDefaults__c> dispatchDefaults = [SELECT Id, CompleteCareOption__c, Work_Order__c FROM DispatchDefaults__c
                                                      WHERE Work_Order__c in :workOrdersID ORDER BY CreatedDate DESC];
        
        
        for(Dispatch_Alert__c alert: alerts) {
            List<Dispatch_Alert__c> adAlerts = null;
            if(workOrderAlerts.containsKey(alert.Work_Order__c)) {
                adAlerts = workOrderAlerts.get(alert.Work_Order__c);
                adAlerts.add(alert);
            } else {
                adAlerts = new List<Dispatch_Alert__c>();
                adAlerts.add(alert);
                workOrderAlerts.put(alert.Work_Order__c,adAlerts);
            }
        }
        
        for(DispatchDefaults__c dispatch: dispatchDefaults) {
            if(!workOrderDispatch.containsKey(dispatch.Work_Order__c)) {
                Boolean adEntitlement = dispatch.CompleteCareOption__c;
                workOrderDispatch.put(dispatch.Work_Order__c,adEntitlement);
            }
        }

        
        //get Einstein Intent information from each case        
        List<Case> cases = [SELECT Id, ADClassification__c, Accidental_Damage_probability__c, Accidental_Damage__c 
                            FROM Case
                            WHERE ID In :caseWorkOrders.keySet()]; 
        
        List<Dispatch_Alert__c> createAlerts = new List<Dispatch_Alert__c>();
        List<Dispatch_Alert__c> deleteAlerts = new List<Dispatch_Alert__c>();
        
        for(Case caseObj: cases){
            List<WorkOrder> workOrders = caseWorkOrders.get(caseObj.id);
            String einteinClassification = caseObj.ADClassification__c;
            Double classificationProb = caseObj.Accidental_Damage_probability__c;
            Boolean isAccidentalDamage = caseObj.Accidental_Damage__c;
            
            //for each work order of a case
            for(WorkOrder workOrderObj: workOrders){
                Boolean alertAlreadyExists = False;
                Boolean adEntitlement = False;
                
                //there is CompleteCareOption__c related with this workOrder
                if(workOrderDispatch.containsKey(workOrderObj.Id)) {
                    adEntitlement = workOrderDispatch.get(workOrderObj.Id);
                }
                
                List<Dispatch_Alert__c> workAlerts = new List<Dispatch_Alert__c>();
                
                if(workOrderAlerts.containsKey(workOrderObj.Id)) {   
                    workAlerts = workOrderAlerts.get(workOrderObj.Id);
                } 
                // alert based on Einstein classification and AD entitlement
                Dispatch_Alert__c adAlert = ADClassificationProcessBuilder.createADAlert(workOrderObj.Id,adEntitlement,isAccidentalDamage,einteinClassification); 
                
                //if there is no CompleteCareOption__c related with this workOrder all AD alert should be deleted       
                if(!workOrderDispatch.containsKey(workOrderObj.Id)) {
                    adAlert = null;
                }
                // delete currently alert on this work order if any and create one if its alert message does not exists
                if(adAlert != null){
                    for(Dispatch_Alert__c alert: workAlerts){
                        if(!((alert.Alert_Details__c.equals(adAlert.Alert_Details__c)) && 
                             (alert.Name.equals(adAlert.Name)) && (alert.Alert_Reason__c.equals(adAlert.Alert_Reason__c)))){
                                 // remove previous AD alert related to this work order
                                 deleteAlerts.add(alert);
                             }else{
                                 alertAlreadyExists = True;
                             }
                    }
                }else{
                    deleteAlerts.addAll(workAlerts);
                }

                if(adAlert != null && !alertAlreadyExists){
                    createAlerts.add(adAlert);
                }
                
            } 
            
            //Add AD alerts 
            insert createAlerts;
            //Remove AD alerts
            delete deleteAlerts;
            
        }
    }
}
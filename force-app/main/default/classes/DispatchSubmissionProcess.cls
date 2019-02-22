/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchSubmissionProcess
Description:  This class contain method that handles work order submission - story #5183322
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
08/31/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class DispatchSubmissionProcess implements Queueable {
    
    @TestVisible private static List < ESupportUrlResponse__x > mockedESupportURLResponse = new List < ESupportUrlResponse__x > ();
    @TestVisible private static list < GetCarBoxAndWayBillParts__x > mockedObjBoxPart = new list < GetCarBoxAndWayBillParts__x > ();
    @TestVisible private static list < DLPLookup__x > mockedObjDLPLookup = new List < DLPLookup__x > ();
    @TestVisible private static list < GetBestFitDSP__x > mockedBestFitDSP = new List < GetBestFitDSP__x > ();
    @TestVisible private static list < GetProviderAttributes__x > mockedProviderAttr = new List < GetProviderAttributes__x > ();
    @TestVisible private static list < QueuePriority__mdt > mockedQueuePriority = new List < QueuePriority__mdt > ();
    @TestVisible private static list < DispatchDSPDLP__c > mockedDSPDLP = new List < DispatchDSPDLP__c > ();
    @TestVisible public static List<DPSAndCallType__x> mockedDPSCallType = new List<DPSAndCallType__x>();
    @TestVisible private static String preferDSP = '';    
    @TestVisible private static String mockedDSPAssigned = '';    
    @TestVisible private Id recordId;
    @TestVisible private static list < GetCarBoxAndWayBillParts__x > objBoxPart = new list < GetCarBoxAndWayBillParts__x > ();
    
    @TestVisible public static Boolean DLPRequired =false;
    @TestVisible private static list < DLPLookup__x > objDLPLookup = new List < DLPLookup__x > ();
    @TestVisible private static String serviceHours = '';
    @TestVisible private static String serviceLevel = '';
    @TestVisible private static String serviceOptions = '';
    @TestVisible private static String calendarDownload = 'N';
    @TestVisible private static String pageType = 'SRDETAIL';
    @TestVisible private static string currDSP = '';
    @TestVisible private static String hasBoxPart = '';
    @TestVisible private static String KoreanMonitor = 'N';
    
    public DispatchSubmissionProcess(Id id) {
        this.recordId = id;
    }
    
    public void execute(QueueableContext context) {
        WorkOrder woDetailLoc = new WorkOrder();
        woDetailLoc = submitProcess(recordId);
        if (woDetailLoc != null) {
            if (woDetailLoc.Status.equalsIgnoreCase('Problem'))
                woDetailLoc.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
            update woDetailLoc;
        }
    }
    
    public static WorkOrder submitProcess(string woRecordId) {
        try {
            DispatchDefaults__c defaultsDetail = new DispatchDefaults__c();
            WorkOrder woDetail = new WorkOrder();
            String woStatus = 'Approved';
            String woDispatchEvent = 'DISPATCH_SUBMISSION_COMPLETE';            
            String woSubStatus = '';
            
            // get work order details
            woDetail = [SELECT Id, DSP__c, FSD_DSP_Selection__c, DSPName__c, Schedule_Enable_Flag__c, Scheduling_URL__c, eSupportCalendar_URL__c,
                        DLP__c, DLP_Name__c, FSD_Transport_DLP__c, eSupport_URL__c, CountryCode, WorkOrderNumber, ScheduleStartDate__c, ScheduleEndDate__c,
                        Status, Sub_Status__c,Service_Type__c, ContactEmal__c, (SELECT PartNumber__c FROM WorkOrderLineItems), AccountId, Account.CCN__c, 
                        Account.Link_Number__c, OperationType__c, PartnerWorkOrderNumber__c, DPSType__c, CallType__c, DPS_BUID__c, DeltaSRNumber__c, Timezone__c,
                        KYC__c, Complete_Care_Option__c, KYHD__c, Service_Option__c, Country, FSD_DASP_Flag__c, AssetItemClass__c, ServiceTag__c,cityCalc__c,stateCalc__c,region__c
                        FROM WorkOrder WHERE Id =: woRecordId LIMIT 1
                       ];
            
            woDetail.OperationType__c = 'DPS';
            woDetail.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                        
            defaultsDetail = [SELECT Id, DPSType__c, DefaultDPSType__c, CallType__c, DefaultCallType__c, OutOfWarranty__c, Service_Type__c, selected_service_option__c, ServiceLevel__c, ServiceHours__c, Service_Configurations__c,
                              DefaultSKU__c, CustomSKU__c, Billable__c, SpecialOptions__c, CompleteCareOption__c, complete_care_option__c, KYHDOption__c, OconusDispatch__c, PremierCode__c, OutOfHours__c, Work_Order__r.City,Work_Order__r.CityCalc__c, Work_Order__r.StateCode, Work_Order__r.StateCalc__c, Work_Order__r.DPS_BUID__c,
                              Work_Order__r.PostalCode, Work_Order__r.CountryCode, Work_Order__r.LOB__c, Work_Order__r.Region__c, Work_Order__r.Service_Type__c,
                              Work_Order__r.Country, Work_Order__r.Deferred__c, Work_Order__r.Sanbao_FLG__c, Work_Order__r.FSD_DASP_Flag__c, Work_Order__r.Service_Option__c,
                              Work_Order__r.CallType__c, Work_Order__r.DPSType__c, Work_Order__r.DSP__c, Bill_To__c, Work_Order__c, Work_Order__r.DSPName__c, Work_Order__r.State, Work_Order__r.FSD_DSP_Selection__c,
                              Work_Order__r.FSD_Oconus_Federal_Flag__c, Work_Order__r.DPS_Region__c, Work_Order__r.KYC__c, Work_Order__r.KYHD__c, Work_Order__r.EntitlementStartDate__c,
                              Work_Order__r.Ground_Shipment_Flag__c, Work_Order__r.Timezone__c, Work_Order__r.DeltaSRNumber__c, Work_Order__r.ServiceTag__c, 
                              Work_Order__r.AssetItemClass__c, Work_Order__r.DPS_Sub_Region__c, Work_Order__r.DLP__c, Work_Order__r.Complete_Care_Option__c, GroundShipFlg__c, Work_Order__r.Korea_Monitor__c 
                              FROM DispatchDefaults__c WHERE Work_Order__c =: woRecordId LIMIT 1
                             ];
            
            if (String.isNotBlank(defaultsDetail.Work_Order__r.Service_Option__c.substringAfter('-'))) {
                serviceOptions = defaultsDetail.Work_Order__r.Service_Option__c;
                serviceHours = defaultsDetail.Work_Order__r.Service_Option__c.substringAfter('-');
                serviceLevel = defaultsDetail.Work_Order__r.Service_Option__c.substringBefore('-');
            }
            
            // perform DSP check
            currDSP = woDetail.DSP__c;
            if (!defaultsDetail.Work_Order__r.Service_Type__c.equalsIgnoreCase('Parts Only')) {
                if (string.isBlank(defaultsDetail.Work_Order__r.DSP__c)) {
                    woDetail = performDSPAssinment(defaultsDetail, woDetail);
                    if (woDetail.Status.endsWithIgnoreCase('Problem'))
                        return woDetail;         
                }
                else {
                    if ((string.isBlank(woDetail.DSPName__c) || (woDetail.DSPName__c == woDetail.DSP__c)) ) 
                    {
                        List<DispatchDSPDLP__c> dspRec = new List<DispatchDSPDLP__c>();
                        dspRec = (!mockedDSPDLP.isEmpty()) ? mockedDSPDLP : [SELECT PartnerName__c FROM DispatchDSPDLP__c 
                                                                             WHERE Type__c =: 'DSP' AND PartnerCode__c =: woDetail.DSP__c 
                                                                             AND CountryCode__c =: woDetail.CountryCode LIMIT 1];
                        if(!dspRec.isEmpty()) {
                            if(!dspRec.isEmpty() && dspRec!=null && dspRec.size() > 0)
                                woDetail.DSPName__c = dspRec[0].PartnerName__c;        
                        }
                        
                    }
                }
                
            }
            
            // get eSupport URL
            woDetail = getESupportURL(defaultsDetail, woDetail);
                        
            // check Rules Engine
            if (string.isBlank(defaultsDetail.Work_Order__r.DPSType__c)) 
            {
                woDetail = getDPSCallType(defaultsDetail, woDetail);
                if (woDetail.Status.endsWithIgnoreCase('Problem'))
                    return woDetail;                
            }
            
            // check box part            
            if (!woDetail.Service_Type__c.equalsIgnoreCase('Labor Only')) {  
                woDetail = performBoxPartAssignment(defaultsDetail, woDetail);
                if (woDetail.Status.endsWithIgnoreCase('Problem'))
                    return woDetail; 
            }
            if(!String.isBlank(hasBoxPart))
             {
                    if(woDetail.region__c=='1' || woDetail.region__c=='2')
                    {
                            if(woDetail.DLP__c==null ||(woDetail.CountryCode=='CA'&& woDetail.Collect_DLP__c==null))
                            {
                                 DLPRequired=true;
                            }
                              else       
                                {
                                    if(woDetail.DLP__c!=null)
                                    {
                                        List<DispatchPartsOrder__c> partsOrderPUDOType = new List<DispatchPartsOrder__c>([SELECT ISP_PUDO_Type__c FROM DispatchPartsOrder__c WHERE Work_Order__c =: woRecordId LIMIT 1]);
                                        
                                        if(partsOrderPUDOType[0].ISP_PUDO_Type__c=='' || partsOrderPUDOType[0].ISP_PUDO_Type__c==null)
                                        {
                                          DLPRequired=true;
                                        }
                                    }
                                }
                    }
                    else 
                    {
                                if(woDetail.region__c=='4' && (String.isBlank(woDetail.DLP__c))){
                                     
                                    DLPRequired=true;
                            }
                        
                    }           
           } 
            // check DLP
            if (DLPRequired) {                   
                woDetail = performDLPAssignment(defaultsDetail, woDetail);
                if (woDetail.Status.endsWithIgnoreCase('Problem'))
                    return woDetail; 
                
                if (objBoxPart.size() > 0 && objBoxPart[0].ResponseCode__c == '100') 
                {
                    createBoxPartDetails(woRecordId);                    
                }
                if (string.isNotEmpty(objDLPLookup[0].Pudo__c))
                {
                    String pudoStr = objDLPLookup[0].Pudo__c;
                    if (string.isNotBlank(objDLPLookup[0].PartsDLP__c) && pudoStr.equalsIgnoreCase('BLANK')) 
                    {
                        woDetail.Status = 'Problem';
                        woDetail.Sub_Status__c = 'PUDO Assignment Failure';                        
                        return woDetail;
                    }
                }
                //Dattaa1 changed it for re-submission 5701937
                else{                    
                    woDetail.Status = 'Problem';
                    woDetail.Sub_Status__c = 'PUDO Assignment Failure';                    
                    return woDetail;
                }
                //5701937 ends
                
                // check if parts order exists
                upSertPartOrderInformation(woRecordId);
                
            }
            
            // check for PUDO information
            // update work order details and event code 
            woDetail.Status = woStatus;
            woDetail.Sub_Status__c = woSubStatus;
            woDetail.DispatchEvent__c =woDispatchEvent;
            
            //woDetail.EventDateTime__c = defaultsDetail.Work_Order__r.EntitlementStartDate__c;
            woDetail.EventDateTime__c = System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
            string priorityESB = '';
            List <QueuePriority__mdt> esbPriority = new List<QueuePriority__mdt>();
            esbPriority = (!mockedQueuePriority.isEmpty()) ? mockedQueuePriority : [SELECT Label FROM QueuePriority__mdt WHERE Label =: serviceOptions ];
                if ((esbPriority.size() > 0 && !esbPriority.isEmpty() && esbPriority != null))
            {
                if (!String.isEmpty(esbPriority[0].Label) )
                    woDetail.QueuePriority__c = 'HIGH';
                else
                    woDetail.QueuePriority__c = 'LOW';
            }
            else
                woDetail.QueuePriority__c = 'LOW';
            
            return woDetail;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'submitWorkOrder', 'Dispatch Management');
            return null;
        }
    }
    
    @TestVisible    
    private static WorkOrder getESupportURL(DispatchDefaults__c defaultsDetail, WorkOrder woDetail)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getESupportURL
    Description:  this function contains the logic to make a call to get eSupport URL
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    {
        try {
            if (string.isNotBlank(woDetail.ScheduleStartDate__c)) {
                calendarDownload = 'Y';
            }
            if (String.isNotBlank(woDetail.ScheduleStartDate__c) && woDetail.Schedule_Enable_Flag__c.equalsIgnoreCase('Y')) {
                pageType = 'SCHEDULE';
            }
            
            list < ESupportUrlResponse__x > objESupport = new list < ESupportUrlResponse__x > ();
            
            objESupport = (!mockedESupportURLResponse.isEmpty()) ? mockedESupportURLResponse : [SELECT EsupportCalendarUrl__c,
                                                                                                EsupportUrl__c, ResponseCode__c, ResponseMessage__c
                                                                                                FROM ESupportUrlResponse__x
                                                                                                WHERE Buid__c =: woDetail.DPS_BUID__c 
                                                                                                AND CountryCode__c =: woDetail.CountryCode
                                                                                                AND DPSNumber__c =: woDetail.PartnerWorkOrderNumber__c 
                                                                                                AND SRNumber__c =: woDetail.DeltaSRNumber__c
                                                                                                AND EmailId__c =: woDetail.ContactEmal__c
                                                                                                AND TimeZone__c =: woDetail.Timezone__c
                                                                                                AND PageType__c =: pageType AND IncludeCalendarDownload__c =: calendarDownload
                                                                                                AND StartDate__c =: woDetail.ScheduleStartDate__c AND EndDate__c =: woDetail.ScheduleEndDate__c
                                                                                               ];
                                                                                                   system.debug('after eSupport Call - ' + objESupport);
            if (objESupport.size() > 0 && !objESupport.isEmpty() && objESupport != null) {
                if (objESupport[0].ResponseCode__c.equals('100')) {
                    woDetail.eSupport_URL__c = objESupport[0].EsupportUrl__c;
                    woDetail.eSupportCalendar_URL__c = objESupport[0].EsupportCalendarUrl__c;
                } else {
                    woDetail.eSupport_URL__c = 'http://www.dell.com/support/incidents-online/' + woDetail.CountryCode + '/en/19/srSearch';
                }
            } else {
                woDetail.eSupport_URL__c = 'http://www.dell.com/support/incidents-online/' + woDetail.CountryCode + '/en/19/srSearch';
            }
            return woDetail;
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'getESupportURL', 'Dispatch Management');
            return woDetail;
            
        }
    }
    
    @TestVisible
    private static WorkOrder performDSPAssinment(DispatchDefaults__c defaultsDetail, WorkOrder woDetail)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       performDSPAssinment
    Description:  this function contains the logic to perform DSP assignment operation calls
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    {
        try {
            if (string.isBlank(woDetail.DSP__c)) {
                
                // call the dsp assignment flow                    
                Map<String, Object> inputMap = new Map<String, Object>();
                inputMap.put('DispBUID', defaultsDetail.Work_Order__r.DPS_BUID__c);
                inputMap.put('DispBatteryShipFlag', '');
                inputMap.put('DispBillable', defaultsDetail.Billable__c);
                inputMap.put('DispCCN', woDetail.Account.CCN__c);
                inputMap.put('DispCity', defaultsDetail.Work_Order__r.City);
                inputMap.put('DispCountryCode', defaultsDetail.Work_Order__r.CountryCode);
                inputMap.put('DispItemClass', defaultsDetail.Work_Order__r.AssetItemClass__c);
                inputMap.put('DispLOB', defaultsDetail.Work_Order__r.LOB__c);
                inputMap.put('DispOOW', defaultsDetail.OutOfWarranty__c ? 'Y' : 'N');
                inputMap.put('DispPostalCode', defaultsDetail.Work_Order__r.PostalCode);                    
                inputMap.put('DispRegionId', integer.valueOf(defaultsDetail.Work_Order__r.Region__c));
                inputMap.put('DispServiceHour', serviceHours);
                inputMap.put('DispServiceLevel', serviceLevel);
                inputMap.put('DispServiceSubType', defaultsDetail.Work_Order__r.Service_Type__c);
                inputMap.put('DispState', defaultsDetail.Work_Order__r.State);
                inputMap.put('DispSvcTag', defaultsDetail.Work_Order__r.ServiceTag__c);                    
                inputMap.put('DispatchAccount', woDetail.AccountId);
                inputMap.put('DispatchCountry', (defaultsDetail.Work_Order__r.Country == 'United States') ? 'USA' : defaultsDetail.Work_Order__r.Country);
                inputMap.put('LinkNumber', woDetail.Account.Link_Number__c);
                
                Flow.Interview.Dispatch_Get_DSP dspFlow = new Flow.Interview.Dispatch_Get_DSP(inputMap);    
                dspFlow.start();
                String dspAssigned = (!string.isBlank(mockedDSPAssigned)) ? mockedDSPAssigned : (String)dspFlow.getVariableValue('AssignedProvider');
                String dspAssignedName = (String)dspFlow.getVariableValue('AssignedProviderName');
                String dspAssignment = (String)dspFlow.getVariableValue('DSPSelectionMethod');
                String dspSchedulingURL = (String)dspFlow.getVariableValue('DSPSchedulingURL');
                String dspScheduleFlag = (String)dspFlow.getVariableValue('DSPScheduleEnabled');
                String dspCommChannel = (String)dspFlow.getVariableValue('CommunicationChannel');
                                
                if(string.isNotEmpty(dspAssigned))
                {
                    woDetail.DSP__c = dspAssigned;
                    woDetail.DSPName__c = dspAssignedName;
                    woDetail.FSD_DSP_Selection__c = dspAssignment;
                    woDetail.Schedule_Enable_Flag__c = dspScheduleFlag;
                    woDetail.Scheduling_URL__c = dspSchedulingURL;
                    woDetail.Communication_Channel__c = dspCommChannel;
                    
                    preferDSP = dspAssigned;
                }
                
                if (string.isBlank(woDetail.DSP__c)) 
                {
                    List < GetBestFitDSP__x > getDSP = new List < GetBestFitDSP__x > ();
                    getDSP = (!mockedBestFitDSP.isEmpty()) ? mockedBestFitDSP : DispatchServiceLevelHandler.callGetDSPFitService(defaultsDetail, defaultsDetail.Work_Order__r.Service_Type__c, serviceHours, serviceLevel);
                    
                    if (getDSP.size() > 0 && !getDSP.isEmpty() && getDSP != null) {
                        if (getDSP[0].ResponseCode__c.equals('100')) 
                        {
                            woDetail.Schedule_Enable_Flag__c = getDSP[0].ISPDSPScheduleEnabled__c;
                            woDetail.Scheduling_URL__c = getDSP[0].DSPSchedulingURL__c;
                            woDetail.DSP__c = getDSP[0].DSP__c;
                            woDetail.FSD_DSP_Selection__c = 'Dynamic Dispatch';
                            
                            List<DispatchDSPDLP__c> dspRec = new List<DispatchDSPDLP__c>();
                            dspRec = [SELECT PartnerName__c FROM DispatchDSPDLP__c 
                                      WHERE Type__c =: 'DSP' AND PartnerCode__c =: getDSP[0].DSP__c
                                      AND CountryCode__c =: woDetail.CountryCode LIMIT 1];
                            if(dspRec!=null && !dspRec.isEmpty() && dspRec.size() > 0) 
                            {
                                defaultsDetail.Work_Order__r.DSPName__c = dspRec[0].PartnerName__c;
                                woDetail.DSPName__c = dspRec[0].PartnerName__c;
                            }
                        } else {
                            woDetail.Status = 'Problem';
                            woDetail.Sub_Status__c = 'DSP Assignment Failure';
                        }
                    } else {
                        woDetail.Status = 'Problem';
                        woDetail.Sub_Status__c = 'DSP Assignment Failure';
                    }
                    currDSP = woDetail.DSP__c;
                }
                
            } else {
                if (string.isNotEmpty(woDetail.FSD_DSP_Selection__c)) {
                    if (woDetail.FSD_DSP_Selection__c.equalsIgnoreCase('Manual')) {
                        List < GetProviderAttributes__x > dpsAttribute = new List < GetProviderAttributes__x > ();
                        dpsAttribute = (!mockedProviderAttr.isEmpty()) ? mockedProviderAttr : DispatchServiceLevelHandler.getProviderAttributes(defaultsDetail, woDetail.Service_Type__c,
                                                                                                                                                woDetail.Service_Option__c, defaultsDetail.Bill_To__c, woDetail.KYC__c,
                                                                                                                                                woDetail.KYHD__c, woDetail.Complete_Care_Option__c, woDetail.DSP__c);
                        if (dpsAttribute.size() > 0 && !dpsAttribute.isEmpty() && dpsAttribute != null) {
                            if (dpsAttribute[0].ResponseCode__c.equals('100')) {
                                woDetail.Schedule_Enable_Flag__c = dpsAttribute[0].ISPDSPScheduleEnabled__c;
                                woDetail.Scheduling_URL__c = dpsAttribute[0].DSPSchedulingURL__c;
                            }
                        }
                    }
                }
            }
            
            if (!string.isBlank(woDetail.DSP__c) && (string.isBlank(woDetail.DSPName__c) || (woDetail.DSPName__c == woDetail.DSP__c)) ) 
            {
                
                List<DispatchDSPDLP__c> dspRec = new List<DispatchDSPDLP__c>();
                dspRec = (!mockedDSPDLP.isEmpty()) ? mockedDSPDLP : [SELECT PartnerName__c FROM DispatchDSPDLP__c 
                                                                     WHERE Type__c =: 'DSP' AND PartnerCode__c =: woDetail.DSP__c 
                                                                     AND CountryCode__c =: woDetail.CountryCode LIMIT 1];
                if(!dspRec.isEmpty()) {
                    if(!dspRec.isEmpty() && dspRec!=null && dspRec.size() > 0)
                        woDetail.DSPName__c = dspRec[0].PartnerName__c;        
                }
                
            }
                        
            return woDetail;
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'performDSPAssinment', 'Dispatch Management');
            woDetail.Status = 'Problem';
            woDetail.Sub_Status__c = 'DSP Assignment Failure';
            return woDetail;
            
        }
        
    }
    
    @TestVisible
    private static WorkOrder getDPSCallType(DispatchDefaults__c defaultsDetail, WorkOrder woDetail)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getDPSCallType
    Description:  this function contains the logic to perform DPS call type
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    {
        try {
            List < DPSAndCallType__x > dpsCallTypeStatus = new List < DPSAndCallType__x > ();
            dpsCallTypeStatus = (!mockedDPSCallType.isEmpty()) ? mockedDPSCallType : DispatchServiceLevelHandler.getDPSTypeAndCallType(defaultsDetail, defaultsDetail.Work_Order__r.Service_Type__c, serviceHours, serviceLevel);
            
            if (dpsCallTypeStatus.size() > 0 && !dpsCallTypeStatus.isEmpty() && dpsCallTypeStatus!=null) {
                if (dpsCallTypeStatus[0].ResponseCode__c.equals('100')) {
                    woDetail.DPSType__c = dpsCallTypeStatus[0].DPSType__c;
                    woDetail.CallType__c = dpsCallTypeStatus[0].CallType__c;
                } else {
                    woDetail.Status = 'Problem';
                    woDetail.Sub_Status__c = 'DPS Type Failure';                 
                }
            } else {
                woDetail.Status = 'Problem';
                woDetail.Sub_Status__c = 'DPS Type Failure';                
            }
            return woDetail;
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'getDPSCallType', 'Dispatch Management');
            woDetail.Status = 'Problem';
            woDetail.Sub_Status__c = 'DPS Type Failure'; 
            return woDetail;
            
        }
    }
    
    @TestVisible
    private static WorkOrder performBoxPartAssignment(DispatchDefaults__c defaultsDetail, WorkOrder woDetail)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       performBoxPartAssignment
    Description:  this function contains the logic to perform box part operation call
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    {
        try {
            objBoxPart = (!mockedObjBoxPart.isEmpty()) ? mockedObjBoxPart : [SELECT BoxPartNumber__c, BoxPartPartType__c,
                                                                             BoxPartDescription__c, ResponseType__c,
                                                                             WaybillPartDescription__c, WaybillPartNumber__c, WaybillPartType__c,
                                                                             ResponseCode__c, ResponseDetails__c, ResponseMessage__c
                                                                             FROM GetCarBoxAndWayBillParts__x
                                                                             WHERE ServiceHours__c =: serviceHours
                                                                             AND ServiceLevel__c =: serviceLevel                                                                               
                                                                             AND BUID__c =: woDetail.DPS_BUID__c    
                                                                             AND ServiceType__c =: woDetail.Service_Type__c  
                                                                             AND ServiceTag__c =: woDetail.ServiceTag__c  
                                                                             AND Country__c =: woDetail.Country                                                                             
                                                                             AND DASP__c =: woDetail.FSD_DASP_Flag__c? 'Y' : 'N'
                                                                             AND Deferred__c =: woDetail.Deferred__c
                                                                             AND ItemClass__c =: woDetail.AssetItemClass__c 
                                                                             AND KYHD__c =: woDetail.KYHD__c ? 'Y' : 'N'                                                                       
                                                                             AND OutofHours__c =: defaultsDetail.OutOfHours__c ? 'Y' : 'N'                                                                              
                                                                             AND PremierCode__c =: defaultsDetail.PremierCode__c
                                                                             AND SKU__c =: defaultsDetail.DefaultSKU__c 
                                                                             AND SystemClassification__c =: defaultsDetail.Service_Configurations__c
                                                                             AND Category__c =: defaultsDetail.SpecialOptions__c                                                                             
                                                                             AND CompleteCare__c =: defaultsDetail.complete_care_option__c ? 'Y' : 'N'
                                                                             AND Billable__c =: defaultsDetail.Billable__c                                                                             
                                                                             AND OutofWarranty__c =: defaultsDetail.OutOfWarranty__c ? 'Y' : 'N'
                                                                            ];
                                                                                if (objBoxPart.size() > 0 && objBoxPart[0].ResponseCode__c == '100') {
                                                                                    if(string.isNotBlank(objBoxPart[0].BoxPartNumber__c))
                                                                                        hasBoxPart = objBoxPart[0].BoxPartNumber__c;  
                                                                                    else {
                                                                                        if(string.isNotBlank(objBoxPart[0].WaybillPartNumber__c))
                                                                                            hasBoxPart = objBoxPart[0].WaybillPartNumber__c;
                                                                                    }
                                                                                } else {
                                                                                    if (objBoxPart[0].ResponseCode__c == '125000'){
                                                                                        hasBoxPart = String.valueOf(woDetail.WorkOrderLineItems.size());                        
                                                                                    }
                                                                                    else {
                                                                                        woDetail.Status = 'Problem';
                                                                                        woDetail.Sub_Status__c = 'Box Assignment Failure';                        
                                                                                    }
                                                                                }
            return woDetail;
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'performBoxPartAssignment', 'Dispatch Management');
            woDetail.Status = 'Problem';
            woDetail.Sub_Status__c = 'Box Assignment Failure';
            return woDetail;
            
        }
    }
    
    @TestVisible
    private static WorkOrder performDLPAssignment(DispatchDefaults__c defaultsDetail, WorkOrder woDetail)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       performDLPAssignment
    Description:  this function contains the logic to perform DLP assignment operation call
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    {
        try {
            
            string stateValue = '';     
            if (defaultsDetail.Work_Order__r.Region__c.equalsIgnoreCase('1')) {
                if (defaultsDetail.Work_Order__r.DPS_Sub_Region__c == 'LA')
                    stateValue = defaultsDetail.Work_Order__r.StateCode;
                else
                    stateValue = defaultsDetail.Work_Order__r.State;
            }                    
            else
                stateValue = defaultsDetail.Work_Order__r.StateCode;
            KoreanMonitor = defaultsDetail.Work_Order__r.Korea_Monitor__c ? 'Y' : 'N';
            objDLPLookup = (!mockedObjDLPLookup.isEmpty()) ? mockedObjDLPLookup : [SELECT PartsDLP__c, PartsDLPName__c, CollectDLP__c, CollectDLPName__c, TransportDLP__c, TransportDLPName__c, 
                                                                                   Pudo__c, CommunicationModel__c, ISPPudoAddressLine1__c,ISPPudoAddressLine2__c,ISPPudoAddressLine3__c, ISPPudoAddressLine4__c,
                                                                                   ISPPudoCity__c,ISPPudoState__c,ISPPudoZipCode__c,ISPPudoCountryCode__c, ISPPudoCustomerNumber__c, ISPPudoAddressSequence__c,
                                                                                   ISPFSDPUDOId__c,ISPFSDPUDOStatus__c, ISPPUDOName__c, ISPPUDODesc__c, ISPPudoCustAddressLine1__c,ISPPudoCustAddressLine2__c,
                                                                                   ISPPudoCustAddressLine3__c, ISPPudoCustAddressLine4__c, ISPPudoCustCity__c, ISPPudoCustState__c,
                                                                                   ISPPudoCustZipCode__c, ISPPudoCustCountryCode__c, ISPPudoCustCountry__c, DSPCompanyNumber__c,
                                                                                   ResponseCode__c, ResponseMessage__c, ResponseDetails__c
                                                                                   FROM DLPLookup__x
                                                                                   WHERE State__c =: woDetail.StateCalc__C
                                                                                   AND ServiceLevel__c =: serviceLevel
                                                                                   AND ServiceProvider__c =: currDSP
                                                                                   AND ServiceHRs__c =: serviceHours
                                                                                   AND ServiceType__c = 'Break Fix'                                                                   
                                                                                   AND DASP__c = null
                                                                                   AND BulkUIFlag__c =: 'N'
                                                                                   AND MonitorCall__c =: KoreanMonitor
                                                                                   AND DSPCode__c =: currDSP                    
                                                                                   AND PostalCode__c =: defaultsDetail.Work_Order__r.PostalCode 
                                                                                   AND ServiceProviderId__c =: woDetail.DSPName__c                     
                                                                                   AND ISOCountryCode__c =: defaultsDetail.Work_Order__r.CountryCode
                                                                                   AND SystemClassification__c =: defaultsDetail.Service_Configurations__c
                                                                                   //AND State__c =: defaultsDetail.Work_Order__r.State
                                                                                   AND LOB__c =: defaultsDetail.Work_Order__r.LOB__c
                                                                                   AND City__c =: defaultsDetail.Work_Order__r.CityCalc__c
                                                                                   AND Region__c =: defaultsDetail.Work_Order__r.DPS_Region__c                    
                                                                                   AND ServiceSubType__c =: defaultsDetail.Work_Order__r.Service_Type__c                    
                                                                                   AND Category__c =: defaultsDetail.SpecialOptions__c                    
                                                                                   AND OOW__c =: defaultsDetail.OutOfWarranty__c ? 'Y' : 'N'
                                                                                   AND OOH__c =: defaultsDetail.OutOfHours__c ? 'Y' : 'N'
                                                                                   AND GroundShipFlg__c =: defaultsDetail.Work_Order__r.Ground_Shipment_Flag__c ? 'Y' : 'N'
                                                                                   AND KYC__c =: defaultsDetail.Work_Order__r.KYC__c ? 'Y' : 'N'
                                                                                   AND KYHD__c =: defaultsDetail.Work_Order__r.KYHD__c ? 'Y' : 'N'
                                                                                   AND FederalOconusFlag__c =: defaultsDetail.Work_Order__r.FSD_Oconus_Federal_Flag__c
                                                                                   AND Billable__c =: defaultsDetail.Billable__c                    
                                                                                   AND CompleteCare__c =: defaultsDetail.complete_care_option__c ? 'Y' : 'N'                    
                                                                                   AND ServiceTag__c=: defaultsDetail.Work_Order__r.ServiceTag__c                     
                                                                                   AND Country__c =: defaultsDetail.Work_Order__r.CountryCode
                                                                                   AND PartsDLP__c =: defaultsDetail.Work_Order__r.DLP__c  
                                                                                   AND CallType__c =: woDetail.CallType__c
                                                                                   AND ServiceProvider__c =: woDetail.DSP__c
                                                                                  ];
                                                                                       
            
            if (objDLPLookup.size() > 0 && !objDLPLookup.isEmpty() && objDLPLookup != null) {
                if (objDLPLookup[0].ResponseCode__c == '100')
                {                    
                    if (string.isNotEmpty(objDLPLookup[0].PartsDLP__c)){
                        woDetail.DLP__c = objDLPLookup[0].PartsDLP__c;
                        if(objDLPLookup[0].PartsDLPName__c =='' || objDLPLookup[0].PartsDLPName__c == null)
                        {
                                List<DispatchDSPDLP__c> dlpRec = new List<DispatchDSPDLP__c>();
                                dlpRec = [SELECT PartnerName__c FROM DispatchDSPDLP__c 
                                          WHERE Type__c =: 'DLP' AND PartnerCode__c =: objDLPLookup[0].PartsDLP__c 
                                          AND CountryCode__c =: defaultsDetail.Work_Order__r.CountryCode LIMIT 1];
                                
                                if(dlpRec!=null && !dlpRec.isEmpty() && dlpRec.size() > 0)
                                    woDetail.DLP_Name__c = dlpRec[0].PartnerName__c;
                         }
                        else
                          {                     
                            woDetail.DLP_Name__c = objDLPLookup[0].PartsDLPName__c;
                          } 
                    }
                    if (string.isNotEmpty(objDLPLookup[0].TransportDLP__c))
                        woDetail.FSD_Transport_DLP__c = objDLPLookup[0].TransportDLP__c;
                    if (string.isNotEmpty(objDLPLookup[0].CollectDLP__c))
                        woDetail.Collect_DLP__c = objDLPLookup[0].CollectDLP__c;
                    
                } else {
                    //Dattaa1 changed it for re-submission 5709665
                    if(String.isEmpty(woDetail.DLP__c)){
                        woDetail.Status = 'Problem';
                        woDetail.Sub_Status__c = 'DLP Assignment Failure';                            
                    }
                }
            } else {
                woDetail.Status = 'Problem';
                woDetail.Sub_Status__c = 'DLP Assignment Failure';                    
            }                
            
            return woDetail;
        }
        catch (Exception e) {
            woDetail.Status = 'Problem';
            woDetail.Sub_Status__c = 'DLP Assignment Failure'; 
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'performDLPAssignment', 'Dispatch Management');
            return woDetail;
        }
    }
    
    
    @TestVisible
    private static void createBoxPartDetails(string woRecordId)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       createBoxPartDetails
    Description:  this function contains the logic to create box part details
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    {
        try {
            
            hasBoxPart = objBoxPart[0].BoxPartNumber__c;
            List <WorkOrderLineItem> boxPartAddList = new List<WorkOrderLineItem>();
            List <WorkOrderLineItem> boxWayBillUpdateList = new List<WorkOrderLineItem>();
            // box parts details
            List <WorkOrderLineItem> boxPart = new List <WorkOrderLineItem>();
            
            Boolean hasRecord = false;
            
            if (string.isNotBlank(objBoxPart[0].BoxPartNumber__c))
            {
                boxPart = [SELECT WorkOrderId, PartNumber__c, PartDescription__c, PartType__c
                           FROM WorkOrderLineItem WHERE WorkOrderId=:woRecordId AND PartNumber__c =:objBoxPart[0].BoxPartNumber__c LIMIT 1];
                
                if(boxPart.size() >0) {
                    
                    hasRecord = true;
                    //boxPart[0].WorkOrderId = woRecordId;
                    boxPart[0].PartNumber__c = objBoxPart[0].BoxPartNumber__c;
                    boxPart[0].PartDescription__c = objBoxPart[0].BoxPartDescription__c;
                    boxPart[0].PartType__c = objBoxPart[0].BoxPartPartType__c;                                
                    //boxPartAddList.add(boxPart[0]);
                    update boxPart;
                } 
                else {
                    Integer recordLine =  [SELECT count() 
                                           FROM WorkOrderLineItem  
                                           WHERE WorkOrderId=:woRecordId LIMIT 1];
                    
                    WorkOrderLineItem boxP = new WorkOrderLineItem(WorkOrderId = woRecordId);
                    //boxP.WorkOrderId = woRecordId;
                    boxP.PartNumber__c = objBoxPart[0].BoxPartNumber__c;
                    boxP.PartDescription__c = objBoxPart[0].BoxPartDescription__c;
                    boxP.PartType__c = objBoxPart[0].BoxPartPartType__c;
                    boxP.Selected_Work_Order__c = woRecordId;
                    boxP.ISP_FSD_Line_Num__c = recordLine+1;
                    boxP.Sequence_Number__c= recordLine+1;
                    boxP.External_Id__c = woRecordId+objBoxPart[0].BoxPartNumber__c;
                    //boxPartAddList.add(boxP);
                    insert boxP;
                    
                }                            
            }
            
            // waybill details
            if (string.isNotBlank(objBoxPart[0].WaybillPartNumber__c))
            {
                
                boxPart = [SELECT WorkOrderId, PartNumber__c, PartDescription__c, PartType__c
                           FROM WorkOrderLineItem WHERE WorkOrderId=:woRecordId AND PartNumber__c =:objBoxPart[0].WaybillPartNumber__c LIMIT 1];
                                
                if(boxPart.size() >0)
                {
                    hasRecord = true;                    
                    //boxPart[0].WorkOrderId = woRecordId;
                    boxPart[0].PartNumber__c = objBoxPart[0].WaybillPartNumber__c;
                    boxPart[0].PartDescription__c = objBoxPart[0].WaybillPartDescription__c;
                    boxPart[0].PartType__c = objBoxPart[0].WaybillPartType__c;
                    //boxWayBillUpdateList.add(boxPart[0]);
                    update boxPart;
                }
                else {
                    Integer recordLine =  [SELECT count() 
                                           FROM WorkOrderLineItem  
                                           WHERE WorkOrderId=:woRecordId LIMIT 1];
                    
                    WorkOrderLineItem boxP2 = new WorkOrderLineItem(WorkOrderId = woRecordId);
                    //boxP.WorkOrderId = woRecordId;
                    boxP2.PartNumber__c = objBoxPart[0].WaybillPartNumber__c;
                    boxP2.PartDescription__c = objBoxPart[0].BoxPartDescription__c;
                    boxP2.PartType__c = objBoxPart[0].BoxPartPartType__c;
                    boxP2.Selected_Work_Order__c = woRecordId;
                    boxP2.ISP_FSD_Line_Num__c = recordLine+1;
                    boxP2.Sequence_Number__c= recordLine+1;
                    boxP2.External_Id__c = woRecordId+objBoxPart[0].WaybillPartNumber__c;
                    //boxWayBillUpdateList.add(boxP);
                    insert boxP2;
                }                      
            }                        
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'createBoxPartDetails', 'Dispatch Management');
        }
    }
    
    @TestVisible
    private static void upSertPartOrderInformation(string woRecordId)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       upSertPartOrderInformation
    Description:  this function contains the logic to upsert parts order information
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    {
        try {
            List<DispatchPartsOrder__c> partsOrder = new List<DispatchPartsOrder__c>();
            DispatchPartsOrder__c partsOrderUpsert = new DispatchPartsOrder__c();
            Boolean performUpdate = false;
            partsOrder = [SELECT ISP_DLP_Cancellation_Reply__c, ISP_DLP_Name__c, ISP_Event_Code__c, ISP_File_Type__c,
                          ISP_FSD_Completion_Date_Time__c, ISP_FSD_Confirmation_Date_Time__c, ISP_FSD_Defrl_Date__c,
                          ISP_FSD_DLP__c, ISP_FSD_Line_Num__c, ISP_FSD_New_Flg__c, ISP_FSD_Parts_Order_ETA__c, ISP_FSD_PUDO_Id__c,
                          ISP_FSD_PUDO_Location__c, ISP_FSD_PUDO_Status__c, ISP_FSD_Reject_Reason__c, ISP_FSD_Rejection_Date_Time__c,
                          ISP_FSD_Seq__c,ISP_FSD_Transport_Confirmation_Date_Time__c,  ISP_FSD_Transport_Reject_Reason__c, 
                          ISP_FSD_Transport_Rejection_Date_Time__c, ISP_Operation_Type__c, ISP_PUDO_AddrLine1__c, ISP_PUDO_AddrLine2__c,
                          ISP_PUDO_AddrLine3__c, ISP_PUDO_AddrLine4__c, ISP_PUDO_BUID__c, ISP_PUDO_City__c, ISP_PUDO_Country__c,
                          ISP_PUDO_Country_Code__c, ISP_PUDO_Desc__c, ISP_PUDO_Name__c, ISP_PUDO_Post_Code__c, ISP_PUDO_Type__c,
                          ISP_Source__c, ISP_TDLP_Cancellation_Reply__c, Name, ExternalId__c
                          FROM DispatchPartsOrder__c WHERE Work_Order__c =: woRecordId LIMIT 1];
            
            if (partsOrder.size() > 0 && !partsOrder.isEmpty() && partsOrder != null){
                partsOrderUpsert = partsOrder[0];
                performUpdate = true;
            }
            
            //partsOrderUpsert.ISP_DLP_Cancellation_Reply__c = '';
            partsOrderUpsert.ISP_DLP_Name__c = objDLPLookup[0].PartsDLPName__c;
            //partsOrderUpsert.ISP_Event_Code__c = '';
            //partsOrderUpsert.ISP_File_Type__c = '';
            //partsOrderUpsert.ISP_FSD_Completion_Date_Time__c = '';
            //partsOrderUpsert.ISP_FSD_Confirmation_Date_Time__c = '';
            //partsOrderUpsert.ISP_FSD_Defrl_Date__c = '';
            partsOrderUpsert.ISP_FSD_DLP__c = objDLPLookup[0].PartsDLP__c;
            //
            //partsOrderUpsert.ISP_FSD_New_Flg__c = '';
            //partsOrderUpsert.ISP_FSD_Parts_Order_ETA__c = '';
            partsOrderUpsert.ISP_FSD_PUDO_Id__c = objDLPLookup[0].ISPFSDPUDOId__c;
            partsOrderUpsert.ISP_FSD_PUDO_Location__c = objDLPLookup[0].Pudo__c;
            partsOrderUpsert.ISP_FSD_PUDO_Status__c = objDLPLookup[0].ISPFSDPUDOStatus__c;
            //partsOrderUpsert.ISP_FSD_Reject_Reason__c = '';
            //partsOrderUpsert.ISP_FSD_Rejection_Date_Time__c = '';
            //
            //partsOrderUpsert.ISP_FSD_Transport_Confirmation_Date_Time__c = '';
            //partsOrderUpsert.ISP_FSD_Transport_Reject_Reason__c = ''; 
            //partsOrderUpsert.ISP_FSD_Transport_Rejection_Date_Time__c = '';
            //partsOrderUpsert.ISP_Operation_Type__c = '';
            partsOrderUpsert.ISP_PUDO_AddrLine1__c = objDLPLookup[0].ISPPudoAddressLine1__c;
            partsOrderUpsert.ISP_PUDO_AddrLine2__c = objDLPLookup[0].ISPPudoAddressLine2__c;
            partsOrderUpsert.ISP_PUDO_AddrLine3__c = objDLPLookup[0].ISPPudoAddressLine3__c;
            partsOrderUpsert.ISP_PUDO_AddrLine4__c = objDLPLookup[0].ISPPudoAddressLine4__c;
            //partsOrderUpsert.ISP_PUDO_BUID__c = '';
            partsOrderUpsert.ISP_PUDO_City__c = objDLPLookup[0].ISPPudoCity__c;
            partsOrderUpsert.ISP_PUDO_Country__c = objDLPLookup[0].ISPPudoCountryCode__c;
                partsOrderUpsert.ISP_PUDO_Country_Code__c = objDLPLookup[0].ISPPudoCountryCode__c;
                partsOrderUpsert.ISP_PUDO_Desc__c = objDLPLookup[0].ISPPUDODesc__c;
                partsOrderUpsert.ISP_PUDO_Name__c = objDLPLookup[0].ISPPUDOName__c;
                partsOrderUpsert.ISP_PUDO_Post_Code__c = objDLPLookup[0].ISPPudoZipCode__c;
                partsOrderUpsert.ISP_PUDO_State__c = objDLPLookup[0].ISPPudoState__c;
                partsOrderUpsert.ISP_PUDO_Type__c = objDLPLookup[0].Pudo__c;
            
            //partsOrderUpsert.ISP_Source__c = '';
            //partsOrderUpsert.ISP_TDLP_Cancellation_Reply__c = '';
            
            if (performUpdate){
                //if(isFieldsUpdatableToUser())
                {
                    Update partsOrderUpsert;   
                }
            } else {
                partsOrderUpsert.ISP_FSD_Seq__c = 1;
                partsOrderUpsert.ISP_FSD_Line_Num__c = 1;
                partsOrderUpsert.Name = woRecordId + String.valueOf(1);
                partsOrderUpsert.ExternalId__c = woRecordId + String.valueOf(1);
                partsOrderUpsert.Work_Order__c = woRecordId; 
                Insert partsOrderUpsert;
            }
            if (partsOrderUpsert.Id != null){
                List<WorkOrderLineItem> woLineList = new List<WorkOrderLineItem>([SELECT Id, DispatchPartsOrder__c FROM WorkOrderLineItem WHERE WorkOrderId =:woRecordId LIMIT 1000]);
                List<WorkOrderLineItem> woLineToBeUpdated = new List<WorkOrderLineItem>();
                for (WorkOrderLineItem item : woLineList)
                {
                    item.DispatchPartsOrder__c = partsOrderUpsert.Id;
                    
                    woLineToBeUpdated.add(item);
                }
                
                Update woLineToBeUpdated;
            }
            
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'upSertPartOrderInformation', 'Dispatch Management');
        }
    }
    
    public static boolean statusUpdateCheck(string woStatusCheck, string oldVal, string newVal, string woRegion, string woSubRegion)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       statusUpdateCheck
    Description:  this function contains the logic for status update check
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/01/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            string sRegionCode = '';
            string sLIC;
            string sValid = '';
            boolean statusChecked = false;
            if (woStatusCheck != 'Labor Status') {
                if(woRegion == 'JAPAN')
                    sRegionCode = 'JP';
                else if(woRegion == 'EMEA')
                    sRegionCode = 'EM';
                else if(woRegion == 'AP')
                    sRegionCode = 'AP';
                else
                {
                    if(woSubRegion == 'LA')
                        sRegionCode = woSubRegion;
                    else
                        sRegionCode = 'UC';
                }
            }
            
            if(woStatusCheck == 'Labor Status')
            {
                if(oldVal == '')
                    oldVal = 'Blank';
                else if(oldVal != 'Acknowledged' && oldVal != 'Cancelled' && oldVal != 'Service Call Closure')
                    oldVal = 'Any Other';

                if(newVal != 'Acknowledged' && newVal != 'Cancelled' && newVal != 'Service Call Closure')
                    NewVal = 'Any Other';

                sLIC = oldVal + '+' + newVal;
                return lookupStatusValue(sLIC, 'Labor');
                //sValid = TheApplication().InvokeMethod("LookupValue", "ISP_DIS_LABOR_STAT", sLIC);
            }
            else if (woStatusCheck == 'Dispatch Parts Status')
            {
                sLIC = oldVal + '+' + newVal + '+' + sRegionCode;
                return lookupStatusValue(sLIC, 'Parts');
                //sValid = TheApplication().InvokeMethod("LookupValue", "ISP_DIS_PART_STAT", sLIC);
            }
            else if (woStatusCheck == 'Dispatch Status')    
            {
                sLIC = OldVal + '+' + newVal + '+' + sRegionCode;                
                return lookupStatusValue(sLIC, 'Dispatch');
                //sValid = TheApplication().InvokeMethod("LookupValue", "ISP_DIS_ACT_STAT", sLIC);              
            }
            else
            {
                if(newVal == 'RETURNED')
                {
                    if(sRegionCode == 'EM')
                    {   
                        sLIC = oldVal + '+' + newVal + '+' + sRegionCode;
                        //sValid = TheApplication().InvokeMethod("LookupValue", "ISP_PART_LINE_STAT", sLIC);
                    }
                    else
                        return false;
                }
                else
                {
                    sLIC = oldVal + '+' + newVal + '+' + sRegionCode;
                    //sValid = TheApplication().InvokeMethod("LookupValue", "ISP_PART_LINE_STAT", sLIC);
                }
            }
            
            if(sValid == 'Y')
                return false;//return false if its a valid transition, so that ISP Labor Status, Dispatch Parts Status and Dispatch Status property is not removed from the msg
            else
                return true;            
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'PartnerUpdatesProcess', 'PartnerUpdate_AMER', 'Dispatch Management');  
            return false;
        }
    }
    @TestVisible
    private static boolean lookupStatusValue(string statusTransition, string statusType)
    {
        try {
            List<Dispatch_Labor_Parts_Status_Setup__c> statusObj = new List<Dispatch_Labor_Parts_Status_Setup__c>();
            statusObj = [SELECT Valid_Transition__c FROM Dispatch_Labor_Parts_Status_Setup__c 
                         WHERE Status_Transition__c =:statusTransition AND Type__c =: statusType];
            
            if (statusObj.size()>0)
                return statusObj[0].Valid_Transition__c;
            return false;
        }catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'PartnerUpdatesProcess', 'lookupStatusValue', 'Dispatch Management');  
            return false;
        }
    }
    
    @TestVisible
    private static boolean isFieldsUpdatableToUser() {
    return Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_FSD_DLP__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_FSD_PUDO_Id__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_FSD_PUDO_Location__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_FSD_PUDO_Status__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_AddrLine1__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_AddrLine2__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_AddrLine3__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_AddrLine4__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_City__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_Country__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_Country_Code__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_Name__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_Desc__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_Post_Code__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_State__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_PUDO_Type__c.isUpdateable()
        && Schema.sObjectType.DispatchPartsOrder__c.Fields.ISP_DLP_Name__c.isUpdateable();
    }
}
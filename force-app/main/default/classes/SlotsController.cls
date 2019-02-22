/* -----------------------------------------------------------------------------------------------------------------------
Name:       SlotsController
Description:  This class handles the processing of scheduling slots story #4916977
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/09/2018     1.0     Rodrigo Carpio      Initial Release
05/09/2018     1.1     Harsha Reddy        Initial Release
--------------------------------------------------------------------------------------------------------------------------*/
public class SlotsController {
    @TestVisible public static List < ESupportUrlResponse__x > mockedESupportURLResponse = new List < ESupportUrlResponse__x > ();
    @TestVisible public static List < ScheduleSlotByAttributes__x > mockedScheduleSlotsByArrtributes = new List < ScheduleSlotByAttributes__x > ();
    @TestVisible public static List < CancelSlot__x > mockedCancelSlots = new List < CancelSlot__x > ();
    @TestVisible public static List < RescheduleSlots__x > mockedReshuleSlots = new List < RescheduleSlots__x > ();
    @TestVisible public static List < ScheduleSlotByAttributes__x > mockedScheduledSlots = new List < ScheduleSlotByAttributes__x > ();
    @TestVisible public static List < AvailableSlotsByAttributes__x > mockedAvailableSlotsByAttr = new List < AvailableSlotsByAttributes__x > ();
    @TestVisible public static List < GetSiebelDeferralDates__x > mokedGetSiebelDeferralDates = new List < GetSiebelDeferralDates__x > ();
    public class scheduleWrap {
        @AuraEnabled public string cancelResponse {
            get;
            set;
        }
        @AuraEnabled public string submitResponse {
            get;
            set;
        }
    }
    // Added Newly
    public class coustomException extends Exception {}

    public with sharing class responseWrapper {
        @AuraEnabled public string errorMessage {
            get;
            set;
        }
        @AuraEnabled public List < DispatchServiceProviderController.slotsWrapper > sWrapperList {
            get;
            set;
        }
        @AuraEnabled public string slaStartDate {
            get;
            set;
        }
        @AuraEnabled public string slaEndDate {
            get;
            set;
        }
        @AuraEnabled public string shiftStart {
            get;
            set;
        }
        @AuraEnabled public string shiftEnd {
            get;
            set;
        }
    }

    @AuraEnabled
    public static string setDeferralDate(string woRecordId, string entitlementStartDate, string entitlementEndDate, string sProvider, string deferPopup) {
        try {
            string returnString = '100';
            Boolean dspOverrideFlag = false;
            List < WorkOrder > oWorkOrder = new List < WorkOrder > ();
            List < DispatchDefaults__c > dispatchDefault = new List < DispatchDefaults__c > ();

            oWorkOrder = [SELECT Status, StartDate, EndDate, EntitlementStartDate__c, EntitlementEndDate__c, schedulingInternalLogic__c,
                SLAStartDate__c, SLAEndDate__c, Deferred__c, ScheduleStartDate__c, ScheduleEndDate__c,
                IsScheduled__c FROM WorkOrder WHERE Id =: woRecordId LIMIT 1
            ];

            dispatchDefault = [SELECT Id, DSP_Override_Request__c FROM DispatchDefaults__c WHERE Work_Order__c =: woRecordId LIMIT 1];

            if (!dispatchDefault.isEmpty()) {
                if (dispatchDefault[0].DSP_Override_Request__c != null) {
                    dspOverrideFlag = dispatchDefault[0].DSP_Override_Request__c;
                }
            }

            DateTime dtStartDate = null;
            DateTime dtEndDate = null;

            string strStartTime = entitlementStartDate.substringAfter('T');
            string strEndTime = entitlementEndDate.substringAfter('T');
            string strEntitleDate = entitlementStartDate.substringBefore('T');
            string strSLADate = oWorkOrder[0].SLAStartDate__c.substringBefore('T');

            oWorkOrder[0].EntitlementStartDate__c = entitlementStartDate;
            oWorkOrder[0].EntitlementEndDate__c = entitlementEndDate;
            oWorkOrder[0].ScheduleStartDate__c = null;
            oWorkOrder[0].ScheduleEndDate__c = null;
            oWorkOrder[0].IsScheduled__c = false;
            oWorkOrder[0].StartDate = null;
            oWorkOrder[0].EndDate = null;
            oWorkOrder[0].schedulingInternalLogic__c = 'Deferred';
            oWorkOrder[0].Defer_Popup__c = deferPopup;
            oWorkOrder[0].Schedule_Enable_Flag__c = 'N';

            //if (oWorkOrder.Status == 'Open') // Commented By Harsha - DEFECT 5245031
            if (oWorkOrder[0].Status == 'Open' && dspOverrideFlag == false) // Modified By Harsha - DEFECT 5245031
            {
                oWorkOrder[0].Status = 'Pending Schedule';
            }

            if (strEntitleDate == strSLADate) {
                if (strStartTime == strEndTime) {
                    oWorkOrder[0].Deferred__c = 'Yes';
                } else {
                    oWorkOrder[0].Deferred__c = 'No';
                }
            } else {
                oWorkOrder[0].Deferred__c = 'Yes';
            }

            Update oWorkOrder[0];

            return returnString;

        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'setDeferralDate', 'Dispatch Management');
            return null;
        }
    }

    @AuraEnabled
    public static void cancelScheduledSlot(Id woRecordId) {
        try {
            WorkOrder oWorkOrder;
            CancelSlot__x cancelRespCode;
            string sScheduleStartDate = '';
            string sScheduleEndDate = '';
            boolean IsScheduleEnabled = false;

            oWorkOrder = [SELECT WorkOrderNumber, Status, AccountId, StartDate, EndDate, Account.Name,
                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c,
                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City, DSPName__c,
                State, StateCode, Country, CountryCode, PostalCode, Region__c, schedulingInternalLogic__c,
                EntitlementStartDate__c, EntitlementEndDate__c, SLAStartDate__c, SLAEndDate__c,
                Deferred__c, IsScheduled__c, ScheduleStartDate__c, ScheduleEndDate__c, PartnerWorkOrderNumber__c
                FROM WorkOrder WHERE Id =: woRecordId LIMIT 1
            ];

            scheduleWrap sWrap = new scheduleWrap();
            IsScheduleEnabled = oWorkOrder.IsScheduled__c;

            if (IsScheduleEnabled) {
                sScheduleStartDate = oWorkOrder.ScheduleStartDate__c;

                sScheduleEndDate = oWorkOrder.ScheduleEndDate__c;

                cancelRespCode = cancelSlot(oWorkOrder);
                oWorkOrder.Deferred__c = 'No';
                oWorkOrder.IsScheduled__c = false;
                oWorkOrder.StartDate = null;
                oWorkOrder.ScheduleEndDate__c = null;
                oWorkOrder.ScheduleStartDate__c = null;
                oWorkOrder.EndDate = null;
                oWorkOrder.DispatchEventCode__c = 'XX';
                oWorkOrder.DCCMTEventCode__c = 'XX';
                oWorkOrder.schedulingInternalLogic__c = 'Neither';

                // Update Work Order
                update oWorkOrder;
            }

            if (cancelRespCode != null) {
                if (cancelRespCode.ReplyCode__c != null) {
                    List < DispatchServiceEvent__c > serEventCancelList = new List < DispatchServiceEvent__c > ();
                    serEventCancelList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                        Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c
                        FROM DispatchServiceEvent__c WHERE Work_Order__c =: oWorkOrder.Id AND Event_Code__c = 'XX'
                        AND Reply_Code__c =: cancelRespCode.ReplyCode__c AND DSP_Code__c =: oWorkOrder.DSP__c LIMIT 1
                    ];

                    if (serEventCancelList.isEmpty() == false && cancelRespCode.ReplyCode__c != '100000') {
                        serEventCancelList[0].DSP_Reference__c = cancelRespCode.ISPConfirmationNumber__c;
                        serEventCancelList[0].Event_DateTime__c = sScheduleStartDate.substringBefore('.') + '|' + sScheduleEndDate.substringBefore('.');
                        //serEventCancelList[0].Reject_Reason__c=cancelRespCode.ResponseMessage__c;
                        serEventCancelList[0].Reply_Code__c = cancelRespCode.ReplyCode__c;
                        serEventCancelList[0].Reply_Code_Description__c = cancelRespCode.ResponseMessage__c;
                        serEventCancelList[0].Service_Event__c = 'CANCEL_SCHEDULE_ATTRCHNG';
                        //serEventCancelList[0].Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());

                        update serEventCancelList[0];

                    } else {

                        DispatchServiceEvent__c serEventCancel = new DispatchServiceEvent__c();
                        serEventCancel.DSP_Code__c = oWorkOrder.DSP__c;
                        serEventCancel.DSP_Details__c = oWorkOrder.DSPName__c;
                        serEventCancel.DSP_Reference__c = cancelRespCode.ISPConfirmationNumber__c;
                        serEventCancel.Event_Code__c = 'XX';
                        serEventCancel.Event_DateTime__c = sScheduleStartDate + '|' + sScheduleEndDate;
                        serEventCancel.Event_Source__c = 'SFDC';
                        //serEventCancel.Reject_Reason__c=cancelRespCode.ResponseMessage__c;
                        serEventCancel.Reply_Code__c = cancelRespCode.ReplyCode__c;
                        serEventCancel.Reply_Code_Description__c = cancelRespCode.ResponseMessage__c;
                        serEventCancel.Service_Event__c = 'CANCEL_SCHEDULE_ATTRCHNG';
                        serEventCancel.Vendor_Transaction_DateTime__c = string.valueOfGmt(System.now());
                        serEventCancel.Work_Order__c = oWorkOrder.Id;

                        insert serEventCancel;
                    }
                }
            }
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'cancelScheduledSlot', 'Dispatch Management');
        }
    }

    @AuraEnabled
    public static string scheduledSlot(Id woRecordId, string scheduleStartTime, string scheduleEndTime) {
        try {
            WorkOrder oWorkOrder;

            string responseCode = '';
            String strStartTime = '';
            String strEndTime = '';
            String serviceLevelTmp = '';
            String serviceHourTmp = '';
            string userName = UserInfo.getFirstName();


            oWorkOrder = [SELECT WorkOrderNumber, AccountId, StartDate, EndDate, Account.Name, Status,
                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c, DSPName__c,
                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City, schedulingInternalLogic__c,
                State, StateCode, Country, CountryCode, PostalCode, Region__c, EntitlementStartDate__c, EntitlementEndDate__c,
                ScheduleStartDate__c, ScheduleEndDate__c, IsScheduled__c, DPS_BUID__c, PartnerWorkOrderNumber__c, DeltaSRNumber__c,
                ContactEmal__c
                FROM WorkOrder WHERE Id =: woRecordId LIMIT 1
            ];

            serviceLevelTmp = oWorkOrder.Service_Option__c.substringBefore('-');

            serviceHourTmp = oWorkOrder.Service_Option__c.substringAfter('-');

            list < ScheduleSlotByAttributes__x > scheduleList = new list < ScheduleSlotByAttributes__x > ();

            scheduleList = (!mockedScheduledSlots.isEmpty()) ? mockedScheduledSlots : [SELECT ConfirmationNumber__c, DispatchID__c, ResponseCode__c, ResponseMessage__c, ReplyCode__c
                FROM ScheduleSlotByAttributes__x WHERE Line1__c =: oWorkOrder.Street AND Line2__c = ''
                AND Line3__c = ''
                AND Line4__c = ''
                AND DispatchID__c =: oWorkOrder.PartnerWorkOrderNumber__c
                AND City__c =: oWorkOrder.City AND IsoCountryCode__c =: oWorkOrder.CountryCode AND State__c =: oWorkOrder.StateCode AND PostalCode__c =: oWorkOrder.PostalCode
                AND ISPRequestID__c =: oWorkOrder.WorkOrderNumber AND ISPTarget__c =: oWorkOrder.DSP__c AND LOB__c =: oWorkOrder.LOB__c AND LoggedUser__c =: userName
                AND Locale__c = 'en_US'
                AND ServiceType__c =: oWorkOrder.Service_Type__c AND ServiceLevel__c =: serviceLevelTmp AND ServiceHours__c =: serviceHourTmp
                AND DPSURL__c =: oWorkOrder.Scheduling_URL__c AND ScheduleEndTime__c =: scheduleEndTime AND ScheduleStartTime__c =: scheduleStartTime LIMIT 1
            ];


            if (scheduleList[0].ResponseCode__c == '100') {
				/*
                DispatchDefaults__c defaultsDetail = new DispatchDefaults__c();

                defaultsDetail = [SELECT Id, DPSType__c, DefaultDPSType__c, CallType__c, DefaultCallType__c, OutOfWarranty__c, Service_Type__c, selected_service_option__c, ServiceLevel__c, ServiceHours__c, Service_Configurations__c,
                    DefaultSKU__c, CustomSKU__c, Billable__c, SpecialOptions__c, CompleteCareOption__c, complete_care_option__c, KYHDOption__c, OconusDispatch__c, PremierCode__c, OutOfHours__c, Work_Order__r.City, Work_Order__r.StateCode, Work_Order__r.DPS_BUID__c,
                    Work_Order__r.PostalCode, Work_Order__r.CountryCode, Work_Order__r.LOB__c, Work_Order__r.Region__c, Work_Order__r.Service_Type__c,
                    Work_Order__r.Country, Work_Order__r.Deferred__c, Work_Order__r.Sanbao_FLG__c, Work_Order__r.FSD_DASP_Flag__c, Work_Order__r.Service_Option__c,
                    Work_Order__r.CallType__c, Work_Order__r.DPSType__c, Work_Order__r.DSP__c, Bill_To__c, Work_Order__c, Work_Order__r.DSPName__c, Work_Order__r.State, Work_Order__r.FSD_DSP_Selection__c,
                    Work_Order__r.FSD_Oconus_Federal_Flag__c, Work_Order__r.DPS_Region__c, Work_Order__r.KYC__c, Work_Order__r.KYHD__c, Work_Order__r.EntitlementStartDate__c,
                    Work_Order__r.Ground_Shipment_Flag__c, Work_Order__r.Timezone__c, Work_Order__r.DeltaSRNumber__c, Work_Order__r.ServiceTag__c,
                    Work_Order__r.AssetItemClass__c, Work_Order__r.DPS_Sub_Region__c, Work_Order__r.DLP__c, Work_Order__r.Complete_Care_Option__c, GroundShipFlg__c
                    FROM DispatchDefaults__c WHERE Work_Order__c =: woRecordId LIMIT 1
                ];
				*/
                if (oWorkOrder.Status == 'Open') {
                    oWorkOrder.Status = 'Pending Schedule';
                }
                strStartTime = getFULLLocalTime(scheduleStartTime, oWorkOrder.Timezone__c);
                strEndTime = getFULLLocalTime(scheduleEndTime, oWorkOrder.Timezone__c);

                oWorkOrder.IsScheduled__c = true;
                oWorkOrder.ScheduleStartDate__c = strStartTime;
                oWorkOrder.ScheduleEndDate__c = strEndTime;
                oWorkOrder.Deferred__c = 'No';
                oWorkOrder.schedulingInternalLogic__c = 'Scheduled';
                oWorkOrder.DispatchEventCode__c = 'XS';
                oWorkOrder.DCCMTEventCode__c = 'XS';
                oWorkOrder.StartDate = processDateTime(scheduleStartTime);
                oWorkOrder.EndDate =  processDateTime(scheduleEndTime); 
                /*
                oWorkOrder.startDate = DateTime.ValueofGMT(scheduleStartTime.replace('T', ' '));
                oWorkOrder.EndDate = DateTime.valueOfGmt(scheduleEndTime.replace('T', ' '));
				*/
                //--- moved the getEsupportURL logic to execute Async to future method.
                //oWorkOrder = getESupportURL(defaultsDetail, oWorkOrder);
                // Update Work Order Record
                update oWorkOrder;
                
                getESupportURL(woRecordId); // Added Newly - to Execute Asynchronously
            }


            if (string.isNotEmpty(scheduleList[0].ReplyCode__c)) {
				// added for PIT defect 6103946 starts here
                integer offSetIndex = scheduleStartTime.indexOf('+');
                if (offSetIndex < 0)
                    offSetIndex = scheduleStartTime.lastIndexOf('-');
                if (offSetIndex >=0) {
                    scheduleStartTime = scheduleStartTime.substring(0, offSetIndex);
                    scheduleEndTime = scheduleEndTime.substring(0, offSetIndex);                            
                }	
                // added for PIT defect 6103946 ends here
                List < DispatchServiceEvent__c > serEventScheduleList = new List < DispatchServiceEvent__c > ();
                serEventScheduleList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                    Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c, DSP_Details__c
                    FROM DispatchServiceEvent__c WHERE Work_Order__c =: oWorkOrder.Id AND Event_Code__c = 'XS'
                    AND Reply_Code__c =: scheduleList[0].ReplyCode__c AND DSP_Code__c =: oWorkOrder.DSP__c LIMIT 1
                ];

                if (serEventScheduleList.isEmpty() == false && scheduleList[0].ReplyCode__c != '100000') {
                    string sExternalId = oWorkOrder.Id + '_' + system.now();
                    serEventScheduleList[0].DSP_Reference__c = scheduleList[0].ConfirmationNumber__c;
                    serEventScheduleList[0].Event_DateTime__c = scheduleStartTime + '|' + scheduleEndTime;
                    //serEventScheduleList[0].Reject_Reason__c=scheduleList[0].ResponseMessage__c;
                    serEventScheduleList[0].Reply_Code__c = scheduleList[0].ReplyCode__c;
                    serEventScheduleList[0].Reply_Code_Description__c = scheduleList[0].ResponseMessage__c;
                    serEventScheduleList[0].Service_Event__c = 'CONFIRM_SCHEDULE';
                    //serEventScheduleList[0].Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());

                    update serEventScheduleList[0];

                } else {

                    DispatchServiceEvent__c serEventSchedule = new DispatchServiceEvent__c();
                    serEventSchedule.DSP_Details__c = oWorkOrder.DSPName__c;
                    serEventSchedule.DSP_Code__c = oWorkOrder.DSP__c;
                    serEventSchedule.DSP_Reference__c = scheduleList[0].ConfirmationNumber__c;
                    serEventSchedule.Event_Code__c = 'XS';

                    if (scheduleStartTime.toUpperCase().indexOf('Z') > 0) {
                        string startSchedule = scheduleStartTime.substring(0, scheduleStartTime.toUpperCase().indexOf('Z') - 1);
                        string endSchedule = scheduleEndTime.substring(0, scheduleEndTime.toUpperCase().indexOf('Z') - 1);
                        serEventSchedule.Event_DateTime__c = startSchedule.replace('T', ' ') + '|' + endSchedule.replace('T', ' ');
                    } else
                        serEventSchedule.Event_DateTime__c = scheduleStartTime.replace('T', ' ') + '|' + scheduleEndTime.replace('T', ' ');

                    serEventSchedule.Event_Source__c = 'SFDC';
                    //serEventSchedule.Reject_Reason__c=scheduleList[0].ResponseMessage__c;
                    serEventSchedule.Reply_Code__c = scheduleList[0].ReplyCode__c;
                    serEventSchedule.Reply_Code_Description__c = scheduleList[0].ResponseMessage__c;
                    serEventSchedule.Service_Event__c = 'CONFIRM_SCHEDULE';
                    //serEventSchedule.Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());
                    serEventSchedule.Work_Order__c = oWorkOrder.Id;

                    insert serEventSchedule;
                }
            }

            return scheduleList[0].ResponseCode__c + '|' + scheduleList[0].ResponseMessage__c + '|' + scheduleList[0].ReplyCode__c;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'scheduledSlot', 'Dispatch Management');
            return null;
        }
    }
    
    //public static WorkOrder getESupportURL(DispatchDefaults__c defaultsDetail, WorkOrder woDetail)
    @future
    public static void getESupportURL(Id woRecordId)
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
		/*
        try {
            string calendarDownload = 'N';
            string pageType = 'SRDETAIL';
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
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotController', 'getESupportURL', 'Dispatch Management');
            woDetail.eSupport_URL__c = 'http://www.dell.com/support/incidents-online/' + woDetail.CountryCode + '/en/19/srSearch';
            return woDetail;
        }
		*/
		
		List<WorkOrder> workOrderList = new List<WorkOrder>();
		workOrderList = [SELECT Id,Schedule_Enable_Flag__c,DPS_BUID__c,
		ScheduleStartDate__c,ScheduleEndDate__c,CountryCode,
			PartnerWorkOrderNumber__c,DeltaSRNumber__c,ContactEmal__c,
			Timezone__c,eSupport_URL__c,eSupportCalendar_URL__c
		FROM WorkOrder WHERE Id =:woRecordId LIMIT 1];
		
		
        try {
            string calendarDownload = 'N';
            string pageType = 'SRDETAIL';
            if (string.isNotBlank(workOrderList[0].ScheduleStartDate__c)) {
                calendarDownload = 'Y';
            }
            if (String.isNotBlank(workOrderList[0].ScheduleStartDate__c) && workOrderList[0].Schedule_Enable_Flag__c.equalsIgnoreCase('Y')) {
                pageType = 'SCHEDULE';
            }

            list < ESupportUrlResponse__x > objESupport = new list < ESupportUrlResponse__x > ();

            objESupport = (!mockedESupportURLResponse.isEmpty()) ? mockedESupportURLResponse : [SELECT EsupportCalendarUrl__c,
                EsupportUrl__c, ResponseCode__c, ResponseMessage__c
                FROM ESupportUrlResponse__x
                WHERE Buid__c =: workOrderList[0].DPS_BUID__c
                AND CountryCode__c =: workOrderList[0].CountryCode
                AND DPSNumber__c =: workOrderList[0].PartnerWorkOrderNumber__c
                AND SRNumber__c =: workOrderList[0].DeltaSRNumber__c
                AND EmailId__c =: workOrderList[0].ContactEmal__c
                AND TimeZone__c =: workOrderList[0].Timezone__c
                AND PageType__c =: pageType AND IncludeCalendarDownload__c =: calendarDownload
                AND StartDate__c =: workOrderList[0].ScheduleStartDate__c AND EndDate__c =: workOrderList[0].ScheduleEndDate__c
            ];
            if (objESupport.size() > 0 && !objESupport.isEmpty() && objESupport != null) {
                if (objESupport[0].ResponseCode__c.equals('100')) {
                    workOrderList[0].eSupport_URL__c = objESupport[0].EsupportUrl__c;
                    workOrderList[0].eSupportCalendar_URL__c = objESupport[0].EsupportCalendarUrl__c;
                } else {
                    workOrderList[0].eSupport_URL__c = 'http://www.dell.com/support/incidents-online/' + workOrderList[0].CountryCode + '/en/19/srSearch';
                }
            } else {
                workOrderList[0].eSupport_URL__c = 'http://www.dell.com/support/incidents-online/' + workOrderList[0].CountryCode + '/en/19/srSearch';
            }
			update workOrderList[0];
			return;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotController', 'getESupportURL', 'Dispatch Management');
            workOrderList[0].eSupport_URL__c = 'http://www.dell.com/support/incidents-online/' + workOrderList[0].CountryCode + '/en/19/srSearch';
			update workOrderList[0];
			return;
        }
    }

    @AuraEnabled
    public static string rescheduledSlot(Id woRecordId, string scheduleStartTime, string scheduleEndTime) {
        try {
            string userName = '';
            WorkOrder oWorkOrder;
            oWorkOrder = [SELECT WorkOrderNumber, AccountId, StartDate, EndDate, Account.Name,
                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c,
                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City, DSPName__c,
                State, Country, PostalCode, Region__c, EntitlementStartDate__c, EntitlementEndDate__c, PartnerWorkOrderNumber__c
                FROM WorkOrder WHERE Id =: woRecordId LIMIT 1
            ];

            list < RescheduleSlots__x > rescheduleList = new list < RescheduleSlots__x > ();

            userName = UserInfo.getFirstName();

            rescheduleList = (!mockedReshuleSlots.isEmpty()) ? mockedReshuleSlots : [SELECT ISPConfirmationNumber__c, ResponseCode__c,
                ResponseMessage__c, ReplyCode__c FROM RescheduleSlots__x
                WHERE WorkOrderNumber__c =: oWorkOrder.PartnerWorkOrderNumber__c AND ISPRequestID__c =: oWorkOrder.WorkOrderNumber
                AND ISPTarget__c =: oWorkOrder.DSP__c AND LOB__c =: oWorkOrder.LOB__c AND LoggedUser__c =: userName
                AND Locale__c = 'en_US'
                AND DPSURL__c =: oWorkOrder.Scheduling_URL__c
                AND ScheduleEndTime__c =: scheduleEndTime AND ScheduleStartTime__c =: scheduleStartTime LIMIT 1
            ];

            if (rescheduleList[0].ResponseCode__c == '100') {

                oWorkOrder.IsScheduled__c = true;
                oWorkOrder.ScheduleStartDate__c = scheduleStartTime;
                oWorkOrder.ScheduleEndDate__c = scheduleEndTime;
                oWorkOrder.Deferred__c = 'No';
                oWorkOrder.schedulingInternalLogic__c = 'Scheduled';
                oWorkOrder.DispatchEventCode__c = 'XR';
                oWorkOrder.DCCMTEventCode__c = 'XR';
                oWorkOrder.startDate = DateTime.ValueofGMT(scheduleStartTime.replace('T', ' '));
                oWorkOrder.EndDate = DateTime.valueOfGmt(scheduleEndTime.replace('T', ' '));

                // Update Work Order Record
                update oWorkOrder;
            }

            if (string.isNotEmpty(rescheduleList[0].ReplyCode__c)) {
                List < DispatchServiceEvent__c > serEventScheduleList = new List < DispatchServiceEvent__c > ();

                serEventScheduleList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                    Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c
                    FROM DispatchServiceEvent__c WHERE Work_Order__c =: oWorkOrder.Id AND Event_Code__c = 'XR'
                    AND Reply_Code__c =: rescheduleList[0].ReplyCode__c AND DSP_Code__c =: oWorkOrder.DSP__c LIMIT 1
                ];

                if (serEventScheduleList.isEmpty() == false && rescheduleList[0].ReplyCode__c != '100000') {

                    serEventScheduleList[0].DSP_Reference__c = rescheduleList[0].ISPConfirmationNumber__c;
                    serEventScheduleList[0].Event_DateTime__c = scheduleStartTime + '|' + scheduleEndTime;
                    //serEventScheduleList[0].Reject_Reason__c=rescheduleList[0].ResponseMessage__c;
                    serEventScheduleList[0].Reply_Code__c = rescheduleList[0].ReplyCode__c;
                    serEventScheduleList[0].Reply_Code_Description__c = rescheduleList[0].ResponseMessage__c;
                    serEventScheduleList[0].Service_Event__c = 'RESCHEDULE_SERVICE';
                    //serEventScheduleList[0].Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());

                    update serEventScheduleList[0];

                } else {

                    DispatchServiceEvent__c serEventSchedule = new DispatchServiceEvent__c();

                    serEventSchedule.DSP_Code__c = oWorkOrder.DSP__c;
                    serEventSchedule.DSP_Details__c = oWorkOrder.DSPName__c;
                    serEventSchedule.DSP_Reference__c = rescheduleList[0].ISPConfirmationNumber__c;
                    serEventSchedule.Event_Code__c = 'XR';
                    if (scheduleStartTime.toUpperCase().indexOf('Z') > 0) {
                        string startSchedule = scheduleStartTime.substring(0, scheduleStartTime.toUpperCase().indexOf('Z') - 1);
                        string endSchedule = scheduleEndTime.substring(0, scheduleEndTime.toUpperCase().indexOf('Z') - 1);
                        serEventSchedule.Event_DateTime__c = startSchedule.replace('T', ' ') + '|' + endSchedule.replace('T', ' ');
                    } else
                        serEventSchedule.Event_DateTime__c = scheduleStartTime.replace('T', ' ') + '|' + scheduleEndTime.replace('T', ' ');
                    //serEventSchedule.Event_DateTime__c= scheduleStartTime +'|'+ scheduleEndTime;
                    serEventSchedule.Event_Source__c = 'SFDC';
                    //serEventSchedule.Reject_Reason__c=rescheduleList[0].ResponseMessage__c;
                    serEventSchedule.Reply_Code__c = rescheduleList[0].ReplyCode__c;
                    serEventSchedule.Reply_Code_Description__c = rescheduleList[0].ResponseMessage__c;
                    serEventSchedule.Service_Event__c = 'RESCHEDULE_SERVICE';
                    //serEventSchedule.Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());
                    serEventSchedule.Work_Order__c = oWorkOrder.Id;
                    serEventSchedule.Work_Order__c = oWorkOrder.Id;

                    insert serEventSchedule;
                }
            }

            return rescheduleList[0].ResponseCode__c + '|' + rescheduleList[0].ResponseMessage__c + '|' + rescheduleList[0].ReplyCode__c;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'rescheduledSlot', 'Dispatch Management');
            return null;
        }
    }
    @AuraEnabled
    Public static scheduleWrap nonSubmittedDispatch(Id woRecordId, string scheduleStartTime, string scheduleEndTime) {
        try {
            WorkOrder oWorkOrder;
            CancelSlot__x cancelRespCode;
            string sScheduleStartDate = '';
            string sScheduleEndDate = '';
            String strDate = '';
            String strStartTime = '';
            String strEndTime = '';
            boolean IsScheduledFlag = false;
            oWorkOrder = [SELECT WorkOrderNumber, Status, AccountId, StartDate, EndDate, Account.Name,
                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c,
                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City, CityCalc__c,
                State, StateCode, Country, CountryCode, PostalCode, Region__c, DSPName__c,
                EntitlementStartDate__c, EntitlementEndDate__c, SLAStartDate__c, SLAEndDate__c,
                Deferred__c, IsScheduled__c, ScheduleStartDate__c, ScheduleEndDate__c, PartnerWorkOrderNumber__c
                FROM WorkOrder WHERE Id =: woRecordId LIMIT 1
            ];
            scheduleWrap sWrap = new scheduleWrap();
            IsScheduledFlag = oWorkOrder.IsScheduled__c;
            if (IsScheduledFlag) {
                sScheduleStartDate = oWorkOrder.ScheduleStartDate__c;
                sScheduleEndDate = oWorkOrder.ScheduleEndDate__c;
                cancelRespCode = cancelSlot(oWorkOrder);
                sWrap.cancelResponse = cancelRespCode.ResponseCode__c + '|' + cancelRespCode.ResponseMessage__c + '|' + cancelRespCode.ReplyCode__c;
            }
            ScheduleSlotByAttributes__x updateRespCodeMessage = scheduleSlot(oWorkOrder, scheduleStartTime, scheduleEndTime);
            sWrap.submitResponse = updateRespCodeMessage.ResponseCode__c + '|' + updateRespCodeMessage.ResponseMessage__c + '|' + updateRespCodeMessage.ReplyCode__c;
            if (oWorkOrder.Status == 'Open') {
                oWorkOrder.Status = 'Pending Schedule';
            }
            if (updateRespCodeMessage.ResponseCode__c == '100') {
                strDate = scheduleStartTime.substring(0, scheduleStartTime.indexOf('T'));
                strStartTime = getFULLLocalTime(scheduleStartTime, oWorkOrder.Timezone__c);
                strEndTime = getFULLLocalTime(scheduleEndTime, oWorkOrder.Timezone__c);
                oWorkOrder.IsScheduled__c = true;
                oWorkOrder.ScheduleStartDate__c = strStartTime;
                oWorkOrder.ScheduleEndDate__c = strEndTime;
                oWorkOrder.Deferred__c = 'No';
                //oWorkOrder.StartDate = DateTime.ValueofGMT(scheduleStartTime.replace('T', ' '));
                //oWorkOrder.EndDate = DateTime.valueOfGMT(scheduleEndTime.replace('T', ' '));
                oWorkOrder.StartDate = processDateTime(scheduleStartTime);
                oWorkOrder.EndDate =  processDateTime(scheduleEndTime); 
                oWorkOrder.schedulingInternalLogic__c = 'Scheduled';
                oWorkOrder.DispatchEventCode__c = 'XS';
                oWorkOrder.DCCMTEventCode__c = 'XS';
            } else {
                oWorkOrder.Deferred__c = 'No';
                oWorkOrder.IsScheduled__c = false;
                oWorkOrder.ScheduleStartDate__c = null;
                oWorkOrder.ScheduleEndDate__c = null;
                oWorkOrder.StartDate = null;
                oWorkOrder.EndDate = null;
                oWorkOrder.schedulingInternalLogic__c = 'Neither';
            }

            // Update Work Order
            update oWorkOrder;


            if (IsScheduledFlag && cancelRespCode != null) {
                if (cancelRespCode.ReplyCode__c != null) {
                    
                    // added for PIT defect 6103946 starts here
                    integer offSetIndex = sScheduleStartDate.indexOf('+');
                    if (offSetIndex < 0)
                        offSetIndex = sScheduleStartDate.lastIndexOf('-');
                    if (offSetIndex >=0) {
                        sScheduleStartDate = sScheduleStartDate.substring(0, offSetIndex);
                        sScheduleEndDate = sScheduleEndDate.substring(0, offSetIndex);                            
                    }	
                    // added for PIT defect 6103946 ends here
                    
                    List < DispatchServiceEvent__c > serEventCancelList = new List < DispatchServiceEvent__c > ();
                    serEventCancelList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                        Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c
                        FROM DispatchServiceEvent__c WHERE Work_Order__c =: oWorkOrder.Id AND Event_Code__c = 'XW'
                        AND Reply_Code__c =: cancelRespCode.ReplyCode__c AND DSP_Code__c =: oWorkOrder.DSP__c LIMIT 1
                    ];

                    if (serEventCancelList.isEmpty() == false && cancelRespCode.ReplyCode__c != '100000') {
                        serEventCancelList[0].DSP_Reference__c = updateRespCodeMessage.ConfirmationNumber__c;
                        serEventCancelList[0].Event_DateTime__c = sScheduleStartDate + '|' + sScheduleEndDate;
                        //serEventCancelList[0].Reject_Reason__c=cancelRespCode.ResponseMessage__c;
                        serEventCancelList[0].Reply_Code__c = cancelRespCode.ReplyCode__c;
                        serEventCancelList[0].Reply_Code_Description__c = cancelRespCode.ResponseMessage__c;
                        serEventCancelList[0].Service_Event__c = 'CANCEL_SCHEDULE';
                        //serEventCancelList[0].Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());

                        update serEventCancelList[0];

                    } else {

                        DispatchServiceEvent__c serEventCancel = new DispatchServiceEvent__c();
                        serEventCancel.DSP_Details__c = oWorkOrder.DSPName__c;
                        serEventCancel.DSP_Code__c = oWorkOrder.DSP__c;
                        serEventCancel.DSP_Reference__c = cancelRespCode.ISPConfirmationNumber__c;
                        serEventCancel.Event_Code__c = 'XW';
                        serEventCancel.Event_DateTime__c = sScheduleStartDate + '|' + sScheduleEndDate;
                        serEventCancel.Event_Source__c = 'SFDC';
                        //serEventCancel.Reject_Reason__c=cancelRespCode.ResponseMessage__c;
                        serEventCancel.Reply_Code__c = cancelRespCode.ReplyCode__c;
                        serEventCancel.Reply_Code_Description__c = cancelRespCode.ResponseMessage__c;
                        serEventCancel.Service_Event__c = 'CANCEL_SCHEDULE';
                        //serEventCancel.Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());
                        serEventCancel.Work_Order__c = oWorkOrder.Id;

                        insert serEventCancel;
                    }
                }
            }


            if (updateRespCodeMessage != null) {

                if (updateRespCodeMessage.ReplyCode__c != null) {
                    
                    // added for PIT defect 6103946 starts here
                    integer offSetIndex = scheduleStartTime.indexOf('+');
                    if (offSetIndex < 0)
                        offSetIndex = scheduleStartTime.lastIndexOf('-');
                    if (offSetIndex >=0) {
                        scheduleStartTime = scheduleStartTime.substring(0, offSetIndex);
                        scheduleEndTime = scheduleEndTime.substring(0, offSetIndex);                            
                    }	
                    // added for PIT defect 6103946 ends here
                    
                    List < DispatchServiceEvent__c > serEventScheduleList = new List < DispatchServiceEvent__c > ();
                    serEventScheduleList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                        Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c
                        FROM DispatchServiceEvent__c WHERE Work_Order__c =: oWorkOrder.Id AND Event_Code__c = 'XR'
                        AND Reply_Code__c =: updateRespCodeMessage.ReplyCode__c AND DSP_Code__c =: oWorkOrder.DSP__c LIMIT 1
                    ];

                    if (serEventScheduleList.isEmpty() == false && updateRespCodeMessage.ReplyCode__c != '100000') {
                        serEventScheduleList[0].DSP_Reference__c = updateRespCodeMessage.ConfirmationNumber__c;
                        serEventScheduleList[0].Event_DateTime__c = scheduleStartTime + '|' + scheduleEndTime;
                        //serEventScheduleList[0].Reject_Reason__c=updateRespCodeMessage.ResponseMessage__c;
                        serEventScheduleList[0].Reply_Code__c = updateRespCodeMessage.ReplyCode__c;
                        serEventScheduleList[0].Reply_Code_Description__c = updateRespCodeMessage.ResponseMessage__c;
                        serEventScheduleList[0].Service_Event__c = 'CONFIRM_SCHEDULE';
                        serEventScheduleList[0].Vendor_Transaction_DateTime__c = string.valueOfGmt(System.now());

                        update serEventScheduleList[0];

                    } else {
                        DispatchServiceEvent__c serEventSchedule = new DispatchServiceEvent__c();
                        serEventSchedule.DSP_Details__c = oWorkOrder.DSPName__c;
                        serEventSchedule.DSP_Code__c = oWorkOrder.DSP__c;
                        serEventSchedule.DSP_Reference__c = updateRespCodeMessage.ConfirmationNumber__c;
                        serEventSchedule.Event_Code__c = 'XS';

                        if (scheduleStartTime.toUpperCase().indexOf('Z') > 0) {
                            string startSchedule = scheduleStartTime.substring(0, scheduleStartTime.toUpperCase().indexOf('Z') - 1);
                            string endSchedule = scheduleEndTime.substring(0, scheduleEndTime.toUpperCase().indexOf('Z') - 1);
                            serEventSchedule.Event_DateTime__c = startSchedule.replace('T', ' ') + '|' + endSchedule.replace('T', ' ');
                        } else
                            serEventSchedule.Event_DateTime__c = scheduleStartTime.replace('T', ' ') + '|' + scheduleEndTime.replace('T', ' ');

                        serEventSchedule.Event_Source__c = 'SFDC';
                        //serEventSchedule.Reject_Reason__c=updateRespCodeMessage.ResponseMessage__c;
                        serEventSchedule.Reply_Code__c = updateRespCodeMessage.ReplyCode__c;
                        serEventSchedule.Reply_Code_Description__c = updateRespCodeMessage.ResponseMessage__c;
                        serEventSchedule.Service_Event__c = 'CONFIRM_SCHEDULE';
                        //serEventSchedule.Vendor_Transaction_DateTime__c  = string.valueOfGmt(System.now());
                        serEventSchedule.Work_Order__c = oWorkOrder.Id;

                        insert serEventSchedule;
                    }
                }
            }
            return sWrap;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'nonSubmittedDispatch', 'Dispatch Management');
            return null;
        }
    }

    public static CancelSlot__x cancelSlot(WorkOrder oWorkOrder) {
        try {
            list < CancelSlot__x > cancelList = new list < CancelSlot__x > ();
            string userName = UserInfo.getFirstName();
            cancelList = (!mockedCancelSlots.isEmpty()) ? mockedCancelSlots : [SELECT ISPConfirmationNumber__c, ResponseCode__c, ResponseMessage__c, ReplyCode__c
                FROM CancelSlot__x WHERE DispatchID__c =: oWorkOrder.PartnerWorkOrderNumber__c
                AND ISPRequestID__c =: oWorkOrder.WorkOrderNumber AND ISPTarget__c =: oWorkOrder.DSP__c AND LOB__c =: oWorkOrder.LOB__c AND Locale__c = 'en_US'
                AND LoggedUser__c =: userName AND DPSURL__c =: oWorkOrder.Scheduling_URL__c LIMIT 1
            ];
            return cancelList[0];
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'cancelSlot', 'Dispatch Management');
            return null;
        }
    }

    public static ScheduleSlotByAttributes__x scheduleSlot(WorkOrder oWorkOrder, string scheduleStartTime, string scheduleEndTime) {
        try {
            string responseCode = '';
            String serviceLevelTmp = oWorkOrder.Service_Option__c.substringBefore('-');
            String serviceHourTmp = oWorkOrder.Service_Option__c.substringAfter('-');
            string userName = UserInfo.getFirstName();

            list < ScheduleSlotByAttributes__x > scheduleList = new list < ScheduleSlotByAttributes__x > ();

            scheduleList = (!mockedScheduleSlotsByArrtributes.isEmpty()) ? mockedScheduleSlotsByArrtributes : [SELECT ConfirmationNumber__c, DispatchID__c, ResponseCode__c, ResponseMessage__c, ReplyCode__c
                FROM ScheduleSlotByAttributes__x WHERE Line1__c =: oWorkOrder.Street
                AND Line2__c = ''
                AND Line3__c = ''
                AND Line4__c = ''
                AND DispatchID__c =: oWorkOrder.PartnerWorkOrderNumber__c AND City__c =: oWorkOrder.CityCalc__c AND IsoCountryCode__c =: oWorkOrder.CountryCode
                AND State__c =: oWorkOrder.StateCode AND PostalCode__c =: oWorkOrder.PostalCode AND ISPRequestID__c =: oWorkOrder.WorkOrderNumber AND ISPTarget__c =: oWorkOrder.DSP__c
                AND LOB__c =: oWorkOrder.LOB__c AND LoggedUser__c =: userName AND DPSURL__c =: oWorkOrder.Scheduling_URL__c AND Locale__c = 'en_US'
                AND ServiceType__c =: oWorkOrder.Service_Type__c
                AND ServiceLevel__c =: serviceLevelTmp AND ServiceHours__c =: serviceHourTmp AND ScheduleEndTime__c =: scheduleEndTime AND ScheduleStartTime__c =: scheduleStartTime LIMIT 1
            ];
            return scheduleList[0];
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'scheduleSlot', 'Dispatch Management');
            return null;
        }
    }
    // Added Newly
    @AuraEnabled//(cacheable = true)
    public static DispatchServiceProviderController.responseWrapper getScheduleSlots(id recordId) {
        return DispatchServiceProviderController.getReScheduleSlots(recordId);
    }
    // Added Newly
    //@AuraEnabled (cacheable=true)
    @AuraEnabled
    public static responseWrapper getDeferralSlots(id recordId) {
        responseWrapper rWrap = new responseWrapper();
        try {
            string serviceHours = '';
            string serviceLevel = '';
            DateTime datSTemp = null;
            DateTime datETemp = null;

            list < WorkOrder > woList = new List < WorkOrder > ();

            woList = [SELECT WorkOrderNumber, Status, AccountId, StartDate, EndDate, Account.Name,
                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c,
                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City,
                State, StateCode, Country, CountryCode, PostalCode, Region__c, CityCalc__c,
                EntitlementStartDate__c, EntitlementEndDate__c, DeltaShiftStart__c,
                DeltaShiftEnd__c, SLAStartDate__c, SLAEndDate__c, DPS_BUID__c, StateCalc__c
                FROM WorkOrder WHERE Id =: recordId LIMIT 1
            ];

            if (string.isNotBlank(woList[0].Service_Option__c)) {
                ServiceHours = woList[0].Service_Option__c.substringAfter('-');
                ServiceLevel = woList[0].Service_Option__c.substringBefore('-');
            }

            Datetime startDate = system.now();
            Datetime EndDate = system.now();
            if (woList[0].EntitlementStartDate__c != null) {
                EndDate = (DateTime) JSON.deserialize('"' + woList[0].EntitlementStartDate__c + '"', DateTime.class);
            }
            // Added Newly for this TASK 5293883 - Ends Here
            integer intDays = startDate.Date().daysBetween(endDate.Date());

            /*if(!(intDays>0)){
                GetSLADates__x slaDates = new GetSLADates__x();
                slaDates = DispatchDefaultsConfiguration.getEntitlementSLA(woList[0].workOrderNumber,woList[0].Service_Option__c,woList[0].PostalCode,woList[0].CountryCode,woList[0].StateCalc__c);
                if(slaDates!=null){
                    if(slaDates.SLAStartDate__c!=null){
                        woList[0].EntitlementStartDate__c = slaDates.SLAStartDate__c;
                    }
                    if(slaDates.SLAEndDate__c!=null){
                        woList[0].EntitlementEndDate__c = slaDates.SLAEndDate__c;
                    }
                    if(slaDates.TimeZone__c!=null){
                        woList[0].Timezone__c = slaDates.TimeZone__c;   
                    }
                }
            }*/

            list < GetSiebelDeferralDates__x > deferList = new list < GetSiebelDeferralDates__x > ();

            string countryLongName = '';
            if (WoList[0].CountryCode__c == 'US') {
                countryLongName = [SELECT Label FROM Asset_Country__mdt WHERE CountryCode__c =: WoList[0].CountryCode__c LIMIT 1].Label;
            } else {
                if (WoList[0].CountryCode__c == 'IN')
                    countryLongName = [SELECT Label FROM Asset_Country__mdt WHERE CountryBUID__c =: WoList[0].DPS_BUID__c AND CountryCode__c != 'IN'
                        LIMIT 1
                    ].Label;
                else
                    countryLongName = woList[0].Country;
            }
            deferList = (!mokedGetSiebelDeferralDates.isEmpty()) ? mokedGetSiebelDeferralDates : [SELECT
                SLAStartDate__c, SLAEndDate__c,
                StartTime__c, EndTime__c, ResponseCode__c, ResponseMessage__c
                FROM GetSiebelDeferralDates__x WHERE
                ServiceType__c =: woList[0].Service_Type__c
                AND ServiceHours__c =: ServiceHours
                AND SLAStartDate__c =: woList[0].SLAStartDate__c
                AND SLAEndDate__c =: woList[0].SLAEndDate__c
                AND ServiceLevel__c =: ServiceLevel
                AND Country__c =: countryLongName
                AND RegionId__c =: woList[0].Region__c
                AND ServiceOption__c =: WoList[0].Service_Option__c
                AND CountryCode__c =: WoList[0].CountryCode__c
                AND WorkOrderNumber__c =: woList[0].WorkOrderNumber LIMIT 200
            ];

            if (!deferList.isEmpty() && deferList.size() > 0 && deferList != null) {
                if (deferList[0].ResponseCode__c.equals('100')) {
                    List < DispatchServiceProviderController.slotsWrapper > slotsWrapperList = new List < DispatchServiceProviderController.slotsWrapper > ();
                    DispatchServiceProviderController.slotsWrapper sWrap;
                    string tempStartDateString = '';
                    string tempEndDateString = '';
                    for (GetSiebelDeferralDates__x avSlt: deferList) {
                        if (String.isNotBlank(avSlt.StartTime__c) && String.isNotBlank(avSlt.EndTime__c)) {
                            if (avSlt.StartTime__c.contains('T') && avSlt.EndTime__c.contains('T')) {
                                sWrap = new DispatchServiceProviderController.slotsWrapper();
                                tempStartDateString = processTime(avSlt.StartTime__c, '');
                                tempEndDateString = processTime(avSlt.EndTime__c, '');
                                if (string.isNotBlank(tempStartDateString)) {
                                    datSTemp = DateTime.ValueofGmt(tempStartDateString.replace('T', ' '));
                                    if (datSTemp != null) {
                                        sWrap.startDate = datSTemp.formatGMT('MMM dd, yyyy');
                                        sWrap.startTime = datSTemp.formatGMT('hh:mm a');
                                        sWrap.startDateVal = tempStartDateString.substringBefore('T');
                                    }
                                }
                                if (string.isNotBlank(tempEndDateString)) {
                                    datETemp = DateTime.ValueofGmt(tempEndDateString.replace('T', ' '));
                                    if (datETemp != null) {
                                        sWrap.endDate = datETemp.formatGMT('MMM dd, yyyy');
                                        sWrap.endTime = datETemp.formatGMT('hh:mm a');
                                        sWrap.endDateVal = tempEndDateString.substringBefore('T');
                                    }
                                }
                                sWrap.startDateTime = avSlt.StartTime__c;
                                sWrap.endDateTime = avSlt.EndTime__c;
                                slotsWrapperList.add(sWrap);
                                datSTemp = null;
                                datETemp = null;
                            }
                        }
                    }
                    if (!slotsWrapperList.isEmpty()) {
                        rWrap.sWrapperList = slotsWrapperList;
                        rWrap.errorMessage = 'SUCCESS';
                        rWrap.shiftStart = woList[0].DeltaShiftStart__c;
                        rWrap.shiftEnd = woList[0].DeltaShiftEnd__c;
                        rWrap.slaStartDate = woList[0].SLAStartDate__c;
                        rWrap.slaEndDate = woList[0].SLAEndDate__c;
                    } else {
                        throw new coustomException('Service Failed to Retrieve Time Slots from Partner');
                    }
                } else {
                    throw new coustomException(deferList[0].ResponseMessage__c);
                }
            } else {
                throw new coustomException('Service Failed to Retrieve Time Slots from Partner');
            }
            return rWrap;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'getDeferralSlots', 'Dispatch Management');
            rWrap.errorMessage = e.getMessage();
            return rWrap;
        }
    }
    // Added Newly    
    @TestVisible
    private static string processTime(string dateTimeValue, String WOTimezone) {
        try {
            string retTime;
            if (dateTimeValue.indexOf('+') > 0) {
                retTime = dateTimeValue.substring(0, dateTimeValue.indexOf(':') + 6);
            } else if (dateTimeValue.indexOf('-') > 10) {
                retTime = dateTimeValue.substring(0, dateTimeValue.indexOf(':') + 6);
            } else {
                DateTime datSTemp = DateTime.ValueofGmt(dateTimeValue.replace('T', ' '));
                if (String.isNotBlank(WOTimezone)) {
                    //retTime = datSTemp.format('yyyy-MM-dd', WOTimezone) + 'T' + datSTemp.format('HH:mm:ss', WOTimezone);
                    retTime = datSTemp.format('YYYY-MM-dd\'T\'HH:mm:ss', WOTimezone);
                } else {
                    //retTime = datSTemp.formatGMT('yyyy-MM-dd') + 'T' + datSTemp.formatGMT('HH:mm:ss');
                    retTime = datSTemp.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss');
                }
            }
            return retTime;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'processTime', 'Dispatch Management');
            return null;
        }
    }
    public static DateTime processDateTime(String strDateTime) {
        DateTime finalDateTime;
        try {
            if (string.isNotEmpty(strDateTime)) {
                finalDateTime = DateTime.ValueofGMT(strDateTime.replace('T', ' '));
                string tempString = '';
                List < String > tempList = new List < String > ();
                if (strDateTime.indexof('+') > 0) {
                    System.debug('strDateTime  --index'+strDateTime.indexof('+'));
                    tempString = strDateTime.substring(strDateTime.indexOf('+') + 1);
                    if (String.isNotBlank(tempString)) {
                        if (tempString.indexof(':') > 0) {
                            tempList = tempString.split(':');
                            if (!tempList.isEmpty()) {
                                if (string.isNotBlank(tempList[0])) {
                                    if (Integer.ValueOf(tempList[0]) > 0) {
                                        finalDateTime = finalDateTime.addHours(-Integer.ValueOf(tempList[0]));
                                    }
                                }
                                if (string.isNotBlank(tempList[1])) {
                                    if (Integer.ValueOf(tempList[1]) > 0) {
                                        finalDateTime = finalDateTime.addMinutes(-Integer.ValueOf(tempList[1]));
                                    }
                                }
                            }
                        }
                    }
                } else if (strDateTime.indexof('-') > 10) {
                    tempString = strDateTime.substring(strDateTime.lastIndexOf('-') + 1);
                    if (String.isNotBlank(tempString)) {
                        if (tempString.indexof(':') > 0) {
                            tempList = tempString.split(':');
                            if (!tempList.isEmpty()) {
                                if (string.isNotBlank(tempList[0])) {
                                    if (Integer.ValueOf(tempList[0]) > 0) {
                                        finalDateTime = finalDateTime.addHours(Integer.ValueOf(tempList[0]));
                                    }
                                }
                                if (string.isNotBlank(tempList[1])) {
                                    if (Integer.ValueOf(tempList[1]) > 0) {
                                        finalDateTime = finalDateTime.addMinutes(Integer.ValueOf(tempList[1]));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return finalDateTime;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotController', 'processDateTime', 'Dispatch Management');
            return null;
        }
    }
       // To Convert Time Value for Delta
    public static string getFULLLocalTime(string sDateTime, string sWOTimezone) {
        try {
            string localTime='';
            String strdt2='';
			DateTime dt;
            //DateTime dt = (DateTime) JSON.deserialize('"' + sDateTime + '"', DateTime.class);
            //String strdt2 = dt.format('YYYY-MM-dd HH:mm:ss', sWOTimezone);
            //strdt2 = strdt2.replace(' ', 'T');
            if(string.isBlank(sDateTime)){
            	throw new coustomException('Input Param sDateTime is Blank');
            }
            if(sDateTime.indexof('+') > 0 || sDateTime.indexof('-') > 10){
            	strdt2 = sDateTime.substring(0, sDateTime.indexOf(':') + 6);
            } else {
                dt = DateTime.ValueofGMT(sDateTime.replace('T', ' '));
                if(string.isNotBlank(sWOTimezone)){
                    strdt2 = dt.format('YYYY-MM-dd\'T\'HH:mm:ss', sWOTimezone);
                } else {
                    strdt2 = dt.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss');
                }
            }
            return strdt2;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'SlotsController', 'getFULLLocalTime', 'Dispatch Management');
            return null;
        }
    }
}
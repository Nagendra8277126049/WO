/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchServiceProviderController
Description:  Controller Apex Class for DispatchServiceProviderEdit Lightning Component -STORY 5587160
-------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  --------------------------------------------------------------------------------
09/24/2018     1.0    Harsha Reddy         Initial Release
01/25/2019	   2.0    Rodrigo Carpio       added section of codes for PIT defect 6103946 
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class DispatchServiceProviderController {
    @TestVisible private static List < AvailableSlotsByAttributes__x > mockedAvailableSlotsByAttr = new List < AvailableSlotsByAttributes__x > ();
    @TestVisible private static List < RescheduleSlots__x > mockedReshuleSlots = new List < RescheduleSlots__x > ();

    public class coustomException extends Exception {}
    public with sharing class slotsWrapper {
        @AuraEnabled public string startDate {
            get;
            set;
        }
        @AuraEnabled public string endDate {
            get;
            set;
        }
        @AuraEnabled public string startDateVal {
            get;
            set;
        }
        @AuraEnabled public string endDateVal {
            get;
            set;
        }
        @AuraEnabled public string startTime {
            get;
            set;
        }
        @AuraEnabled public string endTime {
            get;
            set;
        }
        @AuraEnabled public string startDateTime {
            get;
            set;
        }
        @AuraEnabled public string endDateTime {
            get;
            set;
        }
    }

    public with sharing class responseWrapper {
        @AuraEnabled public string errorMessage {
            get;
            set;
        }
        @AuraEnabled public List < slotsWrapper > sWrapperList {
            get;
            set;
        }
    }

    @AuraEnabled
    public static string saveRescheduledSlot(Id woRecordId, string scheduleStartTime, string scheduleEndTime) {
        try {
            string userName = '';
            WorkOrder oWorkOrder = new WorkOrder();
            oWorkOrder = [SELECT WorkOrderNumber, AccountId, StartDate, EndDate, Account.Name,
                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c,
                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City,
                State, Country, PostalCode, Region__c, EntitlementStartDate__c, EntitlementEndDate__c,PartnerWorkOrderNumber__c
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

            if (!rescheduleList.isEmpty() && rescheduleList.size() > 0) {
                if (rescheduleList[0].ResponseCode__c == '100') {
                    oWorkOrder.IsScheduled__c = true;
                    //oWorkOrder.ScheduleStartDate__c = scheduleStartTime;
                    oWorkOrder.ScheduleStartDate__c = SlotsController.getFULLLocalTime(scheduleStartTime, oWorkOrder.Timezone__c);
                    oWorkOrder.ScheduleEndDate__c = SlotsController.getFULLLocalTime(scheduleEndTime, oWorkOrder.Timezone__c);
                    //oWorkOrder.ScheduleEndDate__c = scheduleEndTime;
                    oWorkOrder.Deferred__c = 'No';
                    oWorkOrder.schedulingInternalLogic__c = 'Scheduled';
                    oWorkOrder.DispatchEventCode__c = 'XR';
                    /*
                    oWorkOrder.startDate = DateTime.ValueofGMT(scheduleStartTime.replace('T', ' '));
                    oWorkOrder.EndDate = DateTime.valueOfGmt(scheduleEndTime.replace('T', ' '));
					*/
                    oWorkOrder.StartDate = SlotsController.processDateTime(scheduleStartTime);
                	oWorkOrder.EndDate =  SlotsController.processDateTime(scheduleEndTime);
                    // Update Work Order Record
                    update oWorkOrder;
                    // Create ServiceEvent
                    createServEvent(rescheduleList, oWorkOrder, scheduleStartTime, scheduleEndTime);
                } else {
                    createServEvent(rescheduleList, oWorkOrder, scheduleStartTime, scheduleEndTime);
                    throw new coustomException(rescheduleList[0].ResponseMessage__c);
                }
            } else {
                throw new coustomException('Service Failed to re-Schedule Time Slots with Partner');
            }
            return 'SUCCESS';
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceProviderController', 'rescheduledSlot', 'Dispatch Management');
            return e.getMessage();
        }
    }

    public static void createServEvent(List < RescheduleSlots__x > rescheduleList, WorkOrder oWorkOrder, string scheduleStartTime, string scheduleEndTime) {
        try {
            if (string.isNotEmpty(rescheduleList[0].ReplyCode__c)) {
                List < DispatchServiceEvent__c > serEventScheduleList = new List < DispatchServiceEvent__c > ();
                serEventScheduleList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                    Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c
                    FROM DispatchServiceEvent__c WHERE Work_Order__c =: oWorkOrder.Id AND Event_Code__c = 'XR'
                    AND Reply_Code__c =: rescheduleList[0].ReplyCode__c AND DSP_Code__c =: oWorkOrder.DSP__c LIMIT 1
                ];
                	// added for PIT defect 6103946 starts here
                    integer offSetIndex = scheduleStartTime.indexOf('+');
                    if (offSetIndex < 0)
                        offSetIndex = scheduleStartTime.lastIndexOf('-');
                    if (offSetIndex >=0) {
                        scheduleStartTime = scheduleStartTime.substring(0, offSetIndex);
                        scheduleEndTime = scheduleEndTime.substring(0, offSetIndex);                            
                    }	
                    // added for PIT defect 6103946 ends here
                if (serEventScheduleList.isEmpty() == false && rescheduleList[0].ReplyCode__c != '100000') {
                    serEventScheduleList[0].DSP_Reference__c = rescheduleList[0].ISPConfirmationNumber__c;
                    serEventScheduleList[0].Event_DateTime__c = scheduleStartTime + '|' + scheduleEndTime;
                    serEventScheduleList[0].Reject_Reason__c = rescheduleList[0].ResponseMessage__c;
                    serEventScheduleList[0].Reply_Code__c = rescheduleList[0].ReplyCode__c;
                    serEventScheduleList[0].Reply_Code_Description__c = rescheduleList[0].ResponseMessage__c;
                    serEventScheduleList[0].Service_Event__c = 'RESCHEDULE_SERVICE';
                    serEventScheduleList[0].Vendor_Transaction_DateTime__c = string.valueOfGmt(System.now());

                    update serEventScheduleList[0];
                } else {
                    DispatchServiceEvent__c serEventSchedule = new DispatchServiceEvent__c();
                    serEventSchedule.DSP_Code__c = oWorkOrder.DSP__c;
                    serEventSchedule.DSP_Reference__c = rescheduleList[0].ISPConfirmationNumber__c;
                    serEventSchedule.Event_Code__c = 'XR';
                    serEventSchedule.Event_DateTime__c = scheduleStartTime + '|' + scheduleEndTime;
                    serEventSchedule.Event_Source__c = 'SFDC';
                    serEventSchedule.Reject_Reason__c = rescheduleList[0].ResponseMessage__c;
                    serEventSchedule.Reply_Code__c = rescheduleList[0].ReplyCode__c;
                    serEventSchedule.Reply_Code_Description__c = rescheduleList[0].ResponseMessage__c;
                    serEventSchedule.Service_Event__c = 'RESCHEDULE_SERVICE';
                    serEventSchedule.Vendor_Transaction_DateTime__c = string.valueOfGmt(System.now());
                    serEventSchedule.Work_Order__c = oWorkOrder.Id;

                    insert serEventSchedule;
                }
            }
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceProviderController', 'createServEvent', 'Dispatch Management');
        }
    }

    @AuraEnabled (cacheable=true)
    public static responseWrapper getReScheduleSlots(id recordId) {
        responseWrapper rWrap = new responseWrapper();
        try {
            string serviceHours = '';
            string serviceLevel = '';
            DateTime datSTemp = null;
            DateTime datETemp = null;

            list < WorkOrder > woList = new List < WorkOrder > ();

            woList = [SELECT WorkOrderNumber, Status, AccountId, StartDate, EndDate, Account.Name,
                ContactId, CountryCode__c, DSP__c, Service_Type__c, Service_Option__c, LOB__c,
                Timezone__c, Scheduling_URL__c, Schedule_Enable_Flag__c, Street, City,CityCalc__c,
                State, StateCode, Country, CountryCode, PostalCode, Region__c,
                EntitlementStartDate__c, EntitlementEndDate__c, DeltaShiftStart__c,
                DeltaShiftEnd__c, SLAStartDate__c, SLAEndDate__c
                FROM WorkOrder WHERE Id =: recordId LIMIT 1
            ];

            if (string.isNotBlank(woList[0].Service_Option__c)) {
                ServiceHours = woList[0].Service_Option__c.substringAfter('-');
                ServiceLevel = woList[0].Service_Option__c.substringBefore('-');
            }
  String LOBCalc='';
  if(woList[0].Region__c!=null && woList[0].Region__c!='1')
  {
    LOBCalc= woList[0].LOB__c;
  }
            list < AvailableSlotsByAttributes__x > scheduleList = new list < AvailableSlotsByAttributes__x > ();
			/*
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-14T13:00:00.000-06:00',ISPEndTime__c='2019-01-14T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-14T08:00:00.000-06:00',ISPEndTime__c='2019-01-14T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-15T13:00:00.000-06:00',ISPEndTime__c='2019-01-15T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-15T08:00:00.000-06:00',ISPEndTime__c='2019-01-15T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-16T13:00:00.000-06:00',ISPEndTime__c='2019-01-14T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-16T08:00:00.000-06:00',ISPEndTime__c='2019-01-14T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-17T13:00:00.000-06:00',ISPEndTime__c='2019-01-15T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-17T08:00:00.000-06:00',ISPEndTime__c='2019-01-15T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-18T13:00:00.000-06:00',ISPEndTime__c='2019-01-14T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            mockedAvailableSlotsByAttr.add(new AvailableSlotsByAttributes__x (ISPStartTime__c='2019-01-18T08:00:00.000-06:00',ISPEndTime__c='2019-01-14T18:00:00.000-06:00',ResponseCode__c='100',ReplyCode__c='100000',ResponseMessage__c='Success'));
            */
            scheduleList = (!mockedAvailableSlotsByAttr.isEmpty()) ? mockedAvailableSlotsByAttr : [SELECT ISPStartTime__c, ISPEndTime__c,
                ResponseCode__c, ReplyCode__c,
                ResponseMessage__c FROM AvailableSlotsByAttributes__x WHERE AddressLine1__c =: woList[0].Street
                AND AddressLine2__c = ''
                AND AddressLine3__c = ''
                AND AddressLine4__c = ''
                AND City__c =: woList[0].CityCalc__c AND CountryCode__c =: woList[0].CountryCode__c
                AND State__c =: woList[0].StateCode AND PostalCode__c =: woList[0].PostalCode
                AND ISPRequestID__c =: woList[0].WorkOrderNumber
                AND ISPTarget__c =: woList[0].DSP__c
                AND LOB__c =: LOBCalc
                AND LoggedUser__c =: UserInfo.getFirstName()
                AND Locale__c = 'en_US'
                AND ServiceType__c =: woList[0].Service_Type__c
                AND ServiceLevel__c =: ServiceLevel AND ServiceHours__c =: ServiceHours
                AND DPSURL__c =: WoList[0].Scheduling_URL__c LIMIT 200
            ];

            if (!scheduleList.isEmpty() && scheduleList.size() > 0) {
                if (scheduleList[0].ResponseCode__c.equals('100')) {
                    List < slotsWrapper > slotsWrapperList = new List < slotsWrapper > ();
                    slotsWrapper sWrap;
                    string tempStartDateString = '';
                    string tempEndDateString = '';
                    for (AvailableSlotsByAttributes__x avSlt: scheduleList) {
                        if (String.isNotBlank(avSlt.ISPStartTime__c) && String.isNotBlank(avSlt.ISPEndTime__c)) {
                            if (avSlt.ISPStartTime__c.contains('T') && avSlt.ISPEndTime__c.contains('T')) {
                                sWrap = new slotsWrapper();
                                tempStartDateString = processTime(avSlt.ISPStartTime__c,woList[0].TimeZone__c);
                                tempEndDateString = processTime(avSlt.ISPEndTime__c,woList[0].TimeZone__c);
                                //datSTemp = DateTime.ValueofGmt(avSlt.ISPStartTime__c.replace('T', ' '));
                                //datETemp = DateTime.ValueofGmt(avSlt.ISPEndTime__c.replace('T', ' '));
                                datSTemp = DateTime.ValueofGmt(tempStartDateString.replace('T', ' '));
                                datETemp = DateTime.ValueofGmt(tempEndDateString.replace('T', ' '));
                                
                                // check slots is on or after Entitlement Start Date
                                // added for 0102 PIT defect                                
                                datetime slaDate = DateTime.ValueofGmt(woList[0].EntitlementStartDate__c.replace('T', ' '));
                                //system.debug('slaDate ' + slaDate);
                                //system.debug('datSTemp ' + datSTemp);
                                if (datSTemp.dateGMT() >= slaDate.dateGMT()) {
                                    sWrap.startDate = datSTemp.formatGMT('MMM dd, yyyy');
                                    sWrap.endDate = datETemp.formatGMT('MMM dd, yyyy');
                                    sWrap.startTime = datSTemp.formatGMT('hh:mm a');
                                    sWrap.endTime = datETemp.formatGMT('hh:mm a');
                                    sWrap.startDateTime = avSlt.ISPStartTime__c;
                                    sWrap.endDateTime = avSlt.ISPEndTime__c;
                                    slotsWrapperList.add(sWrap);
                                }
                                datSTemp = null;
                                datETemp = null;
                            }
                        }
                    }
                    if (!slotsWrapperList.isEmpty()) {
                        rWrap.sWrapperList = slotsWrapperList;
                        rWrap.errorMessage = 'SUCCESS';
                    } else {
                        system.debug('slotsWrapperList.isEmpty() else inside ');
                        throw new coustomException('Service Failed to Retrieve Time Slots from Partner');
                    }
                } else {
                    createServiceEvent(woList[0].DSP__c, scheduleList[0].ReplyCode__c, recordId, scheduleList[0].ResponseMessage__c);
                    system.debug('createServiceEvent ');
                    throw new coustomException(scheduleList[0].ResponseMessage__c);
                }
            } else {
                system.debug('scheduleList.isEmpty() else ');
                throw new coustomException('Service Failed to Retrieve Time Slots from Partner');
            }
            return rWrap;
        } catch (Exception e) {
            system.debug('Exception e ' + e);
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceProviderController', 'getReScheduleSlots', 'Dispatch Management');
            rWrap.errorMessage = e.getMessage();
            return rWrap;
        }
    }

    public static void createServiceEvent(string dsp, string replyCode, Id recordId, string replyMessage) {
        try {
            if (recordId != null) {
                List < DispatchServiceEvent__c > serEventSlotList = new List < DispatchServiceEvent__c > ();
                serEventSlotList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Event_Code__c, Event_DateTime__c, Event_Source__c, Reject_Reason__c,
                    Reply_Code__c, Reply_Code_Description__c, Service_Event__c, Vendor_Transaction_DateTime__c, Work_Order__c
                    FROM DispatchServiceEvent__c WHERE Work_Order__c =: recordId AND Service_Event__c = 'GET_AVAILABLE_SLOT'
                    AND Reply_Code__c =: replyCode AND DSP_Code__c =: dsp LIMIT 1
                ];
                if (!serEventSlotList.isEmpty() && !replyCode.equals('100000')) {
                    serEventSlotList[0].Reject_Reason__c = replyMessage;
                    serEventSlotList[0].Reply_Code__c = replyCode;
                    serEventSlotList[0].Reply_Code_Description__c = replyMessage;
                    serEventSlotList[0].Service_Event__c = 'GET_AVAILABLE_SLOT';
                    serEventSlotList[0].Vendor_Transaction_DateTime__c = string.valueOfGmt(System.now());
                    serEventSlotList[0].Event_DateTime__c = string.valueOfGmt(System.now());
                    update serEventSlotList[0];
                } else {
                    DispatchServiceEvent__c serEventSlot = new DispatchServiceEvent__c();
                    serEventSlot.DSP_Code__c = dsp;
                    serEventSlot.Event_Source__c = 'SFDC';
                    serEventSlot.Reject_Reason__c = replyMessage;
                    serEventSlot.Reply_Code__c = replyCode;
                    serEventSlot.Reply_Code_Description__c = replyMessage;
                    serEventSlot.Service_Event__c = 'GET_AVAILABLE_SLOT';
                    serEventSlot.Vendor_Transaction_DateTime__c = string.valueOfGmt(System.now());
                    serEventSlot.Work_Order__c = recordId;
                    serEventSlot.Event_DateTime__c = string.valueOfGmt(System.now());
                    insert serEventSlot;
                }
            } else {
                throw new coustomException('WorkOrder Id is Blank - Not able to Create Service Event');
            }
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceProviderController', 'CreateServiceEvent', 'Dispatch Management');
        }
    }

    /* 
     * Created By : Harsha Gangi Reddy
     * Created Date: 10/04/2018
     * Requirement : STORY 5587160
     * Description : To check whether Current Date is in 5 business days from Entitlement Start Date
     *  
    */
    public static boolean checkIsFiveBusinessDays(DateTime EntitlementStartDate, string Country) {
        try {
            
            if(String.isNotBlank(Country)){
                if(Country.equalsIgnoreCase('United States')) {
                    Country = 'USA';
                }
                
                Country = Country + ' Holidays';
            } else {
                throw new coustomException('Input Parameter Country is Blank');
            }
            
            //Country = 'USA Holidays'
            
            // Total Days
            integer totalDays = 0;
            
            // StartDateTime
            DateTime StartDateTime = EntitlementStartDate;
            // EndDateTime
            DateTime endDateTime = DateTime.now();

            //Extract Date from DateTime
            // Start Date
            Date startDate = StartDateTime.date();
            // End Date
            Date endDate = endDateTime.date();

            //Convert to GMT
            StartDateTime = StartDateTime.dateGMT();
            endDateTime = endDateTime.dateGMT();

            // Calculate Days
            totalDays = startDate.daysBetween(endDate);

            // Check If days are more than 5
            if (startDate.daysBetween(endDate) > 5) {
                List < Exception_Hours__c > expList = new List < Exception_Hours__c > ();
                expList = [SELECT End_Date__c, Id, Name, Start_Date__c FROM Exception_Hours__c
                    WHERE Name = :Country
                    AND((Start_Date__c >=: StartDate AND Start_Date__c <=: EndDate) OR(END_Date__C >=: StartDate AND END_Date__C <=: EndDate))
                ];

                Date tempDateVar;
                String tempStrVar;
                Date tempStartDateVar;
                Date tempEndDateVar;
                
                while (StartDateTime <= endDateTime) {
                    tempStrVar = StartDateTime.formatGMT('E');
                    // Exclude Saturday and Sunday as Business Working Days
                    if (!tempStrVar.equals('Sat') && !tempStrVar.equals('Sun')) {
                        if(!expList.isEmpty()&& expList.size()>0){
                            for (Exception_Hours__c expH: expList) {
                                tempStartDateVar = expH.Start_Date__c.date();
                                tempEndDateVar = expH.End_Date__c.date();
                                tempDateVar = StartDateTime.Date();
                                
                                if (tempDateVar >= tempStartDateVar && tempDateVar <= tempEndDateVar) {
                                    totalDays = totalDays - 1;
                                }
                            }
                        }
                    } else {
                        totalDays = totalDays - 1;
                    }
                    StartDateTime = StartDateTime.addDays(1);
                }
                if (totalDays > 5) {
                    return false;
                } else {
                    return true;
                }
            } else {
                // days are less than 5
                return true;
            }
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceProviderController', 'checkIsFiveBusinessDays', 'Dispatch Management');
            return false;
        }
    }
    /* 
     * Created By : Harsha Gangi Reddy
     * Created Date: 10/10/2018
     * Requirement : STORY 5587160 - DEFECT 5707549
     * Description : To Process Time Slot received from the partner
    */
    @TestVisible
    private static string processTime(string dateTimeValue,String WOTimezone) {
        try{
            string retTime;
            if (dateTimeValue.indexOf('+')>0){
                retTime = dateTimeValue.substring(0,dateTimeValue.indexOf(':')+6);
            //} else if (dateTimeValue.indexOf('-')>10){
            } else if (dateTimeValue.lastIndexOf('-')>15){
                retTime = dateTimeValue.substring(0,dateTimeValue.indexOf(':')+6);
            } else{
                DateTime datSTemp = DateTime.ValueofGmt(dateTimeValue.replace('T', ' '));
                if (String.isNotBlank(WOTimezone)){
                    //retTime = datSTemp.format('yyyy-MM-dd', WOTimezone)+'T'+ datSTemp.format('HH:mm:ss', WOTimezone);
                    retTime = datSTemp.format('YYYY-MM-dd\'T\'HH:mm:ss', WOTimezone);
                } else {
                    //retTime = datSTemp.formatGMT('yyyy-MM-dd')+'T'+datSTemp.formatGMT('HH:mm:ss');
                    retTime = datSTemp.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss');
                }
            }
            return retTime; 
        }catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e,'DispatchServiceProviderController','processTime','Dispatch Management');
            return null;
        }    
    }
}
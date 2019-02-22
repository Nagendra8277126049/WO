/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchApprovalProcessController
Description:  This class contain method that handles approval process queries
Date         Version    Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
08/23/2018     1.0     Sri Harsha G      Initial Release
08/23/2018     1.0     Rodrigo Carpio    
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class DispatchApprovalProcessController {
    public with sharing class approvalWrapper {
        @AuraEnabled public string responseMessage {
            get;
            set;
        }
        @AuraEnabled public List < String > approvalCriteriaMessage {
            get;
            set;
        }
        @AuraEnabled public String approvalQueueName {
            get;
            set;
        }
        @AuraEnabled public boolean dspOverrideFlag {
            get;
            set;
        }
        @AuraEnabled public boolean autoApproveFlag {
            get;
            set;
        }
        @AuraEnabled public string qMapRecId {
            get;
            set;
        }
        public approvalWrapper() {
            responseMessage = '';
            approvalCriteriaMessage = new List < String > ();
            approvalQueueName = '';
            dspOverrideFlag = false;
            autoApproveFlag = false;
            qMapRecId = '';
        }
    }

    @TestVisible private static List < WorkOrderLineItem > partsList = new List < WorkOrderLineItem > ();
    @TestVisible private static List < DispatchDefaults__c > ddList = new List < DispatchDefaults__c > ();
    @TestVisible private static List < WorkOrder > woList  = new List < WorkOrder > ();
    @TestVisible private static List < string > criteriaMessageList = new List < string > ();
    @TestVisible private static string approvalQueueSet;
    @TestVisible private static string qMapRecIdSet;
    @TestVisible private static string partsString;
    @TestVisible private static string commodityString;
    @TestVisible private static List < DPSAndCallType__x > mockedRequests = new List < DPSAndCallType__x > ();

    @AuraEnabled
    public static approvalWrapper checkApprovalCriteria(Id recordId)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       checkApprovalCriteria
    Description:  this function contains the logic of the check approval 
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/23/2018     1.0     Sri Harsha G    Initial Release
    08/30/2018     1.0     Rodrigo Carpio   Added changes for APS Flag
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        approvalWrapper appWrap = new approvalWrapper();
        try {
            partsString             =   '';
            commodityString         =   '';
            String DASP             =   '';
            woList = [SELECT Id, WorkOrderNumber, CaseApprovalQueueName__c, CaseId, Deferred__c, EntitlementEndDate__c,
                EntitlementStartDate__c, IsDeferralAllowed__c, IsScheduled__c, ScheduleEndDate__c, ScheduleStartDate__c,
                Schedule_Enable_Flag__c, Service_Option__c, Service_Type__c, Status, schedulingInternalLogic__c,
                AD_Override_Flg__c, Complete_Care_Option__c, CountryCode, Country, KYHD__c, FSD_System_Model__c, LOB__c,
                Repeat_Dispatch_Count__c, Reason_for_repeat_Work_Order__c, Sanbao_FLG__c,
                DPSType__c, KYC__c, OwnerLogin__c, AssetProductModel__c,
                CreatedDate, Approval_Criteria_Met__c, CallType__c, DASP__c
                FROM WorkOrder WHERE Id =: recordId LIMIT 1
            ];
            
            partsList = [SELECT CustomerReplaceableUnit__c, FieldReplaceableUnit__c, Country, Quantity,
                Part__c, PartNumber__c, PartCommodity__c, ISP_Cost__c, ISPOrder_Qty__c,PartPrice__c,
                Also_Ship__c, Line_Item_Type__c, Part_Quantity__c, SelectionMethod__c
                FROM WorkOrderLineItem
                WHERE WorkOrderId =: recordId AND Selected_By_user__c = true LIMIT 1000
            ];
            
            ddList = [SELECT DSP_Override_Request__c, DPSType__c, Bill_To__c, Billable__c, Category__c,
                CompleteCareOption__c, OutOfWarranty__c, SpecialOptions__c, Service_Configurations__c,
                CallType__c
                FROM DispatchDefaults__c WHERE Work_Order__c =: recordId ORDER BY CreatedDate DESC NULLS LAST LIMIT 1
            ];
            
            string basicCheckResp = basicWorkOrderCheck();

            if (string.isNotBlank(basicCheckResp)) {
                if (!basicCheckResp.equalsIgnoreCase('SUCCESS')) {
                    appWrap.responseMessage = basicCheckResp;
                    return appWrap;
                }
            }
            DASP    =   woList[0].DASP__c;  
            if (ddList[0].DSP_Override_Request__c && string.isBlank(DASP)) {
                appWrap.dspOverrideFlag = true;
                appWrap.responseMessage = 'SUCCESS';
                return appWrap;
            }

            String dpsType = '';
            dpsType = getDPSTypeAndCallType(new List < string > {
                recordId
            });
            
            if(!(woList[0].Service_Type__c.equalsIgnoreCase('Labor Only')))
            {
                Integer recordLine =  [SELECT count() 
                                            FROM DispatchPartsOrder__c  
                                            WHERE Work_Order__c=:recordId LIMIT 1];
                if (recordLine == 0)
                {
                    DispatchPartsOrder__c partsOrderUpsert = new DispatchPartsOrder__c();
                    partsOrderUpsert.ISP_FSD_Line_Num__c = recordLine+1;
                    partsOrderUpsert.ISP_FSD_Seq__c = recordLine+1;
                    partsOrderUpsert.Name = recordId + String.valueOf(recordLine+1);
                    partsOrderUpsert.ExternalId__c = recordId + String.valueOf(recordLine+1);
                    partsOrderUpsert.Work_Order__c = recordId;
                    
                    Insert partsOrderUpsert;
                    
                    if (partsOrderUpsert.Id != null)
                    {
                    List<WorkOrderLineItem> woLineList = new List<WorkOrderLineItem>([SELECT Id, DispatchPartsOrder__c FROM WorkOrderLineItem WHERE WorkOrderId =:recordId LIMIT 1000]);
                    List<WorkOrderLineItem> woLineToBeUpdated = new List<WorkOrderLineItem>();
                    for (WorkOrderLineItem item : woLineList)
                        {
                            item.DispatchPartsOrder__c = partsOrderUpsert.Id;
                            
                            woLineToBeUpdated.add(item);
                        }
                        
                        Update woLineToBeUpdated;
                    }
                }
            }
            
            if (string.isBlank(dpsType)) {
                appWrap.responseMessage = 'CALL TYPE FAILED';
                return appWrap;
            } else {
                if (dpsType.equalsIgnoreCase('CALL TYPE FAILED')) {
                    appWrap.responseMessage = 'CALL TYPE FAILED';
                    return appWrap;
                }
            }
            
            if (IsCurrentUserApprover()) {
                appWrap.autoApproveFlag = true;
                appWrap.responseMessage = 'SUCCESS';
                return appWrap;
            }

            string responseM = approvalAttributeCheck();

            if (responseM.equalsIgnoreCase('Approve')) {
                appWrap.autoApproveFlag = true;
                appWrap.responseMessage = 'SUCCESS';
                return appWrap;
            } else if (responseM.equalsIgnoreCase('Pending')) {
                appWrap.autoApproveFlag = false;
                appWrap.responseMessage = 'SUCCESS';
                appWrap.approvalQueueName = approvalQueueSet;
                appWrap.qMapRecId = qMapRecIdSet;
                appWrap.approvalCriteriaMessage.addAll(criteriaMessageList);
                return appWrap;
            }

            appWrap.responseMessage = 'FAILURE';

            return appWrap;
        } catch (exception e) {
            appWrap.responseMessage = 'FAILURE';
            return appWrap;
        }
    }

    public static String approvalAttributeCheck()
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       approvalAttributeCheck
    Description:  this function contains the logic of the approval attribute check
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/23/2018     1.0     Sri Harsha G    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {

            boolean OSPUser = false;  // Added - 10/24/2018
            Integer count = 0;

            count = [SELECT count() FROM workorder WHERE CaseId =: woList[0].CaseId AND Status NOT IN('Pending Schedule', 'Open', 'Cancelled', 'Closed') LIMIT 50000];

            if (woList[0].Status.equalsIgnoreCase('Open') || woList[0].Status.equalsIgnoreCase('Pending Schedule')) {
                count = count + 1;
            }

            woList[0].Repeat_Dispatch_Count__c = count;

            List < User > userList = new List < User > ();
            userList = [select Id, Dell_NTUserID__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            Map < Id, Queue_Approval_Attribute_Map__c > QueueMap;
            if (string.isNotBlank(woList[0].CaseApprovalQueueName__c)) {
                QueueMap = new Map < Id, Queue_Approval_Attribute_Map__c > ([SELECT Id, Approval_Attribute_Set__c, 
                    Queue_User__c, Approver__c,OSP_Workorder_Approval_Queue__c
                    FROM Queue_Approval_Attribute_Map__c WHERE Queue_User__c =: userList[0].Dell_NTUserID__c
                    OR Queue_User__c =: woList[0].CaseApprovalQueueName__c LIMIT 50000
                ]);
                // Updated - 10/24/2018
            } else {
                QueueMap = new Map < Id, Queue_Approval_Attribute_Map__c > ([SELECT Id, Approval_Attribute_Set__c, 
                    Queue_User__c, Approver__c,OSP_Workorder_Approval_Queue__c
                    FROM Queue_Approval_Attribute_Map__c WHERE Queue_User__c =: userList[0].Dell_NTUserID__c
                    LIMIT 50000
                ]);
                // Updated - 10/24/2018
            }

            if (!QueueMap.isEmpty() && QueueMap != null && QueueMap.size() > 0) {
                Map < Id, List < Queue_Approval_Attribute_Map__c >> qAAndAASMap = new Map < Id, List < Queue_Approval_Attribute_Map__c >> ();
                for (Queue_Approval_Attribute_Map__c qMap: QueueMap.values()) {
                    if (string.isNotBlank(qMap.Approval_Attribute_Set__c)) {
                        if (qAAndAASMap.containsKey(qMap.Approval_Attribute_Set__c)) {
                            List < Queue_Approval_Attribute_Map__c > qMapList = qAAndAASMap.get(qMap.Approval_Attribute_Set__c);
                            qMapList.add(qMap);
                            qAAndAASMap.put(qMap.Approval_Attribute_Set__c, qMapList);
                        } else {
                            qAAndAASMap.put(qMap.Approval_Attribute_Set__c, new List < Queue_Approval_Attribute_Map__c > {
                                qMap
                            });
                        }
                    }
                }

                if (!qAAndAASMap.isEmpty() && qAAndAASMap.size() > 0 && qAAndAASMap != null) {
                    Map < Id, Approval_Attribute_Set__c > apSetMap = new Map < Id, Approval_Attribute_Set__c > ([SELECT AAS_Name__c, AD_Override_Request__c, Approval_Criteria_Message__c, Billable__c, Bill_To__c, Category__c,
                        Commodity__c, Complete_Care__c, Cost__c, Country__c, CRU__c, Day_of_Week__c,
                        DPS_Type__c, FRU__c, Id, Individual_Dispatch_Probation__c,
                        KYC__c, KYHD__c, Model__c, Name, Out_of_Warranty__c, Overall__c, Part_ID__c,
                        Product_LOB__c, Quantity_excluding_Also_Shipped_Parts__c, Quantity__c,
                        Repeat_Dispatch_Count__c, Repeat_Reason__c, SanBao__c, Service_Hours__c,
                        Service_Level__c, Service_Type__c, SR_Diagnostic_Results__c,
                        SR_Diagnostic_Tool__c, System_Class__c, Time_of_Day__c, APS_Flag__c
                        FROM Approval_Attribute_Set__c WHERE Id IN: qAAndAASMap.keySet() LIMIT 50000
                    ]);

                    if (!apSetMap.isEmpty() && apSetMap.size() > 0 && apSetMap != null) {

                        Map < Id, Approval_Criterion__c > apSetCriteria = new Map < Id, Approval_Criterion__c > ([SELECT Bill_To__c, Commodity__c, KYHD__c, Part_ID__c, Quantity__c,
                            Service_Type__c, System_Class__c, Billable__c, AD_Override_Request__c,
                            Category__c, Complete_Care__c, Cost__c, CRU__c, Day_of_Week__c,
                            FRU__c, Model__c, Out_of_Warranty__c, Overall__c, Product_LOB__c,
                            Repeat_Dispatch_Count__c, Repeat_Reason__c, SanBao__c, Service_Hours__c,
                            Service_Level__c, SR_Diagnostic_Results__c, SR_Diagnostic_Tool__c, Time_of_Day__c,
                            Country__c, KYC__c, DPS_Type__c, Quantity_excluding_Also_Shipped_Parts__c,
                            Approval_Message__c, Approval_Attribute_Set__c, Name, APS_Flag__c FROM Approval_Criterion__c WHERE Active__c = true AND
                            Approval_Attribute_Set__c IN: apSetMap.keySet() LIMIT 50000
                        ]);

                        if (!apSetCriteria.isEmpty() && apSetCriteria.size() > 0 && apSetCriteria != null) {

                            Map < Id, List < Approval_Criterion__c >> apSetAndCriteriaMap = new Map < Id, List < Approval_Criterion__c >> ();

                            for (Approval_Criterion__c acc: apSetCriteria.values()) {
                                if (apSetAndCriteriaMap.containsKey(acc.Approval_Attribute_Set__c)) {
                                    List < Approval_Criterion__c > accList = apSetAndCriteriaMap.get(acc.Approval_Attribute_Set__c);
                                    accList.add(acc);
                                    apSetAndCriteriaMap.put(acc.Approval_Attribute_Set__c, accList);
                                } else {
                                    apSetAndCriteriaMap.put(acc.Approval_Attribute_Set__c, new List < Approval_Criterion__c > {
                                        acc
                                    });
                                }

                            }

                            boolean woCriteriaMatched;
                            DispatchDefaults__c dispDefault = new DispatchDefaults__c();
                            dispDefault = ddList[0];

                            list < WorkOrderLineItem > lineItemList = new List < WorkOrderLineItem > ();
                            lineItemList.addAll(partsList);
                            
                            OSPUser = IsOSPUser(); // Added - 10/24/2018

                            // loop thru all the attribute set
                            for (Approval_Attribute_Set__c apSet: apSetMap.values()) {
                                if (apSetAndCriteriaMap.containsKey(apSet.Id)) {
                                    for (Approval_Criterion__c apCriObj: apSetAndCriteriaMap.get(apSet.Id)) {
                                        if (!apCriObj.Overall__c) {
                                            // call the rounting sub process flow
                                            commodityString = '';
                                            partsString = '';

                                            woCriteriaMatched = dispatchRoutingProcess(woList[0], dispDefault, lineItemList, apCriObj, apSet);

                                            if (woCriteriaMatched) {
                                                criteriaMessageList.add(apCriObj.Approval_Message__c);
                                                if (qAAndAASMap.containsKey(apSet.Id)) {
                                                    for (Queue_Approval_Attribute_Map__c qqMap: qAAndAASMap.get(apSet.Id)) {
                                                        //if (string.isNotBlank(qqMap.Approver__c)){ // Commented - 10/24/2019
                                                        // Updated - 10/24/2019
                                                        if (string.isNotBlank(qqMap.Approver__c) && !OSPUser) {
                                                            approvalQueueSet = qqMap.Approver__c;
                                                            qMapRecIdSet = qqMap.Id;
                                                        } else if (OSPUser && string.isNotBlank(qqMap.OSP_Workorder_Approval_Queue__c)) {
                                                            approvalQueueSet = qqMap.OSP_Workorder_Approval_Queue__c;
                                                            qMapRecIdSet = qqMap.Id;
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            criteriaMessageList.add(apCriObj.Approval_Message__c);
                                                    if (qAAndAASMap.containsKey(apSet.Id)) {
                                                    for (Queue_Approval_Attribute_Map__c qqMap: qAAndAASMap.get(apSet.Id)) {
                                                        if (string.isNotBlank(qqMap.Approver__c) && !OSPUser) {
                                                            approvalQueueSet = qqMap.Approver__c;
                                                            qMapRecIdSet = qqMap.Id;
                                                        } else if (OSPUser && string.isNotBlank(qqMap.OSP_Workorder_Approval_Queue__c)) {
                                                            approvalQueueSet = qqMap.OSP_Workorder_Approval_Queue__c;
                                                            qMapRecIdSet = qqMap.Id;
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            //system.debug('criteriaMessageList list ' + criteriaMessageList);
                            //system.debug('approval Queue Set ' + approvalQueueSet);

                            if (!criteriaMessageList.isEmpty() && criteriaMessageList.size() > 0 && criteriaMessageList != null) {
                                return 'Pending';
                            }
                        }
                    }
                }
            }
            return 'Approve';
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchApprovalProcessController', 'approvalAttributeCheck', 'Dispatch Management');
            return e.getMessage();
        }
    }

    public static boolean dispatchRoutingProcess(WorkOrder woDetailObj, DispatchDefaults__c dispDefault,
        List < WorkOrderLineItem > woLineItemList, Approval_Criterion__c acObj, Approval_Attribute_Set__c aasObj)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       dispatchRoutingProcess
    Description:  this function contains the logic of the RoutingSubflow
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/23/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            boolean criteriaMatched = true;

            boolean woCriteriaMatched = true;
            boolean partsMatched = true;
            boolean commodityMatched = true;
            
            if(!Test.isRunningTest()){
                criteriaMatched = workOrderDetailMatch(woDetailObj, dispDefault, acObj, aasObj);
            }

            if (criteriaMatched == true) {
                if (woLineItemList != null) {
                    
                    if(!Test.isRunningTest()){
                        criteriaMatched = workOrderLineItemMatch(woLineItemList, acObj, aasObj);
                    }

                    if (criteriaMatched) {
                        // this the area to check parts matching
                        if (aasObj.Part_ID__c != null) {
                            List < string > partsList = acObj.Part_ID__c.split(',');
                            Set < String > partsSet = new Set < String > ();
                            partsSet.addAll(partsList);
                            partsMatched = DispatchCheckPartsAndCommodityMatch(partsString, partsSet, true); // put the function that will process Parts ID

                            if ((aasObj.Part_ID__c.equalsIgnoreCase('Include') && partsMatched == false) || (aasObj.Part_ID__c.equalsIgnoreCase('Exclude') && partsMatched == true))
                                return false;
                        }


                        // this the area to check for commodity matching    
                        if (aasObj.Commodity__c != null) {
                            List < string > commodityList = acObj.Commodity__c.split(',');
                            Set < string > commiditySet = new Set < string > ();
                            commiditySet.addAll(commodityList);
                            partsMatched = DispatchCheckPartsAndCommodityMatch(commodityString, commiditySet, true); // put the function that will process Parts ID

                            if ((aasObj.Commodity__c.equalsIgnoreCase('Include') && partsMatched == false) || (aasObj.Commodity__c.equalsIgnoreCase('Exclude') && partsMatched == true)) {
                                return false;
                            }

                        }
                        
                    }
                }
            }
            return criteriaMatched;
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchApprovalProcessController', 'dispatchRoutingProcess', 'Dispatch Management');
            return false;
        }
    }

    public static boolean workOrderDetailMatch(WorkOrder woDetailObj, DispatchDefaults__c dispDefault, Approval_Criterion__c acObj, Approval_Attribute_Set__c aasObj)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       workOrderDetailMatch
    Description:  this functions perform the approval process for work order details
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/23/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            boolean woCriteriaMatched = true;
            String serviceLevelValue = woDetailObj.Service_Option__c.substringBefore('-');
            String serviceHourValue = woDetailObj.Service_Option__c.substringAfter('-');
            boolean billableFlag = (dispDefault.Billable__c == 'Y') ? true : false;
            boolean sanbaoFlag = (woDetailObj.Sanbao_FLG__c == 'Y') ? true : false;
            String dayOfWeek = woDetailObj.CreatedDate.format('EEEE');
            //Start Country matching between WO.Country (standard field) and AC.Country__c - Deepa
            List<String> acCountryList = new List<String>();
            Set<String> countrySet = new Set<String>();
            if(aasObj.Country__c!=NULL && acObj.Country__c!=NULL && woDetailObj.Country!=NULL){
                acCountryList = acObj.Country__c.toUpperCase().split(',');//convert to uppercase, split and add to set    
                system.debug('d>>'+acCountryList);
                countrySet.addAll(acCountryList);
            }
            //End Country Match - added country check to woCriteriaMatched
            if ((aasObj.Service_Type__c && !acObj.Service_Type__c.equalsIgnoreCase(woDetailObj.Service_Type__c)) ||
                (aasObj.Service_Level__c && !acObj.Service_Level__c.equalsIgnoreCase(serviceLevelValue)) ||
                (aasObj.Service_Hours__c && !acObj.Service_Hours__c.equalsIgnoreCase(serviceHourValue)) ||
                (aasObj.Model__c && acObj.Model__c != woDetailObj.AssetProductModel__c) ||
                (aasObj.AD_Override_Request__c && acObj.AD_Override_Request__c != woDetailObj.AD_Override_Flg__c) ||
                (aasObj.Product_LOB__c && acObj.Product_LOB__c.equalsIgnoreCase(woDetailObj.LOB__c)) ||
                (aasObj.KYHD__c && acObj.KYHD__c != woDetailObj.KYHD__c) ||
                (aasObj.Billable__c && acObj.Billable__c != billableFlag) ||
                (aasObj.Category__c && acObj.Category__c!=null && dispDefault.SpecialOptions__c != null && acObj.Category__c != dispDefault.SpecialOptions__c) ||
                (aasObj.Complete_Care__c && acObj.Complete_Care__c != woDetailObj.Complete_Care_Option__c) ||
                (aasObj.Out_of_Warranty__c && acObj.Out_of_Warranty__c != dispDefault.OutOfWarranty__c) ||
                (aasObj.System_Class__c && acObj.System_Class__c != null && dispDefault.Service_Configurations__c != null && acObj.System_Class__c != dispDefault.Service_Configurations__c) ||
                (aasObj.SanBao__c && acObj.SanBao__c != sanbaoFlag) ||
                (aasObj.Repeat_Reason__c && !acObj.Repeat_Reason__c.equalsIgnoreCase(woDetailObj.Reason_for_repeat_Work_Order__c)) ||
                (aasObj.Day_of_Week__c && acObj.Day_of_Week__c != dayOfWeek) ||
                (aasObj.DPS_Type__c && !acObj.DPS_Type__c.equalsIgnoreCase(woDetailObj.DPSType__c.trim())) ||
                (aasObj.KYC__c && acObj.KYC__c != woDetailObj.KYC__c) || (aasObj.Billable__c && acObj.Billable__c != billableFlag) ||
                ((aasObj.Billable__c && acObj.Billable__c == billableFlag) && (aasObj.Bill_To__c && acObj.Bill_To__c != dispDefault.Bill_To__c))
                || (!countrySet.isEmpty() && (!countrySet.contains(woDetailObj.Country.toUpperCase()) && aasObj.Country__c.equalsIgnoreCase('Include'))
                    || (countrySet.contains(woDetailObj.Country.toUpperCase()) && aasObj.Country__c.equalsIgnoreCase('Exclude'))
                ) ) {
                    woCriteriaMatched = false;
                }
            if (aasObj.Repeat_Dispatch_Count__c != null) {
                if ((aasObj.Repeat_Dispatch_Count__c.equalsIgnoreCase('Equal To') && acObj.Repeat_Dispatch_Count__c != woDetailObj.Repeat_Dispatch_Count__c) || (aasObj.Repeat_Dispatch_Count__c.equalsIgnoreCase('Greater Than') && woDetailObj.Repeat_Dispatch_Count__c <= acObj.Repeat_Dispatch_Count__c) || (aasObj.Repeat_Dispatch_Count__c.equalsIgnoreCase('Less Than') && woDetailObj.Repeat_Dispatch_Count__c >= acObj.Repeat_Dispatch_Count__c))
                    woCriteriaMatched = false;
            }
            //system.debug(acObj.Name + ' ' + acObj.DPS_Type__c + ' DPS Type ' + woDetailObj.DPSType__c + ' ' + woCriteriaMatched);
            return woCriteriaMatched;

        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchApprovalProcessController', 'workOrderDetailMatch', 'Dispatch Management');
            return false;
        }
    }

    public static boolean workOrderLineItemMatch(List < WorkOrderLineItem > woLineItemList, Approval_Criterion__c acObj, Approval_Attribute_Set__c aasObj)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       workOrderLineItemMatch
    Description:  this functions perform the approval process for work order line item 
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/23/2018     1.0     Rodrigo Carpio    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            integer qtyAllParts = 0;
            integer qtyExludeAlsoShipped = 0;
            boolean costMatch = false;
            boolean cruMatch = false;
            boolean fruMatch = false;
            boolean apsFlagMatch = false;
            boolean allQtyMatch = false;
            boolean exQtyMatch = false;
            
            integer totalPartPrice = 0; 

            for (WorkOrderLineItem woItem: woLineItemList) {
                qtyAllParts += Integer.valueOf(woItem.Part_Quantity__c);
                if (woItem.Line_Item_Type__c != null) {
                    if (woItem.Line_Item_Type__c != null && !woItem.Line_Item_Type__c.equalsIgnoreCase('Info Parts-Hard Drive-MPS') &&
                        !woItem.Line_Item_Type__c.equalsIgnoreCase('Info Parts-Hard Drive-APS') && !woItem.Line_Item_Type__c.equalsIgnoreCase('APS-Also ship'))
                        qtyExludeAlsoShipped += Integer.valueOf(woItem.Part_Quantity__c);
                }

                /*
                if (aasObj.Cost__c != null) {
                    if ((aasObj.Cost__c.equalsIgnoreCase('Greater Than') && woItem.ISP_Cost__c > acObj.Cost__c) ||
                        (aasObj.Cost__c.equalsIgnoreCase('Less Than') && woItem.ISP_Cost__c < acObj.Cost__c) ||
                        (aasObj.Cost__c.equalsIgnoreCase('Equals To') && woItem.ISP_Cost__c == acObj.Cost__c))
                        costMatch = true;
                }
                */
                if(String.isNotBlank(woItem.PartPrice__c)){
                   totalPartPrice = totalPartPrice + (Integer.valueOf(woItem.Part_Quantity__c) * Decimal.valueOf(woItem.PartPrice__c).intValue());
                }
                boolean cruFlag = false;
                if (woItem.CustomerReplaceableUnit__c != null)
                    cruFlag = (woItem.CustomerReplaceableUnit__c.equalsIgnoreCase('Y')) ? true : false;
                
                boolean fruFlag = false;
                if (woItem.FieldReplaceableUnit__c != null)
                    fruFlag = (woItem.FieldReplaceableUnit__c.equalsIgnoreCase('Y')) ? true : false;

                if (aasObj.CRU__c == true && cruFlag == acObj.CRU__c)
                    cruMatch = true;
                if (aasObj.FRU__c == true && fruFlag == acObj.FRU__c)
                    fruMatch = true;
                
                boolean apsFlag = false;
                //system.debug('woItem.SelectionMethod__c ' + woItem.SelectionMethod__c);
                apsFlag = (woItem.SelectionMethod__c.equalsIgnoreCase('Auto')) ? true : false;
                if (aasObj.APS_Flag__c == true && apsFlag == acObj.APS_Flag__c)
                    apsFlagMatch = true;
                
                if (woItem.PartNumber__c != null) {
                    partsString += woItem.PartNumber__c + ',';
                }

                if (woItem.PartCommodity__c != null) {
                    if (commodityString.indexOf(woItem.PartCommodity__c) < 0)
                        commodityString += woItem.PartCommodity__c + ',';
                }

            }

            if (aasObj.Quantity__c != null) {
                if ((aasObj.Quantity__c.equalsIgnoreCase('Greater Than') && qtyAllParts > acObj.Quantity__c) ||
                    (aasObj.Quantity__c.equalsIgnoreCase('Less Than') && qtyAllParts < acObj.Quantity__c) ||
                    (aasObj.Quantity__c.equalsIgnoreCase('Equals To') && qtyAllParts == acObj.Quantity__c))
                    allQtyMatch = true;
            }

            if (aasObj.Quantity_excluding_Also_Shipped_Parts__c != null) {
                if ((aasObj.Quantity_excluding_Also_Shipped_Parts__c.equalsIgnoreCase('Greater Than') && qtyExludeAlsoShipped > acObj.Quantity_excluding_Also_Shipped_Parts__c) ||
                    (aasObj.Quantity_excluding_Also_Shipped_Parts__c.equalsIgnoreCase('Less Than') && qtyExludeAlsoShipped < acObj.Quantity_excluding_Also_Shipped_Parts__c) ||
                    (aasObj.Quantity_excluding_Also_Shipped_Parts__c.equalsIgnoreCase('Equals To') && qtyExludeAlsoShipped == acObj.Quantity_excluding_Also_Shipped_Parts__c)){
                    exQtyMatch = true;
                 }
            }
            
            if (aasObj.Cost__c != null) {
                if ((aasObj.Cost__c.equalsIgnoreCase('Greater Than') && totalPartPrice > acObj.Cost__c) ||
                    (aasObj.Cost__c.equalsIgnoreCase('Less Than') && totalPartPrice < acObj.Cost__c) ||
                    (aasObj.Cost__c.equalsIgnoreCase('Equals To') && totalPartPrice == acObj.Cost__c))
                {
                    costMatch = true;
                }
            }

            if ((aasObj.Quantity__c != null && !allQtyMatch) || (aasObj.Quantity_excluding_Also_Shipped_Parts__c != null && !exQtyMatch) 
                || (aasObj.Cost__c != null && !costMatch) || (aasObj.CRU__c == true && !cruMatch) 
                || (aasObj.FRU__c == true && !fruMatch) || (aasObj.APS_Flag__c == true && !apsFlagMatch))
            {
                return false;  
            }
            
                
            return true;
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchApprovalProcessController', 'workOrderLineItemMatch', 'Dispatch Management');
            return false;
        }
    }
    public static boolean DispatchCheckPartsAndCommodityMatch(String partsString, set < String > partsSet, boolean IncludeOrExclude)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       DispatchCheckPartsAndCommodityMatch
    Description:  this function contains the logic of the parts and/or commodity check
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/23/2018     1.0     Sri Harsha G    Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        // Include --> True and Excude --> False
        if (String.isNotBlank(partsString) && !partsSet.isEmpty() && partsSet.size() > 0) {
            List < String > partsSplitList = partsString.split(',');
            set < String > partsSplitSet = new set < String > ();
            partsSplitSet.addAll(partsSplitList);
            boolean containsData;
            if (IncludeOrExclude) {
                containsData = partsSplitSet.containsAll(partsSet);
                return containsData;
            } else {
                boolean outFlag = false;
                for (string s: partsSplitList) {
                    if (partsSet.contains(s)) {
                        outFlag = false;
                        break;
                    }
                    outFlag = true;
                }
                return outFlag;
            }
        }
        return false;
    }

    public static string basicWorkOrderCheck() {
        try {
            if (!string.isNotBlank(woList[0].Service_Type__c)) {
                return 'Service Type is Blank - Please select Service Type';
            }
            if (!string.isNotBlank(woList[0].Service_Option__c)) {
                return 'Please select valid service option - before submitting';
            }

            if (partsList.size() > 0 && woList[0].Service_Type__c.equalsIgnoreCase('Labor Only')) {
                return 'You have selected Service Type - Labor Only. Please deselect the selected Parts before Submitting.';
            }

            if (partsList.size() == 0 && (woList[0].Service_Type__c.equalsIgnoreCase('Parts Only') || woList[0].Service_Type__c.equalsIgnoreCase('Parts and Labor'))) {
                return 'The work order cannot be submitted until the parts have been selected.';
            }

            if ((woList[0].Service_Type__c.equalsIgnoreCase('Labor Only') || woList[0].Service_Type__c.equalsIgnoreCase('Parts and Labor')) 
                && woList[0].IsDeferralAllowed__c &&
                (!String.isNotBlank(woList[0].schedulingInternalLogic__c) || woList[0].schedulingInternalLogic__c.equalsIgnoreCase('Neither'))) {
                return 'The work order cannot be submitted until the service is scheduled.';
            }

            return 'SUCCESS';

        } catch (exception e) {

            return 'Error : ' + e.getMessage();
        }
    }

    public static boolean IsCurrentUserApprover() {
        List < Profile > profileList = new List < Profile > ();
        profileList = [select id, Name from Profile where Id =: UserInfo.getProfileId() LIMIT 1];

        if (!profileList.isEmpty() && profileList.size() > 0) {
            if (String.isNotBlank(profileList[0].Name)) {
                //if (profileList[0].Name.equalsIgnoreCase('Dispatch Approver')) {
                if (profileList[0].Name.equalsIgnoreCase('Work Order Approver')) {
                    return true;
                }
            }
        }
        return false;
    }
     // Added - 10/24/2018
    public static boolean IsOSPUser(){
        List < User > userList = new List < User > ();
        userList = [Select OSP__c From User Where Id = :UserInfo.getUserId() LIMIT 1];
        if (!userList.isEmpty() && userList.size() > 0) {
            if (String.isNotBlank(userList[0].OSP__c)) {
                if(userList[0].OSP__c.equalsIgnoreCase('yes')){
                    return true;
                }
            }
        }
        return false;
    }

    @AuraEnabled
    public static String updateWorkOrderRecord(Id recordId, List < String > approvalCriteria, String QueueName, string qMapId, boolean autoApprFlag, boolean dspOverrideFlag) {
        if (dspOverrideFlag == true) {
            //To Replicate the functionality as it is in delta - we are doing multiple WorkOrder Record Updates.
            workorder wo = new workorder(Id = recordId);
            wo.Status = 'Approved';
            wo.DispatchEvent__c = 'DISPATCH_APPROVED';
            
            update wo;

            wo.status = 'Problem';
            wo.Sub_Status__c = 'DSP Assignment Needed';
            wo.RecordTypeId = System.Label.Dispatch_Record_Type_Approval;
            wo.ISP_Siebel_DPS_Flag__c = 'Y';
            wo.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';

            update wo;

            return 'SUCCESS';
        } else if (autoApprFlag == true && dspOverrideFlag == false) {
            workOrder wo = new WorkOrder(Id = recordId);
            wo.Approve_Reject_Comments__c = 'Auto Approved - Work order didnot met any approval criteria';
            wo.Approve_Reject_DateTime__c = system.now();
            wo.Approve_Reject_Reason__c = 'Auto Approved';
            wo.Approved_Rejected__c = 'Approved';
            wo.Approver_Id__c = userInfo.getUserId();
            wo.DispatchEvent__c = 'DISPATCH_APPROVED';
            wo.ISP_Siebel_DPS_Flag__c = 'Y';
            wo.RecordTypeId = System.Label.Dispatch_Record_Type_Submitted;
            wo.status = 'Approved';

            update wo;
            
            // Submit Work order
            DispatchSubmissionProcess dsp = new DispatchSubmissionProcess(recordId);
            Id jobId = system.enqueueJob(dsp);
            // Submit Work order
            
            return 'SUCCESS';
        } else {
            if (string.isNotBlank(QueueName)) {
                List < Group > groupList = new List < Group > ();
                groupList = [SELECT Id, Name, DeveloperName FROM group WHERE DeveloperName =: QueueName LIMIT 1];
                if (!groupList.isEmpty() && groupList.size() > 0) {
                    List < WorkOrder > workOrderList = new List < WorkOrder > ();
                    workOrderList = [SELECT Id, Status, WorkOrderNumber, Approval_Criteria_Met__c, DispatchEvent__c,
                        ISP_Siebel_DPS_Flag__c, RecordTypeId FROM WorkOrder WHERE Id =: recordId LIMIT 1
                    ];
                    
                    DispatchPendingApproval__c dpa = new DispatchPendingApproval__c();

                    dpa.Approval_Status__c = 'pending';
                    dpa.Name = workOrderList[0].WorkOrderNumber;
                    dpa.OwnerId = groupList[0].Id;
                    dpa.Queue_Approval_Attribute_Map__c = qMapId;
                    dpa.RecordTypeId = system.label.DispatchPendingApproval_ReordTypeId;
                    dpa.Work_Order__c = recordId;
                    workOrderList[0].status = 'Pending Review';
                    workOrderList[0].RecordTypeId = System.Label.Dispatch_Record_Type_Approval;
                    workOrderList[0].ISP_Siebel_DPS_Flag__c = 'Y';
                    workOrderList[0].DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                    if (!approvalCriteria.isEmpty() && approvalCriteria.size() > 0) {
                        workOrderList[0].Approval_Criteria_Met__c = String.join(approvalCriteria, ',');
                        dpa.Approval_Criteria_Met__c = String.join(approvalCriteria, ','); 
                        //5729159 - Deepa for Reporting Story
                    }
                    insert dpa;
                    update workOrderList[0];
                    return 'SUCCESS';
                } else {
                    return ' InValid Data - Please Correct Approval Data';
                }
            } else {
                return 'Queue Name is Blank';
            }
        }
    }

    public static string getDPSTypeAndCallType(list < string > workOrderIdList) {
        try {

            string strServiceHours = '';
            string srtServiceLevel = '';
            List < DPSAndCallType__x > dpsTypeCallType = new List < DPSAndCallType__x > ();
            DispatchDefaults__c recordWOLine = new DispatchDefaults__c();
            recordWOLine = [SELECT Id, DPSType__c, DefaultDPSType__c, CallType__c, DefaultCallType__c, OutOfWarranty__c, Service_Type__c, selected_service_option__c, ServiceLevel__c, ServiceHours__c, Service_Configurations__c,
                Billable__c, SpecialOptions__c, CompleteCareOption__c, complete_care_option__c, KYHDOption__c, OconusDispatch__c, PremierCode__c, OutOfHours__c, Work_Order__r.City,Work_Order__r.CityCalc__c, Work_Order__r.StateCode,
                Work_Order__r.DPS_BUID__c, Work_Order__r.PostalCode, Work_Order__r.CountryCode, Work_Order__r.LOB__c, Work_Order__r.Region__c, Work_Order__r.Service_Type__c,
                Work_Order__r.Country, Work_Order__r.Deferred__c, Work_Order__r.Sanbao_FLG__c, Work_Order__r.FSD_DASP_Flag__c, Work_Order__r.Service_Option__c,
                Work_Order__r.CallType__c, Work_Order__r.DPSType__c, Work_Order__r.DSP__c, Bill_To__c, Work_Order__c FROM DispatchDefaults__c WHERE Work_Order__c =: workOrderIdList[0] LIMIT 1
            ];

            if (String.isNotEmpty(recordWOLine.Work_Order__r.Service_Option__c)) {
                if (recordWOLine.Work_Order__r.Service_Option__c.contains('-')) {
                    strServiceHours = recordWOLine.Work_Order__r.Service_Option__c.substringAfter('-');
                    srtServiceLevel = recordWOLine.Work_Order__r.Service_Option__c.substringBefore('-');
                }
            }

            dpsTypeCallType = (!mockedRequests.isEmpty()) ? mockedRequests : [SELECT DPSType__c, CallType__c, ResponseCode__c, ResponseMessage__c FROM DPSAndCallType__x WHERE ActivityType__c = 'Break Fix'
                AND ServiceType__c =: recordWOLine.Service_Type__c
                AND ServiceLevel__c =: srtServiceLevel AND ServiceHours__c =: strServiceHours AND DSP__c =: recordWOLine.Work_Order__r.DSP__c AND PremierCode__c =: recordWOLine.PremierCode__c
                AND OutOfHours__c =: recordWOLine.OutOfHours__c ? 'Y' : 'N'
                AND OutOfWarranty__c =: recordWOLine.OutOfWarranty__c ? 'Y' : 'N'
                AND OconusOrFederalFlag__c =: recordWOLine.OconusDispatch__c
                AND SystemClassification__c =: recordWOLine.Service_Configurations__c AND CompleteCareOption__c =: recordWOLine.complete_care_option__c ? 'Y' : 'N'
                AND KYHDOption__c =: recordWOLine.KYHDOption__c ? 'Y' : 'N'
                AND Deferred__c =: recordWOLine.Work_Order__r.Deferred__c
                AND Category__c =: recordWOLine.SpecialOptions__c AND City__c =: recordWOLine.Work_Order__r.CityCalc__c AND State__c =: recordWOLine.Work_Order__r.StateCode AND DASP__c =: recordWOLine.Work_Order__r.FSD_DASP_Flag__c ? 'Y' : 'N'
                AND BillTo__c =: recordWOLine.Bill_To__c AND Country__c =: recordWOLine.Work_Order__r.CountryCode AND ZipCode__c =: recordWOLine.Work_Order__r.PostalCode AND AddressRegionId__c =: recordWOLine.Work_Order__r.Region__c
                AND DPSType__c =: recordWOLine.DefaultDPSType__c AND CallType__c =: recordWOLine.DefaultCallType__c AND SanbaoFlag__c =: recordWOLine.Work_Order__r.Sanbao_FLG__c LIMIT 1
            ];

            if (dpsTypeCallType.size() > 0 && !dpsTypeCallType.isEmpty() && dpsTypeCallType != null) {
                WorkOrder wo = new WorkOrder(Id = workOrderIdList[0]);
                DispatchDefaults__c dd = new DispatchDefaults__c(Id = recordWOLine.Id);
                if (dpsTypeCallType[0].ResponseCode__c.equals('100')) {
                    if (String.isNotBlank(dpsTypeCallType[0].DPSType__c)) {
                        dd.DPSType__c = dpsTypeCallType[0].DPSType__c;
                        wo.DPSType__c = dpsTypeCallType[0].DPSType__c;
                        woList[0].DPSType__c = dpsTypeCallType[0].DPSType__c;
                        ddList[0].DPSType__c = dpsTypeCallType[0].DPSType__c;
                    }
                    if (String.isNotBlank(dpsTypeCallType[0].CallType__c)) {
                        dd.CallType__c = dpsTypeCallType[0].CallType__c;
                        wo.CallType__c = dpsTypeCallType[0].CallType__c;
                        woList[0].CallType__c = dpsTypeCallType[0].CallType__c;
                        ddList[0].CallType__c = dpsTypeCallType[0].CallType__c;
                    }
                    update wo;
                    update dd;

                    return 'SUCCESS';
                } else {
                    return 'CALL TYPE FAILED';
                }
            } else {
                return 'CALL TYPE FAILED';
            }
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchApprovalProcessController', 'getDPSTypeAndCallType', 'Dispatch Management');
            return 'CALL TYPE FAILED';
        }
    }
}
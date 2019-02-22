/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchDefaultsConfiguration
Description:  This class contain method that handles get dispatch default operation call - story #4346869 
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/03/2018     1.0    Rodrigo Carpio       Initial Release
04/03/2108     1.0    Harsha Reddy         Initial Release
01/11/2019     1.1    Rayana Alencar       Add call to EinsteinAlertController to create/update/delete Alert on WorkOrder page
-------------------------------------------------------------------------------------------------------------------------- */
Public with sharing class DispatchDefaultsConfiguration {


    @TestVisible public static List < GetWorkOrderDetails__x > mockedGetWorkOrderDetails = new List < GetWorkOrderDetails__x > ();
    @TestVisible public static List < AvailableOptions__x > mockedAvailableOptions = new List < AvailableOptions__x > ();
    @TestVisible public static List < GetDispatchDefaults__x > mockedGetDispatchDefaults = new List < GetDispatchDefaults__x > ();
    @TestVisible public static List<CheckPreference__x> mokedCheckPreference = new List<CheckPreference__x>();
    @TestVisible public static List < GetProviderAttributes__x > mockedGetProviderAttributes = new List<GetProviderAttributes__x>();

    Public static List < WorkOrderLineItem > partsList = new List < WorkOrderLineItem > ();

    /* Wrapper Class*/
    public with sharing class defaultWrapper {
        @AuraEnabled public id defaultRecordId {get;set;}
        @AuraEnabled public String serviceType {get;set;}
        @AuraEnabled public List < string > serviceOptions {get;set;}
        @AuraEnabled public List < String > serviceTypeOptions {get;set;}
        @AuraEnabled public List < String > specialOptions {get;set;}
        @AuraEnabled public List < String > billToOptions {get;set;}
        @AuraEnabled public List<string> ADOverrideOptions{get;set;}
        @AuraEnabled public List < String > productClassOptions {get;set;}
        @AuraEnabled public string selectedServiceOpt {get;set;}
        @AuraEnabled public String orderNumber {get;set;}
        @AuraEnabled public String specialOpnsValue {get;set;}
        @AuraEnabled public String productClassification {get;set;}
        @AuraEnabled public Boolean keepYComp {get;set;}
        @AuraEnabled public Boolean dSPOverideReq {get;set;}
        @AuraEnabled public String billTo {get;set;}
        @AuraEnabled public Boolean accidentalDamage {get;set;}
        @AuraEnabled public Boolean accidentalDamage1{get;set;}
        @AuraEnabled public Boolean outOfWarranty {get;set;}
        @AuraEnabled public String Instructions {get;set;}
        @AuraEnabled public String InstructRecordId {get;set;}
        @auraEnabled public String ADOverrideReason{get;set;}
        @AuraEnabled public Boolean KYHDFlag {get;set;}
        @AuraEnabled public Boolean ADCoverageFlag{get;set;}//AD_Coverage_Flag__c
        @AuraEnabled public String locationCoverageLevel{get;set;}//Location Coverage Level;
        @AuraEnabled public String entitlementDetails {get;set;}
        @AuraEnabled public Boolean alternateReturnAddressChkBx {get;set;}
        @AuraEnabled public String alternateReturnPostalCode {get;set;}
        @AuraEnabled public String alternateReturnStreet {get;set;}
        @AuraEnabled public String alternateReturnCity {get;set;}
        @AuraEnabled public String alternateReturnState {get;set;}
        @AuraEnabled public String alternateReturnCountry {get;set;}
        @AuraEnabled public String entitledServiceType {get;set;}
        @AuraEnabled public String ErrorCode {get;set;}
        @AuraEnabled public String WarningMessage {get;set;}
        //added for Story 5615509
        @AuraEnabled public String reasonForDamage {get;set;}
        @AuraEnabled public List < String > reasonForDamageOptions {get;set;}
        @AuraEnabled public List <DispatchDSPDLP__c> DASPValues {get;set;}
        @AuraEnabled public String DASPValue {get;set;}
        @AuraEnabled public String Region {get;set;}
        @AuraEnabled public Boolean DASPflag {get;set;}
        @AuraEnabled public String workOrderCountry {get;set;}
    }

    /*Wrapper Class*/
    public with sharing class optionsWrapper {
        @AuraEnabled public List < String > availableOptions {get;set;}
        @AuraEnabled public List < String > categoryOptions {get;set;}
        @AuraEnabled public String defaultOption {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
    }

    /*Wrapper Class*/
    public with sharing class updateWrapper {
        @AuraEnabled public string instructRecid {get;set;}
        @AuraEnabled public string defaultDispRecId {get;set;}
        @AuraEnabled public string errorMessage {get;set;}
    }

    @future
    public static void performCallToDelta(Id idWorkOrder) {
        try {
            list < GetWorkOrderDetails__x > woList = new list < GetWorkOrderDetails__x > ();
            woList = (!mockedGetWorkOrderDetails.isEmpty()) ? mockedGetWorkOrderDetails :[SELECT 
          WorkOrderId__c, WorkOrderNumber__c, ResponseCode__c, ResponseMessage__c
                    FROM GetWorkOrderDetails__x WHERE WorkOrderId__c =: idWorkOrder LIMIT 1];
        } catch (exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'performCallToDelta', 'Dispatch Management');
        }
    }
    /* this functions makes a call to delta to create the dispatch record */
    @InvocableMethod(label = 'Create Delta Dispatch'
        description = 'Call DELTA interface to create the dispatch')
    public static void createDeltaDispatch(list < string > workOrderList) {
        try {
        //    performCallToDelta(workOrderList[0]);
        } catch (exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'createDeltaDispatch', 'createDeltaDispatch');
        }
    }
    /*this functions makes a call to DELTA to get SLA Information */
    public static void validateSLADates(DispatchDefaults__c createddDefault) {
        try {
            DispatchDefaults__c localDefault = createddDefault;

            String workOrderNum = localDefault.Work_Order__r.WorkOrderNumber;
            string serOptionValue = localDefault.Work_Order__r.Service_Option__c;
            string postalCode = localDefault.Work_Order__r.PostalCode;
            string countryCode = localDefault.Work_Order__r.Country;
            String state_code = localDefault.Work_Order__r.StateCalc__c;
            if (String.isNotEmpty(serOptionValue)) {
                GetSLADates__x slaDates = getEntitlementSLA(workOrderNum,
                    serOptionValue,
                    postalCode,
                    countryCode,
                    state_code);
                if (String.isNotEmpty(slaDates.SLAStartDate__c)) {
                    localDefault.work_order__r.SLAStartDate__c = slaDates.SLAStartDate__c;
                    localDefault.work_order__r.EntitlementStartDate__c = slaDates.SLAStartDate__c;
                    localDefault.work_order__r.EntitlementStartDate__c = slaDates.SLAStartDate__c;
                    //DateTime.Valueof(slaDates.SLAStartDate__c.replace('T', ' '));
                }
                if (String.isNotEmpty(slaDates.SLAEndDate__c)) {
                    localDefault.Work_Order__r.SLAEndDate__c = slaDates.SLAEndDate__c;
                    localDefault.Work_Order__r.EntitlementEndDate__c = slaDates.SLAEndDate__c;
                    //DateTime.Valueof(slaDates.SLAEndDate__c.replace('T', ' '));
                }

                localDefault.work_order__r.DeltaTimezone__c = slaDates.TimeZone__c;
                localDefault.work_order__r.DeltaShiftStart__c = slaDates.ShiftStart__c;
                localDefault.work_order__r.DeltaShiftEnd__c = slaDates.ShiftEnd__c;
                if (String.isNotEmpty(slaDates.TimeZone__c)) {
                    List < Timezone__mdt > tzList = new List < Timezone__mdt > ();
                    tzList = [SELECT Label FROM Timezone__mdt WHERE DeltaTimezone__c =: slaDates.TimeZone__c LIMIT 1];
                    localDefault.work_order__r.Timezone__c = tzList[0].Label;
                }
                update localDefault;
            }
        } catch (Exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'validateSLADates', 'Dispatch Management');
        }

    }
    /* this functions makes a call to maestor to pull the dispatch defaults information */
    @AuraEnabled
    public static defaultWrapper getDispatchDefaults(Id workOrderId) {
        try {
            system.debug('Entered getDispatchDefaults');

            string productValue = '';
            Schema.sObjectType entityType;
            defaultWrapper dWrap = new defaultWrapper();

            List < DispatchDefaults__c > defaultList = new List < DispatchDefaults__c > ();

            defaultList = [SELECT Id, Service_Options_Picklist_values__c,ErrorCode__c,WarningMessage__c, Entitlement_Details__c, Service_Type__c, Billable__c, PO_Number__c, selected_service_option__c, OutOfWarranty__c,
                category__c, Service_Configurations__c, SpecialOptions__c, Bill_To__c, Keep_Your_Components__c, DSP_Override_Request__c, AD_Override__c,
                AvailableCoverages__c, AvailableOptions__c, CompleteCareOption__c, AD_Coverage_Flag__c, Complete_Care_Option__c, OrderNumber__c,
                Bill_To_Order_Number__c, KYHDOption__c, PartsCountry__c, BUID__c, ServiceHours__c, LaborCountry__c, ServiceLevel__c, Default_Service_Type__c,
                Work_Order__r.SLAStartDate__c, Work_Order__r.SLAEndDate__c, Work_Order__r.Service_Option__c, Work_Order__r.Country, Work_Order__r.PostalCode,
                Work_Order__r.WorkOrderNumber, Work_Order__r.Alternate_Return_Postal_Code__c, Work_Order__r.Alternate_Return_Street__c,
                Work_Order__r.Alternate_Return_City__c, Work_Order__r.Alternate_Return_State__c, Work_Order__r.Alternate_Return_Address_Checkbox__c,
                Work_Order__r.Alternate_Return_Country__c,Reason_for_the_Damage__c, Work_Order__r.DPS_Sub_Region__c,
                Work_Order__r.Postal_Code_Changed__c, Work_Order__r.Available_Cities__c, Work_Order__r.CountryCode__c, Work_Order__r.CountryCode, Work_Order__r.DASP__c, Work_Order__r.Region__c FROM DispatchDefaults__c
                WHERE Work_Order__c =: workOrderId LIMIT 1
            ];
                
            if (null != defaultList && defaultList.size() > 0) {
                
                dwrap.alternateReturnAddressChkBx = defaultList[0].Work_Order__r.Alternate_Return_Address_Checkbox__c;
                dWrap.alternateReturnPostalCode = defaultList[0].Work_Order__r.Alternate_Return_Postal_Code__c;
                dWrap.alternateReturnStreet = defaultList[0].Work_Order__r.Alternate_Return_Street__c;
                dWrap.alternateReturnCity = defaultList[0].Work_Order__r.Alternate_Return_City__c;
                dWrap.alternateReturnState = defaultList[0].Work_Order__r.Alternate_Return_State__c;
                dWrap.alternateReturnCountry = defaultList[0].Work_Order__r.Alternate_Return_Country__c;
                dWrap.defaultRecordId = defaultList[0].Id;
                dWrap.Region = defaultList[0].Work_Order__r.Region__c;
                dWrap.specialOptions = getDispatchCategoryOptions(defaultList[0], workOrderId, null);
                dWrap.workOrderCountry = defaultList[0].Work_Order__r.Country;
                

        if (String.isNotEmpty(defaultList[0].Default_Service_Type__c)) {
                    dWrap.entitledServiceType = defaultList[0].Default_Service_Type__c; 
                }
                //Service Type
                if (String.isNotEmpty(defaultList[0].Service_Type__c)) {
                    dWrap.serviceType = defaultList[0].Service_Type__c;
                }

                // Service Options
                if (String.isNotEmpty(defaultList[0].AvailableCoverages__c)) {
                    string ops = defaultList[0].AvailableCoverages__c.replace('||', ',');
                    dWrap.serviceOptions = DispatchDefaultsConfiguration.RemoveNull(ops.split(','));
                }
                
                //DASPValue
                if (String.isNotEmpty(defaultList[0].Work_Order__r.DASP__c)) {
                    dWrap.DASPValue = defaultList[0].Work_Order__r.DASP__c;
                }
                //Category - Special Options
                system.debug('defaultList[0].SpecialOptions__c ' + defaultList[0].SpecialOptions__c);
                if (String.isNotEmpty(defaultList[0].SpecialOptions__c)) {
                    dWrap.specialOpnsValue = defaultList[0].SpecialOptions__c;
                }
                //Product Classification - determined based on LOB Value
                if (String.isNotEmpty(defaultList[0].Service_Configurations__c)) {
                    dWrap.productClassification = defaultList[0].Service_Configurations__c;
                }
                //Selected or Default Service Option
                if (String.isNotEmpty(defaultList[0].selected_service_option__c)) {
                    dWrap.selectedServiceOpt = defaultList[0].selected_service_option__c;
                }
                //Bill To
                if (String.isNotEmpty(defaultList[0].Bill_To__c)) {
                    dWrap.billTo = defaultList[0].Bill_To__c;
                }
                // Order Number
                if (String.isNotEmpty(defaultList[0].Bill_To_Order_Number__c)) {
                    dwrap.orderNumber = defaultList[0].Bill_To_Order_Number__c;
                }
                // Accidental Damage OverRide Reason
                if (String.isNotEmpty(defaultList[0].AD_Override__c)) {
                    dwrap.ADOverrideReason = defaultList[0].AD_Override__c;
                }
                // Error Code from DispatchDefaults
                if (String.isNotEmpty(defaultList[0].ErrorCode__c)) {
                    dWrap.ErrorCode= defaultList[0].ErrorCode__c;
                }
                // Warning message from DispatchDefaults
                if (String.isNotEmpty(defaultList[0].WarningMessage__c)) {
                    dWrap.WarningMessage= defaultList[0].WarningMessage__c;
                }
                // reason For Damage 5615509
                if (String.isNotEmpty(defaultList[0].Reason_for_the_Damage__c)) {
                    dWrap.reasonForDamage = defaultList[0].Reason_for_the_Damage__c;
                }

                dwrap.accidentalDamage = defaultList[0].CompleteCareOption__c;
                dwrap.accidentalDamage1 = defaultList[0].Complete_Care_Option__c;
                dwrap.ADCoverageFlag = defaultList[0].AD_Coverage_Flag__c;
                dWrap.keepYComp = defaultList[0].Keep_Your_Components__c;
                dWrap.dSPOverideReq = defaultList[0].DSP_Override_Request__c;
                dWrap.outOfWarranty = defaultList[0].OutOfWarranty__c;
                dWrap.KYHDFlag = defaultList[0].KYHDOption__c;
                dWrap.entitlementDetails = defaultList[0].Entitlement_Details__c;
                if (String.isNotEmpty(defaultList[0].AvailableOptions__c)) {
                    if (defaultList[0].AvailableOptions__c.contains('-')) {
                        dWrap.locationCoverageLevel = defaultList[0].AvailableOptions__c.substringBeforeLast('-');
                    }
                }

                entityType = defaultList[0].Id.getSObjectType();
                //picklist values for Service_Type__c field


                // Service Type Options
                if (defaultList[0] != null && defaultList[0].Default_Service_Type__c != null && defaultList[0].Billable__c != null) { // added if condition for the task #5287280
                     dWrap.serviceTypeOptions = getServiceTypeByOrder(defaultList[0].Default_Service_Type__c, defaultList[0].Billable__c,defaultList[0].work_order__r.DPS_Sub_Region__c,defaultList[0].Bill_To__c);
                }

                //picklist values for Bill_To__c
                dWrap.billToOptions = getselectOptions(entityType, 'Bill_To__c');
                //picklist values for ADOverride
                dWrap.ADOverrideOptions = getselectOptions(entityType, 'AD_Override__c');
                //picklist values for Service_Configurations__c
                dWrap.productClassOptions = getselectOptions(entityType, 'Service_Configurations__c');
                system.debug('service type ###'+dWrap.serviceType);
                //picklist values for Reason_for_the_Damage__c
                system.debug('reasonForDamageOption');
                dWrap.reasonForDamageOptions = getselectOptions(entityType, 'Reason_for_the_Damage__c');

                if (defaultList[0].DSP_Override_Request__c) {

                    List < DispatchInstruction__c > getInstructList = new List < DispatchInstruction__c > ();

                    getInstructList = [SELECT Id, Work_Order__c, Name, Receiver__c, Type__c, Instruction__c
                        FROM DispatchInstruction__c WHERE Work_Order__c =: workOrderId
                        AND DSP_Override_Request__c = true LIMIT 1

                    ];

                    if (getInstructList.size() > 0) {
                        dWrap.Instructions = getInstructList[0].Instruction__c;
                        dWrap.InstructRecordId = getInstructList[0].Id;
                    }

                }
                dWrap.DASPValues = null;
                if(defaultList[0].Work_Order__r.Region__c == '2')
                    dWrap.DASPValues = getDASPValue(defaultList[0].Work_Order__r.CountryCode);
                
                return dWrap;
            } else {
                //List<WorkOrder> workOrderRecord = new List<WorkOrder>();
                WorkOrder workOrderRecord = [SELECT ServiceTag__c, BUID__c,DPS_BUID__C, City,CityCalc__c,State, Country, CountryCode, OrderNumber__c, CustomerNumber__c, LOB__c, Region__c,CustomerRegion__c,PostalCode, StateCalc__c
                    FROM WorkOrder WHERE Id =: workOrderId LIMIT 1
                ];

                list < GetDispatchDefaults__x > listDefault = new list < GetDispatchDefaults__x > ();

                if (!Test.isRunningTest()) {
                    listDefault = [SELECT AvailableOptions__c, BasicEntitlement__c, Billable__c, BUID__c, CallType__c, CustomSKU__c, Category__c, City__c, CompleteCareOption__c,
                        Country__c, CustomerNumber__c, CustomerPreference__c, DataDestruction__c, DataRecovery__c, DefaultCallType__c, DefaultDPSType__c, DefaultDSP__c, DefaultSKU__c,
                        CustomerRegionId__c, DigitalEntitlements__c, DLP__c, DPSType__c, DSP__c, EntitlementId__c, EntitlementName__c, GroundShipFlg__c,
                        ISPWarrantyOrderBUID__c, ISPWarrantyOrderNum__c, KYCOption__c, KYHDOption__c, LaborCountry__c, LOB__c, MaxCapabilityDLP__c, MaxCapabilityServiceHours__c,
                        MaxCapabilityServiceLevel__c, MaxCapabilityServiceSubType__c, OconusDispatch__c, OrderNumber__c, OutOfHours__c, OutOfWarranty__c, PartsCountry__c,
                        PostalCode__c, PPID__c, PremierCode__c, PremierType__c, ProSupport__c, Region__c, ReverseAgency__c, ServiceHours__c, ServiceLevel__c, ServiceTagId__c,
                        ServiceType__c, SKUNumber__c, State__c, UserID__c, uuid__c, WarningMessage__c,ErrorCode__c, WarrantyEndDate__c, AvailableCoverages__c FROM GetDispatchDefaults__x
                        WHERE ServiceTagId__c =: workOrderRecord.ServiceTag__c AND BUID__c =: workOrderRecord.DPS_BUID__C AND City__c =: workOrderRecord.CityCalc__c
                        AND State__c =: workOrderRecord.StateCalc__c AND OrderNumber__c =: workOrderRecord.OrderNumber__c AND CustomerNumber__c =: workOrderRecord.CustomerNumber__c
                        AND Country__c =: workOrderRecord.CountryCode AND LOB__c =: workOrderRecord.LOB__c AND Region__c =: workOrderRecord.Region__c and CustomerRegionId__c=:workOrderRecord.CustomerRegion__c
                        AND PostalCode__c =: workOrderRecord.PostalCode LIMIT 1
                    ];

                } else {
                    listDefault.add(new GetDispatchDefaults__x(AvailableOptions__c = '2 Hour-24x7', BasicEntitlement__c = 'Y', Billable__c = 'Y', BUID__c = '11', CallType__c = 'testType',
                        CustomSKU__c = 'Y', category__c = 'TEST', City__c = 'Hyderabad', CompleteCareOption__c = 'TRUE', Country__c = 'India', CustomerNumber__c = '8987',
                        CustomerPreference__c = 'XYZ', DataDestruction__c = 'Y', DataRecovery__c = 'Y', DefaultCallType__c = 'testType', DefaultDPSType__c = 'Test DPS Type',
                        DefaultDSP__c = 'test dsp', DefaultSKU__c = 'test sku', CustomerRegionId__c = '1', DigitalEntitlements__c = 'Y', DLP__c = 'Test dlp',
                        DPSType__c = 'test type', DSP__c = 'Test', EntitlementId__c = 'EId123455', EntitlementName__c = 'EName', ErrorCode__c = '100000',
                        GroundShipFlg__c = 'test', ISPWarrantyOrderBUID__c = '123', ISPWarrantyOrderNum__c = '122445', KYCOption__c = 'Y', KYHDOption__c = 'Y',
                        LaborCountry__c = 'India', LOB__c = '4SV', MaxCapabilityDLP__c = 'Test', MaxCapabilityServiceHours__c = 'Found,24x7,24x7,24x7,10x5,24x7',
                        MaxCapabilityServiceLevel__c = 'Not,2 Hour,4 Hour,Remote Effort', MaxCapabilityServiceSubType__c = 'Not Found,Parts and Labor,Parts and Labor',
                        OconusDispatch__c = 'testDisp', OrderNumber__c = '1223', OutOfHours__c = 'Y', OutOfWarranty__c = 'Y', PartsCountry__c = 'India',
                        PostalCode__c = '509199', PPID__c = '12', PremierCode__c = '100', PremierType__c = 'test Type', ProSupport__c = 'Y', Region__c = '1',
                        ReverseAgency__c = 'Y', ServiceHours__c = '8x5', ServiceLevel__c = 'Next Business Day', ServiceTagId__c = 'CAT2077', ServiceType__c = 'Parts and Labor',
                        SKUNumber__c = '123', State__c = 'TN', UserID__c = '9090', uuid__c = '12', WarningMessage__c = 'Sucessful', WarrantyEndDate__c = '12/07/12',
                        AvailableCoverages__c = '||2 Hour-24x7 ||4 Hour-24x7 ||4 Hour-10x5 ||Remote Effort-24x7'));
                    listDefault.add(new GetDispatchDefaults__x(AvailableOptions__c = '2 Hour-24x7', BasicEntitlement__c = 'N', Billable__c = 'N', BUID__c = '11', CallType__c = 'testType',
                        CustomSKU__c = 'N', category__c = 'TEST', City__c = 'Hyderabad', CompleteCareOption__c = 'TRUE', Country__c = 'India', CustomerNumber__c = '8987',
                        CustomerPreference__c = 'XYZ', DataRecovery__c = 'N', DefaultCallType__c = 'testType', DefaultDPSType__c = 'Test DPS Type',
                        DefaultDSP__c = 'test dsp', DefaultSKU__c = 'test sku', CustomerRegionId__c = '1', DigitalEntitlements__c = 'Y', DLP__c = 'Test dlp',
                        DPSType__c = 'test type', DSP__c = 'Test', EntitlementId__c = 'EId123455', EntitlementName__c = 'EName', ErrorCode__c = '100000',
                        GroundShipFlg__c = 'test', ISPWarrantyOrderBUID__c = '123', ISPWarrantyOrderNum__c = '122445', KYCOption__c = 'N', KYHDOption__c = 'N',
                        LaborCountry__c = 'India', LOB__c = '4SV', MaxCapabilityDLP__c = 'Test', MaxCapabilityServiceHours__c = 'Found,24x7,24x7,24x7,10x5,24x7',
                        MaxCapabilityServiceLevel__c = 'Not,2 Hour,4 Hour,Remote Effort', MaxCapabilityServiceSubType__c = 'Not Found,Parts and Labor,Parts and Labor',
                        OconusDispatch__c = 'testDisp', OrderNumber__c = '1223', OutOfHours__c = 'N', OutOfWarranty__c = 'Y', PartsCountry__c = 'India',
                        PostalCode__c = '509199', PPID__c = '12', PremierCode__c = '100', PremierType__c = 'test Type', ProSupport__c = 'N', Region__c = '1',
                        ReverseAgency__c = 'N', ServiceHours__c = '8x5', ServiceLevel__c = 'Next Business Day', ServiceTagId__c = 'CAT2077', ServiceType__c = 'Parts and Labor',
                        SKUNumber__c = '123', State__c = 'TN', UserID__c = '9090', uuid__c = '12', WarningMessage__c = 'Sucessful', WarrantyEndDate__c = '12/07/12',
                        AvailableCoverages__c = '||2 Hour-24x7 ||4 Hour-24x7 ||4 Hour-10x5 ||Remote Effort-24x7'));
                }
                
                system.debug('listDefault ' + listDefault);
                if (listDefault.size() > 0) {
                    
                    dWrap.specialOptions = getDispatchCategoryOptions(null, workOrderId, listDefault[0]);
                    dWrap.Region         = workOrderRecord.Region__c;
                    if (string.isNotEmpty(workOrderRecord.LOB__c)) {
                        List < Product_Classification__mdt > prodClassMDT = [SELECT LOB__c, Value__c FROM Product_Classification__mdt WHERE LOB__c =: workOrderRecord.LOB__c LIMIT 50000];
                        if (null != prodClassMDT && prodClassMDT.size() > 0) {
                            productValue = prodClassMDT[0].value__c;
                       }
                    }


                    Id defaultId = createDispatchDefaults(listDefault[0], workOrderId, productValue);
                    dWrap.defaultRecordId = defaultId;

                    entityType = defaultId.getSObjectType();


                    //picklist values for Bill_To__c
                    dWrap.billToOptions = getselectOptions(entityType, 'Bill_To__c');
                    dWrap.ADOverrideOptions = getselectOptions(entityType, 'AD_Override__c');
                    //picklist values for Service_Configurations__c
                    dWrap.productClassOptions = getselectOptions(entityType, 'Service_Configurations__c');
                    //picklist values for Reason_for_the_Damage__c
                    system.debug('reasonForDamageOption2');
                    dWrap.reasonForDamageOptions = getselectOptions(entityType, 'Reason_for_the_Damage__c');

                    DispatchDefaults__c createddDefault = [SELECT Id, Service_Options_Picklist_values__c, Entitlement_Details__c, Service_Type__c, PO_Number__c, selected_service_option__c, category__c, OutOfWarranty__c,
                        Service_Configurations__c, SpecialOptions__c, Bill_To__c, Keep_Your_Components__c, DSP_Override_Request__c, AvailableCoverages__c,WarningMessage__c,ErrorCode__c,
                        CompleteCareOption__c, Complete_Care_Option__c, AD_Coverage_Flag__c, OrderNumber__c, work_Order__r.OrderNumber__c, Bill_To_Order_Number__c, KYHDOption__c,
                        PartsCountry__c, BUID__c, ServiceHours__c, LaborCountry__c, ServiceLevel__c, work_order__r.Country, AvailableOptions__c, Default_Service_Type__c, Billable__c, Work_Order__r.CountryCode, work_order__r.DPS_Sub_Region__c
                        FROM DispatchDefaults__c WHERE Id =: defaultId LIMIT 1
                    ];

                    dWrap.serviceTypeOptions = getServiceTypeByOrder(createddDefault.Default_Service_Type__c, createddDefault.Billable__c,createddDefault.work_order__r.DPS_Sub_Region__c,createddDefault.Bill_To__c);


                    if (String.isNotEmpty(createddDefault.Default_Service_Type__c)){
                        dWrap.entitledServiceType = createddDefault.Default_Service_Type__c;
                    }
                    //warning message from dispatch Defaults
                    if (String.isNotEmpty(createddDefault.WarningMessage__c)){
                        dWrap.WarningMessage= createddDefault.WarningMessage__c;
                    }
                    //Error Code from Dispatch Defaults
                    if (String.isNotEmpty(createddDefault.ErrorCode__c)){
                        dWrap.ErrorCode= createddDefault.ErrorCode__c;
                    }
                    
                    if (String.isNotEmpty(createddDefault.Service_Type__c)) {
                        dWrap.serviceType = createddDefault.Service_Type__c;
                    }
                    if (String.isNotEmpty(createddDefault.AvailableCoverages__c)) {
                        string ops = createddDefault.AvailableCoverages__c.replace('||', ',');
                        dWrap.serviceOptions = ops.split(',');
                    }
                    system.debug('createddDefault.AvailableCoverages__c ####'+createddDefault.AvailableCoverages__c);
                    system.debug('service type ###'+createddDefault.Default_Service_Type__c);
                    if (String.isNotEmpty(createddDefault.SpecialOptions__c)) {
                        dWrap.specialOpnsValue = createddDefault.SpecialOptions__c;
                    }
                    system.debug('createddDefault.SpecialOptions__c ###'+createddDefault.SpecialOptions__c);
                    if (String.isNotEmpty(createddDefault.Service_Configurations__c)) {
                        dWrap.productClassification = createddDefault.Service_Configurations__c;
                    }
                    if (String.isNotEmpty(createddDefault.selected_service_option__c)) {
                        dWrap.selectedServiceOpt = createddDefault.selected_service_option__c;
                    }
                    if (String.isNotEmpty(createddDefault.Bill_To__c)) {
                        dWrap.billTo = createddDefault.Bill_To__c;
                    }
                    if (String.isNotEmpty(createddDefault.Bill_To_Order_Number__c)) {
                        dwrap.orderNumber = createddDefault.Bill_To_Order_Number__c;
                    }
                    // Accidental Damage from Maestro
                    dwrap.accidentalDamage = createddDefault.CompleteCareOption__c;
                    // Accidental Damage in SFDC
                    dwrap.accidentalDamage1 = createddDefault.Complete_Care_Option__c;
                    // Accidental Damage Flag for Override
                    dwrap.ADCoverageFlag = createddDefault.AD_Coverage_Flag__c;
                    dWrap.keepYComp = createddDefault.Keep_Your_Components__c;
                    dWrap.dSPOverideReq = createddDefault.DSP_Override_Request__c;
                    dWrap.outOfWarranty = createddDefault.outOfWarranty__c;
                    dWrap.KYHDFlag = createddDefault.KYHDOption__c;
                    dWrap.entitlementDetails = createddDefault.Entitlement_Details__c;
                    dWrap.workOrderCountry = createddDefault.work_order__r.Country;
                    if (defaultList != null && !defaultList.isEmpty() && String.isNotEmpty(defaultList[0].AvailableOptions__c)) {
                        if (defaultList[0].AvailableOptions__c.contains('-')) {
                            dWrap.locationCoverageLevel = createddDefault.AvailableOptions__c.substringBeforeLast('-');
                        }
                    }
                    dWrap.DASPValues = null;
                    if(workOrderRecord.Region__c == '2')
                    {
                        dWrap.DASPValues = getDASPValue(createddDefault.Work_Order__r.CountryCode); 
                    }  
                }
                
                system.debug('reasonForDamageOptions >>>'+dWrap.reasonForDamageOptions);
                return dWrap;
            }
        } catch (Exception e) {  ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getDispatchDefaults', 'Dispatch Management');
            return null;
        }
    }

    /* To get Picklist Values of the field */
    public static List < String > getselectOptions(Schema.sObjectType objType, string fld) {
        try {

            List < String > allOpts = new list < String > ();

            // Describe the SObject using its object type.
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

            // Get a map of fields for the SObject
            map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

            // Get the list of picklist values for this field.
            list < Schema.PicklistEntry > values =
                fieldMap.get(fld).getDescribe().getPickListValues();

            // Add these values to the selectoption list.
            for (Schema.PicklistEntry a: values) {
                allOpts.add(a.getValue());
            }
            allOpts.sort();

            return allOpts;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getDispatchDefaults', 'Dispatch Management');
            return null;
        }
    }

    /* To insert Record on Dispatch Defaults Object */
    public static Id createDispatchDefaults(GetDispatchDefaults__x inputList, Id workOrderId, String productValue) {
        try {
            String defaultServOption = '';

            DispatchDefaults__c dDefaultToInsert = new DispatchDefaults__c();

            WorkOrder wOrder = new WorkOrder(Id = workOrderId);

            wOrder.schedulingInternalLogic__c = 'Neither';
            wOrder.ScheduleStartDate__c = null;
            wOrder.ScheduleEndDate__c = null;
            wOrder.StartDate = null;
            wOrder.EndDate = null;

            wOrder.DataDestruction__c = inputList.DataDestruction__c; // rodrigo added for defect#5207765
            //wOrder.DataDestruction__c = 'Y';

            dDefaultToInsert.Work_Order__c = workOrderId;
            if (String.isNotEmpty(inputList.AvailableOptions__c)) {
                dDefaultToInsert.AvailableOptions__c = inputList.AvailableOptions__c;
                if (inputList.AvailableOptions__c.contains('-')) {
                    dDefaultToInsert.MaxCapabilityServiceHours__c = inputList.AvailableOptions__c.substringAfterLast('-');
                    dDefaultToInsert.MaxCapabilityServiceLevel__c = inputList.AvailableOptions__c.substringBeforeLast('-');
                }
            }


            //if (String.isNotEmpty(inputList.ServiceHours__c) && String.isNotEmpty(inputList.ServiceLevel__c)){
            //defaultServOption = inputList.ServiceLevel__c+'-'+inputList.ServiceHours__c;//commented by Dattaa1 service Option
            //}

            dDefaultToInsert.selected_service_option__c = defaultServOption;
            wOrder.Service_Option__c = defaultServOption;

            if (string.isNotEmpty(inputList.CompleteCareOption__c)) {
                if (inputList.CompleteCareOption__c.equalsIgnoreCase('true')) {
                    dDefaultToInsert.BasicEntitlement__c = True;
                }
            }

            if (String.isNotEmpty(inputList.BasicEntitlement__c)) {
                if (inputList.BasicEntitlement__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.BasicEntitlement__c = True;
                }
            }
            if (String.isNotEmpty(inputList.Billable__c)) {
                dDefaultToInsert.Billable__c = inputList.Billable__c;
            }
            if (String.isNotEmpty(inputList.BUID__c)) {
                dDefaultToInsert.BUID__c = inputList.BUID__c;
            }
            if (String.isNotEmpty(inputList.CallType__c)) {
                dDefaultToInsert.CallType__c = inputList.CallType__c;
            }
            dDefaultToInsert.CustomSKU__c = inputList.CustomSKU__c;
      system.debug('inputList.Category__c ####'+inputList.Category__c);
            if (String.isNotEmpty(inputList.Category__c)) {
                dDefaultToInsert.SpecialOptions__c = inputList.Category__c;
            }
            if (String.isNotEmpty(inputList.City__c)) {
                dDefaultToInsert.City__c = inputList.City__c;
            }

            if (String.isNotEmpty(inputList.CompleteCareOption__c)) {
                if (inputList.CompleteCareOption__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.CompleteCareOption__c = True;
                }
            }
            if (String.isNotEmpty(inputList.CompleteCareOption__c)) {
                //dDefaultToInsert.Complete_Care_Option__c = dDefaultToInsert.CompleteCareOption__c;
            }

            if (String.isNotEmpty(inputList.Country__c)) {
                dDefaultToInsert.Country__c = inputList.Country__c;
            }
            if (String.isNotEmpty(inputList.CustomerNumber__c)) {
                dDefaultToInsert.CustomerNumber__c = inputList.CustomerNumber__c;
            }
            if (String.isNotEmpty(inputList.CustomerPreference__c)) {
                dDefaultToInsert.CustomerPreference__c = inputList.CustomerPreference__c;
            }

            if (String.isNotEmpty(inputList.CompleteCareOption__c)) {
                if (inputList.CompleteCareOption__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.DataRecovery__c = True;
                }
            }

            if (String.isNotEmpty(inputList.DefaultCallType__c)) {
                dDefaultToInsert.DefaultCallType__c = inputList.DefaultCallType__c;
            }
            if (String.isNotEmpty(inputList.DefaultDPSType__c)) {
                dDefaultToInsert.DefaultDPSType__c = inputList.DefaultDPSType__c;
            }
            if (String.isNotEmpty(inputList.DefaultDSP__c)) {
                dDefaultToInsert.DefaultDSP__c = inputList.DefaultDSP__c;
            }
            if (String.isNotEmpty(inputList.DefaultSKU__c)) {
                dDefaultToInsert.DefaultSKU__c = inputList.DefaultSKU__c;
            }
            if (String.isNotEmpty(inputList.CustomerRegionId__c)) {
                dDefaultToInsert.CustomerRegionId__c = inputList.CustomerRegionId__c;
            }

            if (String.isNotEmpty(inputList.DigitalEntitlements__c)) {
                if (inputList.DigitalEntitlements__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.DigitalEntitlements__c = True;
                }
            }
            if (String.isNotEmpty(inputList.DLP__c)) {
                dDefaultToInsert.DLP__c = inputList.DLP__c;
            }
            if (String.isNotEmpty(inputList.DPSType__c)) {
                dDefaultToInsert.DPSType__c = inputList.DPSType__c;
            }
            if (String.isNotEmpty(inputList.DSP__c)) {
                dDefaultToInsert.DSP__c = inputList.DSP__c;
            }
            if (String.isNotEmpty(inputList.EntitlementId__c)) {
                dDefaultToInsert.EntitlementId__c = inputList.EntitlementId__c;
            }
            if (String.isNotEmpty(inputList.EntitlementName__c)) {
                dDefaultToInsert.EntitlementName__c = inputList.EntitlementName__c;
            }
            if (String.isNotEmpty(inputList.ErrorCode__c)) {
                dDefaultToInsert.ErrorCode__c = inputList.ErrorCode__c;
            }
            if (String.isNotEmpty(inputList.GroundShipFlg__c)) {
                dDefaultToInsert.GroundShipFlg__c = inputList.GroundShipFlg__c;
            }
            if (String.isNotEmpty(inputList.ISPWarrantyOrderBUID__c)) {
                dDefaultToInsert.ISPWarrantyOrderBUID__c = inputList.ISPWarrantyOrderBUID__c;
            }
            if (String.isNotEmpty(inputList.ISPWarrantyOrderNum__c)) {
                dDefaultToInsert.ISPWarrantyOrderNum__c = inputList.ISPWarrantyOrderNum__c;
            }
            if (String.isNotEmpty(inputList.KYCOption__c)) {
                if (inputList.KYCOption__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.Keep_Your_Components__c = True;
                    dDefaultToInsert.Entitlement_Details__c += '|KYC|';
                }
            }
             if (String.isNotEmpty(inputList.KYHDOption__c) && inputList.KYHDOption__c.equalsIgnoreCase('Y') && (inputList.KYCOption__c==NULL || (String.isNotEmpty(inputList.KYCOption__c)&& !inputList.KYCOption__c.equalsIgnoreCase('Y')))) {
                // Modified by Rodrigo Carpio
                dDefaultToInsert.KYHDOption__c = True;
                if (inputList.KYHDOption__c.equalsIgnoreCase('Y') && (inputList.KYCOption__c==NULL || (String.isNotEmpty(inputList.KYCOption__c)&& !inputList.KYCOption__c.equalsIgnoreCase('Y')))) { //MB: commented for defect 5151930
                    if (string.isNotBlank(dDefaultToInsert.Entitlement_Details__c)) {
                        dDefaultToInsert.Entitlement_Details__c = '|KYHD|';
                    } else {
                        dDefaultToInsert.Entitlement_Details__c = '|KYHD|';
                    }
                }
            }

            if (String.isNotEmpty(inputList.LaborCountry__c)) {
                dDefaultToInsert.LaborCountry__c = inputList.LaborCountry__c;
            }
            if (String.isNotEmpty(inputList.LOB__c)) {
                dDefaultToInsert.LOB__c = inputList.LOB__c;
            }
            if (String.isNotEmpty(inputList.MaxCapabilityDLP__c)) {
                dDefaultToInsert.MaxCapabilityDLP__c = inputList.MaxCapabilityDLP__c;
            }
            /*
            if (String.isNotEmpty(inputList.MaxCapabilityServiceHours__c)) {
                dDefaultToInsert.MaxCapabilityServiceHours__c = inputList.MaxCapabilityServiceHours__c;
            }
            if (String.isNotEmpty(inputList.MaxCapabilityServiceLevel__c)) {
                dDefaultToInsert.MaxCapabilityServiceLevel__c = inputList.MaxCapabilityServiceLevel__c;
            }
            */
            if (String.isNotEmpty(inputList.MaxCapabilityServiceSubType__c)) {
                dDefaultToInsert.MaxCapabilityServiceSubType__c = inputList.MaxCapabilityServiceSubType__c;
            }
            if (String.isNotEmpty(inputList.OconusDispatch__c)) {
                dDefaultToInsert.OconusDispatch__c = inputList.OconusDispatch__c;
            }
            if (String.isNotEmpty(inputList.OrderNumber__c)) {
                dDefaultToInsert.OrderNumber__c = inputList.OrderNumber__c;
            }
            if (String.isNotEmpty(inputList.OutOfHours__c)) {
                if (inputList.OutOfHours__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.OutOfHours__c = True;
                }
            }
            if (String.isNotEmpty(inputList.OutOfWarranty__c)) {
                if (inputList.OutOfWarranty__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.OutOfWarranty__c = True;
                }
            }
            if (String.isNotEmpty(inputList.PartsCountry__c)) {
                dDefaultToInsert.PartsCountry__c = inputList.PartsCountry__c;
            }
            if (String.isNotEmpty(inputList.PostalCode__c)) {
                dDefaultToInsert.PostalCode__c = inputList.PostalCode__c;
            }
            if (String.isNotEmpty(inputList.PPID__c)) {
                dDefaultToInsert.PPID__c = inputList.PPID__c;
            }
            if (String.isNotEmpty(inputList.PremierCode__c)) {
                dDefaultToInsert.PremierCode__c = inputList.PremierCode__c;
            }
            if (String.isNotEmpty(inputList.PremierType__c)) {
                dDefaultToInsert.PremierType__c = inputList.PremierType__c;
            }
            if (String.isNotEmpty(inputList.ProSupport__c)) {
                if (inputList.ProSupport__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.ProSupport__c = True;
                }
            }
            //dDefaultToInsert.ProviderCode__c = inputList.ProviderCode__c;
            if (String.isNotEmpty(inputList.Region__c)) {
                dDefaultToInsert.Region__c = inputList.Region__c;
            }
            if (String.isNotEmpty(inputList.ReverseAgency__c)) {
                if (inputList.ReverseAgency__c.equalsIgnoreCase('Y')) {
                    dDefaultToInsert.ReverseAgency__c = True;
                }
            }
            if (String.isNotEmpty(inputList.ServiceHours__c)) {
                dDefaultToInsert.ServiceHours__c = inputList.ServiceHours__c;
            }
            if (String.isNotEmpty(inputList.ServiceLevel__c)) {
                dDefaultToInsert.ServiceLevel__c = inputList.ServiceLevel__c;
            }
            if (String.isNotEmpty(inputList.ServiceTagId__c)) {
                dDefaultToInsert.ServiceTagId__c = inputList.ServiceTagId__c;
            }
            if (String.isNotEmpty(inputList.ServiceType__c)) {
                dDefaultToInsert.Default_Service_Type__c = inputList.ServiceType__c;
            }
            if (String.isNotEmpty(inputList.SKUNumber__c)) {
                dDefaultToInsert.SKUNumber__c = inputList.SKUNumber__c;
            }
            if (String.isNotEmpty(inputList.State__c)) {
                dDefaultToInsert.State__c = inputList.State__c;
            }
            if (String.isNotEmpty(inputList.UserID__c)) {
                dDefaultToInsert.UserID__c = inputList.UserID__c;
            }
            if (String.isNotEmpty(inputList.uuid__c)) {
                dDefaultToInsert.uuid__c = inputList.uuid__c;
            }
            if (String.isNotEmpty(inputList.WarningMessage__c)) {
                dDefaultToInsert.WarningMessage__c = inputList.WarningMessage__c;
            }
            if (String.isNotEmpty(inputList.WarrantyEndDate__c)) {
                dDefaultToInsert.WarrantyEndDate__c = inputList.WarrantyEndDate__c;
            }
            if (inputList.AvailableCoverages__c != null && inputList.AvailableCoverages__c.contains(defaultServOption)) {
                dDefaultToInsert.AvailableCoverages__c = inputList.AvailableCoverages__c;
            } else {
                if (String.isNotEmpty(defaultServOption)) {
                    dDefaultToInsert.AvailableCoverages__c = inputList.AvailableCoverages__c + '||' + defaultServOption;
                }
            }

            //Product Classification
            if (String.isNotEmpty(productValue)) {
                dDefaultToInsert.Service_Configurations__c = productValue;
            }

            // Update Work Order
            update wOrder;

            // Insert Default Default Record
            insert dDefaultToInsert;
            
            // Create AD Alert
            //EinsteinAlertController.adAlertByDispatch(wOrder.Id, dDefaultToInsert.Id);
            
            return dDefaultToInsert.Id;
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'createDispatchDefaults', 'Dispatch Management');
            return null;
        }
    }

    /* To Update the record with new values on click of save Button*/
    @AuraEnabled
    public static updateWrapper updateDefaultsRecord(Id recordId, Id defaultRecId, string serTypeValue, string serOptionValue,
        string speOptionvalue, string prodClassValue, boolean kYcompvalue,
        boolean accDamageValue, boolean dSPOverideValue, string billToValue,
        string OrderNumber, List < String > servOptionPicklist, string instructions,
        string dspInstrnRecId, boolean kyhdFlag, boolean KYHDFlagChangedTrue, string ADOverrideReason, boolean accDamageFlag,
        boolean altReturnAddressFlag, string altReturnAddressStreet, string altReturnAddressPostalCode,
        string altReturnAddressCity, string altReturnAddressState, string altReturnAddressCountry, string reasonForDamage, string DASPValue, string DSPSelectedfromDASP, boolean KoreaMonitor) {
        try {

            string strOpt           =   '';
            integer indexValue;
            string serviceHour      =   '';
            string serviceLevel     =   '';
            string InstructRecId    =   '';
            string prefDSP          =   '';
            List <GetBestFitDSP__x> getBestFitRecord = new List<GetBestFitDSP__x>();
            List<CheckPreference__x> checkPrefList = new List<CheckPreference__x>();
            List<GetProviderAttributes__x> dspAttrib = new  List<GetProviderAttributes__x>();
            
            updateWrapper uWrap = new updateWrapper();

            DispatchDefaults__c createddDefault = new DispatchDefaults__c();

            createddDefault = [SELECT Id, OutOfWarranty__c, entitlement_details__c, selected_service_option__c, Billable__c, Service_Options_Picklist_values__c,
                Service_Type__c, PO_Number__c, category__c, Service_Configurations__c, SpecialOptions__c,GroundShipFlg__c,OutOfHours__c,
                Work_Order__r.BUID__c, Bill_To_Order_Number__c, Bill_To__c, Keep_Your_Components__c,  Work_Order__r.DSP__c, Work_Order__r.DPS_BUID__c,
                DSP_Override_Request__c, CompleteCareOption__c, OrderNumber__c, work_order__c, KYHDOption__c, Work_Order__r.AssetItemClass__c,
                Work_Order__r.OrderNumber__c, Work_Order__r.ServiceTag__c, Work_Order__r.City,Work_Order__r.CityCalc__c, Work_Order__r.State, Work_Order__r.StateCalc__c,
                Work_Order__r.PostalCode, Work_Order__r.CountryCode__c, Work_Order__r.LOB__c, Work_Order__r.Region__c, Work_Order__r.schedulingInternalLogic__c,
                Work_Order__r.Service_Type__c, Work_Order__r.WorkOrderNumber, Work_Order__r.Country, Work_Order__r.CountryCode,
                Work_Order__r.IsDeferralAllowed__c, Work_Order__r.FSD_DASP_Flag__c, Work_Order__r.Sanbao_FLG__c, Work_Order__r.ScheduleStartDate__c,
                Work_Order__r.ScheduleEndDate__c, Work_Order__r.FSD_Oconus_Federal_Flag__c, Work_Order__r.Deferred__c, Work_Order__r.StateCode, Work_Order__r.Status, Work_Order__r.Sub_Status__c,
                Work_Order__r.Alternate_Return_Address_Checkbox__c, Work_Order__r.Alternate_Return_Postal_Code__c, Work_Order__r.Alternate_Return_Street__c,
                Work_Order__r.Alternate_Return_City__c, Work_Order__r.Alternate_Return_State__c, Work_Order__r.Alternate_Return_Country__c,
                Work_Order__r.Account.CCN__c, Work_Order__r.Account.Link_Number__c, Work_Order__r.AccountId, Work_Order__r.FSD_DSP_Selection__c,
                Work_Order__r.DPS_Sub_Region__c, Work_Order__r.DispatchEvent__c, Work_Order__r.PartnerWorkOrderNumber__c
                FROM DispatchDefaults__c WHERE Id =: defaultRecId LIMIT 1
            ];

            if (serOptionValue.contains('-')) {
                serviceLevel = serOptionValue.substringBeforeLast('-');
                serviceHour = serOptionValue.substringAfterLast('-');
            }
        
            // generate the 11 digit partner work order number
            if (string.isBlank(createddDefault.work_order__r.PartnerWorkOrderNumber__c))
            {
                createddDefault.work_order__r.DispatchEvent__c = 'DISPATCH_STATUS_UPDATE';
                List <Asset_Country__mdt> objAssetCountry = [SELECT RegionId__c, CountryCode__c, CountryBUID__c, RegionName__c, SubRegionName__c, CountryDPSCode__c
                                                             FROM Asset_Country__mdt WHERE Active__c = true AND CountryCode__c =: createddDefault.work_order__r.CountryCode LIMIT 1];
                if (objAssetCountry.size() > 0) {
                    if (!createddDefault.work_order__r.Region__c.equals('1')) {
                        createddDefault.work_order__r.PartnerWorkOrderNumber__c = objAssetCountry[0].CountryDPSCode__c + createddDefault.work_order__r.WorkOrderNumber;
                    } else {
                        createddDefault.work_order__r.PartnerWorkOrderNumber__c = createddDefault.work_order__r.WorkOrderNumber;
                    }    
                }
            }
            
            //if (string.isNotEmpty(serTypeValue) && (serTypeValue.equalsIgnoreCase('Labor Only') || serTypeValue.equalsIgnoreCase('Parts and Labor')) && dSPOverideValue == false) 
            if (string.isNotEmpty(serTypeValue) && (!serTypeValue.equalsIgnoreCase('Parts Only')) && dSPOverideValue == false && string.isEmpty(DASPValue)) 
            {
                 /* call Delta Check preference web service */    
                //checkPrefList = checkPreference(createddDefault.Work_Order__r.WorkOrderNumber);
                // call the dsp assignment flow                    
                    Map<String, Object> inputMap = new Map<String, Object>();
                    inputMap.put('DispBUID', createddDefault.Work_Order__r.DPS_BUID__c);
                    inputMap.put('DispBatteryShipFlag', '');
                    inputMap.put('DispBillable', createddDefault.Billable__c);
                    inputMap.put('DispCCN', createddDefault.Work_Order__r.Account.CCN__c);
                    inputMap.put('DispCity', createddDefault.Work_Order__r.CityCalc__c);
                    inputMap.put('DispCountryCode', createddDefault.Work_Order__r.CountryCode);
                    inputMap.put('DispItemClass', createddDefault.Work_Order__r.AssetItemClass__c);
                    inputMap.put('DispLOB', createddDefault.Work_Order__r.LOB__c);
                    inputMap.put('DispOOW', createddDefault.OutOfWarranty__c ? 'Y' : 'N');
                    inputMap.put('DispPostalCode', createddDefault.Work_Order__r.PostalCode);                    
                    inputMap.put('DispRegionId', integer.valueOf(createddDefault.Work_Order__r.Region__c));
                    inputMap.put('DispServiceHour', serviceHour);
                    inputMap.put('DispServiceLevel', serviceLevel);
                    //inputMap.put('DispServiceSubType', createddDefault.Work_Order__r.Service_Type__c);
                    inputMap.put('DispServiceSubType', serTypeValue);
                    inputMap.put('DispState', createddDefault.Work_Order__r.StateCalc__c);
                    inputMap.put('DispSvcTag', createddDefault.Work_Order__r.ServiceTag__c);                    
                    inputMap.put('DispatchAccount', createddDefault.Work_Order__r.AccountId);
                    inputMap.put('DispatchCountry', (createddDefault.Work_Order__r.Country == 'United States') ? 'USA' : createddDefault.Work_Order__r.Country);
                    inputMap.put('LinkNumber', createddDefault.Work_Order__r.Account.Link_Number__c);
                    inputMap.put('WorkOrderNumber', createddDefault.Work_Order__r.PartnerWorkOrderNumber__c);
                    Flow.Interview.Dispatch_Get_DSP dspFlow = new Flow.Interview.Dispatch_Get_DSP(inputMap);    
                    dspFlow.start();
                    String dspAssigned = (String)dspFlow .getVariableValue('AssignedProvider');
                    String dspAssignedName = (String)dspFlow .getVariableValue('AssignedProviderName');
                    String dspAssignment = (String)dspFlow .getVariableValue('DSPSelectionMethod');
                    String dspSchedulingURL = (String)dspFlow .getVariableValue('DSPSchedulingURL');
                    String dspScheduleFlag = (String)dspFlow .getVariableValue('DSPScheduleEnabled');
                    String dspCommChannel = (String)dspFlow .getVariableValue('CommunicationChannel');
                
                SYstem.debug('dspAssignedName ===> '+dspAssignedName);
                System.debug('dspAssigned ==> '+dspAssigned);
                
                //if(checkPrefList!=null)
                if (string.isNotBlank(dspAssigned))
                {
                    createddDefault.Work_Order__r.Schedule_Enable_Flag__c = dspScheduleFlag;
                    createddDefault.Work_Order__r.FSD_DSP_Selection__c = dspAssignment;
                    createddDefault.Work_Order__r.Scheduling_URL__c = dspSchedulingURL;
                    createddDefault.DSP__c = dspAssigned;
                    createddDefault.Work_Order__r.DSP__c = dspAssigned;
                    //createddDefault.Work_Order__r.DSPName__c = dspAssigned;
                    createddDefault.Work_Order__r.DSPName__c = dspAssignedName;
                    createddDefault.Work_Order__r.Communication_Channel__c = dspCommChannel;
                }
                    /*
                    //if(string.isNotEmpty(checkPrefList[0].WF_DSP__c)){
                    //  prefDSP = checkPrefList[0].WF_DSP__c;
                    //}
                    prefDSP = dspAssigned;
                    // check if DSP is returned
                    if (string.isNotEmpty(prefDSP) && prefDSP != 'D1D' && string.isNotBlank(prefDSP)) {
                        // Make Call to Mastero to get DSP Attributes 
                        dspAttrib =  DispatchServiceLevelHandler.getProviderAttributes(createddDefault,serTypeValue,serOptionValue,billToValue,kYcompvalue,KyhdFlag,accDamageValue,prefDSP);
                        
                        if(dspAttrib!= null ){
                                //Schedule Enable Flag
                                if (string.isNotEmpty(dspAttrib[0].ISPDSPScheduleEnabled__c)) {
                                    createddDefault.Work_Order__r.Schedule_Enable_Flag__c = dspAttrib[0].ISPDSPScheduleEnabled__c;
                                }
                                //DSP Scheduling URL
                                if (string.isNotEmpty(dspAttrib[0].DSPSchedulingURL__c)) {
                                    createddDefault.Work_Order__r.Scheduling_URL__c = dspAttrib[0].DSPSchedulingURL__c;
                                }
                                //DSP
                                if (string.isNotEmpty(dspAttrib[0].ServiceProviderCode__c)) {
                                    createddDefault.DSP__c = dspAttrib[0].ServiceProviderCode__c;
                                    createddDefault.Work_Order__r.DSP__c = dspAttrib[0].ServiceProviderCode__c;
                                    //if(string.isNotEmpty(checkPrefList[0].DSPSelectionMethod__c))
                                    if(string.isNotEmpty(dspAssignment))
                                    {
                                        createddDefault.Work_Order__r.FSD_DSP_Selection__c = dspAssignment;   
                                    } else {
                                        createddDefault.Work_Order__r.FSD_DSP_Selection__c = null;
                                    }
                                }    
                        }
                    } 
                
                
                if(dspAttrib.isEmpty() || dspAttrib==null){
                    getBestFitRecord = new List < GetBestFitDSP__x > ();
                    // Make Call to Mastero to get Best Fit DSP --> When Service Type is set to Labor Only (or) Parts & Labor 
                    getBestFitRecord = DispatchServiceLevelHandler.callGetDSPFitService(createddDefault,serTypeValue,serviceHour,serviceLevel); 
                    
                    if(getBestFitRecord!=null){
                            if (string.isNotEmpty(getBestFitRecord[0].DSP__c) && getBestFitRecord[0].DSP__c != 'D1D') {
                                //Schedule Enable Flag            
                                if (string.isNotEmpty(getBestFitRecord[0].ISPDSPScheduleEnabled__c)) {
                                    if (serviceLevel != 'Next Business Day'){
                                        createddDefault.Work_Order__r.Schedule_Enable_Flag__c = 'N';
                                    } else {
                                        createddDefault.Work_Order__r.Schedule_Enable_Flag__c = getBestFitRecord[0].ISPDSPScheduleEnabled__c;
                                    }
                                }
                                //DSP Scheduling URL
                                if (string.isNotEmpty(getBestFitRecord[0].DSPSchedulingURL__c)) {
                                    createddDefault.Work_Order__r.Scheduling_URL__c = getBestFitRecord[0].DSPSchedulingURL__c;
                                }
                                //DSP
                                if (string.isNotEmpty(getBestFitRecord[0].DSP__c)) {
                                    createddDefault.DSP__c = getBestFitRecord[0].DSP__c;
                                    createddDefault.Work_Order__r.DSP__c = getBestFitRecord[0].DSP__c;
                                    createddDefault.Work_Order__r.FSD_DSP_Selection__c = 'Dynamic Dispatch';
                                }
                                // CommunicationChannel
                                if (string.isNotEmpty(getBestFitRecord[0].CommunicationChannel__c)) {
                                    createddDefault.Work_Order__r.Communication_Channel__c = getBestFitRecord[0].CommunicationChannel__c;
                                }
                            }
                    } else {
                        createddDefault.DSP__c = null;
                        createddDefault.Work_Order__r.DSP__c = null;
                        createddDefault.Work_Order__r.DSPName__c = null;
                        createddDefault.Work_Order__r.Scheduling_URL__c = null;
                        createddDefault.Work_Order__r.Communication_Channel__c = null;
                        createddDefault.Work_Order__r.Schedule_Enable_Flag__c = null;
                        createddDefault.Work_Order__r.FSD_DSP_Selection__c = null;
                    }
                } */
            } else {
                createddDefault.DSP__c = null;
                createddDefault.Work_Order__r.DSP__c = null;
                createddDefault.Work_Order__r.DSPName__c = null;
                createddDefault.Work_Order__r.Scheduling_URL__c = null;
                createddDefault.Work_Order__r.Communication_Channel__c = null;
                createddDefault.Work_Order__r.Schedule_Enable_Flag__c = null;
                createddDefault.Work_Order__r.FSD_DSP_Selection__c = null;
            }
            /*
            if (String.isNotEmpty(createddDefault.Work_Order__r.DSP__c)){
                List<DispatchDSPDLP__c> dspRec = new List<DispatchDSPDLP__c>();
                dspRec = [SELECT PartnerName__c FROM DispatchDSPDLP__c 
                            WHERE Type__c =: 'ISP_DSP_PICK' AND PartnerCode__c =: createddDefault.Work_Order__r.DSP__c 
                            AND CountryCode__c =: createddDefault.Work_Order__r.CountryCode LIMIT 1];
                if(dspRec!=null)
                  createddDefault.Work_Order__r.DSPName__c = dspRec[0].PartnerName__c;
            }*/

            if (String.isNotEmpty(serOptionValue)) {
				// added for defect 5918088 starts here
                string localCountryCode = createddDefault.Work_Order__r.CountryCode;
                if (localCountryCode.endsWithIgnoreCase('IN')) {
                    List <Asset_Country__mdt> objAssetCountry = [SELECT RegionId__c, CountryCode__c, CountryBUID__c, RegionName__c, SubRegionName__c, CountryDPSCode__c
                                                                 FROM Asset_Country__mdt 
                                                                 WHERE Active__c = true AND CountryBUID__c =: createddDefault.work_order__r.DPS_BUID__c 
                                                                 AND CountryCode__c != 'IN' LIMIT 1];
                    if (objAssetCountry.size() > 0) {
                        localCountryCode = objAssetCountry[0].CountryCode__c;
                    //    createddDefault.work_order__r.DeltaISOCountryCode__c = localCountryCode;
                    }
                }
                // added for defect 5918088 ends here
                GetSLADates__x slaDates = getEntitlementSLA(createddDefault.Work_Order__r.WorkOrderNumber, serOptionValue, createddDefault.Work_Order__r.PostalCode, localCountryCode,createddDefault.Work_Order__r.StateCalc__c);
                if (String.isNotEmpty(slaDates.SLAStartDate__c)) {
                    createddDefault.work_order__r.SLAStartDate__c = slaDates.SLAStartDate__c;
                    createddDefault.work_order__r.EntitlementStartDate__c = slaDates.SLAStartDate__c;
                    createddDefault.work_order__r.EntitlementStartDate__c = slaDates.SLAStartDate__c;
                    //DateTime.Valueof(slaDates.SLAStartDate__c.replace('T', ' '));
                }
                if (String.isNotEmpty(slaDates.SLAEndDate__c)) {
                    createddDefault.Work_Order__r.SLAEndDate__c = slaDates.SLAEndDate__c;
                    createddDefault.Work_Order__r.EntitlementEndDate__c = slaDates.SLAEndDate__c;
                    //DateTime.Valueof(slaDates.SLAEndDate__c.replace('T', ' '));
                }

                createddDefault.work_order__r.DeltaTimezone__c = slaDates.TimeZone__c;
                createddDefault.work_order__r.DeltaShiftStart__c = slaDates.ShiftStart__c;
                createddDefault.work_order__r.DeltaShiftEnd__c = slaDates.ShiftEnd__c;

                if (String.isNotEmpty(slaDates.TimeZone__c)) {
                    //Timezone__mdt tz = [SELECT Label FROM Timezone__mdt WHERE DeltaTimezone__c = :slaDates.TimeZone__c LIMIT 50000];
                    // Modified as the per the TASK 5287280
                    List < Timezone__mdt > tzList = new List < Timezone__mdt > ();
                    tzList = [SELECT Label FROM Timezone__mdt WHERE DeltaTimezone__c =: slaDates.TimeZone__c LIMIT 1];
                    createddDefault.work_order__r.Timezone__c = tzList[0].Label;
                }
            }
            createddDefault.work_order__r.FSD_DASP_Flag__c = false;
            if(String.isNotEmpty(DASPValue))
            {
                createddDefault.work_order__r.FSD_DASP_Flag__c = true;
                createddDefault.Work_Order__r.DSP__c = DSPSelectedfromDASP;
                createddDefault.Work_Order__r.DASP__c = DASPValue;
            }
            
            createddDefault.work_order__r.Sanbao_FLG__c = 'N';
            createddDefault.work_order__r.FSD_Oconus_Federal_Flag__c = 'N';
            createddDefault.work_order__r.Deferred__c = 'No';
            createddDefault.work_order__r.FSD_Worked_By_Flg__c = 'N';
            createddDefault.work_order__r.DispatchEventCode__c = '';
            
            //Service Type

            if (String.isNotEmpty(serTypeValue)) {
                //Service Type on Dispatch Defualts
                createddDefault.Service_Type__c = serTypeValue;
                //Service Type on Work Order
                createddDefault.work_order__r.Service_Type__c = serTypeValue;
            }
            //Special Options or Category on Dispatch Defaults

            if (String.isNotEmpty(speOptionvalue)) {
                createddDefault.SpecialOptions__c = speOptionvalue;
                //createddDefault.Default_Service_Type__c = speOptionvalue;
            } else {
                createddDefault.SpecialOptions__c = null;
                //createddDefault.Default_Service_Type__c = null;
            }
            //Accidental Damage Override Values
            if (String.isNotEmpty(ADOverrideReason)) {
                createddDefault.AD_Override__c = ADOverrideReason;
            }
            //Reason For Damage Values
            if (String.isNotEmpty(reasonForDamage)) {
                createddDefault.Reason_for_the_Damage__c = reasonForDamage;
            }
            //Product Classification on Dispatch Defaults
            if (String.isNotEmpty(prodClassValue)) {
                createddDefault.Service_Configurations__c = prodClassValue;
            }

            if (String.isNotEmpty(serOptionValue)) {
                // Selected Service Option
                createddDefault.selected_service_option__c = serOptionValue;
                createddDefault.work_order__r.Service_Option__c = serOptionValue;
                // Service Hours
                //createddDefault.ServiceHours__c = serOptionValue.substringAfterLast('-');
                // Service Level
                //createddDefault.ServiceLevel__c = serOptionValue.substringBeforeLast('-');
            }
            //Order Number
            createddDefault.Bill_To_Order_Number__c = OrderNumber;

            // Bill To Flag
            if (string.isNotEmpty(billToValue)) {
                createddDefault.Billable__c = 'Y';
            } else {
                createddDefault.Billable__c = 'N';
            }

            // Bill To
            createddDefault.Bill_To__c = billToValue;
            // DSP Override Request

            createddDefault.DSP_Override_Request__c = dSPOverideValue;
            // Accidental Damage
            //createddDefault.CompleteCareOption__c = accDamageValue;
            // Keep Your Components
            createddDefault.Keep_Your_Components__c = kYcompvalue;
            // Keep Your Hard Drive
            createddDefault.KYHDOption__c = kyhdFlag;
            //if(!kyhdFlag && createdDefault.entitlement_details__c.contains('KYHD'))
            //createdDefault.entitlement_details__c = createdDefault.entitlement_details__c.remove('KYHD');
            //if(!kYcompvalue)
            //createdDefault.entitlement_details__c = createdDefault.entitlement_details__c.remove('KYC');

            createddDefault.Complete_Care_Option__c = accDamageFlag;

            for (String s: servOptionPicklist) {
                strOpt = strOpt + '||' + s;
            }

            // Available Service Options
            createddDefault.AvailableCoverages__c = strOpt;

            // deferral field setting 
            if ((String.isNotEmpty(serTypeValue)) && (String.isNotEmpty(serOptionValue))) {

                List < Deferral_Setting__mdt > getDeferralSetting = new List < Deferral_Setting__mdt > ();

                getDeferralSetting = [SELECT Deferral_Access__c
                    FROM Deferral_Setting__mdt WHERE Region__c =: createddDefault.work_order__r.Region__c
                    AND Service_Level__c =: serOptionValue.substringBeforeLast('-') AND Service_Type__c =: serTypeValue LIMIT 1
                ];

                //IsDefferalField on Work Order
                if (getDeferralSetting.size() > 0) {
                    createddDefault.work_order__r.IsDeferralAllowed__c = getDeferralSetting[0].Deferral_Access__c;
                } else
                    createddDefault.work_order__r.IsDeferralAllowed__c = false;
            }

            // cancel existing schedule date
            if (String.isNotEmpty(createddDefault.work_order__r.ScheduleStartDate__c)) {
                SlotsController.cancelScheduledSlot(recordId);
                createddDefault.Work_Order__r.ScheduleEndDate__c = null;
                createddDefault.Work_Order__r.ScheduleStartDate__c = null;


            }

            // Set to Neither - Means Not Yet Scheduled or Deferred.
            createddDefault.work_order__r.schedulingInternalLogic__c = 'Neither';


            //Megha: code changes starts started below for Aug story: Mail In
            if (altReturnAddressFlag != null) { //added by dattaa1 for nullcheck 5324405
                createddDefault.work_order__r.Alternate_Return_Address_Checkbox__c = altReturnAddressFlag;
            }
            createddDefault.work_order__r.Alternate_Return_Postal_Code__c = altReturnAddressPostalCode;
            createddDefault.work_order__r.Alternate_Return_Street__c = altReturnAddressStreet;
            createddDefault.work_order__r.Alternate_Return_City__c = altReturnAddressCity;
            createddDefault.work_order__r.Alternate_Return_State__c = altReturnAddressState;
            createddDefault.work_order__r.Alternate_Return_Country__c = altReturnAddressCountry;
            //Megha: code changes done here 

            // Update Work Order Record

            //if KYHDFlag is Changed to True validate if info Parts need to be added.
            if (KYHDFlagChangedTrue && recordId != null) {
                DispatchDefaultsConfiguration.checkHardDriveParts(recordId, KYHDFlagChangedTrue);
            }
            
            
            
            update createddDefault.work_order__r;

            // Update Dispatch Defaults Record

            update createddDefault;

            // if Service Type is Labor Only - Delete Parts
            if (string.isNotEmpty(serTypeValue) && serTypeValue.equalsIgnoreCase('Labor Only')) {
                queryPartsAndDelete(recordId);
            }


            if (dSPOverideValue == true) {
                // Check if dspInstrnRecId has Instruction record Id
                if (string.isNotEmpty(dspInstrnRecId)) {
                    DispatchInstruction__c getInstruct = new DispatchInstruction__c();

                    getInstruct = [SELECT Id, Work_Order__c, Name, Receiver__c, Type__c, Instruction__c
                        FROM DispatchInstruction__c WHERE Id =: dspInstrnRecId LIMIT 1
                    ];

                    getInstruct.Instruction__c = instructions;
                    //getInstruct.Type__c = 'Service Provider';
                    getInstruct.Type__c = 'General Comment';
                    //getInstruct.Receiver__c = 'DELL';
                    getInstruct.Receiver__c = 'All Providers';



                    // Update Instruction record
                    update getInstruct;

                    InstructRecId = getInstruct.Id;
                } else {
                    DispatchInstruction__c createInstruct = new DispatchInstruction__c();

                    createInstruct.DSP_Override_Request__c = true;
                    createInstruct.Instruction__c = instructions;
                    createInstruct.Work_Order__c = createddDefault.work_order__c;
                    //createInstruct.Type__c = 'Service Provider';
                    createInstruct.Type__c = 'General Comment';
                    //createInstruct.Receiver__c = 'DELL';
                    createInstruct.Receiver__c = 'All Providers';
                    
                    //createInstruct.Vendor_Instructions__c = true; Megha commented this statement for defect 5661427 fix


                    // Create New Instruction record
                    insert createInstruct;

                    InstructRecId = createInstruct.Id;
                }
                uWrap.instructRecid = InstructRecId;
            } else {
                if (string.isNotEmpty(dspInstrnRecId)) {
                    DispatchInstruction__c existDispInst = new DispatchInstruction__c();
                    existDispInst = [SELECT Id, Name FROM DispatchInstruction__c WHERE Id =: dspInstrnRecId LIMIT 1];
                    if (existDispInst != null) {
                        delete existDispInst;
                        uWrap.instructRecid = '';
                    }
                }
            }

            //code for AD Instruction

            if (accDamageFlag && createddDefault != null && createddDefault.work_order__c != null) {
                List < DispatchInstruction__c > getADInstruct = [select Id, Is_Type_CompleteCareOption__c from DispatchInstruction__c where Is_Type_CompleteCareOption__c = true and Work_Order__c =: createddDefault.work_order__c limit 50000];
                if (getADInstruct.isempty()) {
                    DispatchInstruction__c newADInstruct = new DispatchInstruction__c();
                    newADInstruct.Is_Type_CompleteCareOption__c = true;
                    newADInstruct.Instruction__c = 'Dell Troubleshooting Log: AD';
                    newADInstruct.Work_Order__c = createddDefault.work_order__c;
                    newADInstruct.Receiver__c = 'All Providers';
                    newADInstruct.Type__c = 'General Comment';
                    newADInstruct.Vendor_Instructions__c = true;
                    insert newADInstruct;
                }
            } else {
                //taken care in process builder
            }
            //code for AD Instruction ends here
            //serviceTypeInstructions(serTypeValue,recordId,createddDefault.Work_Order__r.Region__c);

            uWrap.defaultDispRecId = createddDefault.Id;
            uWrap.errorMessage = '';

            // return the Instruction Record Id
            return uWrap;
        } catch (exception e) {
            updateWrapper uWrap = new updateWrapper();
            uWrap.instructRecid = '';
            uWrap.defaultDispRecId = '';
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,') && e.getMessage().contains(':')) {
                uWrap.errorMessage = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ':');
            }
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'updateDefaultsRecord', 'Dispatch Management');
            return uWrap;
        }
    }

    /* Get Available Options from Mastero when you check billable flag to true (or) change in Service Type */
    @AuraEnabled
    public static optionsWrapper getBillToAvailableOptions(string recordId, string billToFlag, string serviceType, string selectedServiceOption, string DASP) {
        try {
            string defaultServOption = '';
            string DASPFlag = 'N';

            DispatchDefaults__c dispatchDefault;

            List < String > options = new list < String > ();

            dispatchDefault = [SELECT Default_Service_Type__c, Service_Type__c, ServiceLevel__c, ServiceHours__c, LOB__c, Work_Order__r.ServiceTag__c, Service_Configurations__c,AvailableCoverages__c,selected_service_option__c,
                Work_Order__r.Region__c, Work_Order__r.BUID__c, Work_Order__r.LOB__c, Work_Order__r.CityCalc__c, Work_Order__r.StateCalc__c,
                Work_Order__r.State, Work_Order__r.PostalCode, Work_Order__r.Country, Work_Order__r.CountryCode__c,
                Work_Order__r.CountryCode, PartsCountry__c, BUID__c, CompleteCareOption__c, LaborCountry__c,KYHDOption__c, OutOfWarranty__c, Work_Order__r.Id, WorK_Order__r.DASP__c
                FROM DispatchDefaults__c WHERE Work_Order__c =: recordId LIMIT 1
            ];
            // Added Work_Order__r.City in SOQL Query to fix - DEFECT 6037787

            list < AvailableOptions__x > listObject = new list < AvailableOptions__x > ();
           
            
            
            listObject = (!mockedAvailableOptions.isEmpty()) ? mockedAvailableOptions : [SELECT AvailableOptions__c, ProviderCode__c, DefaultAvailableOptions__c, ResponseCode__c, ResponseMessage__c FROM AvailableOptions__x
                WHERE ServiceTagId__c =: dispatchDefault.Work_Order__r.ServiceTag__c AND BUID__c =: dispatchDefault.Work_Order__r.BUID__c
                AND Country__c =: dispatchDefault.Work_Order__r.CountryCode AND City__c =: dispatchDefault.Work_Order__r.CityCalc__c
                AND State__c =: dispatchDefault.Work_Order__r.StateCalc__c AND LOB__c =: dispatchDefault.LOB__c AND Region__c =: dispatchDefault.Work_Order__r.Region__c
                AND PostalCode__c =: dispatchDefault.Work_Order__r.PostalCode AND Billable__c =: billToFlag AND ServiceType__c =: serviceType
                AND ServiceLevel__c =: dispatchDefault.ServiceLevel__c AND ServiceHours__c =: dispatchDefault.ServiceHours__c AND MonitorCall__c = 'N' AND 
                DASP__c = : DASPFlag
                LIMIT 50
            ];


            optionsWrapper oWrap = new optionsWrapper();

            if (listObject.size() > 0) {

                oWrap.responseCode = listObject[0].ResponseCode__c;
                oWrap.responseMessage = listObject[0].ResponseMessage__c;

                //default Option
                /*
                if (String.isNotEmpty(listObject[0].DefaultAvailableOptions__c)) {
                    oWrap.defaultOption = listObject[0].DefaultAvailableOptions__c;
                }
                */

                if ((billToFlag.equalsIgnoreCase('Y')) && listObject[0].DefaultAvailableOptions__c != null && listObject[0].DefaultAvailableOptions__c != 'null' && listObject[0].DefaultAvailableOptions__c.length() > 2) {
                    defaultServOption = listObject[0].DefaultAvailableOptions__c;
                } else {
                    //defaultServOption = dispatchDefault.ServiceLevel__c + '-' +  dispatchDefault.ServiceHours__c;//commented by Dattaa1 service Option
                    defaultServOption = listObject[0].AvailableOptions__c;
                }
                //dattaa1-5594679 starts
                if(String.isEmpty(defaultServOption) && String.isNotEmpty(dispatchDefault.selected_service_option__c)){
                    defaultServOption = dispatchDefault.selected_service_option__c;                    
                }
                //dattaa1-5594679 ends
                if (String.isNotEmpty(defaultServOption)) {
                    oWrap.defaultOption = defaultServOption;
                }

                for (AvailableOptions__x itemObject: listObject) {
                    if (String.isNotEmpty(itemObject.AvailableOptions__c)) {
                        options.add(itemObject.AvailableOptions__c);
                    }
                }
                //dattaa1-5594679 starts
                if(options.isempty() && String.isNotEmpty(dispatchDefault.AvailableCoverages__c)){
                    string ops = dispatchDefault.AvailableCoverages__c.replace('||', ',');
                    options = DispatchDefaultsConfiguration.RemoveNull(ops.split(','));
                }
                //dattaa1-5594679 ends
                // Modified by Harsha Reddy
                if (!options.contains(defaultServOption) && billToFlag.equalsIgnoreCase('Y')) {
                    options.add(defaultServOption);
                }
                oWrap.availableOptions = options;
            }
            if(string.isNotBlank(selectedServiceOption) && selectedServiceOption.contains('-')){                
                dispatchDefault.ServiceHours__c = selectedServiceOption.split('-')[1];
                dispatchDefault.ServiceLevel__c = selectedServiceOption.split('-')[0];
            } else if(string.isNotBlank(defaultServOption) && defaultServOption.contains('-')) {
                dispatchDefault.ServiceHours__c = defaultServOption.split('-')[1];
                dispatchDefault.ServiceLevel__c = defaultServOption.split('-')[0];
            }
            /*
            if (!string.isBlank(defaultServOption) && defaultServOption.contains('-')) {
                dispatchDefault.ServiceHours__c = defaultServOption.split('-')[1];
                dispatchDefault.ServiceLevel__c = defaultServOption.split('-')[0];
            }
            */
            dispatchDefault.Service_Type__c = serviceType;
            oWrap.categoryOptions = getDispatchCategoryOptions(dispatchDefault, dispatchDefault.Work_Order__r.Id, null);


            return oWrap;
        } catch (exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getBillToAvailableOptions', 'Dispatch Management');
            return null;
        }
    }

    @AuraEnabled
    public static GetSLADates__x getEntitlementSLA(string wONumber, string serviceOpt, string pCode, string country,string state_code) {
        try {
            string serviceLevel = '';
            string serviceHour = '';
            string countryValue = '';
            // Delta accepts- country code USA not US.
            // Query on Custom Metadata Type  - Asset_Country_mdt
            if (string.isNotEmpty(country)) {
                List < Asset_Country__mdt > assetCountryMDT = [SELECT Label FROM Asset_Country__mdt WHERE CountryCode__c =: country LIMIT 50000];
                if (null != assetCountryMDT && assetCountryMDT.size() > 0)
                    countryValue = assetCountryMDT[0].Label;
            }

            //split country service Option into ServiceLevel & ServiceHour
            if (serviceOpt.contains('-')) {
                serviceLevel = serviceOpt.substringBeforeLast('-');
                serviceHour = serviceOpt.substringAfterLast('-');
            }
			// for US and postal code having -
			if ( string.isNotEmpty(country) && country.equalsIgnoreCase('US') && pCode.contains('-')) {
                pCode = pCode.substringBeforeLast('-');
            }
            
            List < GetSLADates__x > slaDateList = new List < GetSLADates__x > ();

            if (!Test.isRunningTest()) {
                slaDateList = [SELECT SLAStartDate__c, SLAEndDate__c, ResponseCode__c, TimeZone__c, ShiftStart__c, ShiftEnd__c, ResponseMessage__c FROM GetSLADates__x
                    WHERE ServiceHours__c =: serviceHour AND ServiceLevel__c =: serviceLevel AND Country__c =: countryValue
                    AND PostalCode__c =: pCode AND ServiceOption__c =: serviceOpt AND WorkOrderNumber__c =: wONumber AND StateCode__c =: state_code LIMIT 1
                ];
            } else {
                slaDateList.add(new GetSLADates__x(SLAStartDate__c = '2018-04-14T00:00:00', SLAEndDate__c = '2018-04-14T23:59:00',
                    ResponseCode__c = '100', TimeZone__c = '(GMT-08:00) Pacific Time (US & Canada); Tijuana', ResponseMessage__c = 'Sucess'));
                slaDateList.add(new GetSLADates__x(SLAStartDate__c = '2018-04-14T00:00:00', SLAEndDate__c = '2018-04-14T23:59:00',
                    ResponseCode__c = '100', ResponseMessage__c = 'Sucess'));
                slaDateList.add(new GetSLADates__x(SLAStartDate__c = '2018-04-14T00:00:00', SLAEndDate__c = '2018-04-14T23:59:00',
                    ResponseCode__c = '100', ResponseMessage__c = 'Sucess'));
            }
            return slaDateList[0];
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getEntitlementSLA', 'Dispatch Management');
            return null;
        }
    }

    @AuraEnabled
    public static defaultWrapper updateDispatchDefaults(Id workOrderId, Id dDefaultRecId) {
        try {
            defaultWrapper dWrap = new defaultWrapper();

            List < WorkOrder > workOrderList = new List < WorkOrder > ();
            workOrderList = [SELECT ServiceTag__c, BUID__c,DPS_BUID__C, City,cityCalc__c,State, Country, CountryCode, OrderNumber__c, CustomerNumber__c, StateCalc__c,CustomerRegion__c,
                LOB__c, Region__c, PostalCode, ScheduleStartDate__c FROM WorkOrder WHERE Id =: workOrderId LIMIT 1
            ];

            GetDispatchDefaults__x getDspDefault = getDispatchDefaut(workOrderList[0]);
            List<String> DASPEMEACountry =new List<String>{'AL','DZ','AO','AZ','BH','BA','BW','BG','HR','CY','EG','EE','ET','GH','HU','IS','IQ','IL','CI','JO','KZ','KE','KW','LV','LB','LY','LT','MK','MU','MA','MZ','NA','MG','OM','QA','RO','RU','RW','SA','RS','SI','TZ','TN','TR','UG','UA','AE','YE'};

            // cancel existing schedule date
            if (workOrderList[0].ScheduleStartDate__c != '') {
                SlotsController.cancelScheduledSlot(workOrderId);
            }

            if (getDspDefault != null) {
                string dDefaultId = updateDispatchDefaults(getDspDefault, workOrderId, dDefaultRecId);
                if (dDefaultId != null) {
                    DispatchDefaults__c createddDefault = [SELECT Id, Entitlement_Details__c, Service_Options_Picklist_values__c, Service_Type__c, PO_Number__c, selected_service_option__c, category__c, OutOfWarranty__c,
                        Service_Configurations__c, SpecialOptions__c, Bill_To__c, Keep_Your_Components__c, DSP_Override_Request__c, AvailableCoverages__c, Default_Service_Type__c,
                        CompleteCareOption__c, OrderNumber__c, work_Order__r.OrderNumber__c, Work_Order__r.CountryCode, Bill_To_Order_Number__c, KYHDOption__c, AvailableOptions__c, Billable__c,Complete_Care_Option__c, work_order__r.DPS_Sub_Region__c
                        FROM DispatchDefaults__c WHERE Id =: dDefaultId LIMIT 1
                    ];

                    if (String.isNotEmpty(createddDefault.AvailableCoverages__c)) {
                        string ops = createddDefault.AvailableCoverages__c.replace('||', ',');
                        dWrap.serviceOptions = DispatchDefaultsConfiguration.RemoveNull(ops.split(','));
                    }

                    dWrap.serviceTypeOptions = getServiceTypeByOrder(createddDefault.Default_Service_Type__c, createddDefault.Billable__c,createddDefault.work_order__r.DPS_Sub_Region__c,createddDefault.Bill_To__c);
                    dWrap.serviceType = createddDefault.Service_Type__c;
                    dWrap.specialOpnsValue = createddDefault.SpecialOptions__c;
                    dWrap.productClassification = createddDefault.Service_Configurations__c;
                    dWrap.selectedServiceOpt = createddDefault.selected_service_option__c;
                    dWrap.billTo = createddDefault.Bill_To__c;
                    dwrap.orderNumber = createddDefault.Bill_To_Order_Number__c;
                    dwrap.accidentalDamage = createddDefault.CompleteCareOption__c;
                    dWrap.keepYComp = createddDefault.Keep_Your_Components__c;
                    dWrap.dSPOverideReq = createddDefault.DSP_Override_Request__c;
                    dWrap.outOfWarranty = createddDefault.outOfWarranty__c;
                    dWrap.KYHDFlag = createddDefault.KYHDOption__c;
                    dWrap.entitlementDetails = createddDefault.Entitlement_Details__c;
                    dWrap.DASPValues = getDASPValue(createddDefault.Work_Order__r.CountryCode);
                    
                    if (String.isNotEmpty(createddDefault.AvailableOptions__c)) {
                        if (createddDefault.AvailableOptions__c.contains('-')) {
                            dWrap.locationCoverageLevel = createddDefault.AvailableOptions__c.substringBeforeLast('-');
                        }
                    }
                    

                    if((workOrderList[0].Region__c == '2' && DASPEMEACountry.contains(workOrderList[0].CountryCode)))
                    {
                        dWrap.DASPFlag = true;
                    }
                    else
                    {
                        dWrap.DASPFlag = false;
                    }
                }

            }

            return dWrap;
        } catch (exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'updateDispatchDefaults', 'Dispatch Management');
            return null;
        }
    }

    public static GetDispatchDefaults__x getDispatchDefaut(WorkOrder wOrderRecord) {
        try {

            list < GetDispatchDefaults__x > listDefault = new list < GetDispatchDefaults__x > ();


            listDefault = (!mockedGetDispatchDefaults.isEmpty()) ? mockedGetDispatchDefaults : [SELECT AvailableOptions__c, BasicEntitlement__c, Billable__c, BUID__c, CallType__c, CustomSKU__c, Category__c, City__c, CompleteCareOption__c,
                Country__c, CustomerNumber__c, CustomerPreference__c, DataRecovery__c, DefaultCallType__c, DefaultDPSType__c, DefaultDSP__c, DefaultSKU__c,
                CustomerRegionId__c, DigitalEntitlements__c, DLP__c, DPSType__c, DSP__c, EntitlementId__c, EntitlementName__c, ErrorCode__c, GroundShipFlg__c,
                ISPWarrantyOrderBUID__c, ISPWarrantyOrderNum__c, KYCOption__c, KYHDOption__c, LaborCountry__c, LOB__c, MaxCapabilityDLP__c, MaxCapabilityServiceHours__c,
                MaxCapabilityServiceLevel__c, MaxCapabilityServiceSubType__c, OconusDispatch__c, OrderNumber__c, OutOfHours__c, OutOfWarranty__c, PartsCountry__c,
                PostalCode__c, PPID__c, PremierCode__c, PremierType__c, ProSupport__c, Region__c, ReverseAgency__c, ServiceHours__c, ServiceLevel__c, ServiceTagId__c,
                ServiceType__c, SKUNumber__c, State__c, UserID__c, uuid__c, WarningMessage__c, WarrantyEndDate__c, AvailableCoverages__c FROM GetDispatchDefaults__x
                WHERE ServiceTagId__c =: wOrderRecord.ServiceTag__c AND BUID__c =: wOrderRecord.DPS_BUID__C AND City__c =: wOrderRecord.CityCalc__c
                AND State__c =: wOrderRecord.StateCalc__c AND OrderNumber__c =: wOrderRecord.OrderNumber__c AND CustomerNumber__c =: wOrderRecord.CustomerNumber__c
                AND Country__c =: wOrderRecord.CountryCode AND LOB__c =: wOrderRecord.LOB__c AND Region__c =: wOrderRecord.Region__c and CustomerRegionId__c=:wOrderRecord.CustomerRegion__c
                AND PostalCode__c =: wOrderRecord.PostalCode LIMIT 1
            ];
            //system.debug('inside getdispatdefaut'+ listDefault[0]);
            return listDefault[0];
        } catch (exception e) {  ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getDispatchDefaut', 'Dispatch Management');
            return null;
        }
    }

    public static string updateDispatchDefaults(GetDispatchDefaults__x inputList, Id workOrderId, Id dDefaultId) {
        try {
            string defaultServOption = '';

            DispatchDefaults__c dDefaultToUpdate = new DispatchDefaults__c(Id = dDefaultId);

            WorkOrder wOrder = new WorkOrder(Id = workOrderId);

            wOrder.Service_Type__c = null;
            wOrder.DASP__c = null;
            
            wOrder.DSP__c = null;
            wOrder.schedulingInternalLogic__c = 'Neither';
            dDefaultToUpdate.Service_Type__c = null;
            dDefaultToUpdate.selected_service_option__c = null;
            dDefaultToUpdate.Bill_To__c = null;

            if (String.isNotEmpty(inputList.AvailableOptions__c)) {
                dDefaultToUpdate.AvailableOptions__c = inputList.AvailableOptions__c;
                if (inputList.AvailableOptions__c.contains('-')) {
                    dDefaultToUpdate.MaxCapabilityServiceHours__c = inputList.AvailableOptions__c.substringAfterLast('-');
                    dDefaultToUpdate.MaxCapabilityServiceLevel__c = inputList.AvailableOptions__c.substringBeforeLast('-');
                }
            }

            //if (String.isNotEmpty(inputList.ServiceHours__c) && String.isNotEmpty(inputList.ServiceLevel__c)){
            //defaultServOption = inputList.ServiceLevel__c+'-'+inputList.ServiceHours__c; //commented by dattaa1
            //}

            if (String.isNotEmpty(defaultServOption)) {
                dDefaultToUpdate.selected_service_option__c = defaultServOption;
                wOrder.Service_Option__c = defaultServOption;
            }
            /*
            if(string.isNotEmpty(inputList.AvailableOptions__c)){
                dDefaultToUpdate.selected_service_option__c = inputList.AvailableOptions__c;
                wOrder.Service_Option__c = inputList.AvailableOptions__c;
            }
            */
            if (string.isNotEmpty(inputList.Billable__c)) {
                dDefaultToUpdate.Billable__c = inputList.Billable__c;
            }
            if (string.isNotEmpty(inputList.BUID__c)) {
                dDefaultToUpdate.BUID__c = inputList.BUID__c;
            }
            if (string.isNotEmpty(inputList.CallType__c)) {
                dDefaultToUpdate.CallType__c = inputList.CallType__c;
            }
            if (string.isNotEmpty(inputList.CustomSKU__c)) {
                dDefaultToUpdate.CustomSKU__c = inputList.CustomSKU__c;
            }
            if (string.isNotEmpty(inputList.Category__c)) {
                dDefaultToUpdate.SpecialOptions__c = inputList.Category__c;
            }
            if (string.isNotEmpty(inputList.City__c)) {
                dDefaultToUpdate.City__c = inputList.City__c;
            }
            if (string.isNotEmpty(inputList.Country__c)) {
                dDefaultToUpdate.Country__c = inputList.Country__c;
            }
            if (string.isNotEmpty(inputList.CustomerNumber__c)) {
                dDefaultToUpdate.CustomerNumber__c = inputList.CustomerNumber__c;
            }
            if (string.isNotEmpty(inputList.CustomerPreference__c)) {
                dDefaultToUpdate.CustomerPreference__c = inputList.CustomerPreference__c;
            }
            if (string.isNotEmpty(inputList.DefaultCallType__c)) {
                dDefaultToUpdate.DefaultCallType__c = inputList.DefaultCallType__c;
            }
            if (string.isNotEmpty(inputList.DefaultDPSType__c)) {
                dDefaultToUpdate.DefaultDPSType__c = inputList.DefaultDPSType__c;
            }
            if (string.isNotEmpty(inputList.DefaultDSP__c)) {
                dDefaultToUpdate.DefaultDSP__c = inputList.DefaultDSP__c;
            }
            if (string.isNotEmpty(inputList.DefaultSKU__c)) {
                dDefaultToUpdate.DefaultSKU__c = inputList.DefaultSKU__c;
            }
            if (string.isNotEmpty(inputList.CustomerRegionId__c)) {
                dDefaultToUpdate.CustomerRegionId__c = inputList.CustomerRegionId__c;
            }
            if (string.isNotEmpty(inputList.DLP__c)) {
                dDefaultToUpdate.DLP__c = inputList.DLP__c;
            }
            if (string.isNotEmpty(inputList.DPSType__c)) {
                dDefaultToUpdate.DPSType__c = inputList.DPSType__c;
            }
            if (string.isNotEmpty(inputList.DSP__c)) {
                dDefaultToUpdate.DSP__c = inputList.DSP__c;
            }
            if (string.isNotEmpty(inputList.EntitlementId__c)) {
                dDefaultToUpdate.EntitlementId__c = inputList.EntitlementId__c;
            }
            if (string.isNotEmpty(inputList.EntitlementName__c)) {
                dDefaultToUpdate.EntitlementName__c = inputList.EntitlementName__c;
            }
            if (string.isNotEmpty(inputList.ErrorCode__c)) {
                dDefaultToUpdate.ErrorCode__c = inputList.ErrorCode__c;
            }
            if (string.isNotEmpty(inputList.GroundShipFlg__c)) {
                dDefaultToUpdate.GroundShipFlg__c = inputList.GroundShipFlg__c;
            }
            if (string.isNotEmpty(inputList.ISPWarrantyOrderBUID__c)) {
                dDefaultToUpdate.ISPWarrantyOrderBUID__c = inputList.ISPWarrantyOrderBUID__c;
            }
            if (string.isNotEmpty(inputList.ISPWarrantyOrderNum__c)) {
                dDefaultToUpdate.ISPWarrantyOrderNum__c = inputList.ISPWarrantyOrderNum__c;
            }
            if (string.isNotEmpty(inputList.LaborCountry__c)) {
                dDefaultToUpdate.LaborCountry__c = inputList.LaborCountry__c;
            }
            if (string.isNotEmpty(inputList.LOB__c)) {
                dDefaultToUpdate.LOB__c = inputList.LOB__c;
            }
            if (string.isNotEmpty(inputList.MaxCapabilityDLP__c)) {
                dDefaultToUpdate.MaxCapabilityDLP__c = inputList.MaxCapabilityDLP__c;
            }
            /*
            if(string.isNotEmpty(inputList.MaxCapabilityServiceHours__c)){
                dDefaultToUpdate.MaxCapabilityServiceHours__c = inputList.MaxCapabilityServiceHours__c;
            }
            if(string.isNotEmpty(inputList.MaxCapabilityServiceLevel__c)){
                dDefaultToUpdate.MaxCapabilityServiceLevel__c = inputList.MaxCapabilityServiceLevel__c;
            }
            */
            if (string.isNotEmpty(inputList.MaxCapabilityServiceSubType__c)) {
                dDefaultToUpdate.MaxCapabilityServiceSubType__c = inputList.MaxCapabilityServiceSubType__c;
            }
            if (string.isNotEmpty(inputList.OconusDispatch__c)) {
                dDefaultToUpdate.OconusDispatch__c = inputList.OconusDispatch__c;
            }
            if (string.isNotEmpty(inputList.OrderNumber__c)) {
                dDefaultToUpdate.OrderNumber__c = inputList.OrderNumber__c;
            }
            if (string.isNotEmpty(inputList.PartsCountry__c)) {
                dDefaultToUpdate.PartsCountry__c = inputList.PartsCountry__c;
            }
            if (string.isNotEmpty(inputList.PostalCode__c)) {
                dDefaultToUpdate.PostalCode__c = inputList.PostalCode__c;
            }
            if (string.isNotEmpty(inputList.PPID__c)) {
                dDefaultToUpdate.PPID__c = inputList.PPID__c;
            }
            if (string.isNotEmpty(inputList.PremierCode__c)) {
                dDefaultToUpdate.PremierCode__c = inputList.PremierCode__c;
            }
            if (string.isNotEmpty(inputList.PremierType__c)) {
                dDefaultToUpdate.PremierType__c = inputList.PremierType__c;
            }
            if (string.isNotEmpty(inputList.Region__c)) {
                dDefaultToUpdate.Region__c = inputList.Region__c;
            }
            if (string.isNotEmpty(inputList.ServiceHours__c)) {
                dDefaultToUpdate.ServiceHours__c = inputList.ServiceHours__c;
            }
            if (string.isNotEmpty(inputList.ServiceLevel__c)) {
                dDefaultToUpdate.ServiceLevel__c = inputList.ServiceLevel__c;
            }
            if (string.isNotEmpty(inputList.ServiceTagId__c)) {
                dDefaultToUpdate.ServiceTagId__c = inputList.ServiceTagId__c;
            }
            if (string.isNotEmpty(inputList.ServiceType__c)) {
                dDefaultToUpdate.Default_Service_Type__c = inputList.ServiceType__c;
            }
            if (string.isNotEmpty(inputList.SKUNumber__c)) {
                dDefaultToUpdate.SKUNumber__c = inputList.SKUNumber__c;
            }
            if (string.isNotEmpty(inputList.State__c)) {
                dDefaultToUpdate.State__c = inputList.State__c;
            }
            if (string.isNotEmpty(inputList.UserID__c)) {
                dDefaultToUpdate.UserID__c = inputList.UserID__c;
            }
            if (string.isNotEmpty(inputList.uuid__c)) {
                dDefaultToUpdate.uuid__c = inputList.uuid__c;
            }
            if (string.isNotEmpty(inputList.WarningMessage__c)) {
                dDefaultToUpdate.WarningMessage__c = inputList.WarningMessage__c;
            }
            if (string.isNotEmpty(inputList.WarrantyEndDate__c)) {
                dDefaultToUpdate.WarrantyEndDate__c = inputList.WarrantyEndDate__c;
            }
            /*
            if(string.isNotEmpty(inputList.AvailableCoverages__c)){
                dDefaultToUpdate.AvailableCoverages__c = inputList.AvailableCoverages__c;
            }
            */
            if (string.isNotEmpty(inputList.ReverseAgency__c) && inputList.ReverseAgency__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.ReverseAgency__c = True;
            }
            if (string.isNotEmpty(inputList.ProSupport__c) && inputList.ProSupport__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.ProSupport__c = True;
            }
            if (string.isNotEmpty(inputList.KYCOption__c) && inputList.KYCOption__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.Keep_Your_Components__c = True;
                dDefaultToUpdate.Entitlement_Details__c += '|KYC|';
            }
            if (string.isNotEmpty(inputList.KYHDOption__c) && inputList.KYHDOption__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.KYHDOption__c = True;
                if (string.isNotBlank(dDefaultToUpdate.Entitlement_Details__c))
                    if (!dDefaultToUpdate.Entitlement_Details__c.contains('KYHD'))
                        dDefaultToUpdate.Entitlement_Details__c += '|KYHD|';
                    else
                        dDefaultToUpdate.Entitlement_Details__c = '|KYHD|';
            }
            if (string.isNotEmpty(inputList.OutOfHours__c) && inputList.OutOfHours__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.OutOfHours__c = True;
            }
            if (string.isNotEmpty(inputList.OutOfWarranty__c) && inputList.OutOfWarranty__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.OutOfWarranty__c = True;
            }
            if (string.isNotEmpty(inputList.DigitalEntitlements__c) && inputList.DigitalEntitlements__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.DigitalEntitlements__c = True;
            }
            if (string.isNotEmpty(inputList.CompleteCareOption__c) && inputList.CompleteCareOption__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.DataRecovery__c = True;
            }
            if (string.isNotEmpty(inputList.CompleteCareOption__c) && inputList.CompleteCareOption__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.CompleteCareOption__c = True;
            }
            if (string.isNotEmpty(inputList.BasicEntitlement__c) && inputList.BasicEntitlement__c.equalsIgnoreCase('Y')) {
                dDefaultToUpdate.BasicEntitlement__c = True;
            }

            if (inputList.AvailableCoverages__c != null && !string.isNotEmpty(defaultServOption) && inputList.AvailableCoverages__c.contains(defaultServOption)) { //updated by Dattaa1
                dDefaultToUpdate.AvailableCoverages__c = inputList.AvailableCoverages__c;
            } else {
                if (!string.isNotEmpty(defaultServOption)) {
                    dDefaultToUpdate.AvailableCoverages__c = inputList.AvailableCoverages__c + '||' + defaultServOption;
                }
            }

            // updating Work order Record
            update wOrder;

            // updating Dispatch Defaults Record
            update dDefaultToUpdate;
            
            // update AD Alert if any
            //EinsteinAlertController.adAlertByDispatch(wOrder.Id, dDefaultToUpdate.Id);

            return dDefaultToUpdate.Id;
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'createDispatchDefaults', 'Dispatch Management');
            return null;
        }
    }
    //Archana Giliyar added for US 5509615
    @AuraEnabled
  public static optionsWrapper getWOdata(Id WorkOrderId, string ServiceType, string SvcOptions, string DASP) {
  try{
    optionsWrapper oWrap1 = new optionsWrapper();
        List < String > Spcloptions = new list < String > ();
        if(WorkOrderId != null)
    {
      DispatchDefaults__c dispatchRec;
      dispatchRec  =  [SELECT Default_Service_Type__c, Service_Type__c, ServiceLevel__c, ServiceHours__c, LOB__c, Work_Order__r.ServiceTag__c, Service_Configurations__c,
                Work_Order__r.Region__c, Work_Order__r.BUID__c, Work_Order__r.LOB__c, Work_Order__r.City, Work_Order__r.StateCalc__c,
                Work_Order__r.State, Work_Order__r.PostalCode, Work_Order__r.Country, Work_Order__r.CountryCode__c,
                Work_Order__r.CountryCode, PartsCountry__c, BUID__c, CompleteCareOption__c, LaborCountry__c,
                KYHDOption__c, OutOfWarranty__c, Work_Order__r.Id, Work_Order__r.DASP__c
                FROM DispatchDefaults__c WHERE Work_Order__c =: WorkOrderId LIMIT 1
            ];
      if(ServiceType  != null)
        dispatchRec.Service_Type__c = ServiceType;
      if(SvcOptions  != null)
      {
        dispatchRec.ServiceHours__c = SvcOptions.split('-')[1];
                dispatchRec.ServiceLevel__c = SvcOptions.split('-')[0];
      }
      if(DASP  != null) 
        dispatchRec.Work_Order__r.DASP__c = DASP;
      oWrap1.CategoryOptions  =  getDispatchCategoryOptions(dispatchRec, WorkOrderId, null);
            if(oWrap1.CategoryOptions.size() > 0)
                oWrap1.responsecode  =  '100';
            else
                oWrap1.responsecode  =  '-103';
      system.debug('Spcloptions--->>>'+ oWrap1);    
    }
    return  oWrap1;
  }
   catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getWOdata', 'Dispatch Management');
            return null;
  }
    }
    public static List < string > getDispatchCategoryOptions(DispatchDefaults__c dispatchDefaultRec, Id WorkOrderId, GetDispatchDefaults__x dispatchDefault_Odata) {
        try {
            if (dispatchDefault_Odata != null) {
                system.debug('Inside If-->> 1543');
                dispatchDefaultRec = new DispatchDefaults__c();
                if (String.isNotEmpty(dispatchDefault_Odata.PartsCountry__c)) {
                    dispatchDefaultRec.PartsCountry__c = dispatchDefault_Odata.PartsCountry__c;
                }
                if (String.isNotEmpty(dispatchDefault_Odata.BUID__c)) {
                    dispatchDefaultRec.BUID__c = dispatchDefault_Odata.BUID__c;
                }                
                if (String.isNotEmpty(dispatchDefault_Odata.ServiceHours__c)) {
                    dispatchDefaultRec.ServiceHours__c = dispatchDefault_Odata.ServiceHours__c;
                }
                if (String.isNotEmpty(dispatchDefault_Odata.ServiceType__c)) {
                    dispatchDefaultRec.Service_Type__c = dispatchDefault_Odata.ServiceType__c;
                }
                if (String.isNotEmpty(dispatchDefault_Odata.CompleteCareOption__c)) {
                    if (dispatchDefault_Odata.CompleteCareOption__c.equalsIgnoreCase('Y')) {
                        dispatchDefaultRec.CompleteCareOption__c = True;
                    }
                }
                if (String.isNotEmpty(dispatchDefault_Odata.LaborCountry__c)) {
                    dispatchDefaultRec.LaborCountry__c = dispatchDefault_Odata.LaborCountry__c;
                }
                if (String.isNotEmpty(dispatchDefault_Odata.ServiceLevel__c)) {
                    dispatchDefaultRec.ServiceLevel__c = dispatchDefault_Odata.ServiceLevel__c;
                }
                if (String.isNotEmpty(dispatchDefault_Odata.KYHDOption__c)) {
                    if (dispatchDefault_Odata.KYHDOption__c.equalsIgnoreCase('Y')) {
                        dispatchDefaultRec.KYHDOption__c = True;
                    }
                }
                if (String.isNotEmpty(dispatchDefault_Odata.OutOfWarranty__c)) {
                    if (dispatchDefault_Odata.OutOfWarranty__c.equalsIgnoreCase('Y')) {
                        dispatchDefaultRec.OutOfWarranty__c = True;
                    }
                }
            }
            List < string > categoryList = new List < string > ();
            if (dispatchDefaultRec != null && WorkOrderId != null) {
                WorkOrder workOrderRec = [SELECT ServiceTag__c, BUID__c, City,cityCalc__c, State, Country, CountryCode, OrderNumber__c, CustomerNumber__c, LOB__c, Region__c, PostalCode, StateCalc__c
                    FROM WorkOrder WHERE Id =: workOrderId LIMIT 1
                ];
                Set < string > categorySet = new Set < string > ();

                string ActivityType = 'Break Fix'; //dispatchDefaultRec.;//'Break Fix' ; 
                string PartsCountry = dispatchDefaultRec.PartsCountry__c; //'' ; 
                string AddressBUID = dispatchDefaultRec.BUID__c; //'11' ;  
                string ServiceHours = dispatchDefaultRec.ServiceHours__c; //'10x5' ; 
                //string ServiceType = dispatchDefaultRec.Default_Service_Type__c;//'Parts Only' ;
                string ServiceType = dispatchDefaultRec.Service_Type__c; //'Parts Only' ;
                string DASP = 'N'; //dispatchDefaultRec.;//'N' ; 
                //string CompleteCareOption = (dispatchDefaultRec.CompleteCareOption__c == true) ? 'Y':'N';//'N' ;

                // Accidental Damage Flag
                string CompleteCareOption = 'N';

                string LaborCountry = dispatchDefaultRec.LaborCountry__c; //'' ;
                string SystemClassification = dispatchDefaultRec.Service_Configurations__c; //dispatchDefaultRec.;//'Notebook' ; 
                string AddressRegionId =   workOrderRec.Region__c;    //'1'; //dispatchDefaultRec.;//'1' ;
                string City = workOrderRec.cityCalc__c; //'Miami' ; 
                string ServiceLevel = dispatchDefaultRec.ServiceLevel__c; //'Next Business Day' ;
                string State = workOrderRec.StateCalc__c; //'FL' ;
                string ZipCode = workOrderRec.PostalCode; //'33193' ;
                string Country = workOrderRec.CountryCode; //'US' ;
                string KYHDOption = (dispatchDefaultRec.KYHDOption__c == true) ? 'Y' : 'N'; //'N' ; 
                string OutOfWarranty = (dispatchDefaultRec.OutOfWarranty__c == true) ? 'Y' : 'N'; //'N';
                //if(AddressRegionId == '1' && dispatchDefaultRec.Work_Order__r.DASP__c != '' && dispatchDefaultRec.Work_Order__r.DASP__c != null)
                   //DASP = 'Y'; //dispatchDefaultRec.;//'N'
                list < GetCategoryOverrides__x > categoryOverridesList = [SELECT ActivityType__c, AddressBUID__c, AddressRegionId__c, Category__c, City__c, CompleteCareOption__c, Country__c,
                    DASP__c, DisplayUrl, ExternalId, Id, KYHDOption__c, LaborCountry__c, OutOfWarranty__c, PartsCountry__c, ResponseCode__c,
                    ResponseMessage__c, ServiceHours__c, ServiceLevel__c, ServiceType__c, State__c, SystemClassification__c, ZipCode__c
                    FROM GetCategoryOverrides__x WHERE ActivityType__c =: ActivityType AND PartsCountry__c =: PartsCountry AND
                    AddressBUID__c =: AddressBUID AND ServiceHours__c =: ServiceHours AND ServiceType__c =: ServiceType AND
                    DASP__c =: DASP AND CompleteCareOption__c =: CompleteCareOption AND LaborCountry__c =: LaborCountry AND
                    SystemClassification__c =: SystemClassification AND AddressRegionId__c =: AddressRegionId AND
                    City__c =: City AND ServiceLevel__c =: ServiceLevel AND State__c =: State AND
                    ZipCode__c =: ZipCode AND Country__c =: Country AND KYHDOption__c =: KYHDOption AND OutOfWarranty__c =: OutOfWarranty LIMIT 200
                ];
                system.debug('Category Overrides List--->>'+categoryOverridesList);
                if (categoryOverridesList != null && !categoryOverridesList.isEmpty()) {
                    for (GetCategoryOverrides__x cat: categoryOverridesList) {
                        if (cat.Category__c != null) {
                            categorySet.add(cat.Category__c);
                        }
                    }
                }
                system.debug('Category Set--->>'+categorySet);
                categoryList.addAll(categorySet);
            }
      system.debug('categoryList--->>>'+ categoryList);
            return categoryList;
        } catch (Exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getDispatchCategoryOptions', 'Dispatch Management');
            return null;
        }
    }

    /* 
    // Create or Delete Dispatch Instructions Based on Service Type Value
    public static void serviceTypeInstructions(string serviceType,Id WorkOrderId, string RegionId){
        try{
            Boolean NoRecordsFlag=false;
            //Boolean HasMatchingInstructions = false;
            Boolean hasDefaultInstructRecord = false;
            Boolean hasPartsAndLaborInstRecord = false;
            string defaultServOpt = 'Default';
            
            
            List<DispatchInstruction__c> dispInstList = new List<DispatchInstruction__c>();
            List<DispatchInstruction__c> deleteList = new List<DispatchInstruction__c>();
            List<DispatchInstruction__c> insertList = new List<DispatchInstruction__c>();
          
            
            dispInstList=[SELECT Id,Instruction__c,DSP_Override_Request__c,Service_Type__c,Type__c,Work_Order__c 
            FROM DispatchInstruction__c WHERE Service_Type__c!=null AND Work_Order__c=:WorkOrderId LIMIT 100];
            
            if(!dispInstList.isEmpty() && dispInstList!=null && dispInstList.size()>0){
                for(DispatchInstruction__c dInst: dispInstList){
                    
                    if(dInst.Service_Type__c.equalsIgnoreCase(defaultServOpt)){
                        hasDefaultInstructRecord = true;
                    }
                
                    if(dInst.Service_Type__c.equalsIgnoreCase('Parts and Labor')){
                        hasPartsAndLaborInstRecord = true;
                    }
                    
                    if (dInst.Service_Type__c.equalsIgnoreCase('Parts and Labor') 
                            && !serviceType.equalsIgnoreCase('Parts and Labor')) {
                        deleteList.add(dInst);
                    }
                }
                
            } else {
                NoRecordsFlag = true;
            }
            
            if ((NoRecordsFlag || !hasDefaultInstructRecord)){
                if(RegionId.equals('1')){
                    DispatchInstruction__c dspInst = new DispatchInstruction__c();
                    dspInst.Type__c = 'General Comment';
                    dspInst.Receiver__c = 'All Providers';
                    // Regarding Instruction__c ---> Waiting for update from Suneetha.
                    dspInst.Instruction__c = 'DELL Troubleshoot Log: Waiting for Field Mapping';
                    dspInst.Work_Order__c =  WorkOrderId;
                    dspInst.Service_Type__c = defaultServOpt;
                        
                    insertList.add(dspInst);
                }
            }
            
            if(serviceType.equalsIgnoreCase('Parts and Labor') && !hasPartsAndLaborInstRecord){
                if(RegionId.equals('1')){
                    DispatchInstruction__c dspInst = new DispatchInstruction__c();
                    dspInst.Type__c = 'DSP';
                    dspInst.Receiver__c = 'Replace';
                    dspInst.Instruction__c = 'Parts As Necessary';
                    dspInst.Work_Order__c =  WorkOrderId;
                    dspInst.Service_Type__c = 'Parts and Labor';
                        
                    insertList.add(dspInst);
                }
            }
            
            if(!deleteList.isEmpty() && deleteList!=null){
                delete deleteList;
            } 
            
            if(!insertList.isEmpty() && insertList!=null){
                insert insertList;
            }
            
        } catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchDefaultsConfiguration','serviceTypeInstructions','Dispatch Management'); 
        }
    }
    */

    /* To get Service Type Options On Change of the Bill To Flag */
    @AuraEnabled
    public static List < String > getServiceTypesBasedBillTo(Id dDRecId, String billToFlag) {
    
        List<DispatchDefaults__c> ddList = [SELECT Id, Default_Service_Type__c,work_order__r.DPS_Sub_Region__c,Bill_To__c FROM DispatchDefaults__c WHERE Id =: dDRecId LIMIT 1];

        String defaultServiceType = ddList[0].Default_Service_Type__c;
        String subRegion = ddList[0].work_order__r.DPS_Sub_Region__c;
        String billTOPicklistValue = ddList[0].Bill_To__c;

        List < String > SevTypeList = new List < String > ();

        SevTypeList = getServiceTypeByOrder(defaultServiceType, billToFlag,subRegion,billTOPicklistValue);

        return SevTypeList;
    }

    public static List < String > getServiceTypeByOrder(String defaultServiceType, String BillTo, String subRegion, String billTOPicklistValue) {
    
        try {
        
            List< Service_Type__mdt > ServiceTypeList = new List< Service_Type__mdt > ();
            Integer rankOfDefaultServiceType = 0;
            List < String > ServiceTypeOptions = new List < String > ();
            
            ServiceTypeList = [SELECT MasterLabel, Target_High__c, High__c, Rank__c, Active__c FROM Service_Type__mdt WHERE Active__c = true and Region__c =: subRegion and Onboarded__c = TRUE LIMIT 100];
            
            if(string.isNotBlank(BillTo)){
            
                if( BillTo.equalsIgnoreCase('Y') || (BillTo.equalsIgnoreCase('N') && ((null != billTOPicklistValue) && (billTOPicklistValue.equalsIgnoreCase('CUSTOMER') || 
                billTOPicklistValue.equalsIgnoreCase('Customer Paid/Previous issue'))) ) ) {
                
                   
                    for (Service_Type__mdt servType: ServiceTypeList) {
                        ServiceTypeOptions.add(servType.MasterLabel);
                       
                    }
                    return ServiceTypeOptions;
                    
                } 
                else if (BillTo.equalsIgnoreCase('N')) {
                
                    for(Service_Type__mdt serviceTypeMDT : ServiceTypeList){
            
                        if(serviceTypeMDT.MasterLabel.equalsIgnoreCase(defaultServiceType)){
                            rankOfDefaultServiceType = Integer.valueOf(serviceTypeMDT.Rank__c);
                        }
                    }
                    for(Service_Type__mdt serviceTypeMDT : ServiceTypeList){
                    
                        if(serviceTypeMDT.Rank__c >= rankOfDefaultServiceType){
                            ServiceTypeOptions.add(serviceTypeMDT.MasterLabel);
                        }
                    }
                    return ServiceTypeOptions;
                } 
            }
            return null;
            
        } catch (Exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getServiceTypeByOrder', 'Dispatch Management');
            return null;
        }
    }
   
    @AuraEnabled
    public static Map < String, List < String >> fetchCountryAndStateMap() {

        Map < String, List < String >> countryStateMap;
        List < String > stateList;
        List < Country_State__mdt > countryStateMDList = [Select Id, DeveloperName, Country__c, State__c, StateCode__c From
            Country_State__mdt limit 50000
        ];

        if (null != countryStateMDList && countryStateMDList.size() > 0) {

            countryStateMap = new Map < String, List < String >> ();

            for (Country_State__mdt metadata: countryStateMDList) {

                stateList = new List < String > ();
                if (countryStateMap.containsKey(metadata.Country__c)) {

                    stateList = countryStateMap.get(metadata.Country__c);
                    stateList.add(metadata.StateCode__c);
                    countryStateMap.put(metadata.Country__c, stateList);
                } else {
                    stateList.add(metadata.StateCode__c);
                    countryStateMap.put(metadata.Country__c, stateList);
                }
            }
        }
        return countryStateMap;
    }
    // query And DELETE Parts - if Service Type is Labor Only - Added By Harsha
    public static void queryPartsAndDelete(Id WorkOrderId) {
        try {
            if (partsList.isempty()) {
                partsList = [SELECT Id, PartCommodity__c, SubComponent__c, Line_Item_Type__c, WorkOrderId, AssetId, ServiceTag__c, ServiceBUID__c FROM WorkOrderLineItem WHERE Selected_By_user__c = true AND WorkOrderId =: WorkOrderId LIMIT 500];
            }
            if (partsList.size() > 0 && !partsList.isEmpty()) {
                Database.DeleteResult[] results = Database.delete(partsList, false);
                ExceptionHandler.logHandledExceptions(results, 'DispatchDefaultsConfiguration', 'queryPartsAndDelete', 'Dispatch Management');
            }
            return;
        } catch (Exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'queryPartsAndDelete', 'Dispatch Management');
            return;
        }
    }
    //get the info Parts on check of KYHD
    public static void checkHardDriveParts(Id WorkOrderId, Boolean KYHDFlagChangedTrue) {
        Boolean hasHardDrive = false;
        List < WorkOrderLineItem > addInfoParts = new List < WorkOrderLineItem > ();
        WorkOrderLineItem hardDriveParts = new WorkOrderLineItem();
        if (AutoSelectPartController.workOrderDetails.isempty()) {
            AutoSelectPartController.workOrderDetails = [Select Id, Entitlement_Details__c, KYHD__c, Out_of_Warranty__c, Ground_Shipment_Flag__c, Override_Ground_Shipment__c from workOrder where Id =: WorkOrderId Limit 1];
        }
        if (!AutoSelectPartController.workOrderDetails.isempty() && partsList.isempty() && !AutoSelectPartController.workOrderDetails[0].Out_of_Warranty__c) {
            partsList = [SELECT Id, PartCommodity__c, SubComponent__c, Line_Item_Type__c, WorkOrderId, AssetId, ServiceTag__c, ServiceBUID__c FROM WorkOrderLineItem WHERE Selected_By_user__c = true AND WorkOrderId =: WorkOrderId LIMIT 500];
        }
        if (!partsList.isempty()) {
            for (WorkOrderLineItem wl: partsList) {
                if (((wl.PartCommodity__c != null && wl.PartCommodity__c != '' && (wl.PartCommodity__c.containsIgnoreCase('HARD DRIVE') || wl.PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE'))) || (wl.SubComponent__c != null && wl.SubComponent__c != '' && (wl.SubComponent__c.containsIgnoreCase('HARD DRIVE') || wl.SubComponent__c.containsIgnoreCase('SOLID STATE DRIVE'))))) {
                    hasHardDrive = true;
                    hardDriveParts = wl;
                    break;
                }
            }
            if (hasHardDrive) {
                string calltype = '';
                if (string.isNotEmpty(hardDriveParts.Line_Item_Type__c) && hardDriveParts.Line_Item_Type__c.containsIgnoreCase('APS')) {
                    calltype = 'APS';
                } else {
                    calltype = 'MPS';
                }
                addInfoParts = AutoSelectPartController.ValidateInfoparts(hardDriveParts, calltype, KYHDFlagChangedTrue);
                if (!addInfoParts.isempty()) {
                    for (workorderLineItem wl: addInfoParts) {
                        wl.Selected_By_user__c = true;
                        wl.Selected_Work_Order__c = wl.WorkOrderId;
                        wl.Work_Order_Id_Text__c = String.valueOf(wl.WorkOrderId);
                    }
                    try {
                        Upsert addInfoParts External_Id__c;
                    } catch (Exception e) {   ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'checkHardDriveParts', 'Dispatch Management');
                    }
                }
            }
        }
    }

    @AuraEnabled
    public static optionsWrapper calculateServiceOption(Id workOrderId) {
        
        try{
            List < DispatchDefaults__c > defaultList = new List < DispatchDefaults__c > ();
            List < String > options = new list < String > ();
            String availableOptionFullList = '';
            defaultList = [SELECT Id, Service_Options_Picklist_values__c, BasicEntitlement__c, Entitlement_Details__c, Service_Type__c, Billable__c, PO_Number__c, selected_service_option__c, OutOfWarranty__c,
                category__c, Service_Configurations__c, SpecialOptions__c, Bill_To__c, Keep_Your_Components__c, DSP_Override_Request__c, AD_Override__c, LOB__c,
                AvailableCoverages__c, AvailableOptions__c, CompleteCareOption__c, AD_Coverage_Flag__c, Complete_Care_Option__c, OrderNumber__c,
                Bill_To_Order_Number__c, KYHDOption__c, PartsCountry__c, BUID__c, ServiceHours__c, LaborCountry__c, ServiceLevel__c, Default_Service_Type__c,
                Work_Order__r.SLAStartDate__c, Work_Order__r.SLAEndDate__c, Work_Order__r.Service_Option__c, Work_Order__r.Country, Work_Order__r.PostalCode,
                Work_Order__r.WorkOrderNumber, Work_Order__r.Id, Work_Order__r.Ground_Shipment_Flag__c, Work_Order__r.Override_Ground_Shipment__c, Work_Order__r.ServiceTag__c, Work_Order__r.StateCalc__c,Work_Order__r.CityCalc__c,Work_Order__r.Product_Classification__c, Work_Order__r.BUID__c, Work_Order__r.CountryCode, Work_Order__r.City, Work_Order__r.State, Work_Order__r.Region__c
                FROM DispatchDefaults__c
                WHERE Work_Order__c =: workOrderId LIMIT 1
            ];
            if (defaultList != NULL) {
                List < System_Classification__mdt > SystemClassificationList = [Select Id, MasterLabel, Type__c from System_Classification__mdt where Type__c = 'Enterprise'
                    limit 50000
                ];
                Set < String > SystemClassificationSet = new Set < String > ();
                for (System_Classification__mdt scObj: SystemClassificationList) {
                    SystemClassificationSet.add(scObj.MasterLabel);
                }
    
                if (defaultList[0].BasicEntitlement__c && !(SystemClassificationSet.contains(defaultList[0].Work_Order__r.Product_Classification__c))) {
    
                    String GroundShipment = 'N';
                    if (defaultList[0].Work_Order__r.Ground_Shipment_Flag__c && defaultList[0].Work_Order__r.Override_Ground_Shipment__c) {
                        GroundShipment = 'N';
                    } else if (defaultList[0].Work_Order__r.Ground_Shipment_Flag__c && !(defaultList[0].Work_Order__r.Override_Ground_Shipment__c)) {
                        GroundShipment = 'Y';
                    }
                    list < AvailableOptions__x > listObject = new list < AvailableOptions__x > ();
    
                    listObject = (!mockedAvailableOptions.isEmpty()) ? mockedAvailableOptions : [SELECT AvailableOptions__c, ProviderCode__c, DefaultAvailableOptions__c, ResponseCode__c, ResponseMessage__c FROM AvailableOptions__x
                        WHERE ServiceTagId__c =: defaultList[0].Work_Order__r.ServiceTag__c AND BUID__c =: defaultList[0].Work_Order__r.BUID__c
                        AND Country__c =: defaultList[0].Work_Order__r.CountryCode AND City__c =: defaultList[0].Work_Order__r.CityCalc__c
                        AND State__c =: defaultList[0].Work_Order__r.StateCalc__c AND LOB__c =: defaultList[0].LOB__c AND Region__c =: defaultList[0].Work_Order__r.Region__c
                        AND PostalCode__c =: defaultList[0].Work_Order__r.PostalCode AND Billable__c =: defaultList[0].Billable__c AND ServiceType__c =: defaultList[0].Service_Type__c
                        AND ServiceLevel__c =: defaultList[0].ServiceLevel__c AND ServiceHours__c =: defaultList[0].ServiceHours__c AND MonitorCall__c = 'N'
                        AND GroundShipFlg__c =: GroundShipment LIMIT 50
                    ];
    
                    optionsWrapper gsWrap = new optionsWrapper();
                    String defaultServOption = '';
                    if (listObject.size() > 0) {
                        gsWrap.responseCode = listObject[0].ResponseCode__c;
                        gsWrap.responseMessage = listObject[0].ResponseMessage__c;
    
                        if (defaultList[0].Billable__c.equalsIgnoreCase('Y')) {
                            defaultServOption = listObject[0].DefaultAvailableOptions__c;
                        } else {
                            defaultServOption = listObject[0].AvailableOptions__c;
                        }
                        if (String.isNotEmpty(defaultServOption)) {
                            gsWrap.defaultOption = defaultServOption;
                        }
    
                        for (AvailableOptions__x itemObject: listObject) {
                            if (String.isNotEmpty(itemObject.AvailableOptions__c)) {
                                options.add(itemObject.AvailableOptions__c);
                                availableOptionFullList += itemObject.AvailableOptions__c + '||';
                            }
                        }
                        if (!string.isBlank(availableOptionFullList)) {
                            availableOptionFullList = availableOptionFullList.removeEnd('||').removeStart('null||');
                        }
                        if (!options.contains(defaultServOption) && defaultList[0].Billable__c != NULL && defaultList[0].Billable__c.equalsIgnoreCase('Y')) {
                            options.add(defaultServOption);
                        }
    
                        gsWrap.availableOptions = options;
                    }
    
                    if (!string.isBlank(defaultServOption) && defaultServOption.contains('-')) {
                        defaultList[0].ServiceHours__c = defaultServOption.split('-')[1];
                        defaultList[0].ServiceLevel__c = defaultServOption.split('-')[0];
                    }
                    if (!string.isBlank(defaultServOption)) {
                        defaultList[0].selected_service_option__c = defaultServOption;
                    }
                    if (!string.isBlank(availableOptionFullList)) {
                        defaultList[0].AvailableCoverages__c = availableOptionFullList;
                    }
                    Database.update(defaultList[0]);
                    return gsWrap;
                }
            }
            return null;
        } catch(Exception e){ ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'calculateServiceOption', 'Dispatch Management');
            return null;
        }
    }
    //this method will remove Null values from the drop down. 5621569
    public static List<String> RemoveNull(List<String> optionList){
        List<String> optList=new List<String>();
        if(optionList!=null && !optionList.isempty()){
            for(string str : optionList){
                if(str!=null && string.isnotempty(str) && str.tolowercase()!='null') {
                    optList.add(str);
                }
            }
        }
        return optList;
    }

    public static List<CheckPreference__x> checkPreference(String WorkOrderNumber) {
        try {
            //mokedCheckPreference.add(new CheckPreference__x(WF_DSP__c='IBM', DSPSelectionMethod__c='Dynamic', Dispatch_Number__c='385013883',ResponseCode__c='100'));
            if(String.isNotEmpty(WorkOrderNumber) && String.isNotBlank(WorkOrderNumber)){
              List < CheckPreference__x > checkPrefList = new List < CheckPreference__x > ();
                checkPrefList = (!mokedCheckPreference.isEmpty()) ? mokedCheckPreference : [SELECT WF_DSP__c, DSPSelectionMethod__c, Dispatch_Number__c,ResponseCode__c
                                FROM CheckPreference__x WHERE Dispatch_Number__c=:WorkOrderNumber LIMIT 1];
                if(!checkPrefList.isEmpty() && checkPrefList!=null && checkPrefList.size()>0){
                    if(string.isNotBlank(checkPrefList[0].ResponseCode__c) && string.isNotEmpty(checkPrefList[0].ResponseCode__c)){
                        if(checkPrefList[0].ResponseCode__c=='100'){
                            return checkPrefList;
                        }
                    }
                }
            }
            return null;
        } catch (Exception e) { ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'checkPreference', 'Dispatch Management');
            return null;
        }
    }
    
   @AuraEnabled
    public static List <DispatchDSPDLP__c> getDASPValue(String CountryCode) {
        try {
            Asset_Country__mdt assetcountrymdt      =   new Asset_Country__mdt();
            List<DispatchDSPDLP__c> DASP            =   new List<DispatchDSPDLP__c>();
                                    DASP            =   null;
             assetcountrymdt = [Select Id,RegionName__c, SubRegionName__c from Asset_Country__mdt WHERE CountryCode__c =: CountryCode LIMIT 1];
            List<String> DASPEMEACountry =new List<String>{'AL','DZ','AO','AZ','BH','BA','BW','BG','HR','CY','EG','EE','ET','GH','HU','IS','IQ','IL','CI','JO','KZ','KE','KW','LV','LB','LY','LT','MK','MU','MA','MZ','NA','MG','OM','QA','RO','RU','RW','SA','RS','SI','TZ','TN','TR','UG','UA','AE','YE'};
            if(assetcountrymdt.RegionName__c.equalsIgnoreCase('EMEA'))
            {
                DASP = [Select PartnerCode__c, PartnerName__c From
                DispatchDSPDLP__c where Type__c = 'DASP' AND CountryCode__c =: CountryCode AND Active__c = true limit 50];
            }
            integer i = 0, flag = 0;
            for(DispatchDSPDLP__c dobj : DASP)
            {
                if(dobj.PartnerName__c.equalsIgnoreCase('Flextronics'))
                {
                    flag = 1;
                    break;
                }
                i++;
            }
            if(flag == 1) 
            {
            DASP.remove(i);
            }
            return DASP;
        }
        catch(Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'getDASPValue', 'Dispatch Management');
            return null;
        }
    }
}
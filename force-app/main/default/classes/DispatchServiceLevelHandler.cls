/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchServiceLevelHandler
Description:  This class contain method that handles maestro service level operation call - story #4916686 
Date         Version    Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/07/2018     1.0     Rodrigo Carpio      Initial Release
06/11/2018     1.1     Sri Harsha G        DEFECT 5070477
-------------------------------------------------------------------------------------------------------------------------- */
public class DispatchServiceLevelHandler {
    
    @TestVisible public static List<DPSAndCallType__x> mockedRequests = new List<DPSAndCallType__x>();
    @TestVisible public static List < GetProviderAttributes__x > mockedGetProviderAttributes = new List<GetProviderAttributes__x>();
    @TestVisible public static List < GetBestFitDSP__x > mockedBestFit = new List<GetBestFitDSP__x>();
    @TestVisible public static List < Asset_Country__mdt > mockedAssetCountry = new List<Asset_Country__mdt>();
    @TestVisible public static string stateValue;
    
    public class DPSTypeCallTypeStatus {
        @InvocableVariable public string responseCode;
        @InvocableVariable public string status;
        @InvocableVariable public string subStatus;
    }
    
    @InvocableMethod(label = 'Get DPS Type and Call Type' description = 'Call Maestro interface to Get DPS Type and Call Type')
    public static List<DPSTypeCallTypeStatus> getDPSTypeAndCallType(list<string> workOrderIdList)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getDPSTypeAndCallType
    Description:  this functions makes a call to maestro to dispatch DPS Type and Call Type
    Input: recordId - work order record identifier
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    04/07/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            
            string strServiceHours=''; 
            
            string srtServiceLevel='';
            
            list<DPSTypeCallTypeStatus> dpsDPSCallStatus = new List<DPSTypeCallTypeStatus>();
            
            List<DPSAndCallType__x> dpsTypeCallType = new List<DPSAndCallType__x>();
            
            DispatchDefaults__c recordWOLine = new DispatchDefaults__c();
            
            /*WorkOrder recordWO = [SELECT ServiceTag__c, City, State, BUID__c, PostalCode, CountryCode__c, LOB__c, Region__c,Service_Type__c, DSP__c, Country, Deferred__cFROM WorkOrder WHERE Id = :recordId LIMIT 1];*/
            
            recordWOLine= [SELECT Id,DPSType__c,DefaultDPSType__c,CallType__c,DefaultCallType__c,OutOfWarranty__c,Service_Type__c,selected_service_option__c,ServiceLevel__c,ServiceHours__c,Service_Configurations__c,
                            Billable__c,SpecialOptions__c,CompleteCareOption__c,complete_care_option__c,KYHDOption__c,OconusDispatch__c,PremierCode__c,OutOfHours__c,Work_Order__r.City,Work_Order__r.CityCalc__c,Work_Order__r.StateCode,
                            Work_Order__r.BUID__c,Work_Order__r.PostalCode,Work_Order__r.CountryCode,Work_Order__r.LOB__c, Work_Order__r.Region__c,Work_Order__r.Service_Type__c,
                            Work_Order__r.Country,Work_Order__r.Deferred__c, Work_Order__r.Sanbao_FLG__c, Work_Order__r.FSD_DASP_Flag__c, Work_Order__r.Service_Option__c,
                            Work_Order__r.CallType__c,Work_Order__r.DPSType__c,Work_Order__r.DSP__c,Bill_To__c,Work_Order__c FROM DispatchDefaults__c WHERE Work_Order__c = :workOrderIdList[0] LIMIT 1]; 
            
            if (String.isNotEmpty(recordWOLine.Work_Order__r.Service_Option__c))
            {
                if(recordWOLine.Work_Order__r.Service_Option__c.contains('-'))
                {
                    strServiceHours = recordWOLine.Work_Order__r.Service_Option__c.substringAfter('-');
                    srtServiceLevel = recordWOLine.Work_Order__r.Service_Option__c.substringBefore('-');
                }
            }
            
            dpsTypeCallType = (!mockedRequests.isEmpty()) ? mockedRequests : [SELECT DPSType__c,CallType__c,ResponseCode__c,ResponseMessage__c FROM DPSAndCallType__x WHERE ActivityType__c='Break Fix' AND ServiceType__c= :recordWOLine.Service_Type__c 
                                   AND ServiceLevel__c=:srtServiceLevel AND ServiceHours__c=:strServiceHours AND DSP__c= :recordWOLine.Work_Order__r.DSP__c AND PremierCode__c= :recordWOLine.PremierCode__c 
                                   AND OutOfHours__c=:recordWOLine.OutOfHours__c ? 'Y':'N'  AND OutOfWarranty__c=:recordWOLine.OutOfWarranty__c ? 'Y':'N' AND OconusOrFederalFlag__c=:recordWOLine.OconusDispatch__c 
                                   AND SystemClassification__c=:recordWOLine.Service_Configurations__c AND CompleteCareOption__c=:recordWOLine.complete_care_option__c ? 'Y' : 'N' AND KYHDOption__c=:recordWOLine.KYHDOption__c ? 'Y':'N' AND Deferred__c= :recordWOLine.Work_Order__r.Deferred__c 
                                   AND Category__c=:recordWOLine.SpecialOptions__c AND City__c= :recordWOLine.Work_Order__r.CityCalc__c AND State__c= :recordWOLine.Work_Order__r.StateCode AND DASP__c= :recordWOLine.Work_Order__r.FSD_DASP_Flag__c ? 'Y':'N'
                                   AND BillTo__c=:recordWOLine.Bill_To__c AND Country__c= :recordWOLine.Work_Order__r.CountryCode AND ZipCode__c= :recordWOLine.Work_Order__r.PostalCode AND AddressRegionId__c=:recordWOLine.Work_Order__r.Region__c 
                                   AND DPSType__c = :recordWOLine.DefaultDPSType__c AND CallType__c = :recordWOLine.DefaultCallType__c AND SanbaoFlag__c=:recordWOLine.Work_Order__r.Sanbao_FLG__c LIMIT 1]; 
            
            DPSTypeCallTypeStatus dpsType = new DPSTypeCallTypeStatus();
            
            if (dpsTypeCallType.size()>0)
            {
                WorkOrder wo = new WorkOrder(Id=workOrderIdList[0]);
                    
                DispatchDefaults__c dd = new DispatchDefaults__c(Id=recordWOLine.Id);
                
                if (dpsTypeCallType[0].ResponseCode__c == '100')
                {   
                    
                    if (String.isNotEmpty(dpsTypeCallType[0].DPSType__c)) 
                    {
                        dd.DPSType__c = dpsTypeCallType[0].DPSType__c;    
                        wo.DPSType__c = dpsTypeCallType[0].DPSType__c;    
                    }
                    
                    if (String.isNotEmpty(dpsTypeCallType[0].CallType__c)) 
                    {
                        dd.CallType__c = dpsTypeCallType[0].CallType__c;
                        wo.CallType__c = dpsTypeCallType[0].CallType__c;
                    }
                    
                    dpsType.responseCode = dpsTypeCallType[0].ResponseCode__c;
                    dpsType.status = 'Open';
                    dpsType.subStatus = '';
                    
                }
                else 
                {
                    dpsType.responseCode = dpsTypeCallType[0].ResponseCode__c;
                    dpsType.status = 'Problem';
                    dpsType.subStatus = 'DPS Type Failure';
                }
                
                update wo;
                update dd;
            }
            else 
            {
                dpsType.responseCode = '103';
                dpsType.status = 'Problem';
                dpsType.subStatus = 'DPS Type Failure';
            }
            
            dpsDPSCallStatus.add(dpsType);
            
            return dpsDPSCallStatus;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchServiceLevelHandler','getDPSTypeAndCallType','Dispatch Management'); 
            return null;
        }
    }
    
    public static List<DPSAndCallType__x> getDPSTypeAndCallType(DispatchDefaults__c recordWOLine, string serviceType,
        string serviceHours, string serviceLevel)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getDPSTypeAndCallType
    Description:  this functions makes a call to maestro to dispatch DPS Type and Call Type
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    09/07/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
                        
            List<DPSAndCallType__x> dpsTypeCallType = new List<DPSAndCallType__x>();
            
            dpsTypeCallType = (!mockedRequests.isEmpty()) ? mockedRequests : [SELECT DPSType__c,CallType__c,ResponseCode__c,ResponseMessage__c FROM DPSAndCallType__x WHERE ActivityType__c='Break Fix' AND ServiceType__c= :recordWOLine.Service_Type__c 
                                   AND ServiceLevel__c=:serviceLevel AND ServiceHours__c=:serviceHours AND DSP__c= :recordWOLine.Work_Order__r.DSP__c AND PremierCode__c= :recordWOLine.PremierCode__c 
                                   AND OutOfHours__c=:recordWOLine.OutOfHours__c ? 'Y':'N'  AND OutOfWarranty__c=:recordWOLine.OutOfWarranty__c ? 'Y':'N' AND OconusOrFederalFlag__c=:recordWOLine.OconusDispatch__c 
                                   AND SystemClassification__c=:recordWOLine.Service_Configurations__c AND CompleteCareOption__c=:recordWOLine.complete_care_option__c ? 'Y' : 'N' AND KYHDOption__c=:recordWOLine.KYHDOption__c ? 'Y':'N' AND Deferred__c= :recordWOLine.Work_Order__r.Deferred__c 
                                   AND Category__c=:recordWOLine.SpecialOptions__c AND City__c= :recordWOLine.Work_Order__r.City AND State__c= :recordWOLine.Work_Order__r.StateCode AND DASP__c= :recordWOLine.Work_Order__r.FSD_DASP_Flag__c ? 'Y':'N'
                                   AND BillTo__c=:recordWOLine.Bill_To__c AND Country__c= :recordWOLine.Work_Order__r.CountryCode AND ZipCode__c= :recordWOLine.Work_Order__r.PostalCode AND AddressRegionId__c=:recordWOLine.Work_Order__r.Region__c 
                                   AND DPSType__c = :recordWOLine.DefaultDPSType__c AND CallType__c = :recordWOLine.DefaultCallType__c AND SanbaoFlag__c=:recordWOLine.Work_Order__r.Sanbao_FLG__c LIMIT 1]; 
                                       
            if(!dpsTypeCallType.isEmpty() && dpsTypeCallType.size()>0 && dpsTypeCallType!=null){
                if(string.isNotBlank(dpsTypeCallType[0].ResponseCode__c) && string.isNotEmpty(dpsTypeCallType[0].ResponseCode__c)){
                    if(dpsTypeCallType[0].ResponseCode__c=='100'){
                        return dpsTypeCallType;
                    }
                }
            }
            
            return null;
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchServiceLevelHandler','getDPSTypeAndCallType','Dispatch Management'); 
            return null;
        }
    }
    
    public static List<GetProviderAttributes__x> getProviderAttributes(DispatchDefaults__c defaultRecord, string serviceType,
        string serviceOption, string billToValue, boolean kYcompvalue,
        boolean KyhdFlag, boolean accDamageValue, string serProviderCode) 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getProviderAttributes
    Description:  this functions makes a call to maestro to get provider attributes
    Input: recordId - work order record identifier
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    04/07/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            List <GetProviderAttributes__x> providerAttr;
            string serviceLevel = '';
            string serviceHour = '';
            string countryValue = '';
            string billFlag = 'N';
            List<Asset_Country__mdt> assetCountryMDT = new List<Asset_Country__mdt>();
            // Delta accepts- country code USA not US.
            // Query on Custom Metadata Type  - Asset_Country_mdt
            if (string.isNotEmpty(defaultRecord.Work_Order__r.CountryCode)) {
                assetCountryMDT = (!mockedAssetCountry.isEmpty()) ? mockedAssetCountry : [SELECT DeveloperName FROM Asset_Country__mdt WHERE CountryCode__c =: defaultRecord.Work_Order__r.CountryCode LIMIT 1];
                if (null != assetCountryMDT && assetCountryMDT.size() > 0){
                    countryValue = assetCountryMDT[0].DeveloperName;
                }
            }

            //split country service Option into ServiceLevel & ServiceHour
            if (serviceOption.contains('-')) {
                serviceLevel = serviceOption.substringBeforeLast('-');
                serviceHour = serviceOption.substringAfterLast('-');
            }

            if (string.isNotEmpty(billToValue)) {
                billFlag = 'Y';
            }

            providerAttr = new List < GetProviderAttributes__x > ();
            
            //mockedGetProviderAttributes.add(new GetProviderAttributes__x(ISPDSPScheduleEnabled__c='Y',ServiceProviderCode__c='IBM',DSPSchedulingURL__c='https://localhost.com/customer/scheduling', CommunicationChannel__c='',ResponseCode__c='100'));
            providerAttr = (!mockedGetProviderAttributes.isEmpty()) ? mockedGetProviderAttributes :[SELECT ISPDSPScheduleEnabled__c,ServiceProviderCode__c,DSPSchedulingURL__c, CommunicationChannel__c,ResponseCode__c FROM GetProviderAttributes__x WHERE ActivityBUID__c=:defaultRecord.Work_Order__r.DPS_BUID__c 
                    AND ActivityType__c='Break Fix' AND Billable__c=:billFlag AND BulkFlag__c='N'
                    AND BulkSource__c = '' AND City__c=:defaultRecord.Work_Order__r.City AND CompleteCare__c=:accDamageValue ? 'Y':'N' AND Country__c=:countryValue AND ServiceHour__c =:serviceHour AND KYHD__c =: KyhdFlag ? 'Y' : 'N' AND ServiceSubType__c =: serviceType
                    AND CountryCode__c =: defaultRecord.Work_Order__r.CountryCode AND DASP__c = 'N' AND FederalOconusFlag__c = 'N' AND GroundShipFlg__c =: defaultRecord.GroundShipFlg__c AND KYCOption__c =: kYcompvalue ? 'Y' : 'N'
                    AND LOB__c =: defaultRecord.Work_Order__r.LOB__c AND OOH__c =: defaultRecord.OutOfHours__c ? 'Y' : 'N' AND Options__c =: serviceOption AND Region__c =: defaultRecord.work_order__r.Region__c AND SanbaoFlag__c =: defaultRecord.work_order__r.Sanbao_FLG__c
                    AND ServiceLevel__c =: serviceLevel AND ServiceProviderCode__c =: serProviderCode AND OOWFlag__c =: defaultRecord.OutOfWarranty__c ? 'Y' : 'N' AND State__c =: defaultRecord.Work_Order__r.StateCode AND SystemClassification__c =: defaultRecord.SpecialOptions__c LIMIT 1];
            
            if(!providerAttr.isEmpty() && providerAttr.size()>0 && providerAttr!=null){
                if(string.isNotBlank(providerAttr[0].ResponseCode__c) && string.isNotEmpty(providerAttr[0].ResponseCode__c)){
                    if(providerAttr[0].ResponseCode__c=='100'){
                        return providerAttr;
                    }
                }
            }
            return null;
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceLevelHandler', 'getProviderAttributes', 'Dispatch Management');
            return null;
        }
    }
    
    public static List<GetBestFitDSP__x> callGetDSPFitService(DispatchDefaults__c createddDefault,string serTypeValue, string serviceHour, string serviceLevel)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       callGetDSPFitService
    Description:  this functions makes a call to maestro to get best fit dsp
    Input: 
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    04/07/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */  
    {
        try{
            List<GetBestFitDSP__x> getBestFitRecord = new List<GetBestFitDSP__x>(); 
                string stateValue = '';
                if (createddDefault.Work_Order__r.Region__c == '1') {
                    if (createddDefault.Work_Order__r.DPS_Sub_Region__c == 'LA')
                        stateValue = createddDefault.Work_Order__r.StateCode;
                    else
                        stateValue = createddDefault.Work_Order__r.State;
                }                    
                else
                    stateValue = createddDefault.Work_Order__r.StateCode;
                
                getBestFitRecord = (!mockedBestFit.isEmpty()) ? mockedBestFit : [SELECT DSP__c, ISPDSPScheduleEnabled__c, DSPSchedulingURL__c, CommunicationChannel__c,ResponseCode__c FROM GetBestFitDSP__x
                                WHERE ServiceTagId__c =: createddDefault.Work_Order__r.ServiceTag__c AND BUID__c =: createddDefault.Work_Order__r.DPS_BUID__c
                                AND City__c =: createddDefault.Work_Order__r.CityCalc__c AND State__c =: stateValue AND ItemClass__c =: createddDefault.Work_Order__r.AssetItemClass__c
                                AND Region__c =: createddDefault.Work_Order__r.Region__c AND ISOCountryCode__c =: createddDefault.Work_Order__r.CountryCode
                                AND Billable__c =: createddDefault.Billable__c AND PostalCode__c =: createddDefault.Work_Order__r.PostalCode AND ServiceHour__c =: serviceHour
                                AND ServiceSubType__c =: serTypeValue AND ServiceLevel__c =: serviceLevel AND RegionID__c =: createddDefault.Work_Order__r.Region__c
                                AND LOB__c =: createddDefault.Work_Order__r.LOB__c AND OOWFlag__c =: createddDefault.OutOfWarranty__c ? 'Y' : 'N'
                                //AND PreferenceType__c = 'EXCLUSION' AND ServiceProviderCode__c = 'D1D, IBM'
                                AND PreferenceType__c = 'EXCLUSION'
                                AND ServiceProviderCode__c = 'D1D'
                                AND ServiceType__c = 'Break Fix'
                                LIMIT 1
                            ];
            
            if(!getBestFitRecord.isEmpty() && getBestFitRecord!=null && getBestFitRecord.size()>0){
                if(string.isNotBlank(getBestFitRecord[0].ResponseCode__c) && string.isNotEmpty(getBestFitRecord[0].ResponseCode__c)){
                    if(getBestFitRecord[0].ResponseCode__c=='100'){
                        return getBestFitRecord;
                    }
                }
            }
            return getBestFitRecord;
        } catch(exception e){
            system.debug('e ' + e);
            ExceptionHandler.logHandledExceptions(e, 'DispatchServiceLevelHandler', 'callGetDSPFitService', 'Dispatch Management');
            return null;
        }
    }
}
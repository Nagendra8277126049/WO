/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchCheckPreferences
Description:  This class contain method that handles DSP assignment base on preferences
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
08/06/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public class DispatchCheckPreferences {
    @TestVisible public static List<ProviderPreference__c> mockedAccountPref = new List<ProviderPreference__c>();
    @TestVisible public static List<LinkPreference__c> mockedLinkPref = new List<LinkPreference__c>();
    @TestVisible public static List<GetBestFitDSP__x> mockedBestFitDSP = new List<GetBestFitDSP__x>();
                                       
    private string cpIncProviderName {get;set;}
    private string cpExcProviderName {get;set;}
    private boolean cpCheckCoverage {get;set;}
    
    private string lpIncProviderName {get;set;}
    private string lpExcProviderName {get;set;}
    private boolean lpCheckCoverage {get;set;}
    
    private string errorCode {get;set;}
    public string woStatus {get;set;}
    
    // Wrapper Class for Service Provider Attributes
    public class PreferenceAttributes{
        @InvocableVariable(label='DSP')
        public String providerCode;
 
        @InvocableVariable(label='Scheduling Enabled')
        public String schedulingFlag;
        
        @InvocableVariable(label='Scheduling URL')
        public String schedulingURL;
        
    }
    
    // Method to Invoke Asset Hold Service
    @InvocableMethod(label='Check Preferences' description='This will perform the provider preference logic')
    public static List<PreferenceAttributes> checkPreferences(list<string> workOrderIdList)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       checkPreferences
    Description:  this functions get the preference information
    Input: woInfo - work order information
    Output: none
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/06/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try{
            List<PreferenceAttributes> prefList = new List<PreferenceAttributes>();
            
            return prefList;
        }
        catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'DispatchCheckPreferences','checkPreferences','Dispatch Management');
            return null;
        }
    }
        
    void checkPreferences(WorkOrder woInfo)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       checkPreferences
    Description:  this functions get the preference information
    Input: woInfo - work order information
    Output: none
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/06/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        string serviceType = '';
        string strDSP = '';
        string excDSP = '';
        string strLinkPref = '';
        string selectMethod = 'Preference';
        this.woStatus = '';
        
        // check for service type and DSP is blank
        if ((serviceType == 'Labor Only' || serviceType == 'Parts and Labor') && (strDSP == ''))
        {
            strDSP = getCustomerPreference(woInfo);
            if(lpIncProviderName!='')
            {
                if (cpCheckCoverage == false) // no coverage check
                    strDSP = cpIncProviderName;
                else { // coverage check
                    strDSP = callGSCVforCheckCoverage(cpIncProviderName);
                    if (errorCode == '100' && strDSP != '')
                        strDSP = cpIncProviderName;
                    else {
                        if (errorCode == '-103' || errorCode == '1127002'){
                            strDSP = '';
                            excDSP = cpExcProviderName;
                            woStatus = 'DSP Assignment Failure';
                        }
                    }
                        
                }    
            }
            else {
                if (cpExcProviderName != '')
                {
                    strDSP = '';
                    excDSP = cpExcProviderName;
                }
            }    
            
            // check for link preference
            if (strLinkPref != '' && strDSP == '')
            {
                strDSP = getLinkPreference(woInfo);
                if (lpIncProviderName != '')
                {
                    if(lpIncProviderName!=cpExcProviderName)
                    {
                        if (lpCheckCoverage == false) // no coverage check
                            strDSP = lpIncProviderName;
                        else { // coverage check
                            strDSP = callGSCVforCheckCoverage(lpIncProviderName);
                            if (errorCode == '100')
                                strDSP = lpIncProviderName;
                            else {
                                if (errorCode == '-103' || errorCode == '1127002'){
                                    strDSP = '';
                                    woStatus = 'DSP Assignment Failure';
                                }
                            }
                        }    
                    }
                    else {
                           strDSP = '';
                           excDSP = excDSP + ',' + cpExcProviderName;                        
                    } 
                }
                else {
                    if (lpExcProviderName != '')
                    {
                        strDSP = '';
                        excDSP = excDSP + ',' + cpExcProviderName;
                    }
                }
            }
            
            string orderNumber = '';
            // get order preference
            if (strDSP == '' && orderNumber != '')
            {
                strDSP = getOrderPreference(woInfo);
            }
        }
        
        if ( (woInfo.Region__c == '1' || woInfo.Region__c == '3' || woInfo.Region__c == '4') && (strDSP == ''))
        {
            strDSP = repeatCheck(woInfo);
            selectMethod = 'Repeat';
        }
    }
    
    private string getOrderPreference(WorkOrder woInfo)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       geOrderPreference
    Description:  this functions get the order preference information
    Input: woInfo - work order information
    Output: DSP and other related information if available
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/06/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            string strDSP = '';
            return strDSP;
        }
        catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'DispatchCheckPreferences','getOrderPreference','Dispatch Management');
            return '';
        }
    }
    
    private string repeatCheck(WorkOrder woInfo)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       repeatCheck
    Description:  this functions check for repeat preference information
    Input: woInfo - work order information
    Output: DSP and other related information if available
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/06/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            string strDSP = '';
            
            Integer lastNDays = 8;
            Date dispatchCreatedDateToCompare = Date.today().addDays(-1 * lastNDays);
            
            Asset assetRec = [SELECT Asset_Age__c, Invoice_Date_New__c, 
                              (SELECT CreatedDate, FSD_DSP_Selection__c FROM workorders WHERE CreatedDate >= :dispatchCreatedDateToCompare
                               //and CountryCode == woInfo.CountryCode
                               AND (status != 'Open' and status != 'Cancelled')                               
                              ) 
                              FROM Asset WHERE id = :woInfo.AssetId LIMIT 1];
            if(assetRec.workorders.size()>0)
                strDSP = assetRec.workorders[0].FSD_DSP_Selection__c;
            return strDSP;
        }
        catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'DispatchCheckPreferences','repeatCheck','Dispatch Management');
            return '';
        }
    }
    private string getLinkPreference(WorkOrder woInfo)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getLinkPreference
    Description:  this functions get the link preference information
    Input: woInfo - work order information
    Output: DSP and other related information if available
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/06/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            string strDSP = '';
            List <LinkPreference__c> linkPrefList = new List<LinkPreference__c>();
            linkPrefList = (!mockedLinkPref.isEmpty()) ? mockedLinkPref :
                    [SELECT PreferenceType__c, CheckCoverage__c, ProviderCode__c, LOB__c 
                     FROM LinkPreference__c WHERE Account__c = :woInfo.AccountId LIMIT 100];
            for (LinkPreference__c linkPref : linkPrefList)  
            {
                if (linkPref.PreferenceType__c == 'Inclusion')  
                {
                    this.lpIncProviderName = linkPref.ProviderCode__c;
                    this.lpCheckCoverage = linkPref.CheckCoverage__c;
                    strDSP = linkPref.ProviderCode__c;
                }
                if (linkPref.PreferenceType__c == 'Exclusion')  
                {
                    this.lpExcProviderName = linkPref.ProviderCode__c;
                }
            }
            
            return strDSP;
        }
        catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'DispatchCheckPreferences','getLinkPreference','Dispatch Management');
            return '';
        }
    }
    
    private string getCustomerPreference(WorkOrder woInfo)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getCustomerPreference
    Description:  this functions get the account preference information
    Input: woInfo - work order information
    Output: DSP and other related information if available
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/06/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            string strDSP = '';
            List <ProviderPreference__c> accountPrefList = new List<ProviderPreference__c>();
            accountPrefList = (!mockedAccountPref.isEmpty()) ? mockedAccountPref :
                    [SELECT PreferenceType__c, CheckCoverage__c, ProviderCode__c, LOB__c 
                     FROM ProviderPreference__c WHERE Account__c = :woInfo.AccountId LIMIT 100];
            for (ProviderPreference__c accountPref : accountPrefList)  
            {
                if (accountPref.PreferenceType__c == 'Inclusion')  
                {
                    this.cpIncProviderName = accountPref.ProviderCode__c;
                    this.cpCheckCoverage = accountPref.CheckCoverage__c;
                    strDSP = accountPref.ProviderCode__c;
                }
                if (accountPref.PreferenceType__c == 'Exclusion')  
                {
                    this.cpExcProviderName = accountPref.ProviderCode__c;
                }
            }
            
            return strDSP;
        }
        catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'DispatchCheckPreferences','getCustomerPreference','Dispatch Management');
            return '';
        }
    }
    
    private string callGSCVforCheckCoverage(string recordId)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       callGSCVforCheckCoverage
    Description:  this functions makes a call to GSCV to check coverage
    Input: dispatch information
    Output: DSP and other related information if available
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    08/06/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            string strDSP = '';
            DispatchDefaults__c recordWOLine = [SELECT OutOfWarranty__c, Service_Type__c, selected_service_option__c, Billable__c,
                                                    Work_Order__r.ServiceTag__c,Work_Order__r.City,Work_Order__r.CityCalc__c, Work_Order__r.State, 
                                                    Work_Order__r.DPS_BUID__c,Work_Order__r.PostalCode, Work_Order__r.CountryCode__c, 
                                                    Work_Order__r.LOB__c,Work_Order__r.Region__c,Work_Order__r.Service_Type__c
                                                    FROM DispatchDefaults__c WHERE Work_Order__c = :recordId LIMIT 1];
            List<GetBestFitDSP__x> getBestFit = new List<GetBestFitDSP__x>();
            getBestFit = (!mockedBestFitDSP.isEmpty()) ? mockedBestFitDSP : [SELECT DSP__c, ISPDSPScheduleEnabled__c,  DSPSchedulingURL__c, CommunicationChannel__c FROM GetBestFitDSP__x 
                              WHERE ServiceTagId__c=:recordWOLine.Work_Order__r.ServiceTag__c AND BUID__c=:recordWOLine.Work_Order__r.DPS_BUID__c 
                              AND City__c = :recordWOLine.Work_Order__r.CityCalc__c AND State__c = :recordWOLine.Work_Order__r.State  AND ISOCountryCode__c = :recordWOLine.Work_Order__r.CountryCode__c  
                              AND Region__c = :recordWOLine.Work_Order__r.Region__c AND PostalCode__c = :recordWOLine.Work_Order__r.PostalCode 
                              AND ServiceSubType__c = :recordWOLine.Service_Type__c AND ServiceLevel__c = :recordWOLine.selected_service_option__c AND Billable__c = :recordWOLine.Billable__c 
                              AND LOB__c = :recordWOLine.Work_Order__r.LOB__c AND ItemClass__c = '1O002' AND OOWFlag__c = :recordWOLine.OutOfWarranty__c ? 'Y' : 'N'
                              AND ServiceHour__c = :recordWOLine.selected_service_option__c AND RegionID__c = :recordWOLine.Work_Order__r.Region__c];
            strDSP = getBestFit[0].DSP__c;
            return strDSP;
        }
        catch (Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchCheckPreferences','callGSCVforCheckCoverage','Dispatch Management');
            return null;
        }
    }
    
}
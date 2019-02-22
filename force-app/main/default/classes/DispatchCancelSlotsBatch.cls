/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchCancelSlotsBatch
Description: Batch class to Update Work Order Records - So that it will trigger OBM to Cancel the Slots
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
06/01/2018     1.0    Harsha Reddy       Initial Release
01/06/2019     2.0    Harsha & Carpio	 FY190102 - Jan Release        		
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class DispatchCancelSlotsBatch implements Database.Batchable<Sobject>,Database.Stateful{
    
    private Integer recordsProcessed = 0;
	private string query = '';
    private dateTime batchStartTime = System.now();
    
    public DispatchCancelSlotsBatch(String query) {
        this.query = query;
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name: Start
    Description: To collect the Work Order records to pass to the interface method execute
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    06/01/2018     1.0    Harsha Reddy       Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    public Database.querylocator start(Database.BatchableContext BC) {
        //string query = 'SELECT Id,ScheduleEndDate__c,ScheduleStartDate__c,DispatchEvent__c,StartDate,EndDate FROM WorkOrder WHERE Status IN (\'Pending Schedule\',\'Pending Review\',\'Awaiting Acknowledgement\',\'Approved\',\'Queued\') AND schedulingInternalLogic__c=\'Scheduled\' AND StartDate=TOMORROW';
        return Database.getQueryLocator(query); 
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name: Execute
    Description: This method is called for each batch of records that are passed to it. Will Update the field DispatchEvent__c 
				 to 'SCHEDULE_CANCEL'. So that it will trigger OBM Call to Cancel the Scheduled Slots With Partners.
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    06/01/2018     1.0    Harsha Reddy       Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    /*
    global void execute(Database.BatchableContext BC,List<WorkOrder> records) {
        // process each batch of records
        List<WorkOrder> wOrderList = new List<WorkOrder>();
        for(WorkOrder wOrder: records){                
            // set DispatchEvent to SCHEDULE_CANCEL
            wOrder.DispatchEvent__c='SCHEDULE_CANCEL';
            // Add to Update List
            wOrderList.add(wOrder);
            // increment the instance member counter
            recordsProcessed = recordsProcessed + 1;
        }
            
        if(!wOrderList.isEmpty() && wOrderList.size()>0){
        	// Update Work Order Records
        	Database.SaveResult[] srList = Database.update(wOrderList, false);
            ExceptionHandler.logHandledExceptions(srList, 'CancelScheduledSlots', 'execute', 'Dispatch Management');
    	}
    } 
	*/
    public void execute(Database.BatchableContext BC,List<WorkOrder> records) { 
        try{
            String countryCutoff = '';
            String strConvertedDateTime = '';
            String strConDate = '';
            DateTime currentTime;
            DateTime cutoffTime;
            Set<String> countryCodeSet = New Set<String>();
            Map<String,String> countryCutOffMap = new  Map<String,String> ();
            List<Asset_Country__mdt> assCountryList = new List<Asset_Country__mdt>();
            List<WorkOrder> updateWOrderList = new List<WorkOrder>();
            // Check if records Collection is Not Empty
            if(!records.isEmpty() && records!=null && records.size()>0) {
                // Loop thru all Work Order Records
                for(WorkOrder wo: records){  
                    // Check if Country Code is Not Blank
                    if(String.isNotBlank(wo.CountryCode)){
                        // Add the CountryCode to countryCodeSet Collection
                        countryCodeSet.add(wo.CountryCode);
                    }
                }
                // Check if countryCodeSet Collection is Not Empty
                if(!countryCodeSet.isEmpty() && countryCodeSet!=null && countryCodeSet.size()>0) {
                    if(!Test.isRunningTest()){
                    	assCountryList = [SELECT Id, CountryCode__c, CutOff__c, Active__c FROM Asset_cOuntry__mdt WHERE Active__c = true AND CountryCode__c IN: countryCodeSet LIMIT 50000];
                    } else{
                        assCountryList.add(new Asset_Country__mdt(CutOff__c=system.now().addHours(-1).format('HH:mm','America/Chicago'),Active__c=true,CountryCode__c='US'));
                        assCountryList.add(new Asset_Country__mdt(CutOff__c=system.now().addHours(-1).format('HH:mm','Australia/Perth'),Active__c=true,CountryCode__c='AU'));
                        assCountryList.add(new Asset_Country__mdt(CutOff__c=system.now().addHours(-1).format('HH:mm','Asia/Kolkata'),Active__c=true,CountryCode__c='IN'));
                    }
                    if(assCountryList!=null && !assCountryList.isEmpty() && assCountryList.size()>0){
                        for(Asset_cOuntry__mdt ass : assCountryList){
                            if(String.isNotBlank(ass.CountryCode__c) && String.isNotBlank(ass.CutOff__c)){
                                countryCutOffMap.put(ass.CountryCode__c,ass.CutOff__c);
                            }
                        }
                    }
                    if(!countryCutOffMap.isEmpty() && countryCutOffMap.size()>0 && countryCutOffMap!=null){
                        // Loop thru all Work Order Records
                        for(WorkOrder wo: records){
                            countryCutoff = '';
                            strConvertedDateTime = '';
                            strConDate = '';
                            currentTime = null;
                            cutoffTime = null;
                            // Check if Country Code is Not Blank
                            if(String.isNotBlank(wo.CountryCode)){
                                if(countryCutOffMap.containsKey(wo.CountryCode)){
                                    countryCutoff = countryCutOffMap.get(wo.CountryCode);
                                    if(String.isNotBlank(countryCutoff) && String.isNotBlank(wo.TimeZone__c)){
                                        strConvertedDateTime = System.now().format('yyyy-MM-dd HH:mm:ss',wo.TimeZone__c);
                                        currentTime = DateTime.ValueofGmt(strConvertedDateTime);
                                        strConDate = System.now().format('yyyy-MM-dd',wo.Timezone__c);
                                        cutoffTime = DateTime.ValueofGmt(strConDate+' '+countryCutoff+':00');
                                        if(currentTime>cutoffTime){
                                            Wo.DispatchEvent__c='SCHEDULE_CANCEL';
                                            updateWOrderList.add(wo);
                                            recordsProcessed = recordsProcessed + 1;
                                        }
                                    }
                                }
                            }
                        }   
                    }
                }
            }
            if(!updateWOrderList.isEmpty() && updateWOrderList.size()>0 && updateWOrderList!=null){
                // Update Work Order Records
                Database.SaveResult[] srList = Database.update(updateWOrderList, false);
                ExceptionHandler.logHandledExceptions(srList, 'DispatchCancelSlotsBatch', 'execute', 'Dispatch Management');
            }
        } catch(Exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchCancelSlotsBatch','execute','Dispatch Management');
        }
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name: Finish
    Description: To send confirmation email after post-processing all batch operations.
				 This method is called after all batches are processed.
    --------------------------------------------------------------------------------------------------------------------------
    Date         Version  Author             Summary of Change
    -----------  -------  -----------------  ---------------------------------------------------------------------------------
    06/01/2018     1.0    Harsha Reddy       Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    public void finish(Database.BatchableContext BC) {
        //Move Email Address to Custom Labels - Harsha
        /*
        EmailUtility.sendPlainTextEmail(new List<String>{'Service_Cloud_DEV_Admins@Dell.com'}, 
                                        'Dispatch Cancel Slots Batch Process Completed', 
                                        'Dispatch Cancel Slots Batch Process Processed : '+recordsProcessed);
		*/
        // Do Nothing
    }
}
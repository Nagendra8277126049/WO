/* -----------------------------------------------------------------------------------------------------------------------
Class Name:       AssetTriggerHandler
Description:           
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
               1.0                                  Initial Release
12/20/2018     1.1      Rayana Alencar              Adding the call for creation of Accidental Damage Notification
-------------------------------------------------------------------------------------------------------------------------- 
*/

// tdavis 2018-01-03 - added after update
trigger WorkOrderTrigger on WorkOrder (before update, before insert, after insert, after update)
{
    List<String> cityList = new List<String>();
    Map<String,Id> mapofcityname = new Map<String,Id>();
    if(!(Trigger_Execution_Control__c.getInstance().Skip_WorkOrder_Trigger__c)){
        if(Trigger.isBefore && Trigger.isInsert)
        {
            WorkOrderTriggerHandler.PopulateCityLookup(Trigger.new);
            WorkOrderTriggerHandler.mapLatamCountryStateonInsert(Trigger.new);
            //WorkOrderTriggerHandler.populateLatamAddressfields(Trigger.new);
             
        }
        
        if(Trigger.isAfter && Trigger.isInsert){
            WorkOrderTriggerHandler.populateLatamAddressfields(Trigger.new);
            //handle the AD Notifications  
            WorkOrderTriggerHandler.createAdNotification(Trigger.new); 
        }
        
        
        if(Trigger.isBefore && Trigger.isUpdate){
            //Call Helper.
            if(WorkOrderTriggerHandler.runonce){
                WorkOrderTriggerHandler.updateRegionIdonWorkOrder(Trigger.oldMap, Trigger.newMap);
                WorkOrderTriggerHandler.populateCities(Trigger.new,Trigger.oldMap);
                WorkOrderTriggerHandler.updateAddressonLatamUpdate(Trigger.oldMap,Trigger.new);
                WorkOrderTriggerHandler.deleteAlertOnRejectWorkOrder(Trigger.oldMap,Trigger.new);
                
           }
             //handle the AD Notifications  
             WorkOrderTriggerHandler.createAdNotification(Trigger.new);      
            
        }
    }

    // tdavis 2018-01-03 - added below if statement
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        Click_Integration_Settings__mdt settings =
        [
                SELECT Disable_WorkOrderTrigger__c
                FROM Click_Integration_Settings__mdt
                LIMIT 1
        ];

        if (!settings.Disable_WorkOrderTrigger__c)
        {
            Map<Id, List<ServiceAppointment>> workOrderIdToSAIdsMap = new Map<Id, List<ServiceAppointment>>();
            List<ServiceAppointment> saUpdates = new List<ServiceAppointment>();

            List<ServiceAppointment> serviceAppointments =
            [
                    SELECT Status, Work_Order__c
                    FROM ServiceAppointment
                    WHERE Work_Order__c IN :Trigger.new
            ];

            for (ServiceAppointment sa : serviceAppointments)
            {
                if (!workOrderIdToSAIdsMap.containsKey(sa.Work_Order__c))
                {
                    workOrderIdToSAIdsMap.put(sa.Work_Order__c, new List<ServiceAppointment>());
                }

                workOrderIdToSAIdsMap.get(sa.Work_Order__c).add(sa);
            }

            for (WorkOrder wo : Trigger.new)
            {
                if ((String) Trigger.oldMap.get(wo.Id).get('Status') != (String) Trigger.newMap.get(wo.Id).get('Status')
                        && wo.Status == 'Canceled')
                {
                    if (workOrderIdToSAIdsMap.get(wo.Id) != null)
                    {
                        for (ServiceAppointment sa : workOrderIdToSAIdsMap.get(wo.Id))
                        {
                            sa.Status = 'Canceled';
                            saUpdates.add(sa);
                        }
                    }
                }
            }

            update saUpdates;
        }
    }
    
    // lrf - Resource Schedulling Code
    for(WorkOrder wo : Trigger.New) {
        Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation DSP').getRecordTypeId();
        Id recordTypeIdBadge = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Badge').getRecordTypeId();
        System.debug(recordTypeId);
        if (wo.RecordTypeId == recordTypeId ) {
            System.debug('Record Type: Installation DSP');
            System.debug(wo.PartnerName__c);
             if (Trigger.isBefore) {
                    WorkOrderSchedulingTriggerHandler.PopulatePartnerDetailsFields(Trigger.new);
             }
             if (Trigger.isAfter && Trigger.isInsert) {
                 System.debug('Work Order Trigger - isAfter');
                 System.debug('wo Id: ' + wo.Id);
                 System.debug('wo Project_Task__c: ' + wo.Project_Task__c);
                
                 if (wo.Project_Task__c != null) {
                 
                     String regionName = '';
                     
                     List<pse__Project_Task__c> projectTask =
                        [
                                SELECT pse__Project__c
                                FROM pse__Project_Task__c
                                WHERE ID = :wo.Project_Task__c
                        ];
                        
                    for (pse__Project_Task__c pt: projectTask )
                    {
                    
                        System.debug('pse__Project__c: ' + pt.pse__Project__c);
                        
                        List<pse__Proj__c> project =
                        [
                            SELECT pse__Region__c 
                            FROM pse__Proj__c 
                            WHERE ID = :pt.pse__Project__c
                        ];
                        
                        for (pse__Proj__c p: project) {
                            System.debug('pse__Region__c : ' + p.pse__Region__c );
                            
                            List<pse__Region__c> region =
                            [
                                SELECT Name, pse__Parent_Region__c 
                                FROM pse__Region__c 
                                WHERE ID = :p.pse__Region__c
                            ];
                            
                            for (pse__Region__c r: region) {
                                regionName = r.Name;
                                
                                if (regionName != 'Americas' && regionName != 'APJ' && regionName != 'EMEA') {
                                   region = [
                                               SELECT Name 
                                               FROM pse__Region__c 
                                               WHERE ID = :r.pse__Parent_Region__c
                                            ];
                                   
                                   for (pse__Region__c parentRegion: region) {
                                       regionName = parentRegion.Name.toUpperCase();
                                   }
                                }
                            }
                        }
                        
                    }
                    
                    System.debug('regionName :' + regionName);
                     
                    WorkOrderPreferredPartnerFromGscvService.getPreferredPartnerFromGscv(wo.Id, wo.CountryCode, wo.State, wo.City, wo.PostalCode, regionName);
                 }
             }
        }
        if (wo.RecordTypeId == recordTypeIdBadge ) {
             if (Trigger.isBefore && Trigger.isInsert) {
                    WorkOrderSchedulingTriggerHandler.CheckWorkOrderStatus(Trigger.new);
             }
        }
    } 
}
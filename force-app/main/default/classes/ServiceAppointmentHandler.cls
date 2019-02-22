/*
      Purpose:
            When possible, set the Project lookup on Service Appointment upon creation, so that all project
            related service appointments will be easily visible to the project manager.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/13/18

    =============================================================================================================
    Modification History:
    ----------------------------------------------------------------------------
    Name        Date        Company             Description
    ----------------------------------------------------------------------------
    Pawan K     1/8/19      OAC Services INC.   Added Before Updated event to clone
                                                related Work Orders.
                                                Method : workOrderCloneController 
    ----------------------------------------------------------------------------
*/

public class ServiceAppointmentHandler {
    private static String WORK_ORDER_ID_PREFIX = WorkOrder.SObjectType.getDescribe().getKeyPrefix();
    public static void populateProjectLookup(List<ServiceAppointment> triggerNew) {
        Set<Id> workOrderIds = new Set<Id>();
        List<ServiceAppointment> woSas = new List<ServiceAppointment>();
        for (ServiceAppointment sa:triggerNew) {
            String parentIdString = sa.ParentRecordId;
            if (parentIdString.startsWith(WORK_ORDER_ID_PREFIX)) {
                workOrderIds.add(sa.ParentRecordId);
                woSas.add(sa);
            }
        }
        if (!woSas.isEmpty()) {
            Map<Id,WorkOrder> workOrderMap = new Map<Id,WorkOrder>([SELECT Project_Task__c FROM WorkOrder WHERE Id in :workOrderIds AND Project_Task__c != NULL]);
            Set<Id> projectTaskIds = new Set<Id>();
            for (WorkOrder wo:workOrderMap.values()) {
                projectTaskIds.add(wo.Project_Task__c);
            }
            Map<Id,pse__Project_Task__c> projectTaskMap =
                    new Map<Id,pse__Project_Task__c>(
                    [SELECT pse__Project__c FROM pse__Project_Task__c WHERE Id IN :projectTaskIds]);
            for (ServiceAppointment sa: woSas) {
                WorkOrder wo = workOrderMap.get(sa.ParentRecordId);
                if (wo != null) {
                    pse__Project_Task__c pt = projectTaskMap.get(wo.Project_Task__c);
                    if (pt != null) {
                        sa.Project__c = pt.pse__Project__c;
                        sa.Work_Order__c = wo.Id;
                    }
                }
            }
        }
    }

    // tdavis 2018-11-01 - added below method
    @Future(callout=true)
    public static void cancelClickTask(Id saId)
    {
        Click_Integration_Settings__mdt settings =
        [
                SELECT Development_Username__c, Development_Password__c, Production_Username__c, Production_Password__c,
                        Is_Production__c, ProcessTaskEx_Endpoint_URL__c
                FROM Click_Integration_Settings__mdt
            	WHERE DeveloperName = 'Settings'
                LIMIT 1
        ];

        String username = settings.Is_Production__c ? settings.Production_Username__c : settings.Development_Username__c;
        String password = settings.Is_Production__c ? settings.Production_Password__c : settings.Development_Password__c;

        ServiceAppointment sa =
        [
                SELECT Work_Order__r.WorkOrderNumber, Work_Order__r.ContactId, Duration, Work_Order__r.Contact.Phone,
                        EarliestStartTime, DueDate, SchedEndTime, SchedStartTime, Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name,
                        Work_Order__r.AssetId, Description, Work_Order__r.Project_Task__r.pse__Project__r.Pre_Implementation_Validation__c,
                        Work_Order__r.Id, Number__c, Work_Order__r.Latitude, Work_Order__r.Longitude, DurationType, Work_Order__c,
                        Work_Order__r.Contact.Time_Zone__c, City, State, Street, PostalCode, Country, Integration_Message__c,
                        Status, Assignee__c, Click_Task_Cancelled__c
                FROM ServiceAppointment
                WHERE Id = :saId
        ];

        CancelTaskRequest ctr = new CancelTaskRequest();
        ctr.Task.objectType = 'Task';
        ctr.Task.createOrUpdate = true;
        ctr.Task.CallID = sa.Work_Order__r.Id;
        ctr.Task.ExternalRefID = sa.Id;
        ctr.Task.Number_Z = Integer.valueOf(sa.Number__c);
        ctr.Task.Status.Name = 'Cancelled';
        ctr.ReturnAssignment = false;
        ctr.ReturnSchedulingError = true;
        ctr.TaskRequestedProperties.addAll(new List<String>
        {
                'CallID', 'Number', 'ExternalRefID'
        });

        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.ProcessTaskEx_Endpoint_URL__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
        request.setBodyAsBlob(Blob.valueOf(JSON.serialize(ctr)
                .replace('objectType', '@objectType')
                .replace('createOrUpdate', '@createOrUpdate')
                .replace('Number_Z', 'Number')
        ));
        request.setMethod('POST');

        System.debug('Request: ' + request.getBody());

        HttpResponse response = new Http().send(request);

        CancelTaskResponse deserializedResponse = CancelTaskResponse.parse(response.getBody()
                .replace('@objectType', 'objectType'));

        if (deserializedResponse.ReturnCode == 'ScheduleFailed')
        {
            sa.Click_Task_Cancelled__c = true;
        }

        update sa;
    }

    public static void setNumberField(List<ServiceAppointment> serviceAppointments)
    {
        Map<Id, List<ServiceAppointment>> workOrderToServiceAppointmentMap = new Map<Id, List<ServiceAppointment>>();
        Set<Id> workOrderIds = new Set<Id>();
        List<ServiceAppointment> serviceAppointmentUpdates = new List<ServiceAppointment>();

        for (ServiceAppointment sa : serviceAppointments)
        {
            workOrderIds.add(sa.Work_Order__c);
        }

        for (ServiceAppointment sa : [ SELECT Number__c, Work_Order__c FROM ServiceAppointment WHERE Work_Order__c IN :workOrderIds ])
        {
            if (!workOrderToServiceAppointmentMap.containsKey(sa.Work_Order__c))
            {
                workOrderToServiceAppointmentMap.put(sa.Work_Order__c, new List<ServiceAppointment>());
            }

            workOrderToServiceAppointmentMap.get(sa.Work_Order__c).add(sa);
        }

        for (ServiceAppointment sa : serviceAppointments)
        {
            Integer numberOfServiceAppointments = workOrderToServiceAppointmentMap.get(sa.Work_Order__c).size();
            List<ServiceAppointment> sasToUpdate = [ SELECT Number__c FROM ServiceAppointment WHERE Id IN :serviceAppointments];

            for (ServiceAppointment saToUpdate : sasToUpdate)
            {
                if (numberOfServiceAppointments > 1)
                {
                    saToUpdate.Number__c = numberOfServiceAppointments - 1;
                    serviceAppointmentUpdates.add(saToUpdate);
                }
            }
        }

        update serviceAppointmentUpdates;
    }
    
    public static void workOrderCloneController( List<ServiceAppointment> serviceAppointments, map<Id,ServiceAppointment> oldMapServiceAppointments)
    {
        set<Id> workOrderIds = new set<Id>();
        
        //Custom Setting 
        Trigger_Execution_Control__c triggerControl = Trigger_Execution_Control__c.getOrgDefaults();
        
        //trigger is active?
        if( !triggerControl.Skip_Work_Order_Cloning__c )
        {
            //Get valid Work Orders
            for( ServiceAppointment objSA : serviceAppointments )
            {
                if( objSA.Status == 'Cannot Complete' && objSA.Status != oldMapServiceAppointments.get(objSA.Id).Status )
                {
                    workOrderIds.add(objSA.Work_Order__c);
                }
            }
            
            //callout to clone work orders
            if( !workOrderIds.isEmpty() )
            {
                ServiceAppointmentCloneWorkOrders.cloneWorkOrders(workOrderIds);
            }
        }
    }
}
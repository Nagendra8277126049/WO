/**
 * Created by tdavis on 10/23/18.
 */

public with sharing class GetAppointmentsController
{
    private static Boolean excludeContinent = false;

    @AuraEnabled
    public static ServiceAppointment getSA(Id serviceAppointmentId)
    {
        ServiceAppointment sa =
        [
                SELECT Work_Order__r.WorkOrderNumber, Work_Order__r.ContactId, Duration, Work_Order__r.Contact.Phone,
                        EarliestStartTime, DueDate, SchedEndTime, SchedStartTime, Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__c,
                        Work_Order__r.AssetId, Description, Work_Order__r.Schedule_Type__c, GeocodeAccuracy__c
                FROM ServiceAppointment
                WHERE Id = :serviceAppointmentId
        ];

        return sa;
    }

    @AuraEnabled
    public static Map<String, String> getAppointmentsCallout(Id saId)
    {
        Click_Integration_Settings__mdt settings =
        [
                SELECT Development_Username__c, Development_Password__c, Production_Username__c, Production_Password__c,
                        Is_Production__c, GetAppointments_Endpoint_URL__c, ProcessTaskEx_Endpoint_URL__c
                FROM Click_Integration_Settings__mdt
            	WHERE DeveloperName = 'Settings'
                LIMIT 1
        ];

        String username = settings.Is_Production__c ? settings.Production_Username__c : settings.Development_Username__c;
        String password = settings.Is_Production__c ? settings.Production_Password__c : settings.Development_Password__c;

        String payloadString = '';
        Map<String, String> slotMap = new Map<String, String>();

        ServiceAppointment sa =
        [
                SELECT Work_Order__r.WorkOrderNumber, Work_Order__r.ContactId, Duration, Work_Order__r.Contact.Phone,
                        EarliestStartTime, DueDate, SchedEndTime, SchedStartTime, Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name,
                        Work_Order__r.AssetId, Description, Work_Order__r.Project_Task__r.pse__Project__r.Pre_Implementation_Validation__c,
                        Work_Order__r.Id, Number__c, Work_Order__r.Latitude, Work_Order__r.Longitude, DurationType, Work_Order__c,
                        Work_Order__r.Contact.TimeZone__c, Work_Order__r.Delivery_Method__c, Work_Order__r.Project_Task__r.pse__Project__c, Longitude,
                        Latitude, Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name, Assist_Service_Appointment__c, Required_Engineer_SA__r.Assignee__r.Badge_Id__c,
                        Excluded_Engineer_SA__r.Assignee__r.Badge_Id__c, Required_Engineer_SA__c, Excluded_Engineer_SA__c
                FROM ServiceAppointment
                WHERE Id = :saId
        ];

        if (sa.Work_Order__r.Project_Task__r.pse__Project__r.Pre_Implementation_Validation__c)
        {
            List<ServiceAppointment> relatedSA =
            [
                    SELECT Work_Order__r.WorkOrderNumber, Work_Order__r.ContactId, Duration, Work_Order__r.Contact.Phone,
                            EarliestStartTime, DueDate, SchedEndTime, SchedStartTime, Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name,
                            Work_Order__r.AssetId, Description, Work_Order__r.Project_Task__r.pse__Project__r.Pre_Implementation_Validation__c,
                            Work_Order__r.Id, Number__c, Work_Order__r.Latitude, Work_Order__r.Longitude, DurationType, Work_Order__c,
                            Work_Order__r.Contact.TimeZone__c, Work_Order__r.Delivery_Method__c, Work_Order__r.Project_Task__r.pse__Project__c, Longitude,
                            Latitude, Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name, Assist_Service_Appointment__c
                    FROM ServiceAppointment
                    WHERE Id != :sa.Id
                    AND Work_Order__c = :sa.Work_Order__c
                    LIMIT 1
            ];

            // construct Pre-Imp payload
            GetAppsPreImpTaskRequest gapitr = new GetAppsPreImpTaskRequest(sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false);
            gapitr.Task.objectType = 'Task';
            gapitr.Task.createOrUpdate = true;
            gapitr.Task.CallID = sa.Work_Order__r.WorkOrderNumber;
            gapitr.Task.ExternalRefId = sa.Id;
            gapitr.Task.Number_Z = Integer.valueOf(sa.Number__c);
            gapitr.Task.EarlyStart = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            gapitr.Task.DueDate = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            gapitr.Task.Latitude = String.valueOf(Integer.valueOf(sa.Latitude * 1000000));
            gapitr.Task.Longitude = String.valueOf(Integer.valueOf(sa.Longitude * 1000000));
            gapitr.Task.Duration = convertDurationToSeconds(sa.DurationType, sa.Duration);
            gapitr.Task.IsAppointment = true;
            gapitr.Task.PS_Timezone.Name = sa.Work_Order__r.Contact.TimeZone__c; //'America/New_York'; // needs mapping
            gapitr.Task.TaskType.Name = sa.Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name; //'DELIVERY AND IMPLEMENTATION'; // needs mapping
            gapitr.Task.PS_BusinessUnit.Name = sa.Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name; //'IDS';
            gapitr.Task.RequiredSkills1 = sa.Assist_Service_Appointment__c ? new List<GetAppsPreImpTaskRequest.RequiredSkills1>() : getSkillsPreImpTask(sa.Work_Order__r.Id);
            gapitr.Task.Critical = true;
            if (sa.Required_Engineer_SA__c != null)
            {
                GetAppsPreImpTaskRequest.RequiredEngineers requiredEngineer = new GetAppsPreImpTaskRequest.RequiredEngineers();
                requiredEngineer.ID = sa.Required_Engineer_SA__r.Assignee__r.Badge_Id__c;
                gapitr.Task.RequiredEngineers.add(requiredEngineer); // needs mapping - optional and multiple
            }
            gapitr.Task.PS_IsRemote = sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false;
            gapitr.Task.WorkingArea.Key = -1;
            GetAppsPreImpTaskRequest.TimeDependencies timeDependency = new GetAppsPreImpTaskRequest.TimeDependencies();
            timeDependency.objectType = 'TaskTimeDependency';
            timeDependency.TaskKey.ExternalRefID = relatedSA[0].Id;
            timeDependency.UpperBound = 0;
            timeDependency.LowerBound = 0;
            timeDependency.RelationType = 1;
            timeDependency.RelationOperator = 0;
            timeDependency.Critical = false;
            gapitr.Task.TimeDependencies.add(timeDependency);
            GetAppsPreImpTaskRequest.EngineerDependencies engineerDependency = new GetAppsPreImpTaskRequest.EngineerDependencies();
            engineerDependency.TaskKey.ExternalRefID = relatedSA[0].Id;
            engineerDependency.RelationType = 2;
            gapitr.Task.EngineerDependencies.add(engineerDependency);
            GetAppsPreImpTaskRequest.InnerArray ia = new GetAppsPreImpTaskRequest.InnerArray(relatedSA[0].Work_Order__r.Delivery_Method__c == 'Remote' ? true : false);
            ia.createOrUpdate = true;
            ia.CallID = sa.Work_Order__r.WorkOrderNumber;
            ia.ExternalRefId = relatedSA[0].Id;
            ia.Number_Z = Integer.valueOf(relatedSA[0].Number__c);
            ia.EarlyStart = String.valueOf(relatedSA[0].EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            ia.DueDate = String.valueOf(relatedSA[0].DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            ia.Latitude = String.valueOf(Integer.valueOf(relatedSA[0].Latitude * 1000000));
            ia.Longitude = String.valueOf(Integer.valueOf(relatedSA[0].Longitude * 1000000));
            ia.Duration = convertDurationToSeconds(relatedSA[0].DurationType, sa.Duration);
            ia.IsAppointment = true;
            ia.PS_Timezone.Name = relatedSA[0].Work_Order__r.Contact.TimeZone__c;
            ia.TaskType.Name = sa.Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name; //'DELIVERY AND IMPLEMENTATION'; // needs mapping
            ia.PS_BusinessUnit.Name = relatedSA[0].Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name; //'IDS';
            ia.RequiredSkills1 = sa.Assist_Service_Appointment__c ? new List<GetAppsPreImpTaskRequest.RequiredSkills1>() : getSkillsPreImpTask(relatedSA[0].Work_Order__r.Id);
            ia.Critical = true;
            ia.PS_IsRemote = relatedSA[0].Work_Order__r.Delivery_Method__c == 'Remote' ? true : false;
            ia.WorkingArea.Key = -1;
            gapitr.RelatedTasks.InnerArray.add(ia);
            gapitr.TimeOut = 1440;
            gapitr.Profile = 'Hard Starts';
            gapitr.Period.Start = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            gapitr.Period.Finish = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            GetAppsPreImpTaskRequest.InnerArray_Z iaz = new GetAppsPreImpTaskRequest.InnerArray_Z();
            iaz.objectType = 'Task';
            iaz.ExternalRefID = relatedSA[0].Id;
            gapitr.SameSlotTasks.InnerArray.add(iaz);

            payloadString = JSON.serialize(gapitr, true);
        }

        else
        {
            GetAppsPlanningTaskRequest gaptr = new GetAppsPlanningTaskRequest(sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false);
            gaptr.Task.objectType = 'Task';
            gaptr.Task.createOrUpdate = true;
            gaptr.Task.CallID = sa.Work_Order__r.WorkOrderNumber; //'IDS002';
            gaptr.Task.ExternalRefId = sa.Id; //'IDS002';
            gaptr.Task.Number_Z = Integer.valueOf(sa.Number__c); //1;
            gaptr.Task.DueDate = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-29T18:00:00';
            gaptr.Task.EarlyStart = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-27T10:00:00';
            gaptr.Task.Latitude = String.valueOf(Integer.valueOf(sa.Latitude * 1000000)); //'37868058';
            gaptr.Task.Longitude = String.valueOf(Integer.valueOf(sa.Longitude * 1000000)); //'-122285237';
            gaptr.Task.Duration = convertDurationToSeconds(sa.DurationType, sa.Duration); //14400;
            gaptr.Task.IsAppointment = true;
            gaptr.Task.PS_Timezone.Name = sa.Work_Order__r.Contact.TimeZone__c; //'America/Chicago'; //sa.Work_Order__r.Contact.Time_Zone__c;
            gaptr.Task.TaskType.Name = sa.Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name; //'DELIVERY AND IMPLEMENTATION'; // needs mapping
            if (sa.Required_Engineer_SA__c != null)
            {
                GetAppsPlanningTaskRequest.RequiredEngineers requiredEngineer = new GetAppsPlanningTaskRequest.RequiredEngineers();
                requiredEngineer.ID = sa.Required_Engineer_SA__r.Assignee__r.Badge_Id__c;
                gaptr.Task.RequiredEngineers.add(requiredEngineer); // needs mapping - optional and multiple
            }
            if (sa.Excluded_Engineer_SA__c != null)
            {
                GetAppsPlanningTaskRequest.ExcludedEngineers excludedEngineer = new GetAppsPlanningTaskRequest.ExcludedEngineers();
                excludedEngineer.ID = sa.Excluded_Engineer_SA__r.Assignee__r.Badge_Id__c;
                gaptr.Task.ExcludedEngineers.add(excludedEngineer); // needs mapping - optional and multiple
            }
            gaptr.Task.PS_BusinessUnit.Name = sa.Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name; //'IDS';
            gaptr.Task.RequiredSkills1 = sa.Assist_Service_Appointment__c ? new List<GetAppsPlanningTaskRequest.RequiredSkills1>() : getSkillsPlanningTask(sa.Work_Order__r.Id); //new List<GetAppsPlanningTaskRequest.RequiredSkills1>();
            gaptr.Task.PS_IsRemote = sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false;
            gaptr.Task.WorkingArea.Key = -1;
            gaptr.TimeOut = 9999;
            gaptr.Profile = 'Hard Starts';
            gaptr.Period.Start = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-27T00:00:00';
            gaptr.Period.Finish = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-29T12:00:00';

            payloadString = JSON.serialize(gaptr, true);
        }


        HttpRequest request = constructRequest(settings.GetAppointments_Endpoint_URL__c, payloadString, username, password);

        System.debug('Request: ' + request.getBody());

        HttpResponse response = new Http().send(request);

        System.debug(response.getBody());

        GetAppsResponse deserializedResponse = GetAppsResponse.parse(response.getBody());

        System.debug('Response: ' + deserializedResponse);

        if (sa.Work_Order__r.Delivery_Method__c == 'Remote' && deserializedResponse.TimeInterval == null)
        {
            excludeContinent = true;

            GetAppsPlanningTaskRequest gaptr2 = new GetAppsPlanningTaskRequest(false);
            gaptr2.Task.objectType = 'Task';
            gaptr2.Task.createOrUpdate = true;
            gaptr2.Task.CallID = sa.Work_Order__r.WorkOrderNumber; //'IDS002';
            gaptr2.Task.ExternalRefId = sa.Id; //'IDS002';
            gaptr2.Task.Number_Z = Integer.valueOf(sa.Number__c); //1;
            gaptr2.Task.DueDate = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-29T18:00:00';
            gaptr2.Task.EarlyStart = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-27T10:00:00';
            gaptr2.Task.Latitude = String.valueOf(Integer.valueOf(sa.Latitude * 1000000)); //'37868058';
            gaptr2.Task.Longitude = String.valueOf(Integer.valueOf(sa.Longitude * 1000000)); //'-122285237';
            gaptr2.Task.Duration = convertDurationToSeconds(sa.DurationType, sa.Duration); //14400;
            gaptr2.Task.IsAppointment = true;
            gaptr2.Task.PS_Timezone.Name = sa.Work_Order__r.Contact.TimeZone__c; //'America/Chicago'; //sa.Work_Order__r.Contact.Time_Zone__c;
            gaptr2.Task.TaskType.Name = sa.Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name; //'DELIVERY AND IMPLEMENTATION'; // needs mapping
            if (sa.Required_Engineer_SA__c != null)
            {
                GetAppsPlanningTaskRequest.RequiredEngineers requiredEngineer = new GetAppsPlanningTaskRequest.RequiredEngineers();
                requiredEngineer.ID = sa.Required_Engineer_SA__r.Assignee__r.Badge_Id__c;
                gaptr2.Task.RequiredEngineers.add(requiredEngineer); // needs mapping - optional and multiple
            }
            if (sa.Excluded_Engineer_SA__c != null)
            {
                GetAppsPlanningTaskRequest.ExcludedEngineers excludedEngineer = new GetAppsPlanningTaskRequest.ExcludedEngineers();
                excludedEngineer.ID = sa.Excluded_Engineer_SA__r.Assignee__r.Badge_Id__c;
                gaptr2.Task.ExcludedEngineers.add(excludedEngineer); // needs mapping - optional and multiple
            }
            gaptr2.Task.PS_BusinessUnit.Name = sa.Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name; //'IDS';
            gaptr2.Task.RequiredSkills1 = sa.Assist_Service_Appointment__c ? new List<GetAppsPlanningTaskRequest.RequiredSkills1>() : getSkillsPlanningTask(sa.Work_Order__r.Id); //new List<GetAppsPlanningTaskRequest.RequiredSkills1>();
            gaptr2.Task.PS_IsRemote = sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false;
            gaptr2.Task.WorkingArea.Key = -1;
            gaptr2.TimeOut = 9999;
            gaptr2.Profile = 'Hard Starts';
            gaptr2.Period.Start = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-27T00:00:00';
            gaptr2.Period.Finish = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-29T12:00:00';

            payloadString = JSON.serialize(gaptr2, true);

            HttpRequest request2 = constructRequest(settings.GetAppointments_Endpoint_URL__c, payloadString, username, password);

            System.debug('Request 2: ' + request2.getBody());

            HttpResponse response2 = new Http().send(request2);

            System.debug(response2.getBody());

            deserializedResponse = GetAppsResponse.parse(response2.getBody());

            System.debug('Response 2: ' + deserializedResponse);
        }

        if (deserializedResponse.TimeInterval != null)
        {
            Integer numberOfSlotsInMap = 0;
            for (GetAppsResponse.TimeInterval slot : deserializedResponse.TimeInterval)
            {
                if (numberOfSlotsInMap < 10)
                {
                    slotMap.put(formatDate(slot.Start), JSON.serialize(slot));
                    numberOfSlotsInMap++;
                }
            }
        }

        System.debug(slotMap);

        return slotMap;
    }

    @AuraEnabled
    public static String processTaskExCallout(Id saId, String slot, Boolean isSLA, Boolean isAppointmentTask)
    {
        Click_Integration_Settings__mdt settings =
        [
                SELECT Development_Username__c, Development_Password__c, Production_Username__c, Production_Password__c,
                        Is_Production__c, GetAppointments_Endpoint_URL__c, ProcessTaskEx_Endpoint_URL__c
                FROM Click_Integration_Settings__mdt
            	WHERE DeveloperName = 'Settings'
                LIMIT 1
        ];

        String username = settings.Is_Production__c ? settings.Production_Username__c : settings.Development_Username__c;
        String password = settings.Is_Production__c ? settings.Production_Password__c : settings.Development_Password__c;

        String payloadString = '';

        ServiceAppointment sa =
        [
                SELECT Work_Order__r.WorkOrderNumber, Work_Order__r.ContactId, Duration, Work_Order__r.Contact.Phone,
                        EarliestStartTime, DueDate, SchedEndTime, SchedStartTime, Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name,
                        Work_Order__r.AssetId, Description, Work_Order__r.Project_Task__r.pse__Project__r.Pre_Implementation_Validation__c,
                        Work_Order__r.Id, Number__c, Work_Order__r.Latitude, Work_Order__r.Longitude, DurationType, Work_Order__c,
                        Work_Order__r.Contact.TimeZone__c, City, State, Street, PostalCode, Country, Integration_Message__c,
                        Status, Assignee__c, Work_Order__r.Delivery_Method__c, Work_Order__r.Project_Task__r.pse__Project__c, Project__r.pse__Start_Date__c,
                        Project__r.pse__End_Date__c, Project__r.Id, Work_Order__r.Project_Task__r.Id, Project__r.pse__Project_ID__c,
                        AppointmentNumber, Project__r.OpenText_Node_ID__c, Longitude, Latitude, Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name,
                        Assist_Service_Appointment__c, Assignment__c, Required_Engineer_SA__r.Assignee__r.Badge_Id__c, Excluded_Engineer_SA__r.Assignee__r.Badge_Id__c,
                        Required_Engineer_SA__c, Excluded_Engineer_SA__c, Project__r.pse__Account__r.Name
                FROM ServiceAppointment
                WHERE Id = :saId
        ];

        if (isSLA)
        {
            ProcessTaskExSLARequest ptexslar = new ProcessTaskExSLARequest(excludeContinent == true ? false : sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false);
            ptexslar.Task.objectType = 'Task';
            ptexslar.Task.createOrUpdate = true;
            ptexslar.Task.CallID = sa.Work_Order__r.WorkOrderNumber;
            ptexslar.Task.ExternalRefId = sa.Id;
            ptexslar.Task.Number_Z = Integer.valueOf(sa.Number__c); //1;
            ptexslar.Task.DueDate = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            ptexslar.Task.EarlyStart = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            ptexslar.Task.City = sa.City;
            ptexslar.Task.State = sa.State;
            ptexslar.Task.Street = sa.Street;
            ptexslar.Task.Postcode = sa.PostalCode;
            ptexslar.Task.CountryID.Name = sa.Country;
            ptexslar.Task.PS_TimeZone.Name = sa.Work_Order__r.Contact.TimeZone__c; //'America/Chicago'; //sa.Work_Order__r.Contact.Time_Zone__c;
            ptexslar.Task.PS_BusinessUnit.Name = sa.Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name; //'IDS'; //sa.Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name;
            if (sa.Required_Engineer_SA__c != null)
            {
                ProcessTaskExSLARequest.RequiredEngineers requiredEngineer = new ProcessTaskExSLARequest.RequiredEngineers();
                requiredEngineer.ID = sa.Required_Engineer_SA__r.Assignee__r.Badge_Id__c;
                ptexslar.Task.RequiredEngineers.add(requiredEngineer); // needs mapping - optional and multiple
            }
            if (sa.Excluded_Engineer_SA__c != null)
            {
                ProcessTaskExSLARequest.ExcludedEngineers excludedEngineer = new ProcessTaskExSLARequest.ExcludedEngineers();
                excludedEngineer.ID = sa.Excluded_Engineer_SA__r.Assignee__r.Badge_Id__c;
                ptexslar.Task.ExcludedEngineers.add(excludedEngineer); // needs mapping - optional and multiple
            }
            ptexslar.Task.TaskType.Name = sa.Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name; //'DELIVERY AND IMPLEMENTATION'; // needs mapping
            ptexslar.Task.Latitude = String.valueOf(Integer.valueOf(sa.Latitude * 1000000));
            ptexslar.Task.Longitude = String.valueOf(Integer.valueOf(sa.Longitude * 1000000));
            ptexslar.Task.Duration = convertDurationToSeconds(sa.DurationType, sa.Duration);
            ptexslar.Task.RequiredSkills1 = sa.Assist_Service_Appointment__c ? new List<ProcessTaskExSLARequest.RequiredSkills1>() : getSkillsTaskSLA(sa.Work_Order__r.Id);
            ptexslar.Task.PS_IsRemote = sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false;
            ptexslar.Task.WorkingArea.Key = -1;
            ptexslar.Task.PS_WorkOrderNumber_String = sa.Work_Order__r.WorkOrderNumber;
            ptexslar.Task.PS_SRNumber_String = sa.Project__r.pse__Project_ID__c;
            ptexslar.Task.PS_SANumber = sa.AppointmentNumber;
            ptexslar.Task.PS_SRID = sa.Project__r.Id;
            ptexslar.Task.PS_WorkOrderID = sa.Work_Order__r.Id;
            ptexslar.Task.PS_OpenTextNodeID = sa.Project__r.OpenText_Node_ID__c;
            ptexslar.Task.Customer = sa.Project__r.pse__Account__r.Name;
            ptexslar.TaskRequestedProperties.addAll(new List<String>
            {
                    'CallID', 'Number', 'ExternalRefID', 'Status'
            });
            ptexslar.AssignmentRequestedProperties.addAll(new List<String>
            {
                    'Task', 'Start', 'Finish', 'PS_EngineerID'
            });
            ptexslar.ReturnAssignment = true;
            ptexslar.ReturnSchedulingError = true;

            payloadString = JSON.serialize(ptexslar, true);
        }
        else
        {
            GetAppsResponse.TimeInterval deserializedSlot;

            if (!isAppointmentTask)
            {
                deserializedSlot = (GetAppsResponse.TimeInterval) JSON.deserialize(slot, GetAppsResponse.TimeInterval.class);
            }

            ProcessTaskExTechnicalRequest ptextr = new ProcessTaskExTechnicalRequest(excludeContinent == true ? false : sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false);
            ptextr.Task.objectType = 'Task';
            ptextr.Task.createOrUpdate = true;
            ptextr.Task.CallID = sa.Work_Order__r.WorkOrderNumber; //'IDS002';
            ptextr.Task.ExternalRefId = sa.Id; //'IDS002';
            ptextr.Task.Number_Z = Integer.valueOf(sa.Number__c); //1;
            ptextr.Task.AppointmentStart = isAppointmentTask == true ? '1899-12-30T00:00:00' : deserializedSlot.Start;
            ptextr.Task.AppointmentFinish = isAppointmentTask == true ? '1899-12-30T00:00:00' : deserializedSlot.Finish;
            ptextr.Task.DueDate = String.valueOf(sa.DueDate.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-29T18:00:00';
            ptextr.Task.EarlyStart = String.valueOf(sa.EarliestStartTime.format('yyyy-MM-dd\'T\'HH:mm:ss')); //'2018-11-27T10:00:00';
            ptextr.Task.Latitude = String.valueOf(Integer.valueOf(sa.Latitude * 1000000)); //'37868058';
            ptextr.Task.Longitude = String.valueOf(Integer.valueOf(sa.Longitude * 1000000)); //'-122285237';
            ptextr.Task.Duration = convertDurationToSeconds(sa.DurationType, sa.Duration); //3600;
            ptextr.Task.City = sa.City;
            ptextr.Task.State = sa.State; 
            ptextr.Task.Street = sa.Street;
            ptextr.Task.Postcode = sa.PostalCode;
            ptextr.Task.CountryID.Name = sa.Country;
            ptextr.Task.PS_TimeZone.Name = sa.Work_Order__r.Contact.TimeZone__c; //'America/Chicago'; //sa.Work_Order__r.Contact.Time_Zone__c; //'America/New_York';
            ptextr.Task.TaskType.Name = sa.Work_Order__r.Project_Task__r.pse__Top_level_Parent_Task__r.Name; //'DELIVERY AND IMPLEMENTATION'; // needs mapping
            ptextr.Task.PS_BusinessUnit.Name = sa.Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name; //'IDS'; //sa.Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name;
            ptextr.Task.RequiredSkills1 = sa.Assist_Service_Appointment__c ? new List<ProcessTaskExTechnicalRequest.RequiredSkills1>() : getSkillsTaskTechnical(sa.Work_Order__r.Id); //new List<ProcessTaskExTechnicalRequest.RequiredSkills1>();
            if (sa.Required_Engineer_SA__c != null)
            {
                ProcessTaskExTechnicalRequest.RequiredEngineers requiredEngineer = new ProcessTaskExTechnicalRequest.RequiredEngineers();
                requiredEngineer.ID = sa.Required_Engineer_SA__r.Assignee__r.Badge_Id__c;
                ptextr.Task.RequiredEngineers.add(requiredEngineer); // needs mapping - optional and multiple
            }
            if (sa.Excluded_Engineer_SA__c != null)
            {
                ProcessTaskExTechnicalRequest.ExcludedEngineers excludedEngineer = new ProcessTaskExTechnicalRequest.ExcludedEngineers();
                excludedEngineer.ID = sa.Excluded_Engineer_SA__r.Assignee__r.Badge_Id__c;
                ptextr.Task.ExcludedEngineers.add(excludedEngineer); // needs mapping - optional and multiple
            }
            ptextr.Task.PS_IsRemote = sa.Work_Order__r.Delivery_Method__c == 'Remote' ? true : false;
            ptextr.Task.WorkingArea.Key = -1;
            ptextr.Task.PS_WorkOrderNumber_String = sa.Work_Order__r.WorkOrderNumber;
            ptextr.Task.PS_SRNumber_String = sa.Project__r.pse__Project_ID__c;
            ptextr.Task.PS_SANumber = sa.AppointmentNumber;
            ptextr.Task.PS_SRID = sa.Project__r.Id;
            ptextr.Task.PS_WorkOrderID = sa.Work_Order__r.Id;
            ptextr.Task.PS_OpenTextNodeID = sa.Project__r.OpenText_Node_ID__c;
            ptextr.Task.Customer = sa.Project__r.pse__Account__r.Name;
            ptextr.TaskRequestedProperties.addAll(new List<String>
            {
                    'CallID', 'Number', 'ExternalRefID', 'Status'
            });
            ptextr.AssignmentRequestedProperties.addAll(new List<String>
            {
                    'Task', 'Start', 'Finish', 'PS_EngineerID'
            });
            ptextr.ReturnSchedulingError = true;

            payloadString = JSON.serialize(ptextr, true);
        }

        HttpRequest request = constructRequest(settings.ProcessTaskEx_Endpoint_URL__c, payloadString, username, password);

        System.debug('Request: ' + request.getBody());

        HttpResponse response = new Http().send(request);

        System.debug(String.valueOf(response.getBody()));

        ProcessTaskExResponse deserializedResponse = ProcessTaskExResponse.parse(formatResponse(response.getBody()));

        System.debug('Response: ' + deserializedResponse);

        sa.Integration_Message__c = 'ReturnCode: ' + deserializedResponse.ReturnCode + ' SchedulingError: ' + deserializedResponse.SchedulingError;

        update sa;

        if (deserializedResponse.SchedulingError == null && response.getStatusCode() == 200)
        {
            sa.Status = deserializedResponse.Task.Status.DisplayString;

            if (deserializedResponse.Assignment != null)
            {
                sa.SchedStartTime = Datetime.valueOf(deserializedResponse.Assignment.Start.replace('T', ' '));
                sa.SchedEndTime = Datetime.valueOf(deserializedResponse.Assignment.Finish.replace('T', ' '));

                List<Contact> engineer =
                [
                        SELECT Id
                        FROM Contact
                        WHERE Badge_ID__c = :deserializedResponse.Assignment.PS_EngineerID
                        LIMIT 1
                ];

                if (!engineer.isEmpty())
                {
                    sa.Assignee__c = engineer[0].Id;
                    update sa;

                    Id assignmentId = createAssignment(sa.Id);
                    sa.Assignment__c = assignmentId;
                }
            }

            update sa;

            sendProjectAndOrdersToClick(sa.Work_Order__r.Project_Task__r.pse__Project__c);
        }

        return deserializedResponse.ReturnCode;
    }

    static String formatRequest(String payloadString)
    {
        String payloadString2 = payloadString.replace('objectType', '@objectType');
        String payloadString3 = payloadString2.replace('createOrUpdate', '@createOrUpdate');
        String payloadString4 = payloadString3.replace('Number_Z', 'Number');
        String payloadString5 = payloadString4.replace('InnerArray_Z', 'InnerArray');

        return payloadString5;
    }

    static String formatResponse(String responseString)
    {
        String responseString2 = responseString.replace('@DisplayString', 'DisplayString');
        String responseString3 = responseString2.replace('@objectType', 'objectType');

        return responseString3;
    }

    static HttpRequest constructRequest(String endpointURL, String payloadString, String username, String password)
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointURL);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
        request.setBodyAsBlob(Blob.valueOf(formatRequest(payloadString)));
        request.setMethod('POST');
        request.setTimeout(120000);

        return request;
    }

    static Integer convertDurationToSeconds(String type, Decimal duration)
    {
        if (type == 'Hours')
        {
            duration = Integer.valueOf(duration * 3600);
        }

        if (type == 'Minutes')
        {
            duration = Integer.valueOf(duration * 60);
        }

        return Integer.valueOf(duration);
    }

    static List<GetAppsPlanningTaskRequest.RequiredSkills1> getSkillsPlanningTask(Id workOrderId)
    {
        List<GetAppsPlanningTaskRequest.RequiredSkills1> skillsList = new List<GetAppsPlanningTaskRequest.RequiredSkills1>();

        List<Work_Order_Skill__c> workOrderSkills =
        [
                SELECT Skill_Certification__r.Name, Skill_Certification__r.pse__External_Id__c
                FROM Work_Order_Skill__c
                WHERE Work_Order__c = :workOrderId
        ];

        for (Work_Order_Skill__c skill : workOrderSkills)
        {
            GetAppsPlanningTaskRequest.RequiredSkills1 reqSkill = new GetAppsPlanningTaskRequest.RequiredSkills1();
            reqSkill.objectType = 'TaskRequiredSkill1';
            reqSkill.Key.Id = skill.Skill_Certification__r.pse__External_Id__c;
            reqSkill.SkillLevel = 1;

            skillsList.add(reqSkill);
        }

        return skillsList;
    }

    static List<GetAppsPreImpTaskRequest.RequiredSkills1> getSkillsPreImpTask(Id workOrderId)
    {
        List<GetAppsPreImpTaskRequest.RequiredSkills1> skillsList = new List<GetAppsPreImpTaskRequest.RequiredSkills1>();

        List<Work_Order_Skill__c> workOrderSkills =
        [
                SELECT Skill_Certification__r.Name, Skill_Certification__r.pse__External_Id__c
                FROM Work_Order_Skill__c
                WHERE Work_Order__c = :workOrderId
        ];

        for (Work_Order_Skill__c skill : workOrderSkills)
        {
            GetAppsPreImpTaskRequest.RequiredSkills1 reqSkill = new GetAppsPreImpTaskRequest.RequiredSkills1();
            reqSkill.objectType = 'TaskRequiredSkill1';
            reqSkill.Key.Id = skill.Skill_Certification__r.pse__External_Id__c;
            reqSkill.SkillLevel = 1;

            skillsList.add(reqSkill);
        }

        return skillsList;
    }

    static List<ProcessTaskExTechnicalRequest.RequiredSkills1> getSkillsTaskTechnical(Id workOrderId)
    {
        List<ProcessTaskExTechnicalRequest.RequiredSkills1> skillsList = new List<ProcessTaskExTechnicalRequest.RequiredSkills1>();

        List<Work_Order_Skill__c> workOrderSkills =
        [
                SELECT Skill_Certification__r.Name, Skill_Certification__r.pse__External_Id__c
                FROM Work_Order_Skill__c
                WHERE Work_Order__c = :workOrderId
        ];

        for (Work_Order_Skill__c skill : workOrderSkills)
        {
            ProcessTaskExTechnicalRequest.RequiredSkills1 reqSkill = new ProcessTaskExTechnicalRequest.RequiredSkills1();
            reqSkill.objectType = 'TaskRequiredSkill1';
            reqSkill.Key.Id = skill.Skill_Certification__r.pse__External_Id__c;
            reqSkill.SkillLevel = 1;

            skillsList.add(reqSkill);
        }

        return skillsList;
    }

    static List<ProcessTaskExSLARequest.RequiredSkills1> getSkillsTaskSLA(Id workOrderId)
    {
        List<ProcessTaskExSLARequest.RequiredSkills1> skillsList = new List<ProcessTaskExSLARequest.RequiredSkills1>();

        List<Work_Order_Skill__c> workOrderSkills =
        [
                SELECT Skill_Certification__r.Name, Skill_Certification__r.pse__External_Id__c
                FROM Work_Order_Skill__c
                WHERE Work_Order__c = :workOrderId
        ];

        for (Work_Order_Skill__c skill : workOrderSkills)
        {
            ProcessTaskExSLARequest.RequiredSkills1 reqSkill = new ProcessTaskExSLARequest.RequiredSkills1();
            reqSkill.objectType = 'TaskRequiredSkill1';
            reqSkill.Key.Id = skill.Skill_Certification__r.pse__External_Id__c;
            reqSkill.SkillLevel = 1;

            skillsList.add(reqSkill);
        }

        return skillsList;
    }

    static String formatDate(String dateString)
    {
        Datetime dt = Datetime.valueOf(dateString.replace('T', ' '));
        return dt.format('EEEE') + ', ' + dt.format('MMMMM') + ' ' + dt.day() + ' ' + dt.year() + ' ' + dt.format('h:mm a');
    }


    static void sendProjectAndOrdersToClick(Id projectId)
    {
        List<pse__Proj__c> project = [SELECT Send_To_Click__c FROM pse__Proj__c WHERE Id = :projectId LIMIT 1];
        List<Order> orders = [SELECT Send_To_Click__c FROM Order WHERE Project__c = :projectId];

        if (!project.isEmpty())
        {
            project[0].Send_To_Click__c = true;

            update project[0];
        }

        if (!orders.isEmpty())
        {
            for (Order o : orders)
            {
                o.Send_to_Click__c = true;
            }

            update orders;
        }
    }

    public static Id createAssignment(Id saId)
    {
        ServiceAppointment sa =
        [
                SELECT Project__r.pse__Start_Date__c, Project__r.pse__End_Date__c, Project__r.Id, Assignee__c,
                        Work_Order__r.Project_Task__r.Id
                FROM ServiceAppointment
                WHERE Id = :saId
        ];

        pse__Schedule__c schedule = new pse__Schedule__c();
        schedule.pse__Start_Date__c = sa.Project__r.pse__Start_Date__c;
        schedule.pse__End_Date__c = sa.Project__r.pse__End_Date__c;
        schedule.pse__Monday_Hours__c = 0.00;
        schedule.pse__Tuesday_Hours__c = 0.00;
        schedule.pse__Wednesday_Hours__c = 0.00;
        schedule.pse__Thursday_Hours__c = 0.00;
        schedule.pse__Friday_Hours__c = 0.00;
        schedule.pse__Saturday_Hours__c = 0.00;
        schedule.pse__Sunday_Hours__c = 0.00;
        insert schedule;

        pse__Assignment__c assignment = new pse__Assignment__c();
        assignment.pse__Schedule__c = schedule.Id;
        assignment.pse__Project__c = sa.Project__r.Id;
        assignment.pse__Resource__c = sa.Assignee__c;
        assignment.pse__Bill_Rate__c = 0.00;
        assignment.pse__Cost_Rate_Amount__c = 0.00;
        insert assignment;

        pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
        pta.pse__Project_Task__c = sa.Work_Order__r.Project_Task__r.Id;
        pta.pse__Resource__c = sa.Assignee__c;
        pta.pse__Assignment__c = assignment.Id;
        insert pta;

        return assignment.Id;
    }
}
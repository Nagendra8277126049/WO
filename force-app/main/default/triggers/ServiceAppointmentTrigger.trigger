/*
      Purpose:
            Trigger ServiceAppointmentHandler to populate the project lookup upon service appointment upon
            creation.
            
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
                                                Class : workOrderCloneController 
    ----------------------------------------------------------------------------
    =============================================================================================================
*/

trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, before update, after insert, after update) {
    // tdavis 2018-11-01 - added if statement
    if (Trigger.isBefore && Trigger.isInsert)
    {
        ServiceAppointmentHandler.populateProjectLookup(Trigger.new);
    }
    
    if(Trigger.isBefore && trigger.isUpdate)
    {
        ServiceAppointmentHandler.workOrderCloneController( Trigger.new, Trigger.OldMap);
    }

    // tdavis 2018-11-01 - added all code below
    Click_Integration_Settings__mdt settings =
    [
            SELECT Disable_ServiceAppointmentTrigger__c
            FROM Click_Integration_Settings__mdt
            LIMIT 1
    ];

    if (Trigger.isAfter && Trigger.isInsert && !settings.Disable_ServiceAppointmentTrigger__c)
    {
        ServiceAppointmentHandler.setNumberField(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate && !settings.Disable_ServiceAppointmentTrigger__c)
    {
        for (ServiceAppointment sa : Trigger.new)
        {
            if ((String) Trigger.oldMap.get(sa.Id).get('Status') != (String) Trigger.newMap.get(sa.Id).get('Status')
                    && sa.Status == 'Click_Cancelled')
            {
                ServiceAppointmentHandler.cancelClickTask(sa.Id);
            }
        }
    }
}
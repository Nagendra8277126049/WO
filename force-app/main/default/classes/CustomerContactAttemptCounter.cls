/*
      Purpose:
            Count the number of customer contact attempts per project and maintain in the project's
            Customer_Contact_Attempts__c field by intercepting new tasks of type email that are related
            to projects and firing off a counting cycle.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/12/18
*/

public with sharing class CustomerContactAttemptCounter {
    private static final String PROJECT_KEY_PREFIX = pse__Proj__c.SObjectType.getDescribe().getKeyPrefix();
    private static final List<Customer_Contact_Attempt_Subject_Phrase__mdt> SUBJECT_PHRASES = [SELECT Phrase__c FROM Customer_Contact_Attempt_Subject_Phrase__mdt LIMIT 100];

    public static Set<Id> extractProjectIdsFromEmailTasks(List<Task> tasksToFilter) {
        Set<Id> result = new Set<Id>();
        for (Task candidateTask : tasksToFilter) {
            if (candidateTask.TaskSubtype =='Email' && candidateTask.WhatId != null) {
                String strWhatId = candidateTask.WhatId;
                if (strWhatId.startsWith(PROJECT_KEY_PREFIX)) {
                    result.add(candidateTask.WhatId);
                }
            }
        }
        return result;
    }
    public static Map<Id,List<EmailMessage>> obtainContactEmails(Set<Id> projectIds) {
        Map<Id,List<EmailMessage>> result = new Map<Id,List<EmailMessage>>();
        List<EmailMessage> messages = [SELECT Id,Subject,RelatedToId FROM EmailMessage WHERE RelatedToId IN :projectIds];
        for (EmailMessage message : messages) {
            List<EmailMessage> projMessages;
            if (result.containsKey(message.RelatedToId)) {
                projMessages = result.get(message.RelatedToId);
            }
            else {
                projMessages = new List<EmailMessage>();
            }
            
            if(message.Subject == null)
                continue;
            
            String lowerCaseSubject = message.Subject.toLowerCase();
            Boolean isCustomerContactMessage = false;
            for (Customer_Contact_Attempt_Subject_Phrase__mdt phrase: SUBJECT_PHRASES) {
                if (lowerCaseSubject.contains(phrase.Phrase__c.toLowerCase())) {
                    isCustomerContactMessage = true;
                    break;
                }
            }
            if (isCustomerContactMessage) {
                projMessages.add(message);
                result.put(message.RelatedToId,projMessages);
            }
        }
        return result;
    }
    public static void updateProjects(Map<Id,List<EmailMessage>> projectMessageMap) {
        Map<Id,pse__Proj__c> projectMap = new Map<Id,pse__Proj__c>([SELECT Customer_Contact_Attempts__c FROM pse__Proj__c WHERE Id IN :projectMessageMap.keySet()]);
        List<pse__Proj__c> projectsToUpdate = new List<pse__Proj__c>();
        for (Id projectId:projectMessageMap.keySet()) {
            Integer messageCount = projectMessageMap.get(projectId).size();
            pse__Proj__c project = projectMap.get(projectId);
            if (project != null && messageCount != project.Customer_Contact_Attempts__c) {
                project.Customer_Contact_Attempts__c = messageCount;
                projectsToUpdate.add(project);
            }
        }
        if (!projectsToUpdate.isEmpty()) {
            update projectsToUpdate;
        }
    }
    @Future
    public static void handleTriggerTasks(Set<Id> taskIds) {
        List<Task> tasks = [
                SELECT
                        AccountId,
                        Activity_Age__c,
                        ActivityDate,
                        Assigned_to_me__c,
                        AssignedToLogin__c,
                        CallDisposition,
                        CallDurationInSeconds,
                        CallObject,
                        CallType,
                        Can_Override_DeltaActivity__c,
                        Completion_Status__c,
                        Created_by_Me__c,
                        Created_Date_Time__c,
                        CreatedById,
                        CreatedDate,
                        CurrencyIsoCode,
                        Delta_SR__c,
                        Description,
                        EmailTaskOutboundUpdate__c,
                        Event_Closed__c,
                        Id,
                        IsArchived,
                        IsClosed,
                        IsDeleted,
                        IsDeltaActivity__c,
                        IsHighPriority,
                        IsRecurrence,
                        IsReminderSet,
                        LastModifiedById,
                        LastModifiedDate,
                        Overdue__c,
                        OwnerId,
                        Priority,
                        Public__c,
                        RecordTypeId,
                        RecurrenceActivityId,
                        RecurrenceDayOfMonth,
                        RecurrenceDayOfWeekMask,
                        RecurrenceEndDateOnly,
                        RecurrenceInstance,
                        RecurrenceInterval,
                        RecurrenceMonthOfYear,
                        RecurrenceRegeneratedType,
                        RecurrenceStartDateOnly,
                        RecurrenceTimeZoneSidKey,
                        RecurrenceType,
                        ReminderDateTime,
                        Status,
                        Status__c,
                        Subject,
                        SystemModstamp,
                        TaskSubtype,
                        Type,
                        WhatCount,
                        WhatId,
                        WhoCount,
                        WhoId
                FROM Task
                WHERE Id IN :taskIds];
        updateProjects(obtainContactEmails(extractProjectIdsFromEmailTasks(tasks)));
    }
}
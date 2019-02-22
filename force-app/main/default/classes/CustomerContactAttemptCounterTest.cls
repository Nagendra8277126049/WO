/*
      Purpose:
            Test CustomerContactAttemptCounter
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/12/18
*/

@IsTest
private class CustomerContactAttemptCounterTest {
    @IsTest
    static void projectIdForEmailTaskOnProjectShouldBeExtracted() {
        // GIVEN
        // A project
        pse__Proj__c testProject = new pse__Proj__c(pse__Is_Active__c=true);
        insert testProject;
        // A budget
        pse__Budget__c testBudget = new pse__Budget__c(pse__Project__c=testProject.Id);
        insert testBudget;
        // An email task on the budget
        List<Task> testTasks = new List<Task>();
        testTasks.add(createEmailTaskOnSobject(testBudget));
        // An email task on the project
        testTasks.add(createEmailTaskOnSobject(testProject));
        // An email task that is not associated with any SObject
        testTasks.add(createEmailTaskOnSobject(null));
        insert testTasks;
        // WHEN
        // When I extract the project Ids for email project tasks
        Set<Id> projectIds = CustomerContactAttemptCounter.extractProjectIdsFromEmailTasks(testTasks);
        // THEN
        // The Id for the second task above should be included in the project Id set
        System.assertEquals(new Set<Id>{ testProject.Id },projectIds);
    }
    @IsTest
    static void queryShouldObtainContactAttemptEmailMessagesRelatedToProjects() {
        // GIVEN
        // A project
        pse__Proj__c testProject = new pse__Proj__c(pse__Is_Active__c=true);
        insert testProject;
        // Three email messages on the project where only two look like contact attempts
        List<EmailMessage> testEmailMessages = new List<EmailMessage>();
        testEmailMessages.add(createEmailMessage(testProject,'Contact Attempted'));
        testEmailMessages.add(createEmailMessage(testProject,'Nigerian Prince wants to send you money'));
        testEmailMessages.add(createEmailMessage(testProject,'Welcome'));
        insert testEmailMessages;
        // WHEN
        // I obtain the customer contact attempt emails for the project
        Map<Id,List<EmailMessage>> messageMap = CustomerContactAttemptCounter.obtainContactEmails(new Set<Id>{ testProject.Id });
        // THEN
        // Two are returned
        List<EmailMessage> projMessages = messageMap.get(testProject.Id);
        System.assertNotEquals(null, projMessages);
        System.assertEquals(2,projMessages.size());
    }
    @IsTest
    static void projectsInContactAttemptEmailMapShouldReceiveUpdatedCounts() {
        // GIVEN
        // A project
        pse__Proj__c testProject = new pse__Proj__c(pse__Is_Active__c=true);
        insert testProject;
        // Two email messages on the project that look like contact attempts
        List<EmailMessage> testEmailMessages = new List<EmailMessage>();
        testEmailMessages.add(createEmailMessage(testProject,'Contact Attempted'));
        testEmailMessages.add(createEmailMessage(testProject,'Welcome'));
        insert testEmailMessages;
        // AND
        // I obtain the customer contact attempt emails for the project in a map
        Map<Id,List<EmailMessage>> messageMap = CustomerContactAttemptCounter.obtainContactEmails(new Set<Id>{ testProject.Id });
        // WHEN
        // I apply the updates to the projects
        CustomerContactAttemptCounter.updateProjects(messageMap);
        // THEN
        // The project customer contact attempt counter has been updated to two
        testProject = [SELECT Customer_Contact_Attempts__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        System.assertEquals(2,testProject.Customer_Contact_Attempts__c);
    }
    @IsTest
    static void makeSureTheTriggerGetsCoverage() {
        pse__Proj__c testProject = new pse__Proj__c(pse__Is_Active__c=true);
        insert testProject;
        // An email task on the budget
        List<Task> testTasks = new List<Task>();
        testTasks.add(createEmailTaskOnSobject(testProject));
        Test.startTest();
        insert testTasks;
        Test.stopTest();
    }

    private static EmailMessage createEmailMessage(pse__Proj__c testProject, String subject) {
        return new EmailMessage(ToAddress = 'x@y.com', RelatedToId = testProject.Id, Subject = subject, Incoming=false);
    }

    private static Task createEmailTaskOnSobject(SObject sobj) {
        return new Task(TaskSubtype='Email',WhatId=sobj != null ? sobj.Id : null);
    }

}
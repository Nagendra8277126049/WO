/*
      Purpose:
            Detect changes in ContentDocument records in order to intercept changes in ContentNotes
            related to Project Tasks in PSA, and roll up them up to the related task(s).
            
      Initiative: North Star PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    5/29/18
*/

trigger ContentDocumentTrigger on ContentDocument (after insert, after update, after delete, after undelete) {
    ContentDocumentHandler.rollUpContentNotesToProjectTasks(Trigger.isDelete ? Trigger.old : Trigger.new);
}
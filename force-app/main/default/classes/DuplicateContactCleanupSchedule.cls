global with sharing class DuplicateContactCleanupSchedule implements Schedulable{
    
    
    global void execute(SchedulableContext ctx) {
        ExistingContactDuplicateCleanup duplicateContacts = new ExistingContactDuplicateCleanup('SELECT Id FROM DuplicateRecordSet where recordcount > 1');
        //Batch size is 200, records will be split into batches 
        Database.ExecuteBatch(duplicateContacts,45);
    } 
}
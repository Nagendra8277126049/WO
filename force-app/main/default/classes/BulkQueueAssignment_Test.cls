@isTest
private class BulkQueueAssignment_Test { 
    
     @isTest
     static void Addusers(){

        BulkQueueAssignment__c testbulkAdd = new BulkQueueAssignment__c(
            Name = 'uniquebulkName1',        
            Action__c = 'Add',
            Badge__c = '11449231',
            QueueName__c = 'AMER.TS.CLI.CHAT.EN.OOP.US.COMM'
            );
        insert testbulkAdd;    
Id bulkIDAdd = [Select id from BulkQueueAssignment__c where name = 'uniquebulkName1'].Id;
        
         list <id>  mylist1 = new list <id>();
       mylist1.add(bulkIDAdd); 
       
    BulkQueueAssignment.AddBulkUsers(mylist1);
        
     }


@isTest
     static void Removeusers(){
         
BulkQueueAssignment__c testbulkRemove = new BulkQueueAssignment__c(
            Name = 'uniquebulkName2',        
            Action__c = 'Remove',
            Badge__c = '1190034',
            QueueName__c = 'AMER.TS.CLI.CHAT.EN.OOP.US.COMM'
            );
        insert testbulkRemove;
         Id bulkIDRemove = [Select id from BulkQueueAssignment__c where name = 'uniquebulkName2'].Id;
         list <id>  mylist2 = new list <id>();
         mylist2.add(bulkIDRemove); 
Test.startTest();

BulkQueueAssignment.DeleteFutureCall(mylist2);

Test.stopTest();
         
         
     }
    }